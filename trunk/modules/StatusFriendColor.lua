local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2

local FriendColor = Grid2.statusPrototype:new("friendcolor")

function FriendColor:UpdateUnit(_, unit)
	if unit then
		self:UpdateIndicators(unit)
	end	
end

function FriendColor:OnEnable()
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
end

function FriendColor:OnDisable()
	self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
end

function FriendColor:IsActive(unit)
	return true
end

function FriendColor:UnitColor(unit)
	local dbx= self.dbx
	if dbx.colorHostile and UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
		return dbx.color3
	else
		if Grid2:UnitIsPet(unit) then
			return dbx.color2
		else
			return dbx.color1
		end
	end
end

function FriendColor:GetColor(unit)
	local c = self:UnitColor(unit)
	return c.r, c.g, c.b, c.a
end

local function CreateFriendColor(baseKey, dbx)
	Grid2:RegisterStatus(FriendColor, {"color"}, baseKey, dbx)

	return FriendColor
end

Grid2.setupFunc["friendcolor"] = CreateFriendColor


