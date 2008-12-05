local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Corner_Create(self, parent)
	local Corner = CreateFrame("Frame", nil, parent)
	local cornerSize = self.db.profile.cornerSize
	Corner:SetWidth(cornerSize) -- @FIXME merge the sizes ?
	Corner:SetHeight(cornerSize)
	Corner:SetBackdrop({
		bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	Corner:SetBackdropBorderColor(0,0,0,1)
	Corner:SetBackdropColor(1,1,1,1)
	Corner:SetFrameLevel(5)
	parent[self.name] = Corner
end

local function Corner_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Corner_Layout(self, parent)
	local Corner = parent[self.name]
	Corner:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	local cornerSize = self.db.profile.cornerSize
	Corner:SetWidth(cornerSize) -- @FIXME merge the sizes ?
	Corner:SetHeight(cornerSize)
end

local function Corner_OnUpdate(self, parent, unit, status)
	local Corner = parent[self.name]
	if status then
		Corner:SetBackdropColor(status:GetColor(unit))
		Corner:Show()
	else
		Corner:Hide()
	end
end

local function Corner_SetCornerSize(self, parent, size)
	local Corner = parent[self.name]
	Corner:SetWidth(size)
	Corner:SetHeight(size)
end

local Corner_defaultDB = {
	profile = {
		cornerSize = 5,
	}
}

function Grid2:CreateCornerIndicator(name, anchor, anchorRel, offsetx, offsety)
	name = "corner-"..name
	local Corner = self.indicatorPrototype:new(name)

	Corner.anchor = anchor
	Corner.anchorRel = anchorRel
	Corner.offsetx = offsetx
	Corner.offsety = offsety
	Corner.Create = Corner_Create
	Corner.GetBlinkFrame = Corner_GetBlinkFrame
	Corner.Layout = Corner_Layout
	Corner.OnUpdate = Corner_OnUpdate
	Corner.SetCornerSize = Corner_SetCornerSize
	Corner.defaultDB = Corner_defaultDB

	self:RegisterIndicator(Corner, { "color" })

	return Corner
end
