--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local HealthCurrent = Grid2.statusPrototype:new("health-current", false)
local HealthLow = Grid2.statusPrototype:new("health-low",false)
local Death = Grid2.statusPrototype:new("death", false)
local FeignDeath = Grid2.statusPrototype:new("feign-death", false)
local HealthDeficit = Grid2.statusPrototype:new("health-deficit", false)
local Heals = Grid2.statusPrototype:new("heals-incoming", true)

local Grid2 = Grid2
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitGetIncomingHeals = UnitGetIncomingHeals
local fmt = string.format
local next = next
local strlen = strlen

local statuses= {} -- Enabled statuses

-- Health Events
local function HealthChangedEvent(_, _, unit)
	for status in next, statuses do
		status:UpdateIndicators(unit)
	end
end

-- Quick Health events management
local RegisterEventsQH
do
	local min = math.min
	local max = math.max
	local select = select
	local GetTime = GetTime
	local UnitHealthOriginal = UnitHealth
	local UnitIsDeadOrGhostOriginal = UnitIsDeadOrGhost
	local dead_cache  = {}
	local time_cache   = {}
	local health_cache = {}
	local HealthEvents = { SPELL_DAMAGE = -15, RANGE_DAMAGE = -15, SPELL_PERIODIC_DAMAGE = -15, 
						   DAMAGE_SHIELD = -15, DAMAGE_SPLIT = -15, ENVIRONMENTAL_DAMAGE = -13, SWING_DAMAGE = -12,	
	                       SPELL_PERIODIC_HEAL = 15, SPELL_HEAL = 15,  
						   UNIT_DIED = 0 }
	local function UnitHealthQH(unit)
		return health_cache[unit] or UnitHealthOriginal(unit)
	end
	local function UnitIsDeadOrGhostQH(unit)
		return dead_cache[unit] or UnitIsDeadOrGhostOriginal(unit) 
	end
	local function RosterUpdateEventQH()
		wipe(health_cache)
		wipe(time_cache)
		wipe(dead_cache)
	end
	local function HealthChangedEventQH(unit)  	-- UNIT_HEALTH_FREQUENT event
		if strlen(unit)<8 then  -- Ignore Pets
			local h = UnitHealthOriginal(unit)  	-- Health provided by wow api UnitHealth() 
			local c = health_cache[unit]			-- Health calculated parsing the combat_log
			local m = dead_cache[unit]
			if m then -- Unit is dead acording to combatlog, check if unit has been resurrected (no combatlog event exists to detect resurrections)
				if h>1 then  -- When unit is dead some times UnitHealth() returns 1 instead of 0
					dead_cache[unit] = nil
				end
			elseif c then  -- Health was already updated by combatlogevent, check if this event can be ignored (return without updating health)
				local d = h - c
				if d==0 then  -- No diff between healths, no update needed
					time_cache[unit] = nil  -- Reset differ timestamp
					return 
				elseif d>0 then -- If healths differ use the lowest health value for safety
					local ct = GetTime() 		 
					local tc = time_cache[unit]
					if tc then
						if ct-tc<1 then	-- But we only trust combatlog healths for some time (1 second period)
							return
						end
					else 
						time_cache[unit] = ct  -- Save first time healths were different
						return
					end
				end
			end	
			-- We trust UnitHealth() value instead of combat_log_health prediction, this happens when
			-- health_cache value does not exists or health_cache and UnitHealth() are different for a long time (1 second period)
			time_cache[unit] = nil
			health_cache[unit] = h
		end	
		HealthChangedEvent(_, _, unit)
	end
	local function CombatLogEventQH(...)
		local sign = HealthEvents[select(2,...)] 
		if sign then
			local unit = Grid2:GetUnitidByGUID( select(8,...) )
			if unit and strlen(unit)<8 then  -- A little hack:  strlen(unit)<8 means is not a pet
				local health
				if sign>0 then
					health = min( UnitHealthQH(unit) + select(sign,...), UnitHealthMax(unit) )
				elseif sign<0 then
					health = max( UnitHealthQH(unit) - select(-sign,...), 0 )
				else -- Unit Died
					health = 0 
					dead_cache[unit] = true
				end	
				if health~=health_cache[unit] or sign==0 then
					health_cache[unit] = health
					HealthChangedEvent(_,_,unit)
				end
			end	
		end	
	end
	local EventsQH= {	
		COMBAT_LOG_EVENT_UNFILTERED = CombatLogEventQH,
		RAID_ROSTER_UPDATE          = RosterUpdateEventQH,
		PARTY_MEMBER_CHANGED        = RosterUpdateEventQH,
		UNIT_HEALTH                 = HealthChangedEventQH,
		UNIT_HEALTH_FREQUENT        = HealthChangedEventQH,
		UNIT_MAXHEALTH              = HealthChangedEventQH,
	}
	function RegisterEventsQH(frame)
		if HealthCurrent.quickHealth then
			frame:SetScript("OnEvent",  function(_, event, ...) EventsQH[event](...) end )
			frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			frame:RegisterEvent("RAID_ROSTER_UPDATE")
			frame:RegisterEvent("PARTY_MEMBER_CHANGED")
			UnitHealth = UnitHealthQH
			UnitIsDeadOrGhost = UnitIsDeadOrGhostQH
		else
			UnitHealth = UnitHealthOriginal
			UnitIsDeadOrGhost = UnitIsDeadOrGhostOriginal
		end
	end
