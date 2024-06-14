-- Aura Icons indicator

local Grid2 = Grid2
local min = min
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local format = string.format

local function Icon_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f.myIndicator = self
	f.myFrame = parent
	f.auras = f.auras or {}
	f.visibleCount = 0
end

local function SetAura(f, iconNumber, icon)
	local self = f.myIndicator
	local auras = f.auras
	local aura = auras[iconNumber]

	aura.status, aura.slotID = icon.status, icon.slotID
	if self.showIcons then
		aura.icon:SetTexture(icon.texture)
		if self.useStatus then
			aura:SetBackdropBorderColor(icon.color.r, icon.color.g, icon.color.b, min(icon.color.a,self.borderOpacity) )
		end
	else
		aura.icon:SetColorTexture(icon.color.r, icon.color.g, icon.color.b)
	end
	if self.showStack then
		aura.text:SetText(icon.stackcount > 1 and icon.stackcount or "")
	end
	if self.showCool then
		aura.cooldown:SetCooldown(icon.expiration - icon.duration, icon.duration)
	end
	aura:Show()
end

local function Icon_OnFrameUpdate(f)
	local unit = f.myFrame.unit
	if not unit then return end
	local self = f.myIndicator
	local max = self.maxIcons
	local auras = f.auras

	local iconCount = 0

	for _, status in ipairs(self.statuses) do
		if status:IsActive(unit) then
			if status.GetIcons then
				local k, textures, counts, expirations, durations, colors, slots = status:GetIcons(unit,max)
				for j=1,k do
					if iconCount >= self.maxIcons then
						break
					end

					local icon = {}
					icon.texture = textures[j]
					icon.color = colors[j]
					icon.stackcount = counts[j]
					icon.expiration, icon.duration = expirations[j], durations[j]
					icon.status = status
					icon.slotID = slots[j]

					iconCount = iconCount + 1
				  	SetAura(f, iconCount, icon)
				end
			else
				if iconCount >= self.maxIcons then
					break
				end

				local icon = {}
				icon.texture = status:GetIcon(unit)
				icon.color = {}
				icon.color.r, icon.color.g, icon.color.b, icon.color.a = status:GetColor(unit)
				icon.stackcount = status:GetCount(unit)
				icon.expiration, icon.duration = status:GetExpirationTime(unit) or 0, status:GetDuration(unit) or 0
				icon.status = status
				icon.slotID = nil

				iconCount = iconCount + 1
				SetAura(f, iconCount, icon)
			end
		end
	end

	for j=iconCount+1,self.maxIcons do
		local aura = auras[j]
		aura.status = nil
		aura.slotID = nil
		aura:Hide()
	end
	f.visibleCount = iconCount

	if self.smartLayout then
		local iconNumber = 1
		local rows = math.ceil(iconCount / math.min(self.maxIconsPerRow, self.maxIcons))
		local maxRows = math.ceil(self.maxIcons / self.maxIconsPerRow)
		
		local rowYOffset = (maxRows - rows) / 2

		for row = 1,rows do
			local iconsInRow = math.min(iconCount - ((row - 1) * self.maxIconsPerRow), self.maxIconsPerRow, self.maxIcons)
			
			local rowXOffset = (math.min(self.maxIconsPerRow, self.maxIcons) - iconsInRow) / 2

			for k=1, iconsInRow do
				local aura = auras[iconNumber]
				local width, height = aura:GetSize()

				local rx, ry
				if self.orientation=="VERTICAL" then
					rx, ry = rowYOffset, rowXOffset
				else
					rx, ry = rowXOffset, rowYOffset
				end

				local offsetX = ((width + self.iconSpacing) * rx) + ((k - 1) * self.ux + (row - 1) * self.vx) * (width + self.iconSpacing)
				local offsetY = ((height + self.iconSpacing) * -ry) + ((k - 1) * self.uy + (row - 1) * self.vy) * (height + self.iconSpacing)

				aura:ClearAllPoints()
				aura:SetPoint( self.anchorIcon, f, self.anchorIcon, offsetX, offsetY)
				iconNumber = iconNumber + 1
			end
		end
	end

	f:SetShown(iconCount>=1)
