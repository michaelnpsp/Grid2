-- Aura Icons indicator
if Grid2.versionCli<120100 then return end

local Grid2 = Grid2
local min = min
local wipe = wipe
local next = next
local pairs = pairs
local ipairs = ipairs
local format = string.format
local UnpackColor = Grid2.UnpackColor
local issecretvalue = Grid2.issecretvalue
local canaccessvalue = Grid2.canaccessvalue
local TruncateWhenZero = C_StringUtil.TruncateWhenZero
local UpdateIconColorCurve = Grid2.UpdateIconColorCurve
local RemoveIconColorCurve = Grid2.RemoveIconColorCurve

-------------------------------------------------------------
-- helps functions to disable old mode when mode switches
-------------------------------------------------------------

local function Icon_DisableIconContainer(f)
	for i=1,f.visibleCount do
		local aura = f.auras[i]
		aura.status = nil
		aura.slotID = nil
		aura:Hide()
	end
end

local function Icon_DisableAuraContainer(self, parent, f)
	self:ReleaseAuraContainer(parent, self.auraContainerKey)
	f.auraContainer = nil
end

-------------------------------------------------------------
-- standard non-secret statuses
-------------------------------------------------------------

local function Icon_OnFrameUpdate(f)
	local unit = f.myFrame.unit
	if not unit then return end
	local self = f.myIndicator
	local max = self.maxIcons
	local auras = f.auras
	local showStack = self.showStack
	local showCool  = self.showCooldown
	local showIcons = self.showIcons
	local showColors= self.showColors
	local showBar   = self.showCoolBar
	local needDur   = showColors or showBar
	local useStatus = self.useStatusColor
	local hideDupes = #self.statuses>1 and self.hideDupes
	local function checkDupe(slotID)
		if hideDupes[slotID] then return true end; hideDupes[slotID] = true
	end
	local i = 1
	for _, status in ipairs(self.statuses) do
		if status:IsActive(unit) then -- TODO secret test maybe
			local aura = auras[i]
			aura.status, aura.slotID = status, nil
			if showIcons then
				aura.icon:SetTexture(status:GetIcon(unit))
				aura.icon:SetTexCoord(status:GetTexCoord(unit))
				aura.icon:SetVertexColor(status:GetVertexColor(unit))
				if useStatus then
					local r, g, b, a = status:GetColor(unit)
					aura:SetBackdropBorderColor(r, g, b, self.borderOpacity)
				end
			else
				local r, g, b = status:GetColor(unit)
				aura.icon:SetColorTexture(r, g, b)
			end
			if showStack then
				aura.text:SetText( TruncateWhenZero( status:GetCount(unit) or 0 ) )
			end
			if showCool then
				local expiration, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
				if expiration and duration then
					aura.cooldown:SetCooldownFromExpirationTime(expiration, duration)
				else
					aura.cooldown:SetCooldown(0, 0)
				end
			end
			if needDur then
				local durObject = status:GetDurationObject(unit)
				if showBar then
					if durObject then
						aura.coolBar:SetTimerDuration(durObject, 0, self.cbDirection)
						aura.coolBar:Show()
					else
						aura.coolBar:Hide()
					end
				end
				if showColors then
					UpdateIconColorCurve(aura, durObject)
				end
			end
			aura:Show()
			i = i + 1
			max = max - 1
		end
		if max<=0 then break end
	end
	for j=i,f.visibleCount do
		local aura = auras[j]
		aura.status = nil
		aura.slotID = nil
		aura:Hide()
	end
	f.visibleCount = i-1
	if self.smartCenter and i>1 then
		f:SetSmartSize( self.cellSize * f.visibleCount - self.iconSpacing )
	end
	f:SetShown(i>1)
	if hideDupes then wipe(hideDupes) end
end

-- Delayed updates
local updates, updateFrame = {}
local EnableDelayedUpdates = function()
	updateFrame = CreateFrame("Frame", nil, Grid2LayoutFrame)
	updateFrame:Hide()
	updateFrame:SetScript("OnUpdate", function()
		for f in next, updates do
			Icon_OnFrameUpdate(f)
		end
		wipe(updates)
		updateFrame:Hide()
	end)
	EnableDelayedUpdates = Grid2.Dummy
