local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Bar_Create(self, parent)
	local media = LibStub("LibSharedMedia-3.0", true)
	local texture = media and media:Fetch("statusbar", self.dbx.texture) or "Interface\\Addons\\Grid2\\gradient32x32"


	local BarBG = parent:CreateTexture()
	parent[self.nameBG] = BarBG
	BarBG:SetTexture(texture)

	-- create bar
	local Bar = CreateFrame("StatusBar", nil, parent)
	parent[self.nameFG] = Bar
	Bar:SetStatusBarTexture(texture)
	Bar:SetMinMaxValues(0, 1)
	Bar:SetValue(1)
	Bar:SetStatusBarColor(0,0,0,0.8)

	BarBG:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	Bar:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	self:SetOrientation(parent)
end

local healthBarName = "health"
local healthBarBGName = "health-color"
local healsBarName = "heals"
local function Bar_CreateHH(self, parent)
	local media = LibStub("LibSharedMedia-3.0", true)
	local texture = media and media:Fetch("statusbar", self.dbx.texture) or "Interface\\Addons\\Grid2\\gradient32x32"

	local orientation = Grid2Frame.db.profile.orientation

	-- create bar BG (which users will think is the real bar, as it is the one that has a shiny color)
	-- this is necessary as there's no other way to implement status bars that grow in the other direction than normal
	local healthBarBG = parent[healthBarBGName] or parent:CreateTexture()
	parent[healthBarBGName] = healthBarBG
	healthBarBG:SetTexture(texture)
	healthBarBG:SetVertexColor(0, 0, 0, 1)
	healthBarBG:SetPoint("CENTER", parent, "CENTER")
	-- healthBarBG:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)

	-- create healing bar
	local healsBar = parent[healsBarName] or CreateFrame("StatusBar", nil, parent)
	parent[healsBarName] = healsBar
	healsBar:SetOrientation(orientation)
	healsBar:SetStatusBarColor(0,0,0,0)
	healsBar:SetStatusBarTexture(texture)
	healsBar:SetMinMaxValues(0, 1)
	healsBar:SetValue(0)
	healsBar:SetPoint("TOPLEFT", healthBarBG, "TOPLEFT")
	healsBar:SetPoint("BOTTOMRIGHT", healthBarBG, "BOTTOMRIGHT")

	-- create health bar
	local healthBar = parent[healthBarName] or CreateFrame("StatusBar", nil, parent)
	parent[healthBarName] = healthBar
	healthBar:SetOrientation(orientation)
	healthBar:SetStatusBarColor(0,0,0,1)
	healthBar:SetStatusBarTexture(texture)
	healthBar:SetMinMaxValues(0, 1)
	healthBar:SetValue(1)
	healthBar:SetPoint("TOPLEFT", healsBar, "TOPLEFT")
	healthBar:SetPoint("BOTTOMRIGHT", healsBar, "BOTTOMRIGHT")
	
	if (self.name == healthBarName) then
		self.nameFG = healthBarName
	else
		self.nameFG = healsBarName
	end
	self.nameBG = healthBarBGName
-- print("Bar_CreateHH", self.name, self.nameBG, parent[self.nameBG])
end

local function Bar_Layout(self, parent)
	local frameBorder = Grid2Frame.db.profile.frameBorder * 2
	local inset = frameBorder
	local w, h = parent:GetWidth() - inset, parent:GetHeight() - inset
	local Bar, BarBG = parent[self.nameFG], parent[self.nameBG]
	-- Bar:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
-- print(self.name, parent:GetFrameLevel() + self.frameLevel)
	BarBG:SetWidth(w)
	BarBG:SetHeight(h)
	Bar:SetWidth(w)
	Bar:SetHeight(h)
end

local function Bar_GetBlinkFrame(self, parent)
	return parent[self.nameFG]
end

local function Bar_OnUpdate(self, parent, unit, status)
	local Bar = parent[self.nameFG]
	if status then
		Bar:SetValue(status:GetPercent(unit))
	else
		Bar:SetValue(0)
	end
end