end

-- Delayed updates
local updates = {}
local EnableDelayedUpdates = function()
	CreateFrame("Frame", nil, Grid2LayoutFrame):SetScript("OnUpdate", function()
		for i=1,#updates do
			Icon_OnFrameUpdate(updates[i])
		end
		wipe(updates)
	end)
	EnableDelayedUpdates = Grid2.Dummy
end

-- Warning: This is an overrided indicator:Update() NOT the standard indicator:OnUpdate()
local function Icon_Update(self, parent, unit)
	local f = parent[self.name]
	if f then
		updates[#updates+1] = f
	end
end

-- Layout icons
local function Icon_Layout(self, parent)
	local f = parent[self.name]
	local x,y = 0,0
	local ux,uy = self.ux,self.uy
	local vx,vy = self.vx,self.vy
	local borderSize = self.borderSize
	local iconSize = self.iconSize>1 and self.iconSize or self.iconSize * parent:GetHeight()
	local fontSize = self.fontSize<1 and self.fontSize*iconSize or self.fontSize
	local size = iconSize + self.iconSpacing
	local tc1,tc2,tc3,tc4 = Grid2.statusPrototype.GetTexCoord()
	local level = parent:GetFrameLevel() + self.frameLevel
	local frameName
	if not self.dbx.disableOmniCC then
		local i,j  = parent:GetName():match("Grid2LayoutHeader(%d+)UnitButton(%d+)")
		frameName  = format( "Grid2Icons%s%02d%02d", self.name:gsub("%-","") , i, j )
	end
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	f:SetSize( (size*self.pw) - self.iconSpacing, (size*self.ph) - self.iconSpacing )
	local auras = f.auras
	for i=1,self.maxIcons do
		local frame = auras[i]
		if not frame then
			frame = CreateFrame("Frame", nil, f, "BackdropTemplate")
			frame.icon = frame:CreateTexture(nil, "ARTWORK")
			auras[i] = frame
		end
		frame:SetSize( iconSize, iconSize )
		-- frame container
		Grid2:SetFrameBackdrop(frame, self.backdrop)
		if borderSize>0 then
			local c = self.colorBorder
			frame:SetBackdropBorderColor(c.r,c.g,c.b,c.a)
		end
		frame:ClearAllPoints()
		frame:SetPoint( self.anchorIcon, f, self.anchorIcon, (x*ux+y*vx)*size, (x*uy+y*vy)*size )
		-- stack count text
		if self.showStack then
			local c = self.colorStack
			local text = frame.text
			if not text then
				local tframe = CreateFrame("frame", nil, frame)
				text = tframe:CreateFontString(nil, "OVERLAY")
				frame.text = text
				text.tframe = tframe
				tframe:SetAllPoints()
			end
			text.tframe:SetFrameLevel(level+2)
			text:SetFont(self.font, fontSize, self.fontFlags )
			text:SetTextColor(c.r, c.g, c.b, c.a)
			text:ClearAllPoints()
			text:SetPoint(self.fontPoint, self.fontOffsetX, self.fontOffsetY)
			text:Show()
		elseif frame.text then
			frame.text:Hide()
		end
		-- cooldown animation
		if self.showCooldown then
			frame.cooldown = frame.cooldown or CreateFrame("Cooldown", frameName and frameName..i or nil, frame, "CooldownFrameTemplate")
			frame.cooldown:SetAllPoints()
			frame.cooldown:SetHideCountdownNumbers(true)
			frame.cooldown:SetDrawEdge(self.dbx.disableOmniCC~=nil)
			frame.cooldown.noCooldownCount = self.dbx.disableOmniCC
			frame.cooldown:SetReverse(self.dbx.reverseCooldown)
			frame.cooldown:Show()
		elseif frame.cooldown then
			frame.cooldown:Hide()
		end
		-- icon texture
		frame.icon:SetPoint("TOPLEFT",     frame ,"TOPLEFT",  borderSize, -borderSize)
		frame.icon:SetPoint("BOTTOMRIGHT", frame ,"BOTTOMRIGHT", -borderSize, borderSize)
		frame.icon:SetTexCoord(tc1, tc2, tc3, tc4)
		--
		frame:Hide()
		x = x + 1
		if x>=self.maxIconsPerRow then x = 0; y = y + 1 end
	end
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
end

local pointsX = { TOPLEFT =  1,	TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT = -1 }
local pointsY = { TOPLEFT = -1, TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT =  1 }
local function Icon_UpdateDB(self)
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	-- location
	local l = dbx.location
	self.anchor     = l.point
	self.anchorRel  = l.relPoint
	self.offsetx    = l.x
	self.offsety    = l.y
	self.anchorIcon = (pointsX[self.anchor] and self.anchor) or (self.anchor=="BOTTOM" and "BOTTOMLEFT") or (self.anchor=="RIGHT" and "TOPRIGHT") or "TOPLEFT"
	-- misc variables
	self.borderSize     = dbx.borderSize or 0
	self.orientation    = dbx.orientation or "HORIZONTAL"
	self.frameLevel     = dbx.level or 1
	self.iconSize       = dbx.iconSize or theme.iconSize or 14
	self.iconSpacing    = dbx.iconSpacing or 1
	self.maxIcons       = dbx.maxIcons or 3
	self.maxIconsPerRow = dbx.maxIconsPerRow or 3
	self.maxRows        = math.floor(self.maxIcons/self.maxIconsPerRow) + (self.maxIcons%self.maxIconsPerRow==0 and 0 or 1)
	self.smartLayout 	= dbx.smartLayout or false
	self.uy 			= 0
	self.vx 			= 0
	self.ux 			= pointsX[self.anchorIcon]
	self.vy 			= pointsY[self.anchorIcon]
	self.pw             = math.abs(self.ux)*math.min(self.maxIcons, self.maxIconsPerRow)
	self.ph             = math.abs(self.vy)*self.maxRows
	if self.orientation=="VERTICAL" then
		self.ux, self.vx = self.vx, self.ux
		self.uy, self.vy = self.vy, self.uy
		self.pw, self.ph = self.ph, self.pw
	end
	self.showCooldown    = not dbx.disableCooldown
	self.showStack       = not dbx.disableStack
	self.showIcons       = not dbx.disableIcons
	self.useStatusColor  = dbx.useStatusColor
	self.borderOpacity   = dbx.borderOpacity  or 1
	self.colorBorder     = Grid2:MakeColor(dbx.color1, "WHITE")
	self.colorStack      = Grid2:MakeColor(dbx.colorStack, "WHITE")
	-- stacks text
	local jV,jH = dbx.fontJustifyV or 'MIDDLE', dbx.fontJustifyH or 'CENTER'
	self.fontPoint       = (jV=='MIDDLE' and jH) or (jH=='CENTER' and jV) or jV..jH
	self.fontOffsetX     = dbx.fontOffsetX or 0
	self.fontOffsetY     = dbx.fontOffsetY or 0
	self.fontFlags       = dbx.fontFlags or "OUTLINE"
	self.fontSize        = dbx.fontSize or 9
	self.font            = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	-- backdrop
	self.backdrop = self.borderSize>0 and Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize) or nil
end

local function Icon_GetMouseOverStatus(self, unit, parent, frame)
	frame = frame or parent[self.name]
	local auras = frame.auras
	for i=1,frame.visibleCount do
		local aura = auras[i]
		if aura:IsMouseOver() then
			return aura.status, true, aura.slotID, aura
		end
	end
end

Grid2.setupFunc["icons"] = function(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx       = dbx
	indicator.Create    = Icon_Create
	indicator.Layout    = Icon_Layout
	indicator.Disable   = Icon_Disable
	indicator.UpdateDB  = Icon_UpdateDB
	indicator.UpdateO   = Icon_Update -- special case used by multibar and icons indicator
	indicator.GetMouseOverStatus = Icon_GetMouseOverStatus
	EnableDelayedUpdates()
	Grid2:RegisterIndicator(indicator, { "icon", "icons" })
	return indicator
end
