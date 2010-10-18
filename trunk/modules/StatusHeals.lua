local UnitGUID = UnitGUID
local GetTime = GetTime
local Grid2 = Grid2
local select = select

local function get_active_heal_amount_with_user(unit)
	return UnitGetIncomingHeals(unit) or 0
end

local function get_active_heal_amount_without_user(unit)
	return (UnitGetIncomingHeals(unit) or 0) - (UnitGetIncomingHeals(unit, "player") or 0)
end

local get_active_heal_amount = get_active_heal_amount_without_user

local Heals = Grid2.statusPrototype:new("heals-incoming")

function Heals:UpdateDB()
	HEALCOMM_FLAGS = self.dbx.flags
	HEALCOMM_TIMEFRAME = self.dbx.timeFrame
	get_active_heal_amount = self.dbx.includePlayerHeals
		and get_active_heal_amount_with_user
		or  get_active_heal_amount_without_user
end

function Heals:OnEnable()
	self:RegisterEvent("UNIT_HEAL_PREDICTION", "Update")
	self:UpdateDB()
end

function Heals:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_PREDICTION")
end

function Heals:Update(event, unit)
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
	return Grid2.GetShortNumber(get_active_heal_amount(unit), true)
end

function Heals:GetPercent(unit)
	return (get_active_heal_amount(unit) + UnitHealth(unit)) / UnitHealthMax(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "text", "percent"}, baseKey, dbx)

	return Heals
end

Grid2.setupFunc["heals-incoming"] = Create
