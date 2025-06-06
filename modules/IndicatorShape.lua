--[[ Shape indicator, created by Michael ]]--

local Grid2 = Grid2
local unpack = unpack

local function Shape_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	Icon:SetAllPoints()
	Icon:Show()
	f.Icon = Icon
end

local function Shape_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not status then Frame:Hide(); return end
	Frame.Icon:SetVertexColor( status:GetColor(unit) )
	Frame:Show()
end

local function Shape_Layout(self, parent)
	local f = parent[self.name]
	local level = parent:GetFrameLevel() + self.frameLevel
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	f:SetSize( self.iconSize, self.iconSize )
	f.Icon:SetTexCoord( unpack(self.iconCoord) )
	f.Icon:SetTexture( self.iconPath )
	if self.dbx.shadowEnabled then
		local IconShadow = f.IconShadow or f:CreateTexture(nil, "BORDER")
		IconShadow:ClearAllPoints()
		IconShadow:SetPoint("CENTER", self.shadowX, self.shadowY)
		IconShadow:SetSize(self.shadowSize, self.shadowSize)
		IconShadow:SetTexture(self.iconPath)
		IconShadow:SetTexCoord( unpack(self.iconCoord) )
		IconShadow:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
		IconShadow:Show()
		f.IconShadow = IconShadow
	elseif f.IconShadow then
		f.IconShadow:Hide()
	end
end

local function Shape_Disable(self, parent)
	local f = parent[self.name]
	f.Icon:Hide()
	if f.IconShadow then f.IconShadow:Hide() end
	f:SetParent(nil)
	f:ClearAllPoints()
end

local function Shape_UpdateDB(self)
	local dbx = self.dbx
	-- location
	local l = dbx.location
	self.anchor    = l.point
	self.anchorRel = l.relPoint
	self.offsetx   = l.x
	self.offsety   = l.y
	-- misc variables
	self.color      = Grid2:MakeColor(dbx.shadowColor, "BLACK")
	self.frameLevel = dbx.level or 4
	self.iconSize   = dbx.size or 14
	self.iconPath   = dbx.iconPath or "Interface\\Addons\\Grid2\\media\\shapes"
	-- shape selection and rotation
	local i, j, u, v
	local r = dbx.iconRotation or 0
	local k = dbx.iconIndex or 0
	if k>=0 then
		i, j, u, v = k/8, (k+1)/8, 0, 1
	elseif dbx.iconCoord then
		i, j, u, v = unpack(dbx.iconCoord)
	else
		i, j, u, v = 0, 1, 0, 1
	end
	local x = { i,j,j,i, i,j,j,i }
	local y = { u,u,v,v, u,u,v,v }
	self.iconCoord = { x[5-r],y[5-r], x[8-r],y[8-r], x[6-r],y[6-r], x[7-r],y[7-r] }
	-- shadow
	if dbx.shadowEnabled then
		self.shadowSize = self.iconSize + (dbx.shadowSize or 0)
		self.shadowX    = dbx.shadowX or 0
		self.shadowY    = dbx.shadowY or 0
	end
end

local function CreateShape(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx 			= dbx
	indicator.Create        = Shape_Create
	indicator.Layout        = Shape_Layout
	indicator.OnUpdate      = Shape_OnUpdate
	indicator.Disable       = Shape_Disable
	indicator.UpdateDB      = Shape_UpdateDB
	indicator.GetBlinkFrame = indicator.GetFrame
	Grid2:RegisterIndicator(indicator, { "color" })
	return indicator
end

Grid2.setupFunc["shape"] = CreateShape
