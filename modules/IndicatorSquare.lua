--[[ Square indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2= Grid2

local function Square_Create(self, parent)
	local Square = self:CreateFrame("Frame", parent)
	local size = self.dbx.size
	Square:SetWidth(size)
	Square:SetHeight(size)
	local borderSize = self.borderSize
	if (borderSize) then
		Square:SetBackdrop({
			bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
			edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = borderSize,
			insets = {left = borderSize, right = borderSize, top = borderSize, bottom = borderSize},
		})
	else
		Square:SetBackdrop({
			bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
			insets = {left = 0, right = 0, top = 0, bottom = 0},
		})
	end
	Square:SetBackdropBorderColor(0,0,0,1)
	Square:SetBackdropColor(1,1,1,1)
end

local function Square_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Square_OnUpdate(self, parent, unit, status)
	local Square = parent[self.name]
	if status then
		Square:SetBackdropColor(status:GetColor(unit))
		if self.borderSize then
			local c= self.color
			Square:SetBackdropBorderColor( c.r, c.g, c.b, c.a )
		end
		Square:Show()
	else
		Square:Hide()
	end
end

local function Square_SetIndicatorSize(self, parent, size)
	local f = parent[self.name]
	f:SetWidth(size)
	f:SetHeight(size)
end

local function Square_SetBorderSize(self, parent, borderSize)
	local f = parent[self.name]
	local backdrop = f:GetBackdrop()
	local r1,g1,b1,a1 = f:GetBackdropColor()
	local r2,g2,b2,a2 = f:GetBackdropBorderColor()

	if (borderSize) then
		backdrop.edgeFile = "Interface\\Addons\\Grid2\\white16x16"
		backdrop.edgeSize = borderSize
	else
		backdrop.edgeFile = nil
		backdrop.edgeSize = nil
		borderSize = 0
	end
	backdrop.insets.left = borderSize
	backdrop.insets.right = borderSize
	backdrop.insets.top = borderSize
	backdrop.insets.bottom = borderSize

	f:SetBackdrop(backdrop)
	f:SetBackdropColor(r1,g1,b1,a1)
	f:SetBackdropBorderColor(r2,g2,b2,a2)
end

local function Square_Layout(self, parent)
	local Square = parent[self.name]
	Square:ClearAllPoints()
	Square:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Square:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	Square_SetBorderSize(self, parent, self.borderSize)
	local size = self.dbx.size
	Square:SetSize(size,size)
end

local function Square_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()

	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
	self.SetIndicatorSize = nil
	self.SetBorderSize = nil
end

local function Square_UpdateDB(self, dbx)
	dbx= dbx or self.dbx
	local l= dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level
	self.color= Grid2:MakeColor(dbx.color1)
	self.borderSize= dbx.borderSize
	self.Create = Square_Create
	self.GetBlinkFrame = Square_GetBlinkFrame
	self.Layout = Square_Layout
	self.OnUpdate = Square_OnUpdate
	self.SetIndicatorSize = Square_SetIndicatorSize
	self.SetBorderSize = Square_SetBorderSize
	self.Disable = Square_Disable
	self.UpdateDB = Square_UpdateDB
	self.dbx = dbx
end


local function Create(indicatorKey, dbx)
	local existingIndicator = Grid2.indicators[indicatorKey]
	local indicator = existingIndicator or Grid2.indicatorPrototype:new(indicatorKey)
	Square_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "square" })
	return indicator
end

Grid2.setupFunc["square"] = Create
