local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Health = Grid2.statusPrototype:new("health")
local LowHealth = Grid2.statusPrototype:new("lowhealth")
local Death = Grid2.statusPrototype:new("death")
local HealthDeficit = Grid2.statusPrototype:new("healthdeficit")

Health.defaultDB = {
	profile = {
		deadAsFullHealth = true,
	}
}

local UnitHealth = UnitHealth

local function Frame_OnUnitHealthChanged(self, _, unit)
	if Health.enabled then Health:UpdateIndicators(unit) end
	if LowHealth.enabled then LowHealth:UpdateIndicators(unit) end
	if Death.enabled then Death:UpdateIndicators(unit) end
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
			else
				frame:SetScript("OnEvent", Frame_OnUnitHealthChanged)
				frame:RegisterEvent("UNIT_HEALTH")
				frame:RegisterEvent("UNIT_MAXHEALTH")
			end
		end
	end
end

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
	if self.db.profile.deadAsFullHealth and UnitIsDeadOrGhost(unit) then
		return 1
	end
	return UnitHealth(unit) / UnitHealthMax(unit)
end

function Health:GetText(unit)
	return Grid2:GetShortNumber(UnitHealth(unit))
end

Grid2:RegisterStatus(Health, { "percent", "text" })

LowHealth.defaultDB = {
	profile = {
		threshold = 0.4,
		color = { r = 1, g = 0, b = 0, a = 1 },
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
	local color = self.db.profile.color
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(LowHealth, { "color" })

function Death:OnEnable()
	EnableHealthFrame(true)
end

function Death:OnDisable()
	EnableHealthFrame(false)
end

function Death:IsActive(unit)
	return UnitIsDeadOrGhost(unit)
end

function Death:GetText(unit)
	if UnitIsDead(unit) then
		return L["DEAD"]
	elseif UnitIsGhost(unit) then
		return L["GHOST"]
	end
end

function Death:GetColor(unit)
	return 0.5, 0.5, 0.5, 1
end

Grid2:RegisterStatus(Death, { "text", "color" })

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
