local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Icon_Create(self, parent)
	local f = parent[self.name] or CreateFrame("Frame", nil, parent)
	local borderSize = self.dbx.borderSize
	if (borderSize) then
		f:SetBackdrop({
			edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = borderSize,
			insets = {left = borderSize, right = borderSize, top = borderSize, bottom = borderSize},
		})
	else
		f:SetBackdrop({
			edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = 2,
			insets = {left = 2, right = 2, top = 2, bottom = 2},
		})
	end

	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetAllPoints()

	local Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
	f.Cooldown = Cooldown
	Cooldown:SetAllPoints(f)
	Cooldown:SetReverse(self.dbx.reverseCooldown)
	Cooldown:Hide()

	local CooldownText = f.CooldownText or Cooldown:CreateFontString(nil, "OVERLAY")
	f.CooldownText = CooldownText
	CooldownText:SetAllPoints()
	CooldownText:SetFontObject(GameFontHighlightSmall)
	CooldownText:SetFont(CooldownText:GetFont(), self.dbx.fontSize)
	CooldownText:SetJustifyH("CENTER")
	CooldownText:SetJustifyV("CENTER")
	CooldownText:Hide()

	parent[self.name] = f
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
		local borderSize = self.dbx.borderSize

		if (status.GetBorder and status:GetBorder(unit) > 0) then
			Icon:SetBackdropBorderColor(r, g, b, a)
		elseif (borderSize) then
			local c = self.dbx.color1
			if (c) then
				Icon:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
			end
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
		Icon.CooldownText:SetText(count)
		Icon.CooldownText:Show()
	else
		Icon.CooldownText:Hide()
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

local function Icon_SetIndicatorSize(self, parent, size)
	local f = parent[self.name]
	f:SetWidth(size)
	f:SetHeight(size)
end

local function Icon_SetBorderSize(self, parent, borderSize)
	local f = parent[self.name]
	local backdrop = f:GetBackdrop()

	local Icon = f.Icon
	if (borderSize) then
		Icon:SetPoint("TOPLEFT", f ,"TOPLEFT", borderSize, -1 * borderSize)
		Icon:SetPoint("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -1 * borderSize, borderSize)
		backdrop.edgeSize = borderSize
	else
		Icon:SetAllPoints(f)
		backdrop.edgeSize = 2
		borderSize = 2
	end
	backdrop.insets.left = borderSize
	backdrop.insets.right = borderSize
	backdrop.insets.top = borderSize
	backdrop.insets.bottom = borderSize

	local r, g, b, a = f:GetBackdropBorderColor()

	f:SetBackdrop(backdrop)
	f:SetBackdropBorderColor(r, g, b, a)
end

local function Icon_Layout(self, parent)
	local Icon = parent[self.name]
	Icon:ClearAllPoints()
	Icon:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Icon:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)

	local borderSize = self.dbx.borderSize
	Icon_SetBorderSize(self, parent, borderSize)

	local size = self.dbx.size
	Icon:SetWidth(size)
	Icon:SetHeight(size)
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	local Icon = f.Icon
	Icon:Hide()
	local Cooldown = f.Cooldown
	Cooldown:Hide()
	local CooldownText = f.CooldownText
	CooldownText:Hide()

	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
	self.SetIndicatorSize = nil
	self.SetBorderSize = nil
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
	self.SetIndicatorSize = Icon_SetIndicatorSize
	self.SetBorderSize = Icon_SetBorderSize
	self.Disable = Icon_Disable
	self.UpdateDB = Icon_UpdateDB

	self.dbx = dbx
end


local function CreateIcon(indicatorKey, dbx)
	local existingIndicator = Grid2.indicators[indicatorKey]
	local indicator = existingIndicator or Grid2.indicatorPrototype:new(indicatorKey)
-- print("CreateIcon", existingIndicator, indicator)
	Icon_UpdateDB(indicator, dbx)

	-- if (not existingIndicator) then
		Grid2:RegisterIndicator(indicator, { "icon" })
	-- end
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
