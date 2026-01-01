if not Grid2.secretsEnabled then return end

--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local min = min

local AlignPoints = Grid2.AlignPoints
local defaultBackColor = { r=0, g=0, b=0, a=1 }

local function Bar_CreateHH(self, parent)
	local bar = self:Acquire("StatusBar", parent)
	bar.indicator = self
	bar:SetStatusBarColor(0,0,0,0)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	if self.backColor then
		bar.bgTex = bar.bgTex or bar:CreateTexture()
	end
end

local function Bar_Layout(self, parent)
	local Bar    = parent[self.name]
	local bgTex  = Bar.bgTex
	local orient = self.orientation
	local points = AlignPoints[orient][not self.reverseFill]
	local level  = parent:GetFrameLevel() + self.frameLevel
	Bar:SetParent(parent)
	Bar:ClearAllPoints()
	Bar:SetOrientation(orient)
	Bar:SetStatusBarTexture(self.texture)
	Bar:SetReverseFill(self.reverseFill)
	local parentName = self.parentName
	if parentName then
		local PBar = parent[parentName]
		Bar:SetFrameLevel( PBar:GetFrameLevel() )
		Bar:SetSize( PBar:GetWidth(), PBar:GetHeight() )
		Bar:SetPoint( points[1], PBar:GetStatusBarTexture(), points[2], 0, 0)
		Bar:SetPoint( points[3], PBar:GetStatusBarTexture(), points[4], 0, 0)
		if bgTex then bgTex:Hide() end
	else
		local w = self.width  or parent.container:GetWidth()
		local h = self.height or parent.container:GetHeight()
		Bar:SetFrameLevel(level)
		Bar:SetSize(w, h)
		Bar:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
		local color = self.backColor
		if color then
			local tex = Bar:GetStatusBarTexture()
			local layer, sublayer = tex:GetDrawLayer()
			bgTex:SetDrawLayer(layer, sublayer-1)
			bgTex:SetTexture(self.backTexture)
			bgTex:ClearAllPoints()
			if self.dbx.invertColor then
				bgTex:SetAllPoints(Bar)
			else
				bgTex:SetPoint( points[1], tex, points[2], 0, 0)
				bgTex:SetPoint( points[3], tex, points[4], 0, 0)
				bgTex:SetPoint( points[2], Bar, points[2], 0, 0)
				bgTex:SetPoint( points[4], Bar, points[4], 0, 0)
				bgTex:SetVertexColor( color.r, color.g, color.b, color.a )
			end
			bgTex:Show()
		elseif bgTex then
			bgTex:Hide()
		end
	end
	Bar.fgTex = Bar:GetStatusBarTexture()
	Bar:Show()
end

-- normal setvalue function
local function Bar_SetValue(self, parent, value, min, max)
	local bar = parent[self.name]
	bar:SetMinMaxValues(min or 0, max or 1)
	bar:SetValue(value)
end

--{{{ Bar OnUpdate
-- normal updates
local function Bar_OnUpdate(self, parent, unit, status)
	if status then
		if status.GetValueMinMax then
			self:SetValue( parent, status:GetValueMinMax(unit) )
		else
			self:SetValue( parent, (status:GetPercent(unit)) )
		end
	else
		self:SetValue( parent, 0 )
	end
end

-- updates when background is enabled, bar hidden if no status active
local function Bar_OnUpdate2(self, parent, unit, status)
	if status then
		if status.GetValueMinMax then
			self:SetValue( parent, status:GetValueMinMax(unit) )
		else
			self:SetValue( parent, (status:GetPercent(unit)) )
		end
		parent[self.name]:Show()
	else
		self:SetValue( parent, 0 )
		parent[self.name]:Hide()
	end
end
--}}}

local function Bar_SetOrientation(self, orientation)
	self.orientation     = orientation or Grid2Frame.db.profile.orientation
	self.dbx.orientation = orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	bar:Hide()
	bar:SetParent(nil)
	bar:ClearAllPoints()
end

local function Bar_Destroy(self, parent, bar)
	bar.indicator = nil
end

local function Bar_UpdateDB(self)
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	local l = dbx.location
	self.texture     = Grid2:MediaFetch("statusbar", dbx.texture or theme.barTexture, "Gradient")
	self.backTexture = dbx.backTexture and Grid2:MediaFetch("statusbar", dbx.backTexture, "Gradient") or self.texture
	self.orientation = dbx.orientation or theme.orientation
	self.frameLevel  = dbx.level or 1
	self.anchor      = l.point
	self.anchorRel   = l.relPoint
	self.offsetx     = l.x
	self.offsety     = l.y
	self.width       = dbx.width
	self.height      = dbx.height
	self.reverseFill = not not dbx.reverseFill
	self.backColor   = dbx.backColor or (dbx.invertColor and defaultBackColor) or nil
	self.OnUpdate    = dbx.hideWhenInactive and Bar_OnUpdate2 or Bar_OnUpdate
	self.SetValue    = Bar_SetValue
	self.CanCreate   = self.prototype.CanCreate
end

local function BarColor_OnUpdate(self, parent, unit, status)
	local bar = parent[self.parentName]
	if bar then
		if status then
			local r, g, b, a = status:GetColor(unit)
			bar.fgTex:SetVertexColor(r, g, b, self.opacity)
		else
			bar:SetStatusBarColor(0,0,0,0)
		end
	end
end

local function BarColor_OnUpdateInverted(self, parent, unit, status)
	local bar = parent[self.parentName]
	if bar then
		local r, g, b, a
		if status then
			r, g, b, a = status:GetColor(unit)
		else
			r, g, b, a = 0, 0, 0, 0
		end
		local c = self.backColor
		bar.fgTex:SetVertexColor(c.r, c.g, c.b, min(self.opacity, 0.8))
		bar.bgTex:SetVertexColor(r, g, b, (a or 1)*c.a)
	end
end

local function BarColor_UpdateDB(self)
	local dbx = self.dbx
	self.OnUpdate  = dbx.invertColor and BarColor_OnUpdateInverted or BarColor_OnUpdate
	self.backColor = dbx.backColor or defaultBackColor
	self.opacity   = dbx.opacity or 1
end

local function Create(indicatorKey, dbx)
	local Bar = Grid2.indicatorPrototype:new(indicatorKey)
	Bar.dbx            = dbx
	Bar.Create         = Bar_CreateHH
	Bar.Destroy        = Bar_Destroy
	Bar.OnUpdate       = Bar_OnUpdate
	Bar.SetOrientation = Bar_SetOrientation
	Bar.Disable        = Bar_Disable
	Bar.Layout         = Bar_Layout
	Bar.UpdateDB       = Bar_UpdateDB
	Bar.GetBlinkFrame  = Bar.GetFrame
	Grid2:RegisterIndicator(Bar, { "percent" } )

	local BarColor      = Grid2.indicatorPrototype:new(indicatorKey.."-color")
	BarColor.dbx        = dbx
	BarColor.parentName = indicatorKey
	BarColor.Create     = Grid2.Dummy
	BarColor.Layout     = Grid2.Dummy
	BarColor.OnUpdate   = BarColor_OnUpdate
	BarColor.UpdateDB   = BarColor_UpdateDB
	Grid2:RegisterIndicator(BarColor, { "color" })

	Bar.sideKick = BarColor

	return Bar, BarColor
end

Grid2.setupFunc["bar"] = Create

Grid2.setupFunc["bar-color"] = Grid2.Dummy
