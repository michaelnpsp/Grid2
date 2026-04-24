-- Overlay to display dispells, including dispellable private auras

local Grid2 = Grid2
local pcall = pcall
local strfind = strfind
local InCombatLockdown = InCombatLockdown
local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor

local auraAnchorTemplate = {
	auraIndex = 1,
	isContainer = true,
	showCountdownFrame = false,
	showCountdownNumbers = false,
}

local function RemoveFrameAnchor(f)
	if f and f.auraHandle then
		RemovePrivateAuraAnchor(f.auraHandle)
		f.auraHandle = nil
		f.auraUnit = nil
	end
end

local function Overlay_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f.auraHandle = nil
	f.auraUnit = nil
end

local function Overlay_Release(self, parent)
	RemoveFrameAnchor(parent[self.name])
end

local function Overlay_Update(self, parent, unit)
	local f = parent[self.name]
	if f and unit ~= f.auraUnit then
		RemoveFrameAnchor(f)
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
		end
		f.auraUnit = unit
	end
end

local function Overlay_Layout(self, parent)
	local f = parent[self.name]
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetAllPoints()
	f:SetFrameLevel(parent:GetFrameLevel() + (self.dbx.level or 7) )
	f:SetAttribute("max-buffs", 0)
	f:SetAttribute("max-debuffs", 0)
	f:SetAttribute("max-dispel-debuffs", 1)
	f:SetAttribute("ignore-buffs", true)
	f:SetAttribute("ignore-debuffs", true)
	f:SetAttribute("ignore-dispel-debuffs", true)
	f:SetAttribute("dispel-indicator-option", self.dbx.displayAllDispells and 2 or 1) -- 1=dispellableByMe 2=any dispellable debuff
	f:SetAttribute("show-dispel-indicator-overlay", true)
	f:SetAttribute("always-hide-duration", true)
	f:SetAttribute("set-aura-size-to-icon-size", true)
	f:SetAttribute("suppress-dispel-border-icons", false)
	f:SetAttribute("icon-size", 12)
	f:SetAttribute("power-bar-used-height", 0)
	f:SetAttribute("aura-organization-type", 0)
	f:Show()
end

local function Overlay_Disable(self, parent)
	local f = parent[self.name]
	RemoveFrameAnchor(f)
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
end

local function Overlay_UpdateDB(self)
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
	Grid2:RegisterIndicator(indicator, { "privateaurasdispells" })
	return indicator
end

Grid2.setupFunc["privateaurasdispells"] = Create