local function Bar_SetOrientation(self, parent, orientation)
	orientation = orientation or Grid2Frame.db.profile.orientation
	parent[self.nameFG]:SetOrientation(orientation)
end

local function Bar_SetTexture(self, parent, texture)
	parent[self.nameBG]:SetTexture(texture)
	parent[self.nameFG]:SetStatusBarTexture(texture)
end

local function BarColor_Create(self, parent)
end

local function BarColor_Layout(self, parent)
end

local function BarColor_OnUpdate(self, parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 0)
		--local c = self.dbx.color1
		--self:SetBarColor(parent, c.r, c.g, c.b, 1)
	end
end

local function BarColor_SetBarColor(self, parent, r, g, b, a)
	local Bar, BarBG = parent[self.nameFG], parent[self.nameBG]
	--local c = self.dbx.color1
	if (Grid2Frame.db.profile.invertBarColor) then
		--Bar:SetStatusBarColor(c.r, c.g, c.b, 0.8)
		Bar:SetStatusBarColor(0, 0, 0, 1)
		BarBG:SetVertexColor(r, g, b, a)
	else
		Bar:SetStatusBarColor(r, g, b, a)
		--BarBG:SetVertexColor(c.r, c.g, c.b, 0)
		BarBG:SetVertexColor(0, 0, 0, 0)
	end
end

local function BarColor_SetBarColorHeals(self, parent, r, g, b, a)
	local Bar, BarBG = parent[self.nameFG], parent[self.nameBG]
	local c = self.dbx.color1
	Bar:SetStatusBarColor(r, g, b, a)
end

local function Create(indicatorKey, dbx)
	local colorKey = indicatorKey .. "-color"
	local location = Grid2.locations[dbx.location]

	local Bar = Grid2.indicatorPrototype:new(indicatorKey)
	Bar.nameFG = indicatorKey
	-- Bar.nameBG = colorKey
	Bar.nameBG = "health-color"

	Bar.frameLevel = dbx.level
	Bar.anchor = location.point
	Bar.anchorRel = location.relPoint
	Bar.offsetx = location.x
	Bar.offsety = location.y
	Bar.Create = Bar_CreateHH
	Bar.Layout = Bar_Layout
	Bar.GetBlinkFrame = Bar_GetBlinkFrame
	Bar.OnUpdate = Bar_OnUpdate
	Bar.SetOrientation = Bar_SetOrientation
	Bar.SetTexture = Bar_SetTexture

	Bar.dbx = dbx
	Grid2:RegisterIndicator(Bar, { "percent" })

	local BarColor = Grid2.indicatorPrototype:new(colorKey)
	BarColor.nameFG = Bar.nameFG
	BarColor.nameBG = Bar.nameBG
	BarColor.Create = BarColor_Create
	BarColor.Layout = BarColor_Layout
	BarColor.OnUpdate = BarColor_OnUpdate
	BarColor.SetBarColor = BarColor_SetBarColor
	BarColor.barKey = indicatorKey

	BarColor.dbx = dbx
	Grid2:RegisterIndicator(BarColor, { "color" })

	return Bar, BarColor
end

Grid2.setupFunc["bar"] = Create

function Grid2:InterleaveHealsHealth(frame)
	local healthBar = Grid2.indicators["health"]
	local healsBar = Grid2.indicators["heals"]
	local Bar = frame[healthBar.nameFG]
	local BarBG = frame[healthBar.nameBG]
	local HealsBar = frame[healsBar.nameFG]
	local HealsBarBG = frame[healsBar.nameBG]

	local baseLevel = frame:GetFrameLevel()
	HealsBar:SetFrameLevel(baseLevel + 1)
	Bar:SetFrameLevel(baseLevel + 2)

	local healsBarColor = Grid2.indicators["heals-color"]
	healsBarColor.SetBarColor = BarColor_SetBarColorHeals
end

--ToDo: Is there a better way to handle this dual indicator creation?
local function CreateColor(indicatorKey, dbx)
end
Grid2.setupFunc["bar-color"] = CreateColor

