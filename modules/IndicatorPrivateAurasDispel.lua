-- Overlay to display dispels, including dispellable private auras

local Grid2 = Grid2
local pcall = pcall
local strfind = strfind
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor
local RegisterRosterUnitEvent = Grid2.RegisterRosterUnitEvent
local UnregisterRosterUnitEvent = Grid2.UnregisterRosterUnitEvent

local auraAnchorTemplate = {
	auraIndex = 1,
	isContainer = true,
	showCountdownFrame = false,
	showCountdownNumbers = false,
}

local function Overlay_UpdateVisibility(f, _, unit)
	if GetAuraDataByIndex(unit, 1, "HARMFUL|RAID_PLAYER_DISPELLABLE") then
		f:SetAlpha(0)
	else
		f:SetAlpha(f.myIndicator.opacity)
	end
end

local function Overlay_RemoveFrameAnchor(f)
	if f then
		if f.auraHandle then
			RemovePrivateAuraAnchor(f.auraHandle)
			f.auraHandle = nil
			f.auraUnit = nil
		end
		if f.myIndicator then
			UnregisterRosterUnitEvent(f, "UNIT_AURA")
			f.myIndicator = nil
		end
	end
end

local function Overlay_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f.auraHandle = nil
	f.auraUnit = nil
end

local function Overlay_Release(self, parent)
	Overlay_RemoveFrameAnchor(parent[self.name])
end

local function Overlay_Update(self, parent, unit)
	local f = parent[self.name]
	if f and unit ~= f.auraUnit then
		Overlay_RemoveFrameAnchor(f)
		if unit and not Grid2:UnitIsPet(unit) then
			auraAnchorTemplate.parent = f
			auraAnchorTemplate.unitToken = unit
			f:SetAttribute("group-type", strfind(unit, 'party') and 4 or 5)
			f:SetAttribute("update-settings", true)
			local ok, handle = pcall(function() return AddPrivateAuraAnchor(auraAnchorTemplate) end)
			if ok then
				f.auraHandle =  handle
			else
				Grid2:Debug("Error AddingPrivateAuraAnchor in IndicatorPrivateAurasDispells.lua:", handle)
			end
			if self.hideNormal then
				f.myIndicator = self
				RegisterRosterUnitEvent(f, "UNIT_AURA", Overlay_UpdateVisibility)
			end
		end
		f.auraUnit = unit
	end
end

local function Overlay_Layout(self, parent)
	local f = parent[self.name]
	Overlay_RemoveFrameAnchor(f)
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", -self.sizeAdjust, self.sizeAdjust)
	f:SetPoint("BOTTOMRIGHT", self.sizeAdjust, -self.sizeAdjust)
	f:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel )
	f:SetAlpha(self.opacity)
	f:SetAttribute("max-buffs", 0)
	f:SetAttribute("max-debuffs", 0)
	f:SetAttribute("max-dispel-debuffs", 1)
	f:SetAttribute("ignore-buffs", true)
	f:SetAttribute("ignore-debuffs", true)
	f:SetAttribute("ignore-dispel-debuffs", true)
	f:SetAttribute("dispel-indicator-option", self.dispelType)
	f:SetAttribute("show-dispel-indicator-overlay", true)
	f:SetAttribute("always-hide-duration", true)
	f:SetAttribute("set-aura-size-to-icon-size", true)
	f:SetAttribute("suppress-dispel-border-icons", false)
	f:SetAttribute("icon-size", 12)
	f:SetAttribute("power-bar-used-height", 0)
	f:SetAttribute("aura-organization-type", self.orientation)
	f:Show()
end

local function Overlay_Disable(self, parent)
	local f = parent[self.name]
	Overlay_RemoveFrameAnchor(f)
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
end

local function Overlay_UpdateDB(self)
	local dbx = self.dbx
	self.frameLevel = dbx.level or 7
	self.dispelType = dbx.displayAllDispells and 2 or 1 -- 1=dispellableByMe 2=any dispellable debuff
	self.sizeAdjust = dbx.sizeAdjust or 0
	self.opacity    = dbx.opacity or 1
	self.orientation= dbx.orientation or 0 -- 0=top>bottom, 1=bottom>top, 2=left>right
	self.hideNormal = dbx.hideNormalDispells
end

local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Overlay_Create
	indicator.Layout = Overlay_Layout
	indicator.Disable = Overlay_Disable
	indicator.Release = Overlay_Release
	indicator.UpdateDB = Overlay_UpdateDB
	indicator.UpdateO = Overlay_Update
	Grid2:RegisterIndicator(indicator, { "privateaurasdispel" })
	return indicator
end

Grid2.setupFunc["privateaurasdispel"] = Create