end

-- Warning: This is an overrided indicator:Update() NOT the standard indicator:OnUpdate()
local function Icon_Update(self, parent, unit)
	local f = parent[self.name]
	if not f then return end
	if f.auraContainer then return end
	if not next(updates) then
		updateFrame:Show()
	end
	updates[f] = true
end

-- Layout icons
local function Icon_LayoutA(self, parent)
	local f = parent[self.name]
	Icon_DisableAuraContainer(self, parent, f)
	local x,y = 0,0
	local ux,uy = self.ux,self.uy
	local vx,vy = self.vx,self.vy
	local borderSize = self.borderSize
	local iconSize = self.iconSize>1 and self.iconSize or self.iconSize * parent:GetHeight()
	local fontSize = self.fontSize<1 and self.fontSize*iconSize or self.fontSize
	local ctFontSize = self.ctFontSize<1 and self.ctFontSize*iconSize or self.ctFontSize
	local size = iconSize + self.iconSpacing
	local tc1,tc2,tc3,tc4 = Grid2.statusPrototype.GetTexCoord()
	local level = parent:GetFrameLevel() + self.frameLevel
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	self.cellSize = size
	if not self.smartCenter then
		if size>0 then
			f:SetSize( size*self.pw, size*self.ph )
		else
			f:SetSize( iconSize, iconSize ) -- to avoid 0 size frame when using a negative spacing: iconSize+iconSpacing==0
		end
	elseif self.vertical then
		f:SetWidth(iconSize)
		f.SetSmartSize = f.SetHeight
	else
		f:SetHeight(iconSize)
		f.SetSmartSize = f.SetWidth
	end
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
			frame:SetBackdropBorderColor(UnpackColor(self.colorBorder))
		end
		frame:ClearAllPoints()
		frame:SetPoint( self.anchorIcon, f, self.anchorIcon, (x*ux+y*vx)*size, (x*uy+y*vy)*size )
		-- stack count text
		if self.showStack then
			local text = frame.text
			if not text then
				local tframe = CreateFrame("frame", nil, frame)
				text = tframe:CreateFontString(nil, "OVERLAY")
				frame.text = text
				text.tframe = tframe
				tframe:SetAllPoints()
			end
			text.tframe:SetFrameLevel(level+2)
			text:SetFont(self.font, fontSize, self.fontFlags)
			text:SetTextColor(UnpackColor(self.colorStack))
			text:ClearAllPoints()
			text:SetPoint(self.fontPoint, self.fontOffsetX, self.fontOffsetY)
			text:Show()
		elseif frame.text then
			frame.text:Hide()
		end
		-- cooldown animation
		if self.showCooldown then
			local cooldown = frame.cooldown or CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
			cooldown:SetAllPoints()
			cooldown:SetAlpha(1)
			cooldown:SetHideCountdownNumbers(not self.showCoolText)
			cooldown:SetDrawEdge(self.dbx.drawEdge)
			cooldown:SetDrawSwipe(self.showSwipe)
			cooldown:SetReverse(self.dbx.reverseCooldown)
			if self.showCoolText then
				local text = cooldown:GetCountdownFontString()
				text:SetFont(self.ctFont, ctFontSize, self.ctFontFlags)
				text:SetTextColor(UnpackColor(self.ctColor))
				text:ClearAllPoints()
				text:SetPoint(self.ctFontPoint, self.ctFontOffsetX, self.ctFontOffsetY)
				text:SetMaxLines(1)
				frame.coolText = text
			else
				frame.coolText = nil
			end
			cooldown:Show()
			frame.cooldown = cooldown
		elseif frame.cooldown then
			frame.cooldown:Hide()
		end
		-- cooldown bar
		if self.showCoolBar then
			local bar = frame.coolBar or CreateFrame("StatusBar", nil, frame)
			bar:ClearAllPoints()
			bar:SetPoint(self.cbPoint, frame, self.cbPoint, self.cbOffsetX, self.cbOffsetY)
			bar:SetFrameLevel(level+2)
			bar:SetOrientation(self.cbOrientation)
			bar:SetWidth( self.cbOrientation=='VERTICAL' and self.cbThickness or iconSize-borderSize*2 )
			bar:SetHeight( self.cbOrientation=='HORIZONTAL' and self.cbThickness or iconSize-borderSize*2 )
			bar:SetStatusBarTexture(self.cbTexture)
			bar:SetStatusBarColor(UnpackColor(self.cbColor))
			bar:SetReverseFill(self.cbReverse)
			bar:Show()
			frame.coolBar = bar
			local background = bar.background or bar:CreateTexture(nil, "BACKGROUND")
			background:ClearAllPoints()
			background:SetAllPoints()
			background:SetTexture(self.cbTexture)
			background:SetVertexColor(UnpackColor(self.cbColorBack))
			bar.background = background
		elseif frame.coolBar then
			frame.coolBar:Hide()
		end
		-- icon texture
		frame.icon:SetPoint("TOPLEFT",     frame ,"TOPLEFT",  borderSize, -borderSize)
		frame.icon:SetPoint("BOTTOMRIGHT", frame ,"BOTTOMRIGHT", -borderSize, borderSize)
		frame.icon:SetTexCoord(tc1, tc2, tc3, tc4)
		-- colorization
		frame.colorCurveObject = self.showColors and self.ctColorCurve
		frame.colorCurveText   = self.showColorsText and frame.coolText
		frame.colorCurveBar    = self.showColorsBar and frame.coolBar
		frame.colorCurveBorder = self.showColorsBorder and frame.SetBackdropBorderColor
		--
		frame:Hide()
		x = x + 1
		if x>=self.maxIconsPerRow then x = 0; y = y + 1 end
	end
