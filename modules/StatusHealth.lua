--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local HealthCurrent = Grid2.statusPrototype:new("health-current", false)
local HealthLow = Grid2.statusPrototype:new("health-low",false)
local FeignDeath = Grid2.statusPrototype:new("feign-death", false)
local HealthDeficit = Grid2.statusPrototype:new("health-deficit", false)
local Heals = Grid2.statusPrototype:new("heals-incoming", false)
local MyHeals = Grid2.statusPrototype:new("my-heals-incoming", false)
local OverHeals = Grid2.statusPrototype:new("overhealing", false)
local Death = Grid2.statusPrototype:new("death", true)

local Grid2 = Grid2
local next = next
local tostring = tostring
local fmt = string.format
local select = select
local GetTime = GetTime
local UnitHealth = UnitHealth
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitHealthMax = UnitHealthMax
local C_Timer_After = C_Timer.After
local unit_is_valid = Grid2.unit_is_valid

-- Caches
local heals_enabled = false
local heals_required = 0
local heals_minimum = 1
local heals_multiplier = 1
local heals_bitflag
local heals_timeband
local heals_cache = setmetatable( {}, {__index = function() return 0 end} )

local myheals_enabled = false
local myheal_required = 0
local myheals_minimum = 1
local myheals_multiplier = 1
local myheals_bitflag
local myheals_timeband
local myheals_cache = setmetatable( {}, {__index = function() return 0 end} )

local overheals_enabled = false
local overheals_minimum = 1

local healthdeficit_enabled = false

-- Health statuses update function
local statuses = {}

local function UpdateIndicators(unit)
	if unit_is_valid[unit] then
		for status in next, statuses do
			status:UpdateIndicators(unit)
		end
		if overheals_enabled then
			OverHeals:UpdateIndicators(unit)
		end
	end
end

-- Events management
local RegisterEvent, UnregisterEvent
do
	local isWoW90 = Grid2.isWoW90
	local frame
	local Events = {}
	function RegisterEvent(event, func)
		if isWoW90 and event == 'UNIT_HEALTH_FREQUENT' then return end
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
	local roster_units = Grid2.roster_units
	local UnitHealthOriginal = UnitHealth
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
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
		if unit then
			local h = UnitHealthOriginal(unit)
			if h==health_cache[unit] then return end
			health_cache[unit] = h
			UpdateIndicators(unit)
		end
	end
	local function CombatLogEventReal(...)
		local sign = HealthEvents[select(2,...)]
		if sign then
			local unit = roster_units[select(8,...)]
			if unit and strlen(unit)<8 then
				local health
				if sign>0 then
					health = min( (health_cache[unit] or UnitHealthOriginal(unit)) + select(sign,...), UnitHealthMax(unit) )
				elseif sign<0 then
					health = max( (health_cache[unit] or UnitHealthOriginal(unit)) - select(-sign,...), 0 )
				end
				if health~=health_cache[unit] then
					health_cache[unit] = health
					UpdateIndicators(unit)
				end
			end
		end
	end
	local function CombatLogEvent()
		CombatLogEventReal(CombatLogGetCurrentEventInfo())
	end
	function EnableQuickHealth()
		if HealthCurrent.dbx.quickHealth then
			RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
			RegisterEvent("GROUP_ROSTER_UPDATE", RosterUpdateEvent)
			RegisterEvent("UNIT_HEALTH", HealthChangedEvent)
			RegisterEvent("UNIT_MAXHEALTH", HealthChangedEvent)
			RegisterEvent("UNIT_HEALTH_FREQUENT", HealthChangedEvent)
			UnitHealth = UnitQuickHealth
		end
	end
	function DisableQuickHealth()
		UnitHealth = UnitHealthOriginal
		UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "GROUP_ROSTER_UPDATE", "UNIT_HEALTH","UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH")
	end
end

