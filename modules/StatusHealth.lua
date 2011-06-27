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
local fmt= string.format

local function Frame_OnUnitHealthChanged(self, _, unit)
	if HealthCurrent.enabled then HealthCurrent:UpdateIndicators(unit) end
	if Heals.enabled then Heals:UpdateIndicators(unit) end
	if HealthLow.enabled then HealthLow:UpdateIndicators(unit) end
	if Death.enabled then Death:UpdateIndicators(unit) end
	if FeignDeath.enabled then FeignDeath:UpdateIndicators(unit) end
	if HealthDeficit.enabled then HealthDeficit:UpdateIndicators(unit) end
end

local EnableHealthFrame, HealthFrameEnabled, UpdateHealthFrequency
do
	local frame
	local count = 0
	local HealthEvent
	function EnableHealthFrame(enable)
		local prev = (count == 0)
		if enable then
			count = count + 1
		else
			count = count - 1
		end
		assert(count >= 0)
		local curr = (count == 0)
		if prev ~= curr then
			if not frame then
				frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			end
			if curr then
				frame:SetScript("OnEvent", nil)
				frame:UnregisterEvent("UNIT_MAXHEALTH")
				frame:UnregisterEvent( HealthEvent )
				HealthEvent= nil
			else
				HealthEvent= HealthCurrent.frequentUpdates and "UNIT_HEALTH_FREQUENT" or "UNIT_HEALTH"
				frame:SetScript("OnEvent", Frame_OnUnitHealthChanged)
				frame:RegisterEvent("UNIT_MAXHEALTH")
				frame:RegisterEvent( HealthEvent )
			end
		end
	end
	function HealthFrameEnabled()
		return count>0
	end
	function UpdateHealthFrequency()
		local NewHealthEvent=  HealthCurrent.frequentUpdates and "UNIT_HEALTH_FREQUENT" or "UNIT_HEALTH"
		if HealthEvent and NewHealthEvent~=HealthEvent then
			frame:UnregisterEvent(HealthEvent)
			frame:RegisterEvent(NewHealthEvent)
			HealthEvent= NewHealthEvent
		end
	end
end

-- health status

function HealthCurrent:OnEnable()
	self:UpdateDB()
	EnableHealthFrame(true)
end

function HealthCurrent:OnDisable()
	EnableHealthFrame(false)
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
	self.deadAsFullHealth= self.dbx.deadAsFullHealth
	self.color1= Grid2:MakeColor(self.dbx.color1)
	self.color2= Grid2:MakeColor(self.dbx.color2)
	self.color3= Grid2:MakeColor(self.dbx.color3)
	self.frequentUpdates= self.dbx.frequentUpdates
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
end

function HealthLow:OnDisable()
	EnableHealthFrame(false)
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
end

function Death:OnDisable()
	EnableHealthFrame(false)
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
end

function FeignDeath:OnDisable()
	EnableHealthFrame(false)
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
end

function HealthDeficit:OnDisable()
	EnableHealthFrame(false)
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
end

function Heals:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_PREDICTION")
	wipe(HealsCache)
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
