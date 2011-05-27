local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local CreatureColor = Grid2.statusPrototype:new("creaturecolor")


function CreatureColor:OnEnable()
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
end

function CreatureColor:UpdateUnit(_, unitid)
	if unitid then
		self:UpdateIndicators(unitid)
	end	
end

function CreatureColor:OnDisable()
	self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
end

function CreatureColor:IsActive(unit)
	return true
end

function CreatureColor:UnitColor(unit)
	local p = self.dbx
	local colors = p.colors
	if p.colorHostile and UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
		return colors.HOSTILE
	else
		local c = UnitCreatureType(unit)
		return colors[c or "UNKNOWN_UNIT"] or colors.UNKNOWN_UNIT
	end
end

function CreatureColor:GetColor(unit)
	local color = self:UnitColor(unit)
	return color.r, color.g, color.b, color.a
end

local function CreateCreatureColor(baseKey, dbx)
	Grid2:RegisterStatus(CreatureColor, {"color"}, baseKey, dbx)

	return CreatureColor
end

Grid2.setupFunc["creaturecolor"] = CreateCreatureColor


