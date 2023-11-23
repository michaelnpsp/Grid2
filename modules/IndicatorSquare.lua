--[[ Square indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2

local function Square_Create(self, parent)
	self:Acquire("Frame", parent, "BackdropTemplate")
end

local function Square_OnUpdate(self, parent, unit, status)
	local Square = parent[self.name]
	if status then
		Square:SetBackdropColor(status:GetColor(unit))
		Square:SetAlpha(1)
	else
		Square:SetAlpha(0)
	end
end

local function Square_OnUpdateBorder(self, parent, unit, status)
	local Square = parent[self.name]
	if status then
		Square:SetBackdropBorderColor(status:GetColor(unit))
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
	if self.borderSwap then
		local c = self.color
		local r,g,b,a = Square:GetBackdropBorderColor()
		Grid2:SetFrameBackdrop(Square, self.backdrop)
		Square:SetBackdropColor( c.r, c.g, c.b, c.a )
		if r then Square:SetBackdropBorderColor( r,g,b,a ) end
	else
		local r,g,b,a = Square:GetBackdropColor()
		Grid2:SetFrameBackdrop(Square, self.backdrop)
		if r then Square:SetBackdropColor( r,g,b,a ) end
		if self.borderSize then
			local c = self.color
			Square:SetBackdropBorderColor( c.r, c.g, c.b, c.a )
		end
	end
	local mode = self.blendMode
	if mode then
		Square.Center:SetBlendMode(mode)
		Square:SetBorderBlendMode(mode)
	end	
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
	self.borderSwap = dbx.borderSwap
	self.blendMode = dbx.blend
	self.width = dbx.size or dbx.width
	if self.width==0 then self.width= nil end
	self.height= dbx.size or dbx.height
	if self.height==0 then self.height= nil end
	-- backdrop
	local borderSize = self.borderSize or 0
	self.backdrop = Grid2:GetBackdropTable( borderSize>0 and "Interface\\Addons\\Grid2\\media\\white16x16" or nil, borderSize>0 and borderSize or nil, Grid2:MediaFetch("statusbar", dbx.texture, "Grid2 Flat"), false, 0, borderSize )
	-- methods
	self.OnUpdate = self.borderSwap and Square_OnUpdateBorder or Square_OnUpdate
end


local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Square_Create
	indicator.Layout = Square_Layout
	indicator.OnUpdate = Square_OnUpdate
	indicator.Disable = Square_Disable
	indicator.UpdateDB = Square_UpdateDB
	indicator.GetBlinkFrame = indicator.GetFrame
	Grid2:RegisterIndicator(indicator, { "color" })
	return indicator
end

Grid2.setupFunc["square"] = Create
