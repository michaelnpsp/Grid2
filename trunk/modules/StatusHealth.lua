--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local HealthCurrent = Grid2.statusPrototype:new("health-current", false)
local HealthLow = Grid2.statusPrototype:new("health-low",false)
local FeignDeath = Grid2.statusPrototype:new("feign-death", false)
local HealthDeficit = Grid2.statusPrototype:new("health-deficit", false)
local Death = Grid2.statusPrototype:new("death", false)
local Heals = Grid2.statusPrototype:new("heals-incoming", false)

local Grid2 = Grid2
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitGetIncomingHeals = UnitGetIncomingHeals
local fmt = string.format
local select = select
local next = next

-- Health statuses update function
local statuses = {} 

local function UpdateIndicators(unit)
	for status in next, statuses do
		status:UpdateIndicators(unit)
	end
end

-- Events management
local RegisterEvent, UnregisterEvent
do
	local frame
	local Events = {}
	function RegisterEvent(event, func)
		if not frame then
			frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			frame:SetScript( "OnEvent",  function(_, event, ...) Events[event](...) end )
		end
		if not Events[event] then frame:RegisterEvent(event) end	
		Events[event] = func
	end	
	function UnregisterEvent(...)
		if frame then 
			for i=select("#",...),1,-1 do
				local event = select(i,...)
				if Events[event] then
					frame:UnregisterEvent( event )
					Events[event] = nil
				end	
			end
		end
	end	
end

-- Quick/Instant Health management
local EnableQuickHealth, DisableQuickHealth
do
	local UnitHealthOriginal = UnitHealth
	local min = math.min
	local max = math.max
	local strlen = strlen
	local health_cache = {}
	local HealthEvents = { SPELL_DAMAGE = -15, RANGE_DAMAGE = -15, SPELL_PERIODIC_DAMAGE = -15, 
						   DAMAGE_SHIELD = -15, DAMAGE_SPLIT = -15, ENVIRONMENTAL_DAMAGE = -13, 
						   SWING_DAMAGE = -12, SPELL_PERIODIC_HEAL = 15, SPELL_HEAL = 15 }
	local function UnitQuickHealth(unit)
		return health_cache[unit] or UnitHealthOriginal(unit)
	end
	local function RosterUpdateEvent()
		wipe(health_cache)
	end
	local function HealthChangedEvent(unit)
		if strlen(unit)<8 then  -- Ignore Pets
			local h = UnitHealthOriginal(unit)  	
			local c = health_cache[unit]			
			if h==c then return end	
			health_cache[unit] = h
		end	
		UpdateIndicators(unit)
	end 
	local function CombatLogEvent(...)
		local sign = HealthEvents[select(2,...)] 
		if sign then
			local unit = Grid2:GetUnitidByGUID( select(8,...) )
			if unit and strlen(unit)<8 then  
				local health
				if sign>0 then
					health = min( UnitQuickHealth(unit) + select(sign,...), UnitHealthMax(unit) )
				elseif sign<0 then
					health = max( UnitQuickHealth(unit) - select(-sign,...), 0 )
				end	
				if health~=health_cache[unit] then
					health_cache[unit] = health
					UpdateIndicators(unit)
				end
			end	
		end	
	end
	function EnableQuickHealth()
		if HealthCurrent.dbx.quickHealth then
			RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
			RegisterEvent("RAID_ROSTER_UPDATE"  , RosterUpdateEvent)
			RegisterEvent("PARTY_MEMBER_CHANGED", RosterUpdateEvent)
			RegisterEvent("UNIT_HEALTH_FREQUENT", HealthChangedEvent)
			RegisterEvent("UNIT_MAXHEALTH"      , HealthChangedEvent)
			UnitHealth = UnitQuickHealth
		end	
	end
	function DisableQuickHealth()
		UnitHealth = UnitHealthOriginal
		UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "RAID_ROSTER_UPDATE", "PARTY_MEMBER_CHANGED", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH")
	end
end

-- Functions shared by several Health statuses
local function Health_RegisterEvents()
	RegisterEvent("UNIT_HEALTH_FREQUENT", UpdateIndicators )
	RegisterEvent("UNIT_MAXHEALTH", UpdateIndicators )
	EnableQuickHealth()
end

local function Health_UnregisterEvents()
	UnregisterEvent( "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH" )
	DisableQuickHealth() 
end

local function Health_UpdateStatuses()
	if next(statuses) then
		local new = (HealthCurrent.dbx.quickHealth or false)
		local cur = (UnitHealth == UnitQuickHealth)
		if new~=cur then
			Health_UnregisterEvents()
			Health_RegisterEvents()
		end	
	end	
end

local function Health_Enable(status)
	if not next(statuses) then Health_RegisterEvents() end
	statuses[status] = true
end	

