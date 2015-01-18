--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local GetTime = GetTime
local min = min

local AlignPoints= {
	HORIZONTAL = { 
		[true]  = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" },    -- normal Fill
		[false] = { "BOTTOMRIGHT",  "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"  },  -- reverse Fill
	},	
	VERTICAL   = {
		[true]  = { "BOTTOMLEFT","TOPLEFT","BOTTOMRIGHT","TOPRIGHT" }, -- normal Fill
		[false] = { "TOPRIGHT", "BOTTOMRIGHT","TOPLEFT","BOTTOMLEFT" }, -- reverse Fill
	}	
}

local function Bar_CreateHH(self, parent)
	local bar = self:CreateFrame("StatusBar", parent)
	local bar.textures = bar.textures  or {}
	bar:SetStatusBarColor(0,0,0,0)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	bar:Show()
end

local function Bar_Layout(self, parent)
	local Bar    = parent[self.name]
	local bgBar  = Bar.bgBar
	local orient = self.orientation or Grid2Frame.db.profile.orientation
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
	
	
	textures[1] = bar:GetStatusBarTexture()
	for i=2,self.dbx.textureCount do
		textures[i] = textures[i] or bar:CreateTexture()
		textures[i]:SetTexture( self.textures[i] )
	end
	bar.textures = textures
	
	
end

local function Bar_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Bar_PlaceBarTexture(self, prevTexture, texture, value, direction)
	return texture
end

local function Bar_SetValues(self, parent, value)
	local bar = parent[self.name]
	bar:SetValue(value)
	local alignPoints = self.alignPoints
	local barSize     = self.barSize
	local statuses    = self.statuses
	local textures    = bar.textures		
	local prevTexture = textures[1]
	local fromValue   = value
	for i=2,#textures do
		local status = statuses[i]
		if status then
			value = status:IsActive(unit) and status:GetPercent(unit) or 0
		else
			value = 1 - valueFrom
		end
		local texture = textures[i]
		if value>0 then
			local direction = texture.myDirection
			local valueTo = valueFrom + value * direction
			value = max( min(valueTo,1), 0) - max( min(valueFrom,1), 0)
			if value~=0 then
				local points = alignPoints[direction]
				texture:SetPoint( points[1], prevTexture, points[2], 0, 0)
				texture:SetPoint( points[3], prevTexture, points[4], 0, 0)
				texture:mySetSize( value * direction * barSize )
				texture:Show()
				prevTexture = texture
			else
				texture:Hide()
			end
			valueFrom = valueTo
		else
			texture:Hide()
		end
	end
end

local min,max = min,max
local function Bar_SetValueStacked(self, parent, value)
	local bar = parent[self.name]
	bar.valueReal = value or 0	
	local indicator = self.barParent
	local valueFrom = indicator and parent[indicator.name].valueTo or 0	
	local valueTo, valueCrop
	while true do
		if self.reverseFill then
			valueTo = valueFrom - (bar.valueReal or 0)
			valueCrop = max( min(valueFrom,1), 0) - max( min(valueTo,1), 0) 
		else
			valueTo = valueFrom + (bar.valueReal or 0)
			valueCrop = max( min(valueTo,1), 0) - max( min(valueFrom,1), 0)
		end
		bar:SetValue(valueCrop)
		bar.valueTo = valueTo
		self = self.barChild
		if not self then return end
		valueFrom = valueTo
		bar = parent[self.name]
	end
end

local function Bar_OnUpdate(self, parent, unit, status)
	self:SetValue(parent, status and status:GetPercent(unit) or 0)
end

--}}}

local function Bar_SetOrientation(self, orientation)
	self.orientation     = orientation
	self.dbx.orientation = orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	bar:Hide()
	self.Layout   = nil
	self.OnUpdate = nil
end

local function Bar_UpdateDB(self, dbx)
	dbx = dbx or self.dbx
	self.texture = Grid2:MediaFetch("statusbar", dbx.texture, "Gradient")
	
	local l = dbx.location
	self.frameLevel     = dbx.level or 1
	self.anchor         = l.point
	self.anchorRel      = l.relPoint
	self.offsetx        = l.x
	self.offsety        = l.y
	self.width          = dbx.width
	self.height         = dbx.height
	self.orientation    = dbx.orientation
	self.reverseFill    = dbx.reverseFill	
	self.backColor      = dbx.backColor
	self.Create         = Bar_CreateHH
	self.GetBlinkFrame  = Bar_GetBlinkFrame
	self.OnUpdate       = Bar_OnUpdate
	self.SetOrientation = Bar_SetOrientation
	self.Disable        = Bar_Disable	
	self.UpdateDB       = Bar_UpdateDB
	self.Layout         = Bar_Layout
	self.OnUpdate       = Bar_OnUpdate
	self.dbx            = dbx
end

local function BarColor_OnUpdate(self, parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 0)
	end
end

local function BarColor_SetBarColor(self, parent, r, g, b, a)
	parent[self.BarName]:SetStatusBarColor(r, g, b, min(self.opacity,a or 1) )
end


local function BarColor_UpdateDB(self)
	self.opacity = self.dbx.opacity or 1
end

local function Create(indicatorKey, dbx)

	local Bar = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	Bar_UpdateDB(Bar,dbx)
	Grid2:RegisterIndicator(Bar, { "percent" }, true)

	local colorKey    = indicatorKey .. "-color"
	local BarColor    = Grid2.indicators[colorKey] or Grid2.indicatorPrototype:new(colorKey)
	BarColor.dbx      = dbx
	BarColor.BarName  = indicatorKey
	BarColor.Create   = Grid2.Dummy
	BarColor.Layout   = Grid2.Dummy
	BarColor.OnUpdate = BarColor_OnUpdate
	BarColor.UpdateDB = BarColor_UpdateDB
	BarColor_UpdateDB(BarColor)
	Grid2:RegisterIndicator(BarColor, { "color" })

	Bar.sideKick = BarColor

	return Bar, BarColor
end

Grid2.setupFunc["bar"] = Create

Grid2.setupFunc["bar-color"] = Grid2.Dummy