end

-- Normal Health events management
local EnableHealthFrame, HealthFrameEnabled, UpdateHealthFrequency
do
	local frame
	local count = 0
	local function UnregisterEvents()
		frame:SetScript("OnEvent", nil)
		frame:UnregisterAllEvents()
	end
	local function RegisterEvents()
		frame:SetScript("OnEvent", HealthChangedEvent)
		frame:RegisterEvent("UNIT_MAXHEALTH")
		frame:RegisterEvent( HealthCurrent.frequentUpdates and "UNIT_HEALTH_FREQUENT" or "UNIT_HEALTH" )
		RegisterEventsQH(frame) 
	end
	function EnableHealthFrame(enable)
		local prev = (count == 0)
		count = count + (enable and 1 or -1)
		assert(count >= 0)
		local curr = (count == 0)
		if prev ~= curr then
			if not frame then
				frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			end
			if curr then 
				UnregisterEvents()
			else
				RegisterEvents()
			end
		end
	end
	function HealthFrameEnabled()
		return count>0
	end
	function UpdateHealthFrequency()
		UnregisterEvents()
		RegisterEvents()
	end
end

-- health status

function HealthCurrent:OnEnable()
	self:UpdateDB()
	EnableHealthFrame(true)
	statuses[self]= true
end

function HealthCurrent:OnDisable()
	EnableHealthFrame(false)
	statuses[self]= nil
end

function HealthCurrent:IsActive(unit)
	return true
end

function HealthCurrent:GetPercent(unit)
	if (self.deadAsFullHealth and UnitIsDeadOrGhost(unit)) then
		return 1
	end
	return UnitHealth(unit) / UnitHealthMax(unit)
end

function HealthCurrent:GetTextDefault(unit)
	return fmt("%.1fk", UnitHealth(unit) / 1000)
end

function HealthCurrent:GetColor(unit)
	local f,t
	local p= self:GetPercent(unit)
	if p>=0.5 then
		f,t,p = self.color2, self.color1, (p-0.5)*2
	else
		f,t,p = self.color3, self.color2, p*2
	end
	return (t.r-f.r)*p+f.r , (t.g-f.g)*p+f.g , (t.b-f.b)*p+f.b, (t.a-f.a)*p+f.a
end

function HealthCurrent:UpdateDB()
	self.deadAsFullHealth = self.dbx.deadAsFullHealth
	self.color1 = Grid2:MakeColor(self.dbx.color1)
	self.color2 = Grid2:MakeColor(self.dbx.color2)
	self.color3 = Grid2:MakeColor(self.dbx.color3)
	self.quickHealth = self.dbx.quickHealth
	self.frequentUpdates = self.dbx.frequentUpdates or self.quickHealth
	if HealthFrameEnabled() then UpdateHealthFrequency() end
end

