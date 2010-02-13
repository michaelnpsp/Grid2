local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Icon_Create(self, parent)
	local f = CreateFrame("Frame", nil, parent)
	f:SetBackdrop({
		edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = 2,
		insets = {left = 2, right = 2, top = 2, bottom = 2},
	 })

	local Icon = f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetAllPoints()

	local Cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
	f.Cooldown = Cooldown
	Cooldown:SetAllPoints(f)
	Cooldown:Hide()

	local Text = Cooldown:CreateFontString(nil, "OVERLAY")
	f.Text = Text
	Text:SetAllPoints()
	Text:SetFontObject(GameFontHighlightSmall)
	Text:SetFont(Text:GetFont(), self.dbx.fontSize)
	Text:SetJustifyH("CENTER")
	Text:SetJustifyV("CENTER")
	Text:Hide()

	parent[self.name] = f
end

local function Icon_Layout(self, parent)
	local Icon = parent[self.name]
	Icon:ClearAllPoints()
	Icon:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Icon:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	local iconSize = self.dbx.iconSize
	Icon:SetWidth(iconSize)
	Icon:SetHeight(iconSize)
end

local function Icon_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local GetTime = GetTime
local function Icon_OnUpdate(self, parent, unit, status)
	local Icon = parent[self.name]
	if not status then
		Icon:Hide()
		return
	end
	Icon.Icon:SetTexture(status:GetIcon(unit))
	Icon:Show()
	if status.GetTexCoord then
		Icon.Icon:SetTexCoord(status:GetTexCoord(unit))
	else
		Icon.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	end
	if (status.GetColor) then
		local r, g, b, a = status:GetColor(unit)

		if (status.GetBorder and status:GetBorder(unit) > 0) then
			Icon:SetBackdropBorderColor(r, g, b, a)
		else
			Icon:SetBackdropBorderColor(0, 0, 0, 0)
		end
		Icon.Icon:SetAlpha(a or 1)
	else
		Icon:SetBackdropBorderColor(1, 0, 0)
		Icon.Icon:SetAlpha(1)
	end
	if status.GetCount then
		local count = status:GetCount(unit)
		if not count or count <= 1 then count = "" end
		Icon.Text:SetText(count)
		Icon.Text:Show()
	else
		Icon.Text:Hide()
	end
	if (status.GetExpirationTime and status.GetDuration) then
		local expirationTime, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
		if expirationTime and duration then
			Icon.Cooldown:SetCooldown(expirationTime - duration, duration)
			Icon.Cooldown:Show()
		else
			Icon.Cooldown:Hide()
		end
	else
		Icon.Cooldown:Hide()
	end
end

local function Icon_SetIconSize(self, parent, iconSize)
	local Icon = parent[self.name]
	Icon:SetWidth(iconSize)
	Icon:SetHeight(iconSize)
end

local function Icon_UpdateDB(self, dbx)
	local oldType = self.dbx and self.dbx.type or dbx.type
	local location = Grid2.locations[dbx.location]

	self.frameLevel = dbx.level
	self.anchor = location.point
	self.anchorRel = location.relPoint
	self.offsetx = location.x
	self.offsety = location.y
	self.Create = Icon_Create
	self.GetBlinkFrame = Icon_GetBlinkFrame
	self.Layout = Icon_Layout
	self.OnUpdate = Icon_OnUpdate
	self.SetIconSize = Icon_SetIconSize
	self.UpdateDB = Icon_UpdateDB

	self.dbx = dbx
	
	if (oldType ~= dbx.type) then
		return true
	end
end


local function CreateIcon(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)

	Icon_UpdateDB(indicator, dbx)

	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
