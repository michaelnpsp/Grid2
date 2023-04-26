--[[ PrivateAura indicator ]]--

local Grid2 = Grid2

local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor

if not AddPrivateAuraAnchor then return end

local iconAnchor = { point = "CENTER", relativePoint = "CENTER", offsetX = 0, offsetY = 0 }
local durationAnchor = { point = "BOTTOM", relativePoint = "BOTTOM", offsetX = 0, offsetY = 0 }

local function Icon_Create(self, parent)
	self:Acquire("Frame", parent)
end

local function Icon_OnUpdate(self, parent, unit)
	local f = parent[self.name]
	if f and unit ~= f.auraUnit then
		if f.auraHandle then
			RemovePrivateAuraAnchor(f.auraHandle)
		end
		local anchor = self.auraAnchor
		anchor.unitToken = unit
		anchor.parent = f
		anchor.durationAnchor.relativeTo = f
		local iconInfo = anchor.iconInfo
		iconInfo.iconWidth = f:GetWidth()
		iconInfo.iconHeight = f:GetHeight()
		iconInfo.iconAnchor.relativeTo = f
		f.auraHandle = AddPrivateAuraAnchor(self.auraAnchor)
		f.auraUnit = unit
	end	
end

local function Icon_Layout(self, parent)
	local l = self.dbx.location
	local f = parent[self.name]
	f:Hide()
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(l.point, parent.container, l.relPoint, l.x, l.y)
	f:SetFrameLevel( parent:GetFrameLevel() + self.frameLevel )
	local size = self.iconSize>1 and self.iconSize or self.iconSize * parent:GetHeight()
	f:SetSize(size,size)
	f.auraUnit = nil
	f:Show() 
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
	if f.auraHandle then
		RemovePrivateAuraAnchor( f.auraHandle )
		f.auraHandle = nil
		f.auraUnit = nil
	end
end

local function Icon_UpdateDB(self)
	local dbx = self.dbx
	self.frameLevel = dbx.level or 7
	self.iconSize = dbx.size or Grid2Frame.db.profile.iconSize or 14
	local anchor = self.auraAnchor
	anchor.auraIndex = dbx.auraIndex or 1
	anchor.showCountdownFrame = not dbx.disableCooldown
	anchor.showCountdownNumbers = not dbx.disableCooldownNumbers
end

Grid2.setupFunc["privateaura"]  = function(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.auraAnchor = { iconInfo = { iconAnchor = iconAnchor }, durationAnchor = durationAnchor }	
	indicator.dbx		 = dbx
	indicator.Create     = Icon_Create
	indicator.Layout     = Icon_Layout
	indicator.Disable    = Icon_Disable
	indicator.UpdateDB   = Icon_UpdateDB
	indicator.UpdateO    = Icon_OnUpdate
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end
