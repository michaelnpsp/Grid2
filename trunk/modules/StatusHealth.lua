local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local HealthCurrent = Grid2.statusPrototype:new("health-current")
local HealthLow = Grid2.statusPrototype:new("health-low")
local Death = Grid2.statusPrototype:new("death")
local FeignDeath = Grid2.statusPrototype:new("feign-death")
local HealthDeficit = Grid2.statusPrototype:new("health-deficit")

local UnitHealth = UnitHealth

local function Frame_OnUnitHealthChanged(self, _, unit)
	if HealthCurrent.enabled then HealthCurrent:UpdateIndicators(unit) end
	if HealthLow.enabled then HealthLow:UpdateIndicators(unit) end
	if Death.enabled then Death:UpdateIndicators(unit) end
	if FeignDeath.enabled then FeignDeath:UpdateIndicators(unit) end
	if HealthDeficit.enabled then HealthDeficit:UpdateIndicators(unit) end
end

local EnableHealthFrame
do
	local frame
	local count = 0
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
				frame:UnregisterEvent("UNIT_HEALTH")
				frame:UnregisterEvent("UNIT_MAXHEALTH")
--				frame:UnregisterMessage("Grid_UnitJoined")
			else
				frame:SetScript("OnEvent", Frame_OnUnitHealthChanged)
				frame:RegisterEvent("UNIT_HEALTH")
				frame:RegisterEvent("UNIT_MAXHEALTH")
--				frame:RegisterMessage("Grid_UnitJoined")
			end
		end
	end
end



function HealthCurrent:OnEnable()
	EnableHealthFrame(true)
end

function HealthCurrent:OnDisable()
	EnableHealthFrame(false)
end

function HealthCurrent:IsActive(unit)
	return true
end

function HealthCurrent:GetPercent(unit)
	if (self.dbx.deadAsFullHealth and UnitIsDeadOrGhost(unit)) then
		return 1
	end
	return UnitHealth(unit) / UnitHealthMax(unit)
end

function HealthCurrent:GetTextDefault(unit)
	return Grid2.GetShortNumber(UnitHealth(unit))
end

function HealthCurrent:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local function CreateHealthCurrent(baseKey, dbx)
	Grid2:RegisterStatus(HealthCurrent, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(HealthCurrent)
	
	return HealthCurrent
end

Grid2.setupFunc["health-current"] = CreateHealthCurrent



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
	if UnitIsDead(unit) then
		return L["DEAD"]
	elseif UnitIsGhost(unit) then
		return L["GHOST"]
	end
end

local function CreateFeignDeath(baseKey, dbx)
	Grid2:RegisterStatus(FeignDeath, {"color", "percent", "text"}, baseKey, dbx)

	return FeignDeath
end

Grid2.setupFunc["feign-death"] = CreateFeignDeath



function HealthDeficit:OnEnable()
	EnableHealthFrame(true)
end

function HealthDeficit:OnDisable()
	EnableHealthFrame(false)
end

function HealthDeficit:IsActive(unit)
	return (1 - HealthCurrent:GetPercent(unit)) > self.dbx.threshold
end

function HealthDeficit:GetText(unit)
	return Grid2.GetShortNumber(UnitHealth(unit) - UnitHealthMax(unit))
end

local function CreateHealthDeficit(baseKey, dbx)
	Grid2:RegisterStatus(HealthDeficit, {"text"}, baseKey, dbx)

	return HealthDeficit
end

Grid2.setupFunc["health-deficit"] = CreateHealthDeficit
