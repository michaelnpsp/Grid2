local HealComm = LibStub:GetLibrary("LibHealComm-4.0", true)
if not HealComm then return end

local UnitGUID = UnitGUID
local Grid2 = Grid2
local select = select

-- These probably should be configurable
local HEALCOMM_FLAGS = HealComm.CASTED_HEALS
local HEALCOMM_TIMEFRAME = nil
local HEALCOMM_INCLUDE_PLAYER_HEALS = false

-- As with healcomm-3.0, we only report active healing for other healers than player.
local get_active_heal_amount
if HEALCOMM_INCLUDE_PLAYER_HEALS then
	get_active_heal_amount = function (unit)
		return HealComm:GetHealAmount(UnitGUID(unit), HEALCOMM_FLAGS, HEALCOMM_TIMEFRAME)
	end
else
	get_active_heal_amount = function (unit)
		return HealComm:GetOthersHealAmount(UnitGUID(unit), HEALCOMM_FLAGS, HEALCOMM_TIMEFRAME)
	end
end

local function get_effective_heal_amount(unit)
	local guid = UnitGUID(unit)
	local heal = HealComm:GetHealAmount(guid, HEALCOMM_FLAGS, HEALCOMM_TIMEFRAME)
	return heal and heal * HealComm:GetHealModifier(guid) or 0
end

local Heals = Grid2.statusPrototype:new("heals-incoming")

function Heals:OnEnable()
	HealComm.RegisterCallback(self, "HealComm_HealStarted", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealUpdated", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealDelayed", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealStopped", "Update")
	HealComm.RegisterCallback(self, "HealComm_ModifierChanged", "UpdateModifier")
end

function Heals:OnDisable()
	HealComm.UnregisterCallback(self, "HealComm_HealStarted")
	HealComm.UnregisterCallback(self, "HealComm_HealUpdated")
	HealComm.UnregisterCallback(self, "HealComm_HealDelayed")
	HealComm.UnregisterCallback(self, "HealComm_HealStopped")
	HealComm.UnregisterCallback(self, "HealComm_ModifierChanged")
end

function Heals:Update(event, healerGuid, _, _, _, ...)
	for i = 1, select("#", ...) do
		local guid = select(i, ...)
		local unit = Grid2:GetUnitidByGUID(guid)
		if unit then
			self:UpdateIndicators(unit)
		end
	end
end

function Heals:UpdateModifier(event, guid)
	local unit = Grid2:GetUnitidByGUID(guid)
	if unit then
		self:UpdateIndicators(unit)
	end
end


function Heals:IsActive(unit)
	local heal = get_active_heal_amount(unit)
	return heal and heal > 0
end

Heals.defaultDB = {
	profile = {
		color1 = { r = 0, g = 1, b = 0, a = 1 },
	}
}

function Heals:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function Heals:GetText(unit)
	return Grid2:GetShortNumber(get_effective_heal_amount(unit), true)
end

function Heals:GetPercent(unit)
	return (get_effective_heal_amount(unit) + UnitHealth(unit)) / UnitHealthMax(unit)
end

Grid2:RegisterStatus(Heals, { "color", "text", "percent" })