local function CreateHealthCurrent(baseKey, dbx)
	Grid2:RegisterStatus(HealthCurrent, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(HealthCurrent)

	return HealthCurrent
end

Grid2.setupFunc["health-current"] = CreateHealthCurrent

-- health-low status

function HealthLow:OnEnable()
	EnableHealthFrame(true)
	statuses[self]= true
end

function HealthLow:OnDisable()
	EnableHealthFrame(false)
	statuses[self]= nil
end

function HealthLow:IsActive(unit)
	return HealthCurrent:GetPercent(unit) < self.dbx.threshold
end

function HealthLow:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local function CreateHealthLow(baseKey, dbx)
	Grid2:RegisterStatus(HealthLow, {"color"}, baseKey, dbx)

	return HealthLow
end

Grid2.setupFunc["health-low"] = CreateHealthLow

-- death status

function Death:OnEnable()
	EnableHealthFrame(true)
	statuses[self]= true
end

function Death:OnDisable()
	EnableHealthFrame(false)
	statuses[self]= nil
end

function Death:IsActive(unitid)
	return UnitIsDeadOrGhost(unitid)
end

function Death:GetColor(unitid)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Death:GetIcon(unitid)
	return [[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
end

function Death:GetPercent(unitid)
	local color = self.dbx.color1
	return UnitIsDeadOrGhost(unitid) and color.a or 1
end

function Death:GetText(unitid)
	if (UnitIsDead(unitid)) then
		return L["DEAD"]
	elseif UnitIsGhost(unitid) then
		return L["GHOST"]
	end
end

local function CreateDeath(baseKey, dbx)
	Grid2:RegisterStatus(Death, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Death
end

Grid2.setupFunc["death"] = CreateDeath

-- feign-death status

function FeignDeath:OnEnable()
	EnableHealthFrame(true)
	statuses[self]= true
end

function FeignDeath:OnDisable()
	EnableHealthFrame(false)
	statuses[self]= nil
end

function FeignDeath:IsActive(unit)
	return UnitIsFeignDeath(unit)
end

function FeignDeath:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function FeignDeath:GetPercent(unit)
	local color = self.dbx.color1
	return UnitIsFeignDeath(unit) and color.a or 1
end

function FeignDeath:GetText(unit)
	if UnitIsFeignDeath(unit) then
		return L["FD"]
	end
end

local function CreateFeignDeath(baseKey, dbx)
	Grid2:RegisterStatus(FeignDeath, {"color", "percent", "text"}, baseKey, dbx)

	return FeignDeath
end

Grid2.setupFunc["feign-death"] = CreateFeignDeath

-- health-deficit status

function HealthDeficit:OnEnable()
	EnableHealthFrame(true)
	statuses[self]= true
end

function HealthDeficit:OnDisable()
	EnableHealthFrame(false)
	statuses[self]= nil
end

function HealthDeficit:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function HealthDeficit:IsActive(unit)
	return (1 - HealthCurrent:GetPercent(unit)) > self.dbx.threshold
end

function HealthDeficit:GetText(unit)
	return fmt("%.1fk", (UnitHealth(unit) - UnitHealthMax(unit)) / 1000)
end

local function CreateHealthDeficit(baseKey, dbx)
	Grid2:RegisterStatus(HealthDeficit, {"color", "text"}, baseKey, dbx)

	return HealthDeficit
end

Grid2.setupFunc["health-deficit"] = CreateHealthDeficit

-- heals-incoming status

local HealsCache= {}

local function Heals_get_with_user(unit)
	return UnitGetIncomingHeals(unit) or 0
end
local function Heals_get_without_user(unit)
	return (UnitGetIncomingHeals(unit) or 0)  - (UnitGetIncomingHeals(unit, "player") or 0)
end
local Heals_GetHealAmount = Heals_get_without_user

function Heals:UpdateDB()
	local m= self.dbx.flags
	self.minimum= (m and m>1 and m ) or 1
	Heals_GetHealAmount = self.dbx.includePlayerHeals
		and Heals_get_with_user
		or  Heals_get_without_user
end

function Heals:OnEnable()
	self:RegisterEvent("UNIT_HEAL_PREDICTION", "Update")
	self:UpdateDB()
	statuses[self]= true
end

function Heals:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_PREDICTION")
	wipe(HealsCache)
	statuses[self]= nil
end

function Heals:Update(event, unit)
	if unit then
		local cache= HealsCache[unit] or 0
		local heal = Heals_GetHealAmount(unit)
		if heal<self.minimum then heal = 0 end
		if cache ~= heal then
			HealsCache[unit] = heal
			self:UpdateIndicators(unit)
		end
	end
end

function Heals:IsActive(unit)
	return (HealsCache[unit] or 0) > 1
end

function Heals:GetColor(unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function Heals:GetText(unit)
	return fmt("+%.1fk", HealsCache[unit] / 1000)
end

function Heals:GetPercent(unit)
	return (HealsCache[unit] + UnitHealth(unit)) / UnitHealthMax(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "text", "percent"}, baseKey, dbx)

	return Heals
end

Grid2.setupFunc["heals-incoming"] = Create
