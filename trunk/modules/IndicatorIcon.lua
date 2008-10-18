local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Icon_Create(self, parent)
	local f = CreateFrame("Frame", nil, parent)
	f:SetAllPoints()
	f:SetFrameLevel(parent:GetFrameLevel() +  4)
	local Icon = f:CreateTexture(nil, "OVERLAY")
	local iconSize = self.db.profile.iconSize
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetWidth(iconSize)
	Icon:SetHeight(iconSize)
	parent[self.name] = Icon
end

local function Icon_Layout(self, parent)
	local Icon = parent[self.name]
	Icon:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	local iconSize = self.db.profile.iconSize
	Icon:SetWidth(iconSize)
	Icon:SetHeight(iconSize)
end

local function Icon_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Icon_OnUpdate(self, parent, unit, status)
	local Icon = parent[self.name]
	if status then
		Icon:SetTexture(status:GetIcon(unit))
		Icon:Show()
	else
		Icon:Hide()
	end
end

local function Icon_SetIconSize(self, parent, size)
	local Icon = parent[self.name]
	Icon:SetWidth(iconSize)
	Icon:SetHeight(iconSize)
end

local Icon_defaultDB = {
	profile = {
		iconSize = 16,
	}
}

local function CreateIconIndicator(name, anchor, anchorRel, offsetx, offsety)

	name = "icon-"..name 
	local Icon = Grid2.indicatorPrototype:new(name)

	Icon.anchor = anchor
	Icon.anchorRel = anchorRel
	Icon.offsetx = offsetx
	Icon.offsety = offsety
	Icon.Create = Icon_Create
	Icon.GetBlinkFrame = Icon_GetBlinkFrame
	Icon.Layout = Icon_Layout
	Icon.OnUpdate = Icon_OnUpdate
	Icon.SetIconSize = Icon_SetIconSize
	Icon.defaultDB = Icon_defaultDB

	Grid2:RegisterIndicator(Icon, { "icon" })
	return Icon
end

Grid2.CreateIconIndicator = CreateIconIndicator

CreateIconIndicator("center", "CENTER", "CENTER", 0, 0)
