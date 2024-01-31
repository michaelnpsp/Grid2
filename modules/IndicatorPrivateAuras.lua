--[[ PrivateAuras indicator ]]--

local Grid2 = Grid2

local wipe = wipe
local strmatch = strmatch

if not C_UnitAuras then return end
local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor
if not AddPrivateAuraAnchor then return end

local function ClearFrameAuraAnchors(f)
	local auraHandles = f.auraHandles
	for i=1,#auraHandles do
		RemovePrivateAuraAnchor(auraHandles[i])
	end
	return wipe(auraHandles)
end

local function Icon_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f.auraHandles = {}
end

local function Icon_Update(self, parent, unit)
	local f = parent[self.name]
	if f and unit ~= f.auraUnit then
		local auraHandles = ClearFrameAuraAnchors(f)
		local iconAnchor = self.iconAnchor
		iconAnchor.relativeTo = f
		iconAnchor.offsetX = 0
		iconAnchor.offsetY = 0
		local auraAnchor = self.auraAnchor
		auraAnchor.parent = f
		auraAnchor.unitToken = unit
		auraAnchor.auraIndex = self.auraIndex
		auraAnchor.iconInfo.iconWidth = f.iconSize
		auraAnchor.iconInfo.iconHeight = f.iconSize
		for i=1,self.maxIcons do
			auraHandles[i] = AddPrivateAuraAnchor(auraAnchor)
			iconAnchor.offsetX = iconAnchor.offsetX + self.sumx
			iconAnchor.offsetY = iconAnchor.offsetY + self.sumy
			auraAnchor.auraIndex = auraAnchor.auraIndex + 1
		end
		f.auraUnit = unit
	end
end

local function Icon_Layout(self, parent)
	local dbx = self.dbx
	local l = dbx.location
	local f = parent[self.name]
	local iconSize = self.iconSize>1 and self.iconSize or self.iconSize * parent:GetHeight()
	local sizeFull = iconSize + (dbx.iconSpacing or 1)
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint( l.point, parent.container, l.relPoint, l.x, l.y )
	f:SetFrameLevel( parent:GetFrameLevel() + (dbx.level or 1) )
	f:SetSize( sizeFull*self.colCount, sizeFull*self.rowCount )
	self.sumx = sizeFull * self.horMult
	self.sumy = sizeFull * self.verMult
	f.iconSize = iconSize
	f.auraUnit = nil
	f:Show()
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	ClearFrameAuraAnchors(f)
	f.auraUnit = nil
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
end

local function Icon_UpdateDB(self)
	local dbx = self.dbx
	self.maxIcons = dbx.maxIcons or 4
	self.auraIndex= dbx.auraIndex or 1
	self.iconSize = dbx.iconSize or Grid2Frame.db.profile.iconSize or 14
	self.auraAnchor.showCountdownFrame = not dbx.disableCooldown
	self.auraAnchor.showCountdownNumbers = not dbx.disableCooldownNumbers
	local anchor = self.iconAnchor
	if dbx.orientation=='VERTICAL' then
		anchor.point = strmatch(dbx.location.point,'BOTTOM') or 'TOP'
		anchor.relativePoint = anchor.point
		self.horMult = 0
		self.verMult = anchor.point=='TOP' and -1 or 1
		self.colCount = 1
		self.rowCount = self.maxIcons
	else
		anchor.point = strmatch(dbx.location.point,'RIGHT') or 'LEFT'
		anchor.relativePoint = anchor.point
		self.horMult = anchor.point=='LEFT' and 1 or -1
		self.verMult = 0
		self.colCount = self.maxIcons
		self.rowCount = 1
	end
end

Grid2.setupFunc["privateauras"] = function(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.iconAnchor = {}
	indicator.auraAnchor = { iconInfo = { iconAnchor = indicator.iconAnchor } }
	indicator.dbx       = dbx
	indicator.Create    = Icon_Create
	indicator.Layout    = Icon_Layout
	indicator.Disable   = Icon_Disable
	indicator.UpdateDB  = Icon_UpdateDB
	indicator.UpdateO   = Icon_Update
	Grid2:RegisterIndicator(indicator, { "privateauras" })
	return indicator
end
