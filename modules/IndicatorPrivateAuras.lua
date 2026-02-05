--[[ PrivateAuras indicator ]]--

local Grid2 = Grid2
local wipe = wipe
local strmatch = strmatch
local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor

local Bug30Fix = true -- border bug workaround (border is always 30 pixels size, so we need to scale the icons instead of change size)

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
	f.auraFrames = {}
end

local function Icon_Update(self, parent, unit)
	local f = parent[self.name]
	if f and unit ~= f.auraUnit then
		local auraHandles = ClearFrameAuraAnchors(f)
		local auraAnchor = self.auraAnchor
		local iconAnchor = auraAnchor.iconInfo.iconAnchor
		auraAnchor.unitToken = unit
		auraAnchor.auraIndex = self.auraIndex
		local auraFrames = f.auraFrames
		for i=1,self.maxIcons do
			auraAnchor.parent = auraFrames[i]
			iconAnchor.relativeTo = auraFrames[i]
			auraHandles[i] = AddPrivateAuraAnchor(auraAnchor)
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
	if Bug30Fix then f:SetScale(iconSize/30); iconSize = 30; end -- Workaround to icon border bug (it does not obey iconSize and its always 30 pixels width).
	local sizeFull = iconSize + (dbx.iconSpacing or 1)
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint( l.point, parent.container, l.relPoint, l.x, l.y )
	f:SetFrameLevel( parent:GetFrameLevel() + (dbx.level or 1) )
	f:SetSize( sizeFull*self.colCount, sizeFull*self.rowCount )
	f.auraUnit = nil
	local auraAnchor = self.auraAnchor
	auraAnchor.iconInfo.iconWidth = iconSize
	auraAnchor.iconInfo.iconHeight = iconSize
	local offsetX = 0
	local offsetY = 0
	local sumX = sizeFull * self.horMult
	local sumY = sizeFull * self.verMult
	local auraFrames = f.auraFrames
	for i=1, self.maxIcons do
		local frame = auraFrames[i] or CreateFrame('frame', nil, f)
		frame:ClearAllPoints()
		frame:SetPoint(self.point, f, self.point, offsetX, offsetY)
		frame:SetSize(iconSize, iconSize)
		frame:Show()
		offsetX = offsetX + sumX
		offsetY = offsetY + sumY
		auraFrames[i] = frame
	end
	for i=self.maxIcons+1, #auraFrames do
		auraFrames[i]:Hide()
	end
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
	if dbx.orientation=='VERTICAL' then
		self.point = strmatch(dbx.location.point,'BOTTOM') or 'TOP'
		self.horMult = 0
		self.verMult = self.point=='TOP' and -1 or 1
		self.colCount = 1
		self.rowCount = self.maxIcons
	else
		self.point = strmatch(dbx.location.point,'RIGHT') or 'LEFT'
		self.horMult = self.point=='LEFT' and 1 or -1
		self.verMult = 0
		self.colCount = self.maxIcons
		self.rowCount = 1
	end
end

Grid2.setupFunc["privateauras"] = function(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.auraAnchor = { iconInfo={ iconAnchor={ offsetX=0, offsetY=0, point='CENTER', relativePoint='CENTER' } } }
	indicator.dbx       = dbx
	indicator.Create    = Icon_Create
	indicator.Layout    = Icon_Layout
	indicator.Disable   = Icon_Disable
	indicator.UpdateDB  = Icon_UpdateDB
	indicator.UpdateO   = Icon_Update
	Grid2:RegisterIndicator(indicator, { "privateauras" })
	return indicator
end
