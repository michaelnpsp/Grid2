local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Bar = Grid2.indicatorPrototype:new("bar")

function Bar:Create(parent)
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

	parent.BarBG:SetPoint("CENTER")
	parent.Bar:SetPoint("CENTER")
	self:SetOrientation(parent)
end

function Bar:Layout(parent)
	local w, h = parent:GetWidth() - 2, parent:GetHeight() - 2
	parent.BarBG:SetWidth(w)
	parent.BarBG:SetHeight(h)
	parent.Bar:SetWidth(w)
	parent.Bar:SetHeight(h)
end

function Bar:GetBlinkFrame(parent)
	return parent.Bar
end

function Bar:OnUpdate(parent, unit, status)
	if status then
		parent.Bar:SetValue(status:GetPercent(unit))
	else
		parent.Bar:SetValue(1)
	end
end

function Bar:SetOrientation(parent, orientation)
	orientation = orientation or self.db.profile.orientation
	parent.Bar:SetOrientation(orientation)
end

function Bar:SetTexture(parent, texture)
	parent.BarBG:SetTexture(texture)
	parent.Bar:SetStatusBarTexture(texture)
end

Bar.defaultDB = {
	profile = {
		orientation = "VERTICAL",
		texture = "Gradient",
	}
}

Grid2:RegisterIndicator(Bar, { "percent" })

local BarColor = Grid2.indicatorPrototype:new("barcolor")

function BarColor:Create(parent)
end

function BarColor:Layout(parent)
end

function BarColor:OnUpdate(parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 1)
	end
end

function BarColor:SetBarColor(parent, r, g, b, a)
	if self.db.profile.invertBarColor then
		parent.Bar:SetStatusBarColor(r, g, b, a)
		parent.BarBG:SetVertexColor(0, 0, 0, 0)
	else
		parent.Bar:SetStatusBarColor(0, 0, 0, 0.8)
		parent.BarBG:SetVertexColor(r, g, b ,a)
	end
end

BarColor.defaultDB = {
	profile = {
		invertBarColor = false,
	}
}

Grid2:RegisterIndicator(BarColor, { "color" })
