--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local AlignPoints = Grid2.AlignPoints
local defaultBackColor = { r=0, g=0, b=0, a=1 }

local function Bar_Create(self, parent)
	self:Acquire("Frame", parent)
end

local function Bar_Layout(self, parent)
	if not self.auraMode then
		self:ReleaseAuraSlotButton(parent)
		return
	end
	local f = parent[self.name]
	f:SetAllPoints()
	self:AcquireAuraSlotButton(parent, nil, function(_, _, button, filter, status)
		button:Hide()
		button.coolBar = button.coolBar or CreateFrame("StatusBar", nil, button)
		local Bar = button.coolBar
		if self.backColor then
			Bar.bgTex = Bar.bgTex or Bar:CreateTexture()
		end
		local bgTex = Bar.bgTex
		local orient = self.orientation
		local points = AlignPoints[orient][not self.reverseFill]
		local level  = parent:GetFrameLevel() + self.frameLevel
		Bar:ClearAllPoints()
		Bar:SetOrientation(orient)
		Bar:SetStatusBarTexture(self.texture)
		Bar:SetReverseFill(self.reverseFill)
		local w = self.width  or parent.container:GetWidth()
		local h = self.height or parent.container:GetHeight()
		Bar:SetFrameLevel(level)
		Bar:SetSize(w, h)
		Bar:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
		local color = self.barColor
		if color then
			Bar:SetStatusBarColor( color.r, color.g, color.b, color.a )
		else
			Bar:SetStatusBarColor( status:GetColor() )
		end
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
		button:SetDurationBar(Bar, self.cbOptions)
		f:Show()
	end)
end

local function Bar_SetOrientation(self, orientation)
	self.orientation = orientation or Grid2Frame.db.profile.orientation
	self.dbx.orientation = orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	bar:Hide()
	bar:SetParent(nil)
	bar:ClearAllPoints()
	self:ReleaseAuraSlotButton(parent)
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
	self.barColor    = dbx.barColor
	self.backColor   = dbx.backColor or (dbx.invertColor and defaultBackColor) or nil
	self.cbOptions   = {direction = dbx.elapsed and 0 or 1, interpolation = dbx.interpolation}
	self.CanCreate   = self.prototype.CanCreate
end

local function Create(indicatorKey, dbx)
	local Bar = Grid2.indicatorPrototype:new(indicatorKey)
	Bar.dbx            = dbx
	Bar.Create         = Bar_Create
	Bar.Destroy        = Bar_Destroy
	Bar.OnUpdate       = Bar_OnUpdate
	Bar.SetOrientation = Bar_SetOrientation
	Bar.Disable        = Bar_Disable
	Bar.Layout         = Bar_Layout
	Bar.UpdateDB       = Bar_UpdateDB
	Bar.OnUpdate       = Grid2.Dummy
	Grid2:RegisterIndicator(Bar, { "aura" } )
	return Bar
end

Grid2.setupFunc["baraura"] = Create
