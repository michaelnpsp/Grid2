local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Square_Create(self, parent)
	local Square = CreateFrame("Frame", nil, parent)
	local cornerSize = self.db.profile.cornerSize
	Square:SetWidth(cornerSize) -- @FIXME merge the sizes ?
	Square:SetHeight(cornerSize)
	Square:SetBackdrop({
		bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	Square:SetBackdropBorderColor(0,0,0,1)
	Square:SetBackdropColor(1,1,1,1)
	parent[self.name] = Square
end

local function Square_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Square_Layout(self, parent)
	local Square = parent[self.name]
	Square:ClearAllPoints()
	Square:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Square:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	local cornerSize = self.db.profile.cornerSize
	Square:SetWidth(cornerSize) -- @FIXME merge the sizes ?
	Square:SetHeight(cornerSize)
end

local function Square_OnUpdate(self, parent, unit, status)
	local Square = parent[self.name]
	if status then
		Square:SetBackdropColor(status:GetColor(unit))
		Square:Show()
	else
		Square:Hide()
	end
end

local function Square_SetSize(self, parent, size)
	local Square = parent[self.name]
	Square:SetWidth(size)
	Square:SetHeight(size)
end

local Square_defaultDB = {
	profile = {
		cornerSize = 5,
	}
}

function Grid2:CreateSquareIndicator(indicatorKey, level, anchor, anchorRel, offsetx, offsety)
	if type(level) == "string" then
		level, anchor, anchorRel, offsetx, offsety = 0, level, anchor, anchorRel, offsetx
	end
	local Square = self.indicatorPrototype:new(indicatorKey)

	Square.frameLevel = level
	Square.anchor = anchor
	Square.anchorRel = anchorRel
	Square.offsetx = offsetx
	Square.offsety = offsety
	Square.Create = Square_Create
	Square.GetBlinkFrame = Square_GetBlinkFrame
	Square.Layout = Square_Layout
	Square.OnUpdate = Square_OnUpdate
	Square.SetSize = Square_SetSize
	Square.defaultDB = Square_defaultDB

	self:RegisterIndicator(Square, { "color" })

	return Square
end
