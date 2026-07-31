--[[ Shape indicator, created by Michael ]]--

local Grid2 = Grid2
local unpack = unpack
local min = math.min
local GetAtlasInfo = C_Texture.GetAtlasInfo
local canaccessvalue = Grid2.canaccessvalue
local SetAlphaFromBoolean = Grid2.SetAlphaFromBoolean

local AURA_SYMBOL_OPTIONS = {
	showIcon = false,
	showWhenHarmful = true,
	showWhenHelpful = false,
	showWithoutDispelType = false,
	style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
}

local function Shape_Create(self, parent)
	local f = self:Acquire("Frame", parent)
end

local function Shape_OnUpdate(self, parent, unit, status, state, secret, invert)
	local f = parent[self.name]
	if not f.iconContainer then return end
	if status then
		if self.opacity then
			local r, g, b, a = status:GetColor(unit)
			f.Icon:SetVertexColor(r, g, b, canaccessvalue(a) and min(self.opacity, a or 1) or self.opacity)
		else
			f.Icon:SetVertexColor(status:GetColor(unit))
		end
		SetAlphaFromBoolean(f, state, 1, 0, secret, invert)
	else
		f:SetAlpha(0)
	end
end

local function Shape_DisableIconContainer(self, parent)
	local f = parent[self.name]
	if f.iconContainer then
		f:Hide()
		f.iconContainer = nil
	end
end

local function Shape_DisableAuraContainer(self, parent)
	self:ReleaseAuraSlotButton(parent)
end

local function Shape_LayoutAura(self, parent)
	local filter, status = self:GetStatusAurasFilter()
	local f = self:AcquireAuraSlotButton(parent, filter)
	local container = parent.container
	local level = parent:GetFrameLevel() + self.frameLevel
	local width = self.width or parent.container:GetWidth()
	local height = self.height or parent.container:GetHeight()
	if not f.Icon then
		f.Icon = f:CreateTexture(nil, "ARTWORK")
		f.Icon:SetAllPoints()
	end
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	f:SetSize(width, height)
	f.Icon:SetBlendMode(self.blendMode)
	f.Icon:SetAlpha(self.opacity or 1)
	if self.useDispelIcon then
		f.Icon:SetTexCoord(0,1,0,1)
		f.Icon:SetTexture(nil)
		f:SetAuraBorder(f.Icon, AURA_SYMBOL_OPTIONS)
	else
		f:ClearAuraBorder()
		f.Icon:SetTexCoord( unpack(self.iconCoord) )
		f.Icon:SetTexture( self.iconPath )
	end
	f.Icon:Show()
	if self.dbx.shadowEnabled and not self.useDispelIcon then
		local IconShadow = f.IconShadow or f:CreateTexture(nil, "BORDER")
		IconShadow:ClearAllPoints()
		IconShadow:SetPoint("CENTER", self.shadowX, self.shadowY)
		IconShadow:SetSize(width + self.shadowSize, height + self.shadowSize)
		IconShadow:SetTexture(self.iconPath)
		IconShadow:SetTexCoord( unpack(self.iconCoord) )
		IconShadow:SetBlendMode(self.blendMode)
		IconShadow:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
		IconShadow:Show()
		f.IconShadow = IconShadow
	elseif f.IconShadow then
		f.IconShadow:Hide()
	end
end

local function Shape_LayoutIcon(self, parent)
	local f = parent[self.name]
	local level = parent:GetFrameLevel() + self.frameLevel
	local width = self.width or parent.container:GetWidth()
	local height = self.height or parent.container:GetHeight()
	if not f.Icon then
		f.Icon = f:CreateTexture(nil, "ARTWORK")
		f.Icon:SetAllPoints()
	end
	f.iconContainer = f
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	f:SetSize(width, height)
	f.Icon:SetTexCoord( unpack(self.iconCoord) )
	f.Icon:SetTexture( self.iconPath )
	f.Icon:SetBlendMode(self.blendMode)
	f.Icon:Show()
	if self.dbx.shadowEnabled then
		local IconShadow = f.IconShadow or f:CreateTexture(nil, "BORDER")
		IconShadow:ClearAllPoints()
		IconShadow:SetPoint("CENTER", self.shadowX, self.shadowY)
		IconShadow:SetSize(width + self.shadowSize, height + self.shadowSize)
		IconShadow:SetTexture(self.iconPath)
		IconShadow:SetTexCoord( unpack(self.iconCoord) )
		IconShadow:SetBlendMode(self.blendMode)
		IconShadow:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
		IconShadow:Show()
		f.IconShadow = IconShadow
	elseif f.IconShadow then
		f.IconShadow:Hide()
	end
	f:SetAlpha(0)
	f:Show()
end

local function Shape_Layout(self, parent)
	if self.auraMode then
		Shape_LayoutAura(self, parent)
	else
		Shape_DisableAuraContainer(self, parent)
	end
	if self.iconMode then
		Shape_LayoutIcon(self, parent)
	else
		Shape_DisableIconContainer(self, parent)
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
	self.color      = Grid2.MakeColor(dbx.shadowColor, "BLACK")
	self.frameLevel = dbx.level or 4
	self.useDispelIcon = dbx.useDispelIcon
	self.iconPath   = dbx.iconPath or "Interface\\Addons\\Grid2\\media\\shapes"
	self.blendMode  = dbx.blend or 'BLEND'
	self.opacity    = dbx.opacity
	self.width      = dbx.width or dbx.size or 14
	if self.width==0 then self.width = nil end
	self.height     = dbx.height or dbx.size or 14
	if self.height==0 then self.height = nil end
	-- shape selection and rotation
	local i, j, u, v
	local r = dbx.iconRotation or 0
	local k = dbx.iconIndex or 0
	local a = (dbx.iconPath and GetAtlasInfo(dbx.iconPath)) or (type(k)=='string' and GetAtlasInfo(k))
	if a then
		self.iconPath, i, j, u, v = a.file, a.leftTexCoord, a.rightTexCoord, a.topTexCoord, a.bottomTexCoord
	elseif (tonumber(k) or 0)>=0 then
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
		self.shadowSize = dbx.shadowSize or 0
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
