if not Grid2.secretsEnabled then return end

--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local min = min
local max = max
local pairs = pairs
local ipairs = ipairs

local OpositePoint = { LEFT = 'RIGHT', RIGHT = 'LEFT', TOP = 'BOTTOM', BOTTOM = 'TOP' }

local AlignPoints = {
	HORIZONTAL = {
		[true]  = "LEFT", -- normal Fill
		[false] = "RIGHT", -- reverse Fill
	},
	VERTICAL   = {
		[true]  = "BOTTOM", -- normal Fill
		[false] = "TOP", -- reverse Fill
	}
}

local function Bar_CreateHH(self, parent)
	local bar = self:Acquire("Frame", parent)
	bar:SetClipsChildren(true)
end

-- sets bar value using status data
local function SetBarStatusValue(self, unit, frame, status)
	local index = self.priorities[status]
	local bar   = frame.myTextures[index]
	if bar.glowLine then
		bar:SetValue(status:IsActive(unit) and 1 or 0)
	elseif status.GetValueMinMax then
		local value, min, max = status:GetValueMinMax(unit)
		bar:SetMinMaxValues(min, max)
		bar:SetValue(value)
	else
		bar:SetValue( status:GetPercent(unit) or 0 )
	end
end

-- Warning: This is an overrided indicator:Update() NOT the standard indicator:OnUpdate()
local function Bar_Update(self, parent, unit, status)
	if unit then
		local frame = parent[self.name]
		if frame then
			if status then
				SetBarStatusValue(self, unit, frame, status)
			else -- update due a layout or groupType change not from a status notifying a change
				for i, status in ipairs(self.statuses) do
					SetBarStatusValue(self, unit, frame, status)
				end
			end
		end
	end
end
-- }}}

local function Bar_Layout(self, parent)
	local frame = parent[self.name]
	local width = self.width  or parent.container:GetWidth()
	local height = self.height or parent.container:GetHeight()
	local frameLevel = parent:GetFrameLevel() + self.frameLevel
	local alignPoints = self.alignPoints
	frame:SetParent(parent)
	frame:ClearAllPoints()
	frame:SetFrameLevel(frameLevel)
	frame:SetSize(width, height)
	frame:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	-- bars
	local prevTex = frame
	local prevPnt = self.alignPoint
    local barCount = #self.bars
	local textures = frame.myTextures or {}
	local ctextures
	for i=1,barCount do
		local setup = self.bars[i]
		local texture = textures[i] or CreateFrame("StatusBar", nil, frame)
		texture.glowLine = setup.lineSize
		texture.myReverse = setup.reverse  -- texture is a StatusBar frame not a texture
		texture.myOpacity = setup.opacity
		texture.myNoOverlap = setup.noOverlap
		texture.myHorAdjust = setup.horAdjust
		texture.myVerAdjust = setup.verAdjust
		texture:Hide()
		texture:ClearAllPoints()
		texture:SetValue(0)
		texture:SetMinMaxValues(0, 1)
		texture:SetFrameLevel(frameLevel)
		texture:SetOrientation(self.orientation)
		texture:SetReverseFill(setup.reverse)
		texture:SetStatusBarTexture(setup.texture, "ARTWORK", setup.sublayer)
		local textureReal = texture:GetStatusBarTexture()
		-- texture:SetTexCoord(0,1,0,1)
		-- texture:SetTexture(setup.texture, setup.horWrap, setup.verWrap)
		textureReal:SetHorizTile(setup.horWrap~='CLAMP')
		textureReal:SetVertTile(setup.verWrap~='CLAMP')
		textureReal:SetBlendMode(setup.lineBlend or 'BLEND')
		local c = setup.color
		if c then
			texture:SetStatusBarColor( c.r, c.g, c.b, setup.opacity )
		else
			ctextures = ctextures or {}; ctextures[#ctextures+1] = texture
		end
		if setup.background then
			texture:SetValue(1)
			texture:SetAllPoints()
		elseif setup.lineSize then
			if self.orientation == "HORIZONTAL" then
				texture:SetSize( setup.lineSize, height )
				texture:SetPoint( setup.pointFrom, prevTex, prevPnt, setup.lineAdjust, 0 )
			else
				texture:SetSize( width, setup.lineSize )
				texture:SetPoint( setup.pointFrom, prevTex, prevPnt, 0, setup.lineAdjust )
			end
		else
			texture:SetSize( width, height )
			texture:SetPoint( setup.pointFrom, prevTex, prevPnt )
			prevTex = textureReal
			prevPnt = setup.pointTo
		end
		textures[i] = texture
		texture:Show()
	end
	for i=barCount+1,#textures do
		textures[i]:Hide()
		textures[i]:ClearAllPoints()
	end
	frame.myTextures = textures
	frame.myCTextures = ctextures
	frame.myMaxIndex = #self.statuses
	frame:Show()
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
	local alignPoint   = AlignPoints[orientation][not dbx.reverseFill]
	self.foreColor     = dbx.invertColor and backColor or texColor
	self.orientation   = orientation
	self.alignPoint    = alignPoint
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
		reverse  = not not dbx.reverseMainBar,
		pointFrom = self.reverseFill and OpositePoint[alignPoint] or alignPoint,
		pointTo   = self.reverseFill and alignPoint or OpositePoint[alignPoint],
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
			reverse  = not not setup.reverse,
			pointFrom = setup.reverse and OpositePoint[alignPoint] or alignPoint,
			pointTo   = setup.reverse and alignPoint or OpositePoint[alignPoint],
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
			lineBlend = setup.glowLine and (setup.blendMode or 'ADD') or nil,
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
	local frame = parent[self.parentName]
	if frame then
		local textures = frame.myCTextures
		if textures then
			for i=#textures,1,-1 do
				local bar = textures[i]
				bar:SetStatusBarColor( r, g, b, min(bar.myOpacity, a or 1) )
			end
		end
	end
end

local function BarColor_SetBarColorInverted(self, parent, r, g, b, a)
	local frame = parent[self.parentName]
	if frame then
		local textures = frame.myTextures
		if textures then
			textures[#textures]:SetStatusBarColor(r, g, b, a)
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
