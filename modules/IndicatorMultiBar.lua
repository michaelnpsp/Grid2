--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local min = min
local max = max
local wipe = wipe
local pairs = pairs
local ipairs = ipairs

local AlignPoints = Grid2.AlignPoints
local SetSizeMethods = { HORIZONTAL = "SetWidth", VERTICAL = "SetHeight" }
local GetSizeMethods = { HORIZONTAL = "GetWidth", VERTICAL = "GetHeight" }

local function Bar_CreateHH(self, parent)
	local bar = self:Acquire("Frame", parent)
	bar.myIndicator = self
	bar.myValues = {}
end

local function Bar_OnFrameUpdate(bar)
	local self        = bar.myIndicator
	local horizontal  = self.horizontal
	local points      = self.alignPoints[1]
	local barSize     = bar[self.GetSizeMethod](bar)
	local barSizeDir  = barSize * self.direction
	local myTextures  = bar.myTextures
	local myValues    = bar.myValues
	local valueTo     = 0
	local valueMax    = 0
	local maxIndex    = 0
	local size, offset, offseu
	for i=1,bar.myMaxIndex do
		local texture = myTextures[i]
		local value = myValues[i] or 0
		if value>0 then
			maxIndex = i
			if texture.myLineAdjust then
				offset = texture.myNoOverlap and valueMax or valueTo
				if horizontal then
					texture:SetPoint( points, bar, points, offset*barSizeDir+texture.myLineAdjust, 0)
				else
					texture:SetPoint( points, bar, points, 0, offset*barSizedir+texture.myLineAdjust)
				end
				texture:Show()
			else
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
						texture:SetPoint( points, bar, points, offset*barSizeDir, 0)
						if texture.myHorAdjust then texture:SetTexCoord(0,size,0,1) end
					else
						texture:SetPoint( points, bar, points, 0, offset*barSizeDir)
						if texture.myVerAdjust then texture:SetTexCoord(0,1,1-size,1) end
					end
					texture:mySetSize( size * barSize )
					texture:Show()
				else
					texture:Hide()
				end
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
			local points = self.alignPoints[2]
			texture:SetPoint( points, bar, points, 0, 0)
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
			else -- update due a layout or groupType change not from a status notifying a change
				for i, status in ipairs(self.statuses) do
					values[i] = status:GetPercent(unit) or 0
				end
				bar.myMaxIndex = #self.statuses
			end
			updates[bar] = true
		end
	end
end
-- }}}

local function Bar_Layout(self, parent)
	local bar = parent[self.name]
	local width = self.width  or parent.container:GetWidth()
	local height = self.height or parent.container:GetHeight()
	bar:SetParent(parent)
	bar:ClearAllPoints()
	bar:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	bar:SetSize(width, height)
	bar:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	-- extra bars
	local ctextures
    local barCount = #self.bars
	local textures = bar.myTextures or {}
	for i=1,barCount do
		local setup = self.bars[i]
		local texture = textures[i] or bar:CreateTexture()
		texture:Hide()
		texture:ClearAllPoints()
		texture.mySetSize = texture[ self.SetSizeMethod ]
		texture.myReverse = setup.reverse
		texture.myOpacity = setup.opacity
		texture.myNoOverlap = setup.noOverlap
		texture.myHorAdjust = setup.horAdjust
		texture.myVerAdjust = setup.verAdjust
		if texture:GetTexture() then texture:SetTexture(nil) end
		texture:SetTexCoord(0,1,0,1)
		texture:SetTexture(setup.texture, setup.horWrap, setup.verWrap)
		texture:SetHorizTile(setup.horWrap~='CLAMP')
		texture:SetVertTile(setup.verWrap~='CLAMP')
		texture:SetDrawLayer("ARTWORK", setup.sublayer)
		texture:SetBlendMode(setup.lineSize and 'ADD' or 'BLEND')
		local c = setup.color
		if c then
			texture:SetVertexColor( c.r, c.g, c.b, setup.opacity )
		else
			ctextures = ctextures or {}; ctextures[#ctextures+1] = texture
		end
		if setup.background then
			texture:SetAllPoints()
			texture:Show()
		elseif setup.lineSize then
			texture.myLineAdjust = setup.lineAdjust
			texture:SetWidth ( self.orientation == "HORIZONTAL" and setup.lineSize or width )
			texture:SetHeight( self.orientation ~= "HORIZONTAL" and setup.lineSize or height)
		else
			texture:SetSize(width, height)
		end
		textures[i] = texture
	end
	for i=barCount+1,#textures do
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
		for i=1,#textures do
			textures[i]:Hide()
		end
	end
	bar:Hide()
	bar:SetParent(nil)
	bar:ClearAllPoints()
end

local function Bar_UpdateDB(self)
	local bars         = {}
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
	self.bars          = bars
	local mainBar = {
		reverse   = dbx.reverseMainBar,
		opacity   = dbx.textureColor.a,
		color     = self.foreColor,
		texture   = Grid2:MediaFetch("statusbar", dbx.texture or theme.barTexture, "Gradient"),
		horWrap   = dbx.horTile or 'CLAMP',
		verWrap   = dbx.verTile or 'CLAMP',
		horAdjust = dbx.horTile==nil,
		verAdjust = dbx.verTile==nil,
		sublayer  = 0,
	}
	bars[1] = mainBar
	for i,setup in ipairs(dbx) do
		bars[#bars+1] = {
			reverse   = setup.reverse,
			noOverlap = setup.noOverlap,
			opacity   = setup.color.a,
			color     = setup.color.r and setup.color or self.foreColor,
			texture   = setup.texture and Grid2:MediaFetch("statusbar", setup.texture) or mainBar.texture,
			horWrap   = setup.horTile or 'CLAMP',
			verWrap   = setup.verTile or 'CLAMP',
			horAdjust = setup.horTile=='CLAMP',
			verAdjust = setup.verTile=='CLAMP',
			sublayer  = setup.glowLine and 7 or i,
			lineSize  = setup.glowLine,
			lineAdjust= setup.glowLine and (setup.glowLineAdjust or 0) or nil,
		}
	end
	if backColor then
	    bars[#bars+1] = {
			texture = dbx.backTexture and Grid2:MediaFetch("statusbar", dbx.backTexture) or mainBar.texture,
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
		local textures = bar.myCTextures
		if textures then
			for i=#textures,1,-1 do
				local tex = textures[i]
				tex:SetVertexColor( r, g, b, min(tex.myOpacity, a or 1) )
			end
		end
	end
end

local function BarColor_SetBarColorInverted(self, parent, r, g, b, a)
	local bar = parent[self.parentName]
	if bar then
		local textures = bar.myTextures
		if textures then
			textures[#textures]:SetVertexColor(r, g, b, a)
		end
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
