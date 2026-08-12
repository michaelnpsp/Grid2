--[[ Square indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2

local SetAlphaFromBoolean = Grid2.SetAlphaFromBoolean
local UnpackColor = Grid2.UnpackColor

--==============================================================
--
--==============================================================

local function Square_DisableAuraContainer(self, parent)
	self:ReleaseAuraSlotButton(parent)
end

local function Square_LayoutAura(self, parent)
	local filter, status = self:GetStatusAurasFilter()
	local button = self:AcquireAuraSlotButton(parent, filter)
	local level = parent:GetFrameLevel() + self.frameLevel
	local container = parent.container
	button:ClearAllPoints()
	button:SetFrameLevel(level)
	button:SetPoint(self.anchor, container, self.anchorRel, self.offsetx, self.offsety)
	button:SetSize(self.width or container:GetWidth() , self.height or container:GetHeight())
	local tex = button.__texture
	if not tex then
		tex = button:CreateTexture(nil, "ARTWORK")
		button.__texture = tex
	end
	local btex = tex.__borderTexture
	if not btex then
		btex = button:CreateTexture(nil, "ARTWORK")
		btex:SetAllPoints()
		tex.__borderTexture = btex
	end
	tex:ClearAllPoints()
	local borderSize = self.borderSize
	if borderSize then
		tex:SetPoint("TOPLEFT", borderSize, -borderSize)
		tex:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		btex:SetTexture( Grid2:GetSliceBorderTexture(borderSize) )
		btex:SetTextureSliceMargins(borderSize, borderSize, borderSize, borderSize)
		btex:SetTextureSliceMode(1)
		btex:Show()
	else
		tex:SetAllPoints()
		btex:Hide()
	end
	button:ClearAuraBorder()
	button:ClearDurationText()
	if filter.cooldownTextOptions then -- coloring by remaining time, using a special font
		local colorFrame = button._colorFrame
		if not colorFrame then
			colorFrame = CreateFrame("Frame", nil, button)
			colorFrame:SetClipsChildren(true)
			button._colorFrame = colorFrame
			local text = colorFrame:CreateFontString(nil, "OVERLAY")
			text:SetPoint('CENTER')
			text:SetFont("Interface\\Addons\\Grid2\\media\\grid2-squares.ttf", 32, '')
			text:SetMaxLines(1)
			colorFrame.text = text
		end
		colorFrame:ClearAllPoints()
		if borderSize then
			colorFrame:SetPoint("TOPLEFT", borderSize, -borderSize)
			colorFrame:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		else
			colorFrame:SetAllPoints()
		end
		colorFrame:SetFrameLevel(level)
		colorFrame:Show()
		button:SetDurationText(colorFrame.text, filter.cooldownTextOptions)
		btex:SetVertexColor( UnpackColor(self.color) )
		tex:Hide()
	elseif self.borderSwap then
		if button._colorFrame then button._colorFrame:Hide() end
		tex:SetColorTexture( UnpackColor(self.color) )
		button:SetAuraBorder(btex, filter.borderOptions)
	else
		if button._colorFrame then button._colorFrame:Hide() end
		btex:SetVertexColor( UnpackColor(self.color) )
		tex:SetColorTexture(1,1,1,1)
		button:SetAuraBorder(tex, filter.borderOptions)
	end
end

--==============================================================
--
--==============================================================

local function Square_Create(self, parent)
	self:Acquire("Frame", parent, "BackdropTemplate")
end

local function Square_OnUpdate(self, parent, unit, status, state, secret, invert)
	local Square = parent[self.name]
	if not Square.iconContainer then
		return
	end
	if status then
		Square:SetBackdropColor(status:GetColor(unit))
		SetAlphaFromBoolean(Square, state, 1, 0, secret, invert)
	else
		Square:SetAlpha(0)
	end
end

local function Square_OnUpdateBorder(self, parent, unit, status, state, secret, invert)
	local Square = parent[self.name]
	if not Square.iconContainer then
		return
	end
	if status then
		Square:SetBackdropBorderColor(status:GetColor(unit))
		SetAlphaFromBoolean(Square, state, 1, 0, secret, invert)
	else
		Square:SetAlpha(0)
	end
end

local function Square_DisableIconContainer(self, parent)
	local f = parent[self.name]
	if f.iconContainer then
		f:Hide()
		f.iconContainer = nil
	end
end

local function Square_LayoutIcon(self, parent)
	local Square, container = parent[self.name], parent.container
	Square.iconContainer = Square
	Square:SetParent(parent)
	Square:ClearAllPoints()
	Square:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Square:SetPoint(self.anchor, container, self.anchorRel, self.offsetx, self.offsety)
	Square:SetWidth( self.width or container:GetWidth() )
	Square:SetHeight( self.height or container:GetHeight() )
	if self.borderSwap then
		local r,g,b,a = Square:GetBackdropBorderColor()
		Grid2:SetFrameBackdrop(Square, self.backdrop)
		Square:SetBackdropColor( UnpackColor(self.color) )
		if r then Square:SetBackdropBorderColor( r,g,b,a ) end
	else
		local r,g,b,a = Square:GetBackdropColor()
		Grid2:SetFrameBackdrop(Square, self.backdrop)
		if r then Square:SetBackdropColor( r,g,b,a ) end
		if self.borderSize then
			Square:SetBackdropBorderColor( UnpackColor(self.color) )
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

local function Square_Layout(self, parent)
	if self.auraMode then
		Square_LayoutAura(self, parent)
	else
		Square_DisableAuraContainer(self, parent)
	end
	if self.iconMode then
		Square_LayoutIcon(self, parent)
	else
		Square_DisableIconContainer(self, parent)
	end
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
	self.color = Grid2.MakeColor(dbx.color1)
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