local function Health_Disable(status)
	statuses[status] = nil
	if not next(statuses) then Health_UnregisterEvents() end	
end

local function Health_GetColor(self, unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

-- health-current status
HealthCurrent.OnEnable  = Health_Enable
HealthCurrent.OnDisable = Health_Disable

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
	Health_UpdateStatuses()
end

local function CreateHealthCurrent(baseKey, dbx)
	Grid2:RegisterStatus(HealthCurrent, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(HealthCurrent)
	HealthCurrent:UpdateDB()
	return HealthCurrent
end

Grid2.setupFunc["health-current"] = CreateHealthCurrent

-- health-low status
HealthLow.OnEnable  = Health_Enable
HealthLow.OnDisable = Health_Disable
HealthLow.GetColor  = Health_GetColor

function HealthLow:IsActive(unit)
	return HealthCurrent:GetPercent(unit) < self.dbx.threshold
end

local function CreateHealthLow(baseKey, dbx)
	Grid2:RegisterStatus(HealthLow, {"color"}, baseKey, dbx)

	return HealthLow
end

Grid2.setupFunc["health-low"] = CreateHealthLow

-- feign-death status
FeignDeath.OnEnable  = Health_Enable
FeignDeath.OnDisable = Health_Disable
FeignDeath.GetColor  = Health_GetColor

function FeignDeath:IsActive(unit)
	return UnitIsFeignDeath(unit)
end

function FeignDeath:GetPercent(unit)
	return self.dbx.color1.a 
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
HealthDeficit.OnEnable  = Health_Enable
HealthDeficit.OnDisable = Health_Disable
HealthDeficit.GetColor  = Health_GetColor

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

-- death status
local dead_cache= {}

Death.GetColor= Health_GetColor

local function DeathUpdateEvent(unit)
	if UnitIsDeadOrGhost(unit) then
		local dead = UnitIsGhost(unit) and 2 or 1
		if dead ~= dead_cache[unit] then
			dead_cache[unit] = dead
			Death:UpdateIndicators(unit)
			if HealthCurrent.enabled and HealthCurrent.deadAsFullHealth then
				HealthCurrent:UpdateIndicators(unit)
			end
		end	
	elseif dead_cache[unit] then
		dead_cache[unit] = nil
		Death:UpdateIndicators(unit)
	end
end

function Death:OnEnable()
	RegisterEvent( "UNIT_HEALTH", DeathUpdateEvent )
end

function Death:OnDisable()
	UnregisterEvent( "UNIT_HEALTH" )
end

function Death:IsActive(unit)
	if UnitIsDeadOrGhost(unit) then 
		return true 
	end
end

function Death:GetIcon()
	return [[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
end

function Death:GetPercent(unit)
	return self.dbx.color1.a 
end

function Death:GetText(unit)
	if UnitIsGhost(unit) then
		return L["GHOST"]
	else
		return L["DEAD"]
	end
end

local function CreateDeath(baseKey, dbx)
	Grid2:RegisterStatus(Death, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Death
end

Grid2.setupFunc["death"] = CreateDeath

-- heals-incoming status
local heals_cache= {}

Heals.GetColor= Health_GetColor

local function Heals_get_with_user(unit)
	return UnitGetIncomingHeals(unit) or 0
end
local function Heals_get_without_user(unit)
	return (UnitGetIncomingHeals(unit) or 0)  - (UnitGetIncomingHeals(unit, "player") or 0)
end
local Heals_GetHealAmount = Heals_get_without_user

local function HealsUpdateEvent(unit)
	if unit then
		local cache= heals_cache[unit] or 0
		local heal = Heals_GetHealAmount(unit)
		if heal<Heals.minimum then heal = 0 end
		if cache ~= heal then
			heals_cache[unit] = heal
			Heals:UpdateIndicators(unit)
		end
	end
end

function Heals:UpdateDB()
	local m= self.dbx.flags
	self.minimum= (m and m>1 and m ) or 1
	Heals_GetHealAmount = self.dbx.includePlayerHeals and Heals_get_with_user or Heals_get_without_user
end

function Heals:OnEnable()
	Health_Enable(self)
	RegisterEvent("UNIT_HEAL_PREDICTION", HealsUpdateEvent)
	self:UpdateDB()
end

function Heals:OnDisable()
	wipe(heals_cache)
	UnregisterEvent("UNIT_HEAL_PREDICTION")
	Health_Disable(self)
end

function Heals:IsActive(unit)
	return (heals_cache[unit] or 0) > 1
end

function Heals:GetText(unit)
	return fmt("+%.1fk", heals_cache[unit] / 1000)
end

function Heals:GetPercent(unit)
	return (heals_cache[unit] + UnitHealth(unit)) / UnitHealthMax(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "text", "percent"}, baseKey, dbx)

	return Heals
end

Grid2.setupFunc["heals-incoming"] = Create
