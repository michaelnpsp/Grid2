--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local min = min
local max = max
local pairs = pairs
local ipairs = ipairs

local AlignPoints = Grid2.AlignPoints
local SetSizeMethods = { HORIZONTAL = "SetWidth", VERTICAL = "SetHeight" }
local GetSizeMethods = { HORIZONTAL = "GetWidth", VERTICAL = "GetHeight" }

local function Bar_CreateHH(self, parent)
	local bar = self:Acquire("StatusBar", parent)
	bar.myIndicator = self
	bar.myValues = {}
	bar:SetStatusBarColor(0,0,0,0)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
end

-- Warning Do not put bar:SetValue() methods inside this function because for some reason the bar is not updated&painted
-- on current frame (the bar update is delayed to the next frame), but extra bar textures are updated on current frame.
-- generating a graphic glitch because main bar & extra bars are displayed out of sync (in diferente frames)
-- In this case we are talking about screen frames like in frames per second.
local function Bar_OnFrameUpdate(bar)
	local self        = bar.myIndicator
	local direction   = self.direction
	local horizontal  = self.horizontal
	local points      = self.alignPoints
	local barSize     = bar[self.GetSizeMethod](bar)
	local myTextures  = bar.myTextures
	local myValues    = bar.myValues
	local valueTo     = myValues[1] or 0
	local valueMax    = valueTo
	local maxIndex    = 0
	if self.reverse then
		valueMax, valueTo = 0, -valueTo
	end
	local size, offset, offseu
	for i=2,bar.myMaxIndex do
		local texture = myTextures[i]
		local value = myValues[i] or 0
		if value>0 then
			maxIndex = i
			if texture.myReverse then
			  offset  = valueTo - value
			  offseu  = valueTo
			  valueTo = offset
			elseif texture.myNoOverlap then
			  offset   = valueMax
			  offseu   = valueMax+value
			  valueTo  = offseu
			  valueMax = valueTo
			else
			  offset   = valueTo
			  offseu   = valueTo+value
			  valueTo  = offseu
			  valueMax = valueTo>valueMax and valueTo or valueMax
			end
			if offset<0 then offset = 0 end
			if offseu>1 then offseu = 1 end
			size = offseu - offset
			if size>0 then
				if horizontal then
					texture:SetPoint( points[1], bar, points[1], direction*offset*barSize, 0)
					if texture.myHorAdjust then texture:SetTexCoord(0,size,0,1) end
				else
					texture:SetPoint( points[1], bar, points[1], 0, direction*offset*barSize)
					if texture.myVerAdjust then texture:SetTexCoord(0,1,1-size,1) end
				end
				texture:mySetSize( size * barSize )
				texture:Show()
			else
				texture:Hide()
			end
		else
			texture:Hide()
		end
	end
	bar.myMaxIndex = maxIndex
	if self.backAnchor then
		local texture = myTextures[#myTextures]
		local size = (self.backAnchor==1) and myValues[1] or valueMax
		if size<1 then
			texture:SetPoint( points[2], bar, points[2], 0, 0)
			texture:mySetSize( (1-size) * barSize )
			texture:Show()
		else
			texture:Hide()
		end
	end
end

-- {{{ Optimization: Updating modified bars only on next frame repaint
local updates = {}
local EnableDelayedUpdates = function()
	CreateFrame("Frame", nil, Grid2LayoutFrame):SetScript("OnUpdate", function()
		for bar in pairs(updates) do
			Bar_OnFrameUpdate(bar)
		end
		wipe(updates)
	end)
	EnableDelayedUpdates = Grid2.Dummy
end

-- Warning: This is an overrided indicator:Update() NOT the standard indicator:OnUpdate()
-- We are calling bar:SetValue()/bar:SetMainBarValue() here instead of inside Bar_OnFrameUpdate() because the
-- StatusBar texture is not updated inmmediatly like the additional bars textures, generating a graphic glitch.
local function Bar_Update(self, parent, unit, status)
	if unit then
		local bar = parent[self.name]
		if bar then
			local values = bar.myValues
			if status then
				local index = self.priorities[status]
				local value = status:GetPercent(unit) or 0
				values[index] = value
				if value>0 and index>bar.myMaxIndex then
					bar.myMaxIndex = index -- Optimization to avoid updating bars with zero value
				end
				if index==1 then
				   bar:SetMainBarValue(value)
				end
				if self.backAnchor or bar.myMaxIndex>1 then
					updates[bar] = true
				end
			else -- update due a layout or groupType change not from a status notifying a change
				for i, status in ipairs(self.statuses) do
					values[i] = status:GetPercent(unit) or 0
				end
				bar.myMaxIndex = #self.statuses
				bar:SetMainBarValue(values[1] or 0)
				updates[bar] = true
			end
		end
	end
end
-- }}}

local function Bar_Layout(self, parent)
	local bar = parent[self.name]
	-- main bar
	local width = self.width  or parent.container:GetWidth()
	local height = self.height or parent.container:GetHeight()
	bar:SetParent(parent)
	bar:ClearAllPoints()
	bar:SetOrientation(self.orientation)
	bar:SetReverseFill(self.reverseFill)
	bar:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	bar:SetStatusBarTexture(self.texture)
	local barTexture = bar:GetStatusBarTexture()
	barTexture:SetDrawLayer("ARTWORK", 0)
	barTexture:SetHorizTile(self.horTile)
	barTexture:SetVertTile(self.verTile)
	bar:SetStatusBarTexture(self.texture)
	local color = self.foreColor
	if color then bar:SetStatusBarColor(color.r, color.g, color.b, self.opacity) end
	bar:SetSize(width, height)
	bar:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	bar:SetValue(0)
	bar.SetMainBarValue = self.reverse and Grid2.Dummy or bar.SetValue
	-- extra bars
	local ctextures
    local barCount = #self.bars
	local textures = bar.myTextures or { barTexture }
	for i=1,barCount do
		local setup = self.bars[i]
		local texture = textures[i+1] or bar:CreateTexture()
		texture:Hide()
		texture:ClearAllPoints()
		texture.mySetSize = texture[ self.SetSizeMethod ]
		texture.myReverse = setup.reverse
		texture.myNoOverlap = setup.noOverlap
		texture.myOpacity = setup.opacity
		texture.myHorAdjust = setup.horAdjust
		texture.myVerAdjust = setup.verAdjust
		if texture:GetTexture() then texture:SetTexture(nil) end
		texture:SetTexCoord(0,1,0,1)
		texture:SetTexture(setup.texture, setup.horWrap, setup.verWrap)
		texture:SetHorizTile(setup.horWrap~='CLAMP')
		texture:SetVertTile(setup.verWrap~='CLAMP')
		texture:SetDrawLayer("ARTWORK", setup.sublayer)
		local c = setup.color
		if c then
			texture:SetVertexColor( c.r, c.g, c.b, setup.opacity )
		else
			ctextures = ctextures or {}; ctextures[#ctextures+1] = texture
		end
		if setup.background then
			texture:SetAllPoints(); texture:Show()
		else
			texture:SetSize( width, height )
		end
		textures[i+1] = texture
	end
	for i=barCount+2,#textures do
		textures[i]:Hide()
	end
	bar.myTextures = textures
	bar.myCTextures = ctextures
	bar.myMaxIndex = #self.statuses
	bar:Show()
end

local function Bar_SetOrientation(self, orientation)
	self.dbx.orientation = orientation
	self.orientation = orientation or Grid2Frame.db.profile.orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	local textures = bar.myTextures
	if textures then
		for i=2,#textures do
			textures[i]:Hide()
		end
	end
	bar:Hide()
	bar:SetParent(nil)
	bar:ClearAllPoints()
end

local function Bar_UpdateDB(self)
	local dbx          = self.dbx
	local l            = dbx.location
	local theme        = Grid2Frame.db.profile
	local orientation  = dbx.orientation or theme.orientation
	local backColor    = dbx.backColor
	local texColor     = dbx.textureColor.r and dbx.textureColor
	self.foreColor     = dbx.invertColor and backColor or texColor
	self.orientation   = orientation
	self.SetSizeMethod = SetSizeMethods[orientation]
	self.GetSizeMethod = GetSizeMethods[orientation]
	self.alignPoints   = AlignPoints[orientation][not dbx.reverseFill]
	self.frameLevel    = dbx.level or 1
	self.anchor        = l.point
	self.anchorRel     = l.relPoint
	self.offsetx       = l.x
	self.offsety       = l.y
	self.width         = dbx.width
	self.height        = dbx.height
	self.direction     = dbx.reverseFill and -1 or 1
	self.horizontal    = (orientation == "HORIZONTAL")
	self.reverseFill   = not not dbx.reverseFill
	self.backAnchor    = dbx.backAnchor
	self.reverse       = dbx.reverseMainBar
	self.opacity       = dbx.textureColor.a
	self.texture       = Grid2:MediaFetch("statusbar", dbx.texture or theme.barTexture, "Gradient")
	self.horTile       = dbx.horTile~=nil
	self.verTile       = dbx.verTile~=nil
	self.bars          = {}
	for i,setup in ipairs(dbx) do
		self.bars[i] = {
			reverse   = setup.reverse,
			noOverlap = setup.noOverlap,
			opacity   = setup.color.a,
			color     = setup.color.r and setup.color or self.foreColor,
			texture   = setup.texture and Grid2:MediaFetch("statusbar", setup.texture) or self.texture,
			horWrap   = setup.horTile or 'CLAMP',
			verWrap   = setup.verTile or 'CLAMP',
			horAdjust = setup.horTile=='CLAMP',
			verAdjust = setup.verTile=='CLAMP',
			sublayer  = i,
		}
	end
	if backColor then
	    self.bars[#self.bars+1] = {
			texture = dbx.backTexture and Grid2:MediaFetch("statusbar", dbx.backTexture) or self.texture,
			horWrap = dbx.backHorTile or 'CLAMP',
			verWrap = dbx.backVerTile or 'CLAMP',
			color = dbx.invertColor and texColor or backColor,
			opacity = backColor.a,
			background = not self.backAnchor,
			sublayer = -1,
		}
	end
end

--{{ Bar Color indicator

local function BarColor_OnUpdate(self, parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 0)
	end
end

local function BarColor_SetBarColor(self, parent, r, g, b, a)
	local bar = parent[self.parentName]
	if bar then
		bar:SetStatusBarColor(r, g, b, min(self.opacity,a or 1) )
		local textures = bar.myCTextures
		if textures then
			for i=#textures,1,-1 do
				local tex = textures[i]
				tex:SetVertexColor( r, g, b, min(tex.myOpacity, a) )
			end
		end
	end
end

local function BarColor_SetBarColorInverted(self, parent, r, g, b, a)
	local bar = parent[self.parentName]
	if bar then
		local textures = bar.myTextures
		textures[#textures]:SetVertexColor(r, g, b, a)
	end
end

local function BarColor_UpdateDB(self)
	local dbx = self.dbx
	self.SetBarColor = dbx.invertColor and BarColor_SetBarColorInverted or BarColor_SetBarColor
	self.OnUpdate = dbx.textureColor.r and Grid2.Dummy or BarColor_OnUpdate
	self.opacity = dbx.textureColor.a
end

--- }}}

local function Create(indicatorKey, dbx)
	local Bar = Grid2.indicatorPrototype:new(indicatorKey)
	Bar.dbx = dbx
	-- Hack to caculate status index fast: statuses[priorities[status]] == status
	Bar.sortStatuses    = function (a,b) return Bar.priorities[a] < Bar.priorities[b] end
	Bar.Create          = Bar_CreateHH
	Bar.SetOrientation  = Bar_SetOrientation
	Bar.Disable         = Bar_Disable
	Bar.Layout          = Bar_Layout
	Bar.UpdateDB        = Bar_UpdateDB
	Bar.UpdateO         = Bar_Update -- special case used by multibar and icons indicator
	Grid2:RegisterIndicator(Bar, { "percent" })
	EnableDelayedUpdates()

	local BarColor      = Grid2.indicatorPrototype:new(indicatorKey.."-color")
	BarColor.dbx        = dbx
	BarColor.parentName = indicatorKey
	BarColor.Create     = Grid2.Dummy
	BarColor.Layout     = Grid2.Dummy
	BarColor.UpdateDB   = BarColor_UpdateDB
	Grid2:RegisterIndicator(BarColor, { "color" })
	Bar.sideKick = BarColor

	return Bar, BarColor
end

Grid2.setupFunc["multibar"] = Create

Grid2.setupFunc["multibar-color"] = Grid2.Dummy
