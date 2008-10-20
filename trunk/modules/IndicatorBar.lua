local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Bar_Create(self, parent)
	local media = LibStub("LibSharedMedia-3.0", true)
	local texture = media and media:Fetch("statusbar", self.db.profile.texture) or "Interface\\Addons\\Grid2\\gradient32x32"

	parent.BarBG = parent:CreateTexture()
	parent.BarBG:SetTexture(texture)

	-- create bar
	parent.Bar = CreateFrame("StatusBar", nil, parent)
	parent.Bar:SetStatusBarTexture(texture)
	parent.Bar:SetMinMaxValues(0, 1)
	parent.Bar:SetValue(1)
	parent.Bar:SetStatusBarColor(0,0,0,0.8)

	parent.BarBG:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	parent.Bar:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	self:SetOrientation(parent)
end

local function Bar_Layout(self, parent)
	local inset = self.db.profile.inset or 2
	local w, h = parent:GetWidth() - inset, parent:GetHeight() - inset
	parent.BarBG:SetWidth(w)
	parent.BarBG:SetHeight(h)
	parent.Bar:SetWidth(w)
	parent.Bar:SetHeight(h)
end

local function Bar_GetBlinkFrame(self, parent)
	return parent.Bar
end

local function Bar_OnUpdate(self, parent, unit, status)
	if status then
		parent.Bar:SetValue(status:GetPercent(unit))
	else
		parent.Bar:SetValue(1)
	end
end

local function Bar_SetOrientation(self, parent, orientation)
	orientation = orientation or self.db.profile.orientation
	parent.Bar:SetOrientation(orientation)
end

local function Bar_SetTexture(self, parent, texture)
	parent.BarBG:SetTexture(texture)
	parent.Bar:SetStatusBarTexture(texture)
end

local Bar_defaultDB = {
	profile = {
		orientation = "VERTICAL",
		texture = "Gradient",
		inset = 2
	}
}

local function BarColor_Create(self, parent)
end

local function BarColor_Layout(self, parent)
end

local function BarColor_OnUpdate(self, parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 1)
	end
end

local function BarColor_SetBarColor(self, parent, r, g, b, a)
	if self.db.profile.invertBarColor then
		parent.Bar:SetStatusBarColor(r, g, b, a)
		parent.BarBG:SetVertexColor(0, 0, 0, 0)
	else
		parent.Bar:SetStatusBarColor(0, 0, 0, 0.8)
		parent.BarBG:SetVertexColor(r, g, b ,a)
	end
end

local BarColor_defaultDB = {
	profile = {
		invertBarColor = false,
	}
}

function Grid2:CreateBarIndicator(name, anchor, anchorRel, offsetx, offsety)
	name = "bar-"..name

	local Bar = self.indicatorPrototype:new(name)
	Bar.anchor = anchor
	Bar.anchorRel = anchorRel
	Bar.offsetx = offsetx
	Bar.offsety = offsety
	Bar.Create = Bar_Create
	Bar.Layout = Bar_Layout
	Bar.GetBlinkFrame = Bar_GetBlinkFrame
	Bar.OnUpdate = Bar_OnUpdate
	Bar.SetOrientation = Bar_SetOrientation
	Bar.SetTexture = Bar_SetTexture
	Bar.defaultDB = Bar_defaultDB

	self:RegisterIndicator(Bar, { "percent" })

	local BarColor = self.indicatorPrototype:new(name.."-color")
	BarColor.Create = BarColor_Create
	BarColor.Layout = BarColor_Layout
	BarColor.OnUpdate = BarColor_OnUpdate
	BarColor.SetBarColor = BarColor_SetBarColor
	BarColor.defaultDB = BarColor_defaultDB

	self:RegisterIndicator(BarColor, { "color" })

	return Bar, BarColor
end

Grid2:CreateBarIndicator("health", "CENTER")
Grid2:CreateBarIndicator("heals", "CENTER")