end

-------------------------------------------------------------
-- blizzard secret aura containers 12.1+
-------------------------------------------------------------

local function Icon_SetupButtonB(self, parent, auraContainer, frame, borderOptions)
	-- frame button
	local iconSize = self.iconSize>1 and self.iconSize or self.iconSize * parent:GetHeight()
	frame:SetSize(iconSize, iconSize)
	frame:SetAlpha(1)
	local level = parent:GetFrameLevel() + self.frameLevel
	frame:SetFrameLevel(level+1)
	-- aura icon
	if not frame.icon then
		frame.icon = frame:CreateTexture(nil, "ARTWORK")
		frame:SetIcon(frame.icon)
	end
	-- frame border
	local borderSize = self.borderSize
	if borderSize>0 then
		local border = frame.border
		if not border then
			border = frame:CreateTexture(nil, "BACKGROUND")
			border:ClearAllPoints()
			border:SetAllPoints()
			border:SetColorTexture(1,1,1,1)
			frame.border = border
		end
		if self.useStatusColor then -- dispel border
			frame:SetAuraBorder(border, borderOptions)
		else -- fixed border
			frame:ClearAuraBorder()
			border:SetColorTexture(UnpackColor(self.colorBorder))
		end
		border:Show()
	elseif frame.border then
		frame:ClearAuraBorder(frame.border)
		frame.border:Hide()
	end
	-- stack count text
	if self.showStack then
		local fontSize = self.fontSize<1 and self.fontSize*iconSize or self.fontSize
		local text = frame.text
		if not text then
			local tframe = CreateFrame("frame", nil, frame)
			text = tframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			frame.text = text
			text.tframe = tframe
			tframe:SetAllPoints()
		end
		text.tframe:SetFrameLevel(level+2)
		text:SetFont(self.font, fontSize, self.fontFlags)
		text:SetTextColor(UnpackColor(self.colorStack))
		text:ClearAllPoints()
		text:SetPoint(self.fontPoint, self.fontOffsetX, self.fontOffsetY)
		text:Show()
		frame:SetApplicationCount(text, {})
	elseif frame.text then
		frame:ClearApplicationCount()
		frame.text:Hide()
	end
	-- cooldown animation & cooldown text
	if self.showCooldown then
		local cooldown = frame.cooldown or CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
		cooldown:SetAllPoints()
		cooldown:SetAlpha(1)
		cooldown:SetHideCountdownNumbers(not self.showCoolText)
		cooldown:SetDrawEdge(self.dbx.drawEdge)
		cooldown:SetDrawSwipe(self.showSwipe)
		cooldown:SetReverse(self.dbx.reverseCooldown)
		if self.showCoolText then
			local ctFontSize = self.ctFontSize<1 and self.ctFontSize*iconSize or self.ctFontSize
			local text = cooldown:GetCountdownFontString()
			text:SetFont(self.ctFont, ctFontSize, self.ctFontFlags)
			text:SetTextColor(UnpackColor(self.ctColor))
			text:ClearAllPoints()
			text:SetPoint(self.ctFontPoint, self.ctFontOffsetX, self.ctFontOffsetY)
			text:SetMaxLines(1)
			frame.coolText = text
			frame:SetDurationText(text, self.ctOptions)
		else
			frame.coolText = nil
			frame:ClearDurationText()
		end
		cooldown:Show()
		frame.cooldown = cooldown
		frame:SetDurationCooldown(cooldown)
	elseif frame.cooldown then
		frame.cooldown:Hide()
		frame:ClearDurationCooldown()
	end
	-- cooldown bar
	if self.showCoolBar then
		local bar = frame.coolBar or CreateFrame("StatusBar", nil, frame)
		bar:ClearAllPoints()
		bar:SetPoint(self.cbPoint, frame, self.cbPoint, self.cbOffsetX, self.cbOffsetY)
		bar:SetFrameLevel(level+2)
		bar:SetOrientation(self.cbOrientation)
		bar:SetWidth( self.cbOrientation=='VERTICAL' and self.cbThickness or iconSize-borderSize*2 )
		bar:SetHeight( self.cbOrientation=='HORIZONTAL' and self.cbThickness or iconSize-borderSize*2 )
		bar:SetStatusBarTexture(self.cbTexture)
		bar:SetStatusBarColor(UnpackColor(self.cbColor))
		bar:SetReverseFill(self.cbReverse)
		bar:Show()
		frame.coolBar = bar
		frame:SetDurationBar(bar, self.cbOptions)
		local background = bar.background or bar:CreateTexture(nil, "BACKGROUND")
		background:ClearAllPoints()
		background:SetAllPoints()
		background:SetTexture(self.cbTexture)
		background:SetVertexColor(UnpackColor(self.cbColorBack))
		bar.background = background
	elseif frame.coolBar then
		frame:ClearDurationBar(frame.coolBar)
		frame.coolBar:Hide()
	end
	-- icon texture
	frame.icon:SetPoint("TOPLEFT",     frame ,"TOPLEFT",  borderSize, -borderSize)
	frame.icon:SetPoint("BOTTOMRIGHT", frame ,"BOTTOMRIGHT", -borderSize, borderSize)
	frame.icon:SetTexCoord( Grid2.statusPrototype.GetTexCoord() )
	-- tooltip
	self:SetAuraButtonTooltip(frame)
