local HealComm = LibStub:GetLibrary("LibHealComm-4.0", true)
if not HealComm then return end

local UnitGUID = UnitGUID
local GetTime = GetTime
local Grid2 = Grid2
local select = select

local HEALCOMM_FLAGS = HealComm.CASTED_HEALS
local HEALCOMM_TIMEFRAME = nil

local function get_active_heal_amount_with_user(unit)
	local time = HEALCOMM_TIMEFRAME and GetTime() + HEALCOMM_TIMEFRAME
	return HealComm:GetHealAmount(UnitGUID(unit), HEALCOMM_FLAGS, time)
end

local function get_active_heal_amount_without_user(unit)
	local time = HEALCOMM_TIMEFRAME and GetTime() + HEALCOMM_TIMEFRAME
	return HealComm:GetOthersHealAmount(UnitGUID(unit), HEALCOMM_FLAGS, time)
end

local get_active_heal_amount = get_active_heal_amount_without_user

local function get_effective_heal_amount(unit)
	local guid = UnitGUID(unit)
	local time = HEALCOMM_TIMEFRAME and GetTime() + HEALCOMM_TIMEFRAME
	local heal = HealComm:GetHealAmount(guid, HEALCOMM_FLAGS, time)
	return heal and heal * HealComm:GetHealModifier(guid) or 0
end


local Heals = Grid2.statusPrototype:new("heals-incoming")

function Heals:UpdateDB()
	HEALCOMM_FLAGS = self.dbx.flags
	HEALCOMM_TIMEFRAME = self.dbx.timeFrame
	get_active_heal_amount = self.dbx.includePlayerHeals
		and get_active_heal_amount_with_user
		or  get_active_heal_amount_without_user
end

function Heals:OnEnable()
	HealComm.RegisterCallback(self, "HealComm_HealStarted", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealUpdated", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealDelayed", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealStopped", "Update")
	HealComm.RegisterCallback(self, "HealComm_ModifierChanged", "UpdateModifier")
	self:UpdateDB()
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

function Heals:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Heals:GetText(unit)
	return Grid2.GetShortNumber(get_effective_heal_amount(unit), true)
end

function Heals:GetPercent(unit)
	return (get_effective_heal_amount(unit) + UnitHealth(unit)) / UnitHealthMax(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "text", "percent"}, baseKey, dbx)

	return Heals
end

Grid2.setupFunc["heals-incoming"] = Create
