local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Health = Grid2.statusPrototype:new("health")
local LowHealth = Grid2.statusPrototype:new("health-low")
local Death = Grid2.statusPrototype:new("death")
local FeignDeath = Grid2.statusPrototype:new("feign-death")
local HealthDeficit = Grid2.statusPrototype:new("health-deficit")

local UnitHealth = UnitHealth

local function Frame_OnUnitHealthChanged(self, _, unit)
	if Health.enabled then Health:UpdateIndicators(unit) end
	if LowHealth.enabled then LowHealth:UpdateIndicators(unit) end
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



Health.defaultDB = {
	profile = {
		color1 = { r = 0, g = 1, b = 0, a = 1 },
		deadAsFullHealth = nil,
	}
}

function Health:OnEnable()
	EnableHealthFrame(true)
end

function Health:OnDisable()
	EnableHealthFrame(false)
end

function Health:IsActive(unit)
	return true
end

function Health:GetPercent(unit)
	if (self.db.profile.deadAsFullHealth and UnitIsDeadOrGhost(unit)) then
		return 1
	end
	return UnitHealth(unit) / UnitHealthMax(unit)
end

function Health:GetText(unit)
	return Grid2:GetShortNumber(UnitHealth(unit))
end

function Health:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(Health, { "percent", "text", "color" })


LowHealth.defaultDB = {
	profile = {
		threshold = 0.4,
		color1 = { r = 1, g = 0, b = 0, a = 1 },
	}
}

function LowHealth:OnEnable()
	EnableHealthFrame(true)
end

function LowHealth:OnDisable()
	EnableHealthFrame(false)
end

function LowHealth:IsActive(unit)
	return Health:GetPercent(unit) < self.db.profile.threshold
end

function LowHealth:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(LowHealth, { "color" })



Death.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = 1, a = 1 },
	}
}

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
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function Death:GetIcon(unitid)
	return [[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
end

function Death:GetPercent(unitid)
	local color = self.db.profile.color1
	return UnitIsDeadOrGhost(unitid) and color.a or 1
end

function Death:GetText(unitid)
	if (UnitIsDead(unitid)) then
		return L["DEAD"]
	elseif UnitIsGhost(unitid) then
		return L["GHOST"]
	end
end

Grid2:RegisterStatus(Death, { "color", "icon", "percent", "text" })



FeignDeath.defaultDB = {
	profile = {
		color1 = { r = 1, g = .5, b = 1, a = 1 },
	}
}

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
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function FeignDeath:GetPercent(unit)
	local color = self.db.profile.color1
	return UnitIsFeignDeath(unit) and color.a or 1
end

function FeignDeath:GetText(unit)
	if UnitIsDead(unit) then
		return L["DEAD"]
	elseif UnitIsGhost(unit) then
		return L["GHOST"]
	end
end

Grid2:RegisterStatus(FeignDeath, { "color", "percent", "text" })



HealthDeficit.defaultDB = {
	profile = {
		threshold = 0.2,
	}
}

function HealthDeficit:OnEnable()
	EnableHealthFrame(true)
end

function HealthDeficit:OnDisable()
	EnableHealthFrame(false)
end

function HealthDeficit:IsActive(unit)
	return (1 - Health:GetPercent(unit)) > self.db.profile.threshold
end

function HealthDeficit:GetText(unit)
	return Grid2:GetShortNumber(UnitHealth(unit) - UnitHealthMax(unit))
end

Grid2:RegisterStatus(HealthDeficit, {"text"})