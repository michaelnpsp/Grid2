--[[ Square indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2

local function Square_Create(self, parent)
	self:CreateFrame("Frame", parent)
end

local function Square_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Square_OnUpdate(self, parent, unit, status)
	local Square = parent[self.name]
	if status then
		Square:SetBackdropColor(status:GetColor(unit))
		if self.borderSize then
			local c = self.color
			Square:SetBackdropBorderColor( c.r, c.g, c.b, c.a )
		end
		Square:SetAlpha(1)
	else
		Square:SetAlpha(0)
	end
end

local function Square_Layout(self, parent)
	local Square, container = parent[self.name], parent.container
	Square:SetParent(parent)
	Square:ClearAllPoints()
	Square:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Square:SetPoint(self.anchor, container, self.anchorRel, self.offsetx, self.offsety)
	Square:SetWidth( self.width or container:GetWidth() )
	Square:SetHeight( self.height or container:GetHeight() )
	local r1,g1,b1,a1 = Square:GetBackdropColor()
	local r2,g2,b2,a2 = Square:GetBackdropBorderColor()
	Grid2:SetFrameBackdrop(Square, self.backdrop)
	Square:SetBackdropColor(r1,g1,b1,a1)
	Square:SetBackdropBorderColor(r2,g2,b2,a2)
	Square:Show()
end

local function Square_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()	
end

local function Square_UpdateDB(self)
	local dbx = self.dbx
	-- variables
	local l = dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level
	self.color = Grid2:MakeColor(dbx.color1)
	self.borderSize = dbx.borderSize
	self.width = dbx.size or dbx.width
	if self.width==0 then self.width= nil end
	self.height= dbx.size or dbx.height
	if self.height==0 then self.height= nil end
	-- backdrop
	local borderSize = self.borderSize or 0
	self.backdrop = Grid2:GetBackdropTable( borderSize>0 and "Interface\\Addons\\Grid2\\media\\white16x16" or nil, borderSize>0 and borderSize or nil, Grid2:MediaFetch("statusbar", dbx.texture, "Grid2 Flat"), false, 0, borderSize )
end


local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Square_Create
	indicator.GetBlinkFrame = Square_GetBlinkFrame
	indicator.Layout = Square_Layout
	indicator.OnUpdate = Square_OnUpdate
	indicator.Disable = Square_Disable
	indicator.UpdateDB = Square_UpdateDB
	Square_UpdateDB(indicator)
	Grid2:RegisterIndicator(indicator, { "square" })
	return indicator
end

Grid2.setupFunc["square"] = Create
 