end

local function Icon_LayoutB(self, parent)
	local f = parent[self.name]
	-- hide non-aura icons if necessary
	if f.visibleCount>0 then Icon_DisableIconContainer(f) end
	-- root indicator frame
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	local iconSize = self.iconSize>1 and self.iconSize or self.iconSize * parent:GetHeight()
	local size = iconSize + self.iconSpacing
	if size>0 then
		f:SetSize( size*self.pw+1, size*self.ph+1 )
	else
		f:SetSize( iconSize, iconSize ) -- to avoid 0 size frame when using a negative spacing: iconSize+iconSpacing==0
	end
	f:Show()
	-- bliz aura container
	Icon_DisableAuraContainer(self, parent, f)
	local auraContainer = self:AcquireAuraContainer(parent, self.auraContainerKey, f)
	auraContainer._buttons = {}
	auraContainer:ClearAllPoints()
	auraContainer:SetAllPoints()
	auraContainer:SetSize(f:GetSize())
	auraContainer:SetFlowLayoutAxis(self.layoutAxis)
	auraContainer:SetFlowLayoutMaximumLineSize( self.vertical and f:GetHeight() or f:GetWidth() )
	auraContainer:SetFlowLayoutAnchorPoint(self.anchorIcon)
	auraContainer:SetFlowLayoutGrowthDirection(self.horizontalDirection, self.verticalDirection)
	auraContainer:SetFlowLayoutPadding(0,0,0,0)
	local buttons = auraContainer._buttons
	for i, status in ipairs(self.statuses) do
		if status.GetAurasFilter then
			local key, filter = tostring(i), status:GetAurasFilter()
			local maxFrameCount = math.min(self.maxIcons, filter.maxAuras or 64)
			local count = 10 - maxFrameCount
			auraContainer:AddAuraGroup( key, filter.filter, {
				maxFrameCount = maxFrameCount,
				sortMethod = filter.sortRule or 0,
				sortDirection = filter.sortDir or 0,
				candidateFilters = filter.candidateFilters,
				initializeFrame = function(button)
					if count>0 then count = count -1; return end
					buttons[#buttons+1] = button
					Icon_SetupButtonB(self, parent, auraContainer, button, filter.borderOptions)
				end
			} )
			auraContainer:SetAuraGroupLayout(key, self.groupLayout)
		end
	end
	f.auraContainer = auraContainer
end

-------------------------------------------------------------
-- shared
-------------------------------------------------------------

local function Icon_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f.myIndicator = self
	f.myFrame = parent
	f.auras = f.auras or {}
	f.visibleCount = 0
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
	Icon_DisableAuraContainer(self, parent, f)
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
	self.layoutAxis     = AnchorUtil.FlowLayoutAxis[dbx.orientation=='VERTICAL' and 'Vertical' or 'Horizontal']
	self.vertical       = dbx.orientation=='VERTICAL'
	self.borderSize     = dbx.borderSize or 0
	self.frameLevel     = dbx.level or 1
	self.iconSize       = dbx.iconSize or theme.iconSize or 14
	self.iconSpacing    = dbx.iconSpacing or 1
	self.maxIcons       = dbx.maxIcons or 3
	self.maxIconsPerRow = dbx.maxIconsPerRow or 3
	self.maxRows        = math.floor(self.maxIcons/self.maxIconsPerRow) + (self.maxIcons%self.maxIconsPerRow==0 and 0 or 1)
	self.smartCenter    = dbx.smartCenter and self.maxRows==1
	self.uy 			= 0
	self.vx 			= 0
	self.ux 			= pointsX[self.anchorIcon]
	self.vy 			= pointsY[self.anchorIcon]
	self.pw             = math.abs(self.ux)*math.min(self.maxIcons, self.maxIconsPerRow)
	self.ph             = math.abs(self.vy)*self.maxRows
	if self.vertical then
		self.ux, self.vx = self.vx, self.ux
		self.uy, self.vy = self.vy, self.uy
		self.pw, self.ph = self.ph, self.pw
	end
	self.showSwipe       = not (dbx.disableCooldown or dbx.disableCooldownAnim)
	self.showCoolText    = dbx.enableCooldownText
	self.showCooldown    = dbx.enableCooldownText or not dbx.disableCooldown
	self.showStack       = not dbx.disableStack
	self.showIcons       = not dbx.disableIcons
	self.showCoolBar     = dbx.enableCooldownBar
	self.useStatusColor  = dbx.useStatusColor
	self.borderOpacity   = dbx.borderOpacity  or 1
	self.colorBorder     = Grid2.MakeColor(dbx.color1, "WHITE")
	-- stacks text
	local jV,jH = dbx.fontJustifyV or 'MIDDLE', dbx.fontJustifyH or 'CENTER'
	self.fontPoint       = (jV=='MIDDLE' and jH) or (jH=='CENTER' and jV) or jV..jH
	self.fontOffsetX     = dbx.fontOffsetX or 0
	self.fontOffsetY     = dbx.fontOffsetY or 0
	self.fontFlags       = dbx.fontFlags or "OUTLINE"
	self.fontSize        = dbx.fontSize or 9
	self.font            = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	self.colorStack      = Grid2.MakeColor(dbx.colorStack, "WHITE")
	-- cooldown text
	local ctJV,ctJH      = dbx.ctFontJustifyV or 'MIDDLE', dbx.ctFontJustifyH or 'CENTER'
	self.ctFontFlags     = dbx.ctFontFlags or "OUTLINE"
	self.ctFontSize      = dbx.ctFontSize or 9
	self.ctFont          = Grid2:MediaFetch("font", dbx.ctFont or theme.font) or STANDARD_TEXT_FONT
	self.ctFontPoint     = (ctJV=='MIDDLE' and ctJH) or (ctJH=='CENTER' and ctJV) or ctJV..ctJH
	self.ctFontOffsetX   = dbx.ctFontOffsetX or 0
	self.ctFontOffsetY   = dbx.ctFontOffsetY or -1
	self.ctColor         = Grid2.MakeColor(dbx.ctColor, "WHITE")
	-- coldown bar
	self.cbPoint        = dbx.cbPoint or 'BOTTOM'
	self.cbOrientation  = (self.cbPoint=='LEFT' or self.cbPoint=='RIGHT') and 'VERTICAL' or 'HORIZONTAL'
	self.cbThickness    = dbx.cbThickness~=0 and (dbx.cbThickness or 2) or nil
	self.cbDirection    = dbx.cbDirection or 1
	self.cbReverse      = dbx.cbReverse or false
	self.cbTexture		= Grid2:MediaFetch("statusbar", dbx.cbTexture or 'Grid2 Flat', 'Grid2 Flat')
	self.cbOffsetX      = (self.cbPoint=='LEFT' or self.cbPoint=='BOTTOM') and self.borderSize or -self.borderSize
	self.cbOffsetY      = 0
	self.cbOptions      = { direction = self.cbDirection }
	if self.cbOrientation=='HORIZONTAL' then self.cbOffsetX, self.cbOffsetY = self.cbOffsetY, self.cbOffsetX end
	self.cbColor        = Grid2.MakeColor(dbx.cbColor, "WHITE")
	self.cbColorBack    = Grid2.MakeColor(dbx.cbColorBack, "RED")
	-- color curve
	self.showColors      = dbx.ctColors~=nil
	self.showColorsText  = dbx.ctColorsText
	self.showColorsBorder= dbx.ctColorsBorder
	self.showColorsBar   = dbx.ctColorsBar
	if dbx.ctColors then
		self.ctColorCurve = self.ctColorCurve or C_CurveUtil.CreateColorCurve()
		self.ctColorCurve:SetType(Enum.LuaCurveType.Step)
		self.ctColorCurve:ClearPoints()
		for i,color in ipairs(dbx.ctColors) do
			self.ctColorCurve:AddPoint(dbx.ctThresholds[i] or 0, color)
		end
	end
	self.ctOptions = dbx.ctColors and { textColor={ curve=self.ctColorCurve, property=Enum.DurationTextBindingProperty.RemainingDuration } } or nil
	-- hide duplicated icons, used if several buffs/debufs statuses are linked to the indicator
	self.hideDupes = dbx.hideDupes and {} or nil
	-- backdrop
	self.backdrop = self.borderSize>0 and Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize) or nil
	-- used only in auraContainer mode
	self.horizontalDirection = pointsX[self.anchorIcon]
	self.verticalDirection = pointsY[self.anchorIcon]
	self.groupLayout = { elementSpacing = self.iconSpacing, lineSpacing = self.iconSpacing, gapX = 0, gapY = 0, forceNewRow = false }
	self.auraContainerKey = string.format("%s_%s", self.dbx.type, self.name)
end

local function Icon_Layout(self, parent)
	if self.auraMode then
		Icon_LayoutB(self, parent)
	else
		Icon_LayoutA(self, parent)
	end
end

Grid2.setupFunc["icons"] = function(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx       = dbx
	indicator.Create    = Icon_Create
	indicator.Disable   = Icon_Disable
	indicator.Destroy   = Icon_Disable
	indicator.UpdateDB  = Icon_UpdateDB
	indicator.Layout    = Icon_Layout
	indicator.UpdateO   = Icon_Update -- special case used by multibar and icons indicator
	EnableDelayedUpdates()
	Grid2:RegisterIndicator(indicator, { "icon", "icons" })
	return indicator
end

