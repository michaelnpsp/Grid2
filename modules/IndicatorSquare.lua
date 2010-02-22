local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Square_Create(self, parent)
	local Square = CreateFrame("Frame", nil, parent)
	local cornerSize = self.dbx.cornerSize
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
	local cornerSize = self.dbx.cornerSize
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

local function Square_Disable(self, parent)
	local Square = parent[self.name]
	Square:SetBackdrop(nil)
	Square:SetBackdropBorderColor(0,0,0,0)
	Square:SetBackdropColor(0,0,0,0)
	Square:Hide()

	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
	self.SetSize = nil
end

local function Square_UpdateDB(self, dbx)
	-- ToDo: copy if it already exists
	-- ToDo: update if it changed
-- if (self.dbx) then
	-- print("Square_UpdateDB self.dbx:", self.dbx, self.dbx.cornerSize, "dbx:", dbx, dbx.cornerSize)
-- end
	local oldType = self.dbx and self.dbx.type or dbx.type
	local location = Grid2.locations[dbx.location]

	self.frameLevel = dbx.level
	self.anchor = location.point
	self.anchorRel = location.relPoint
	self.offsetx = location.x
	self.offsety = location.y
	self.Create = Square_Create
	self.GetBlinkFrame = Square_GetBlinkFrame
	self.Layout = Square_Layout
	self.OnUpdate = Square_OnUpdate
	self.SetSize = Square_SetSize
	self.Disable = Square_Disable
	self.UpdateDB = Square_UpdateDB

	self.dbx = dbx
end


local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)

	Square_UpdateDB(indicator, dbx)
	
	Grid2:RegisterIndicator(indicator, { "square" })
	return indicator
end

Grid2.setupFunc["square"] = Create
