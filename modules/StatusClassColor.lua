local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local ClassColor = Grid2.statusPrototype:new("classcolor")

ClassColor.defaultDB = {
	profile = {
		colorHostile = true,
		colors = {
			HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
			UNKNOWN_UNIT = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
			UNKNOWN_PET = { r = 0, g = 1, b = 0, a = 1 },
			[L["Beast"]] = { r = 0.93725490196078, g = 0.75686274509804, b = 0.27843137254902, a = 1 },
			[L["Demon"]] = { r = 0.54509803921569, g = 0.25490196078431, b = 0.68627450980392, a = 1 },
			[L["Humanoid"]] = { r = 0.91764705882353, g = 0.67450980392157, b = 0.84705882352941, a = 1 },
			[L["Elemental"]] = { r = 0.1, g = 0.3, b = 0.9, a = 1 },
		},
	}
}

for class, color in pairs(RAID_CLASS_COLORS) do
	ClassColor.defaultDB.profile.colors[class] = { r = color.r, g = color.g, b = color.b, a = 1 }
end

function ClassColor:OnEnable()
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
end

function ClassColor:UpdateUnit(_, unit)
	self:UpdateIndicators(unit)
end

function ClassColor:OnDisable()
	self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
end

function ClassColor:IsActive(unit)
	return true
end

function ClassColor:UnitColor(unit)
	local p = self.db.profile
	local colors = p.colors
	if not Grid2:UnitIsPet(unit) then
		local _, c = UnitClass(unit)
		return colors[c or "UNKNOWN_UNIT"] or colors.UNKNOWN_UNIT
	elseif UnitIsCharmed(unit) and p.colorHostile then
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

Grid2:RegisterStatus(ClassColor, { "color" })
