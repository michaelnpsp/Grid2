local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local ClassColor = Grid2.statusPrototype:new("classcolor")
local Charmed = Grid2.statusPrototype:new("charmed")


function ClassColor:OnEnable()
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
end

function ClassColor:UpdateUnit(_, unitid)
	self:UpdateIndicators(unitid)
end

function ClassColor:OnDisable()
	self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
end

function ClassColor:IsActive(unit)
	return true
end

function ClassColor:UnitColor(unit)
	local p = self.dbx
	local colors = p.colors
	if (not Grid2:UnitIsPet(unit)) then
		local _, c = UnitClass(unit)
		return colors[c or "UNKNOWN_UNIT"] or colors.UNKNOWN_UNIT
	elseif (UnitIsCharmed(unit) and p.colorHostile and UnitIsEnemy("player", unit)) then
		return colors.HOSTILE
	else
		local c = UnitCreatureType(unit)
		return colors[c or "UNKNOWN_PET"] or colors.UNKNOWN_PET
	end
end

function ClassColor:GetColor(unit)
	local color = self:UnitColor(unit)
	return color.r, color.g, color.b, color.a
end

local function CreateClassColor(baseKey, dbx)
	Grid2:RegisterStatus(ClassColor, {"color"}, baseKey, dbx)

	return ClassColor
end

Grid2.setupFunc["classcolor"] = CreateClassColor



function Charmed:OnEnable()
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
end

function Charmed:UpdateUnit(_, unitid)
	self:UpdateIndicators(unitid)
end

function Charmed:OnDisable()
	self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
end

function Charmed:IsActive(unit)
	local owner = Grid2:GetOwnerUnitByUnit(unit)
	if (owner and UnitHasVehicleUI(owner)) then
		return nil
	else
		return UnitIsCharmed(unit)
	end
end

function Charmed:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Charmed:GetText(unit)
	return L["Charmed"]
end

function Charmed:GetPercent(unit)
	return UnitIsCharmed(unit) and 1 or self.dbx.color1.a
end

local function  CreateCharmed(baseKey, dbx)
	Grid2:RegisterStatus(Charmed, { "color", "text", "percent" }, baseKey, dbx)
	
	return Charmed
end

Grid2.setupFunc["charmed"] =  CreateCharmed