local function Health_RegisterEvents()
	RegisterEvent("UNIT_HEALTH", UpdateIndicators )
	RegisterEvent("UNIT_MAXHEALTH", UpdateIndicators )
	RegisterEvent("UNIT_HEALTH_FREQUENT", UpdateIndicators )
	RegisterEvent("UNIT_CONNECTION", UpdateIndicators )
	EnableQuickHealth()
end

local function Health_UnregisterEvents()
	UnregisterEvent( "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH", "UNIT_CONNECTION" )
	DisableQuickHealth()
end

local function Health_UpdateStatuses()
	if next(statuses) then
		Health_UnregisterEvents()
		Health_RegisterEvents()
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

-- health-current status
HealthCurrent.OnEnable  = Health_Enable
HealthCurrent.OnDisable = Health_Disable
HealthCurrent.IsActive  = Grid2.statusLibrary.IsActive

function HealthCurrent_GetPercent(self,unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or UnitHealth(unit) / m
end

local function HealthCurrent_GetPercentDFH(self, unit)
	if UnitIsDeadOrGhost(unit) then return 1 end
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or UnitHealth(unit) / m
end

if Grid2.isClassic then
	function HealthCurrent:GetText1(unit)
		local h = UnitHealth(unit)
		return h<1000 and fmt("%d",h) or fmt("%.1fk",h/1000)
	end
	function HealthCurrent:GetText2(unit)
		return tostring(UnitHealth(unit))
	end
else
	function HealthCurrent:GetText1(unit)
		return fmt("%.1fk", UnitHealth(unit) / 1000)
	end
end
HealthCurrent.GetText = HealthCurrent.GetText1

function HealthCurrent:GetColor(unit)
	local f,t
	local p = self:GetPercent(unit)
	if p>=0.5 then
		f,t,p = self.color2, self.color1, (p-0.5)*2
	else
		f,t,p = self.color3, self.color2, p*2
	end
	return (t.r-f.r)*p+f.r , (t.g-f.g)*p+f.g , (t.b-f.b)*p+f.b, (t.a-f.a)*p+f.a
end

function HealthCurrent:UpdateDB()
	self.GetText = self.dbx.displayRawNumbers and self.GetText2 or self.GetText1
	self.GetPercent = self.dbx.deadAsFullHealth and HealthCurrent_GetPercentDFH or HealthCurrent_GetPercent
	self.color1 = Grid2:MakeColor(self.dbx.color1)
	self.color2 = Grid2:MakeColor(self.dbx.color2)
	self.color3 = Grid2:MakeColor(self.dbx.color3)
	Health_UpdateStatuses()
end

local function CreateHealthCurrent(baseKey, dbx)
	Grid2:RegisterStatus(HealthCurrent, {"percent", "text", "color"}, baseKey, dbx)
	HealthCurrent:UpdateDB()
	return HealthCurrent
end

Grid2.setupFunc["health-current"] = CreateHealthCurrent

Grid2:DbSetStatusDefaultValue( "health-current", {type = "health-current", colorCount=3, color1 = {r=0,g=1,b=0,a=1}, color2 = {r=1,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}  })

-- health-low status
HealthLow.OnEnable  = Health_Enable
HealthLow.OnDisable = Health_Disable
HealthLow.GetColor  = Grid2.statusLibrary.GetColor

function HealthLow:IsActive1(unit)
	return HealthCurrent:GetPercent(unit) < self.dbx.threshold
end

function HealthLow:IsActive2(unit)
	return UnitHealth(unit) < self.dbx.threshold
end

function HealthLow:UpdateDB()
	self.IsActive = self.dbx.threshold<=1 and self.IsActive1 or self.IsActive2
end

local function CreateHealthLow(baseKey, dbx)
	Grid2:RegisterStatus(HealthLow, {"percent", "color"}, baseKey, dbx)
	HealthLow:UpdateDB()
	return HealthLow
end

Grid2.setupFunc["health-low"] = CreateHealthLow

Grid2:DbSetStatusDefaultValue( "health-low", {type = "health-low", threshold = 0.4, color1 = {r=1,g=0,b=0,a=1}})

-- feign-death status
local feign_cache = {}

FeignDeath.GetColor = Grid2.statusLibrary.GetColor

local function FeignDeathUpdateEvent(unit)
	if unit_is_valid[unit] then
		local feign = UnitIsFeignDeath(unit)
		if feign~=feign_cache[unit] then
			feign_cache[unit] = feign
			FeignDeath:UpdateIndicators(unit)
		end
	end
end

function FeignDeath:OnEnable()
	RegisterEvent( "UNIT_AURA", FeignDeathUpdateEvent )
end

function FeignDeath:OnDisable()
	UnregisterEvent( "UNIT_AURA" )
	wipe(feign_cache)
end

function FeignDeath:IsActive(unit)
	return UnitIsFeignDeath(unit)
end

local feignText = L["FD"]
function FeignDeath:GetText(unit)
	return feignText
end

function Death:GetPercent(unit)
	return self.dbx.color1.a, feignText
end

local function CreateFeignDeath(baseKey, dbx)
	Grid2:RegisterStatus(FeignDeath, {"color", "percent", "text"}, baseKey, dbx)
	return FeignDeath
end

Grid2.setupFunc["feign-death"] = CreateFeignDeath

Grid2:DbSetStatusDefaultValue( "feign-death", {type = "feign-death", color1 = {r=1,g=.5,b=1,a=1}})

-- health-deficit status
HealthDeficit.GetColor  = Grid2.statusLibrary.GetColor

function HealthDeficit:OnEnable()
	self:UpdateDB()
	Health_Enable(self)
	healthdeficit_enabled = self.dbx.addIncomingHeals~=nil
	if healthdeficit_enabled and not Heals.enabled then
		Heals:OnEnable()
	end
end

function HealthDeficit:OnDisable()
	Health_Disable(self)
	if healthdeficit_enabled and not Heals.enabled then
		Heals:OnDisable()
	end
	healthdeficit_enabled = false
end

function HealthDeficit:IsActive(unit)
	return self:GetPercent(unit) >= self.dbx.threshold
end

if Grid2.isClassic then
	function HealthDeficit:GetText1(unit)
		local h = UnitHealth(unit) - UnitHealthMax(unit)
		return h>-1000 and fmt("%d",h) or fmt("%.1fk",h/1000)
	end
	function HealthDeficit:GetText2(unit)
		return tostring(UnitHealth(unit) - UnitHealthMax(unit))
	end
	function HealthDeficit:GetTextH1(unit)
		local h = UnitHealth(unit) - UnitHealthMax(unit) + heals_cache[unit]
		return h>-1000 and fmt("%d",h) or fmt("%.1fk",h/1000)
	end
	function HealthDeficit:GetTextH2(unit)
		return tostring(UnitHealth(unit) - UnitHealthMax(unit) + heals_cache[unit])
	end
else
	function HealthDeficit:GetText1(unit)
		return fmt("%.1fk", (UnitHealth(unit) - UnitHealthMax(unit)) / 1000)
	end
	function HealthDeficit:GetTextH1(unit)
		return fmt("%.1fk", (UnitHealth(unit) - UnitHealthMax(unit)  + heals_cache[unit]) / 1000)
	end
end
HealthDeficit.GetText = HealthDeficit.GetText1

function HealthDeficit:GetPercent1(unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 1 or ( m - UnitHealth(unit) ) / m
end
function HealthDeficit:GetPercent2(unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 1 or max( ( m - UnitHealth(unit) - heals_cache[unit] ) / m, 0)
end
HealthDeficit.GetPercent = HealthDeficit.GetPercent1

function HealthDeficit:GetPercentText(unit)
	return fmt( "%.0f%%", -self:GetPercent(unit)*100 )
end

function HealthDeficit:UpdateDB()
	if self.dbx.addIncomingHeals then
		self.GetPercent = HealthDeficit.GetPercent2
		self.GetText = self.dbx.displayRawNumbers and self.GetTextH2 or self.GetTextH1
	else
		self.GetPercent = HealthDeficit.GetPercent1
		self.GetText = self.dbx.displayRawNumbers and self.GetText2 or self.GetText1
	end
end

local function CreateHealthDeficit(baseKey, dbx)
	Grid2:RegisterStatus(HealthDeficit, { "percent", "color", "text"}, baseKey, dbx)
	return HealthDeficit
end

Grid2.setupFunc["health-deficit"] = CreateHealthDeficit

Grid2:DbSetStatusDefaultValue( "health-deficit", {type = "health-deficit", color1 = {r=1,g=1,b=1,a=1}, threshold = 0.05})

-- death status
local textDeath = L["DEAD"]
local textGhost = L["GHOST"]
local dead_cache = {}
local units_to_fix = {}

Death.GetColor = Grid2.statusLibrary.GetColor

local function DeathUpdateUnit(_, unit, noUpdate)
	if unit_is_valid[unit] then
		local new = UnitIsDeadOrGhost(unit) and (UnitIsGhost(unit) and textGhost or textDeath) or false
		if (not new) and UnitHealth(unit)<=0 and not units_to_fix[unit] then
			Death:FixDeathBug(unit) -- see ticket #907
		end
		if new ~= dead_cache[unit] then
			dead_cache[unit] = new
			if not noUpdate then
				if new then
					if heals_cache[unit]~=0 then
						heals_cache[unit] = 0
						Heals:UpdateIndicators(unit)
					end
					if HealthCurrent.enabled then
						HealthCurrent:UpdateIndicators(unit)
					end
				end
				Death:UpdateIndicators(unit)
			end
		end
	end
end

local function DeathTimerEvent()
	local updateFunc = HealthCurrent.enabled and HealthCurrent.dbx.deadAsFullHealth and HealthCurrent.UpdateIndicators
	for unit in next, units_to_fix do
		DeathUpdateUnit(nil, unit)
		if updateFunc then updateFunc(HealthCurrent,unit) end
	end
	wipe(units_to_fix)
end

function Death:FixDeathBug(unit)
	if not next(units_to_fix) then
		C_Timer_After(0.05, DeathTimerEvent)
	end
	units_to_fix[unit] = true
	Grid2:Debug("Fixing possible death bug (ticket #907) for unit:", unit)
end

function Death:Grid_UnitUpdated(_, unit)
	DeathUpdateUnit(_, unit, true)
end

function Death:Grid_UnitLeft(_, unit)
	dead_cache[unit] = nil
end

function Death:OnEnable()
	self:RegisterEvent( "UNIT_HEALTH", DeathUpdateUnit )
	self:RegisterEvent( "UNIT_MAXHEALTH", DeathUpdateUnit )
	self:RegisterEvent( "UNIT_CONNECTION", DeathUpdateUnit )
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
end

function Death:OnDisable()
	self:UnregisterEvent( "UNIT_HEALTH" )
	self:UnregisterEvent( "UNIT_MAXHEALTH" )
	self:UnregisterEvent( "UNIT_CONNECTION" )
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(dead_cache)
end

function Death:IsActive(unit)
	if dead_cache[unit] then return true end
end

function Death:GetIcon()
	return [[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
end

function Death:GetPercent(unit)
	return self.dbx.color1.a, dead_cache[unit]
end

function Death:GetText(unit)
	return dead_cache[unit]
end

local function CreateDeath(baseKey, dbx)
	Grid2:RegisterStatus(Death, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return Death
end

Grid2.setupFunc["death"] = CreateDeath

Grid2:DbSetStatusDefaultValue( "death", {type = "death", color1 = {r=1,g=1,b=1,a=1}})

-- heals-incoming status
local HealComm = Grid2.isClassic and LibStub("LibHealComm-4.0",true)
local HealsPlayer
local HealsNoPlayer
local HealsAbsorbNoPlayer
local HealsAbsorbPlayer
local HealsUpdateEvent
local UnitGetMyIncomingHeals
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local RegisterEvent = RegisterEvent     -- Do not remove this line because RegisterEvent is redefined if we are in Classic
local UnregisterEvent = UnregisterEvent -- Do not remove this line because UnregisterEvent is redefined if we are in Classic

if Grid2.isClassic then -- This code block can be safety be removed for retail
	local UnitGUID = UnitGUID
	local roster_units = Grid2.roster_units
	local playerGUID = UnitGUID('player')
	local function HealUpdated(event, casterGUID, spellID, healType, endTime, ... )
		for i=select("#", ...),1,-1 do
			HealsUpdateEvent( roster_units[select(i, ...)] )
		end
	end
	local function HealModifier(event, guid)
		HealsUpdateEvent( roster_units[guid] )
	end
	UnitGetTotalHealAbsorbs = function()
		return 0
	end
	UnitGetMyIncomingHeals = function(unit)
		local guid = UnitGUID(unit)
		return (HealComm:GetHealAmount(guid, myheals_bitflag, myheals_timeband and GetTime()+myheals_timeband, playerGUID) or 0) * (HealComm:GetHealModifier(guid) or 1)
	end
	RegisterEvent = function(event, func)
		HealComm.RegisterCallback( Grid2, "HealComm_HealStarted", HealUpdated )
		HealComm.RegisterCallback( Grid2, "HealComm_HealUpdated", HealUpdated )
		HealComm.RegisterCallback( Grid2, "HealComm_HealStopped", HealUpdated )
		HealComm.RegisterCallback( Grid2, "HealComm_HealDelayed", HealUpdated )
		HealComm.RegisterCallback( Grid2, "HealComm_ModifierChanged", HealModifier)
	end
	UnregisterEvent = function(event)
		HealComm.UnregisterCallback( Grid2, "HealComm_HealStarted" )
		HealComm.UnregisterCallback( Grid2, "HealComm_HealUpdated" )
		HealComm.UnregisterCallback( Grid2, "HealComm_HealStopped" )
		HealComm.UnregisterCallback( Grid2, "HealComm_HealDelayed" )
		HealComm.UnregisterCallback( Grid2, "HealComm_ModifierChanged")
	end
	function HealsPlayer(unit)
		local guid = UnitGUID(unit)
		return (HealComm:GetHealAmount(guid, heals_bitflag, heals_timeband and GetTime()+heals_timeband) or 0) * (HealComm:GetHealModifier(guid) or 1)
	end
	function HealsNoPlayer(unit)
		local guid = UnitGUID(unit)
		return (HealComm:GetOthersHealAmount(guid, heals_bitflag, heals_timeband and GetTime()+heals_timeband) or 0) * (HealComm:GetHealModifier(guid) or 1)
	end
	function HealsAbsorbPlayer(unit)
		return 0
	end
	function HealsAbsorbNoPlayer(unit, myheal)
		return 0
	end
else -- retail
	UnitGetMyIncomingHeals = UnitGetIncomingHeals
	function HealsPlayer(unit)
		return UnitGetIncomingHeals(unit) or 0
	end
	function HealsNoPlayer(unit, myheal)
		return (UnitGetIncomingHeals(unit) or 0) - myheal
	end
	function HealsAbsorbPlayer(unit)
		local v = (UnitGetIncomingHeals(unit) or 0) - (UnitGetTotalHealAbsorbs(unit) or 0)
		return v>=0 and v or 0
	end
	function HealsAbsorbNoPlayer(unit, myheal)
		local v = (UnitGetIncomingHeals(unit) or 0)  - myheal - (UnitGetTotalHealAbsorbs(unit) or 0)
		return v>=0 and v or 0
	end
end
local HealsGetAmount = HealsNoPlayer

HealsUpdateEvent = function(unit)
	if unit then
		local myheal = myheal_required>0 and UnitGetMyIncomingHeals(unit, "player") or 0
		if myheals_enabled then
			local heal = myheal>=myheals_minimum and myheal * myheals_multiplier or 0
			if myheals_cache[unit] ~= heal then
				myheals_cache[unit] = heal
				MyHeals:UpdateIndicators(unit)
			end
		end
		if heals_enabled or overheals_enabled then
			local heal = HealsGetAmount(unit, myheal)
			heal = heal>=heals_minimum and heal * heals_multiplier or 0
			if heals_cache[unit] ~= heal then
				heals_cache[unit] = heal
				Heals:UpdateIndicators(unit)
			end
			if overheals_enabled then
				OverHeals:UpdateIndicators(unit)
			end
			if healthdeficit_enabled then
				HealthDeficit:UpdateIndicators(unit)
			end
		end
	end
end

function Heals:UpdateDB()
	local m = self.dbx.flags
	heals_minimum = (m and m>1 and m ) or 1
	heals_multiplier = self.dbx.multiplier or 1
	if self.dbx.includeHealAbsorbs and not Grid2.isClassic then
		HealsGetAmount = self.dbx.includePlayerHeals and HealsAbsorbPlayer or HealsAbsorbNoPlayer
	else
		HealsGetAmount = self.dbx.includePlayerHeals and HealsPlayer or HealsNoPlayer
	end
	if Grid2.isClassic then
		heals_bitflag  = self.dbx.healTypeFlags or HealComm.ALL_HEALS
		heals_timeband = self.dbx.healTimeBand
	end
	self.GetText = self.dbx.displayRawNumbers and self.GetText2 or self.GetText1
end

function Heals:OnEnable()
	self:UpdateDB()
	if heals_required==0 then
		RegisterEvent("UNIT_HEAL_PREDICTION", HealsUpdateEvent)
	end
	if self.dbx.includeHealAbsorbs and not Grid2.isClassic then
		RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", HealsUpdateEvent)
	end
	if not self.dbx.includePlayerHeals and not Grid2.isClassic then -- in classic we do not need to substract player heals
		myheal_required = bit.bor(myheal_required,1)
	end
	heals_required = bit.bor(heals_required,1) -- set bit1
	heals_enabled = true
end

function Heals:OnDisable()
	wipe(heals_cache)
	heals_enabled = false
	heals_required = bit.band(heals_required,7-1) -- clear bit1
	myheal_required = bit.band(myheal_required,2) -- clear bit1
	if heals_required==0 then
		UnregisterEvent("UNIT_HEAL_PREDICTION")
	end
	if self.dbx.includeHealAbsorbs and not Grid2.isClassic then
		UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
	end
end

function Heals:IsActive(unit)
	return heals_cache[unit] > 1
end

if Grid2.isClassic then
	function Heals:GetText1(unit)
		local h = heals_cache[unit]
		return h<1000 and fmt("+%d",h) or fmt("+%.1fk",h/1000)
	end
	function Heals:GetText2(unit)
		return fmt("+%d",heals_cache[unit])
	end
else
	function Heals:GetText1(unit)
		return fmt("+%.1fk", heals_cache[unit] / 1000)
	end
end
Heals.GetText = Heals.GetText1

function Heals:GetPercent(unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or heals_cache[unit] / m
end

Heals.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "text", "percent"}, baseKey, dbx)
	return Heals
end

Grid2.setupFunc["heals-incoming"] = Create

Grid2:DbSetStatusDefaultValue( "heals-incoming", {type = "heals-incoming", includePlayerHeals = false, flags = 0, multiplier=1, color1 = {r=0,g=1,b=0,a=1}})

-- overhealing

function OverHeals:UpdateDB()
	overheals_minimum = self.dbx.minimum or 1
	self.GetText = self.dbx.displayRawNumbers and self.GetText2 or self.GetText1
end

function OverHeals:OnEnable()
	self:UpdateDB()
	Health_Enable(self)
	if heals_required==0 then RegisterEvent("UNIT_HEAL_PREDICTION", HealsUpdateEvent) end
	heals_required = bit.bor(heals_required,4) -- set bit3
	overheals_enabled = true
end

function OverHeals:OnDisable()
	Health_Disable(self)
	overheals_enabled = false
	heals_required = bit.band(heals_required,7-4) -- clear bit3
	if heals_required==0 then UnregisterEvent("UNIT_HEAL_PREDICTION") end
end

function OverHeals:IsActive(unit)
	return heals_cache[unit]+UnitHealth(unit)-UnitHealthMax(unit)>=overheals_minimum
end

function OverHeals:GetText1(unit)
	local h = heals_cache[unit]+UnitHealth(unit)-UnitHealthMax(unit)
	return h<1000 and fmt("+%d",h) or fmt("+%.1fk",h/1000)
end

function OverHeals:GetText2(unit)
	return fmt("+%d", heals_cache[unit]+UnitHealth(unit)-UnitHealthMax(unit) )
end

OverHeals.GetText = GetText1

OverHeals.GetColor = Grid2.statusLibrary.GetColor

function OverHeals:GetPercent(unit)
	local m = UnitHealthMax(unit)
	return m>0 and ( heals_cache[unit]+UnitHealth(unit)-m ) / m or 0
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(OverHeals, {"color", "text", "percent"}, baseKey, dbx)
	return OverHeals
end

Grid2.setupFunc["overhealing"] = Create

Grid2:DbSetStatusDefaultValue( "overhealing", {type = "overhealing", color1 = {r=.5,g=.5,b=1,a=1}})

-- my-heals-incoming status

MyHeals.GetColor = Grid2.statusLibrary.GetColor

function MyHeals:UpdateDB()
	local m = self.dbx.flags
	myheals_minimum = (m and m>1 and m ) or 1
	myheals_multiplier = self.dbx.multiplier or 1
	if Grid2.isClassic then
		myheals_bitflag  = self.dbx.healTypeFlags or HealComm.ALL_HEALS
		myheals_timeband = self.dbx.healTimeBand
	end
	self.GetText = self.dbx.displayRawNumbers and self.GetText2 or self.GetText1
end

function MyHeals:OnEnable()
	self:UpdateDB()
	if heals_required==0 then RegisterEvent("UNIT_HEAL_PREDICTION", HealsUpdateEvent) end
	myheal_required = bit.bor(myheal_required,2) -- set bit2
	heals_required  = bit.bor(heals_required,2)   -- set bit2
	myheals_enabled = true
end

function MyHeals:OnDisable()
	wipe(myheals_cache)
	myheals_enabled = false
	myheal_required = bit.band(myheal_required,1) -- clear bit2
	heals_required = bit.band(heals_required,7-2) -- clear bit2
	if heals_required==0 then UnregisterEvent("UNIT_HEAL_PREDICTION") end
end

function MyHeals:IsActive(unit)
	return myheals_cache[unit] > 1
end

if Grid2.isClassic then
	function MyHeals:GetText1(unit)
		local h = myheals_cache[unit]
		return h<1000 and fmt("+%d",h) or fmt("+%.1fk",h/1000)
	end
	function MyHeals:GetText2(unit)
		return fmt("+%d",myheals_cache[unit])
	end
else
	function MyHeals:GetText1(unit)
		return fmt("+%.1fk", myheals_cache[unit] / 1000)
	end
end
MyHeals.GetText = MyHeals.GetText1

function MyHeals:GetPercent(unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or myheals_cache[unit] / m
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(MyHeals, {"color", "text", "percent"}, baseKey, dbx)
	return MyHeals
end

Grid2.setupFunc["my-heals-incoming"] = Create

Grid2:DbSetStatusDefaultValue( "my-heals-incoming", {type = "my-heals-incoming", flags = 0, multiplier=1, color1 = {r=0,g=1,b=0,a=1}})
