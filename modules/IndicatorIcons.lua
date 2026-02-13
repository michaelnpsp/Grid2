-- Aura Icons indicator

local Grid2 = Grid2
local min = min
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local format = string.format
local issecretvalue = Grid2.issecretvalue
local canaccessvalue = Grid2.canaccessvalue
local UpdateIconColorCurve = Grid2.UpdateIconColorCurve
local RemoveIconColorCurve = Grid2.RemoveIconColorCurve
local TruncateWhenZero = C_StringUtil.TruncateWhenZero

local function Icon_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f.myIndicator = self
	f.myFrame = parent
	f.auras = f.auras or {}
	f.visibleCount = 0
end

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
	local useStatus = self.useStatusColor
	local i = 1
	for _, status in ipairs(self.statuses) do
		if status.GetIcons then
			local k, textures, counts, expirations, durations, colors, slots = status:GetIcons(unit,max)
			for j=1,k do
				local aura = auras[i]
				aura.status, aura.slotID = status, slots[j]
				if showIcons then
					aura.icon:SetTexture(textures[j])
					if useStatus then
						local c = colors[j]
						aura:SetBackdropBorderColor(c.r, c.g, c.b, self.borderOpacity) -- color is secret we cannot use min()
					end
				else
					local c = colors[j]
					aura.icon:SetColorTexture(c.r, c.g, c.b)
				end
				if showStack then
					local count = counts[j]
					if canaccessvalue(count) then
						aura.text:SetText( count>1 and count or "" )
					else
						aura.text:SetText( TruncateWhenZero(count) )
					end
				end
				if showCool then
					local cooldown = aura.cooldown
					local expiration, duration = expirations[j], durations[j]
					if canaccessvalue(duration) then
						cooldown:SetCooldown(expiration-duration, duration)
					else
						cooldown:SetCooldownFromExpirationTime(expiration, duration)
					end
					if showColors and slots[j] then
						UpdateIconColorCurve(aura, status:GetDurationObject(unit, slots[j]))
					end
				end
				aura:Show()
				i = i + 1
			end
			max = max - k
		elseif status:IsActive(unit) then -- TODO secret test maybe
			local aura = auras[i]
			aura.status, aura.slotID = status, nil
			if showIcons then
				aura.icon:SetTexture(status:GetIcon(unit))
				aura.icon:SetTexCoord(status:GetTexCoord(unit))
				aura.icon:SetVertexColor(status:GetVertexColor(unit))
				if useStatus then
					local r,g,b,a = status:GetColor(unit)
					aura:SetBackdropBorderColor(r,g,b, min(a or 1,self.borderOpacity) )
				end
			else
				local r,g,b = status:GetColor(unit)
				aura.icon:SetColorTexture(r,g,b)
			end
			if showStack then
				local count = status:GetCount(unit)
				aura.text:SetText( (issecretvalue(count) or count>1) and count or "")
			end
			if showCool then
				local expiration, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
				if expiration and duration then
					if canaccessvalue(duration) then
						aura.cooldown:SetCooldown(expiration-duration, duration)
					else
						aura.cooldown:SetCooldownFromExpirationTime(expiration, duration)
					end
					if showColors then
						UpdateIconColorCurve(aura, status:GetDurationObject(unit))
					end
				else
					aura.cooldown:SetCooldown(0, 0)
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
	local ctFontSize = self.ctFontSize<1 and self.ctFontSize*iconSize or self.ctFontSize
	local size = iconSize + self.iconSpacing
	local tc1,tc2,tc3,tc4 = Grid2.statusPrototype.GetTexCoord()
	local level = parent:GetFrameLevel() + self.frameLevel
	local tooltipEnabled = self.dbx.tooltipEnabled
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
			local cooldown = frame.cooldown or CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
			cooldown:SetAllPoints()
			cooldown:SetAlpha(1)
			cooldown:SetHideCountdownNumbers(not self.showCoolText)
			cooldown:SetDrawEdge(false)
			cooldown:SetDrawSwipe(self.showSwipe)
			cooldown:SetReverse(self.dbx.reverseCooldown)
			if self.showCoolText then
				local color, text = self.ctColor, cooldown:GetCountdownFontString()
				text:SetFont(self.ctFont, ctFontSize, self.ctFontFlags)
				text:SetTextColor(color.r, color.g, color.b, color.a)
				text:ClearAllPoints()
				text:SetPoint(self.ctFontPoint, self.ctFontOffsetX, self.ctFontOffsetY)
				text:SetMaxLines(1)
				if self.showColors then
					frame.colorCurveObject = self.ctColorCurve
					frame.colorCurveText = text
					frame.colorCurveBorder = self.showColorsBorder and frame.SetBackdropBorderColor
				end
			end
			cooldown:Show()
			frame.cooldown = cooldown
		elseif frame.cooldown then
			frame.cooldown:Hide()
		end
		-- icon texture
		frame.icon:SetPoint("TOPLEFT",     frame ,"TOPLEFT",  borderSize, -borderSize)
		frame.icon:SetPoint("BOTTOMRIGHT", frame ,"BOTTOMRIGHT", -borderSize, borderSize)
		frame.icon:SetTexCoord(tc1, tc2, tc3, tc4)
		-- tooltip management
		self:EnableFrameTooltips(frame, tooltipEnabled)
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
	self.useStatusColor  = dbx.useStatusColor
	self.borderOpacity   = dbx.borderOpacity  or 1
	self.colorBorder     = Grid2:MakeColor(dbx.color1, "WHITE")
	-- stacks text
	local jV,jH = dbx.fontJustifyV or 'MIDDLE', dbx.fontJustifyH or 'CENTER'
	self.fontPoint       = (jV=='MIDDLE' and jH) or (jH=='CENTER' and jV) or jV..jH
	self.fontOffsetX     = dbx.fontOffsetX or 0
	self.fontOffsetY     = dbx.fontOffsetY or 0
	self.fontFlags       = dbx.fontFlags or "OUTLINE"
	self.fontSize        = dbx.fontSize or 9
	self.font            = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	self.colorStack      = Grid2:MakeColor(dbx.colorStack, "WHITE")
	-- cooldown text
	local ctJV,ctJH      = dbx.ctFontJustifyV or 'MIDDLE', dbx.ctFontJustifyH or 'CENTER'
	self.ctFontFlags     = dbx.ctFontFlags or "OUTLINE"
	self.ctFontSize      = dbx.ctFontSize or 9
	self.ctFont          = Grid2:MediaFetch("font", dbx.ctFont or theme.font) or STANDARD_TEXT_FONT
	self.ctFontPoint     = (ctJV=='MIDDLE' and ctJH) or (ctJH=='CENTER' and ctJV) or ctJV..ctJH
	self.ctFontOffsetX   = dbx.ctFontOffsetX or 0
	self.ctFontOffsetY   = dbx.ctFontOffsetY or -1
	self.ctColor         = Grid2:MakeColor(dbx.ctColor or (dbx.ctColors and dbx.ctColors[1]), "WHITE")
	self.showColors      = dbx.ctColors~=nil
	self.showColorsBorder= dbx.ctColorsBorder
	if dbx.ctColors then
		self.ctColorCurve =  self.ctColorCurve or C_CurveUtil.CreateColorCurve()
		self.ctColorCurve:SetType(Enum.LuaCurveType.Step)
		self.ctColorCurve:ClearPoints()
		for i,color in ipairs(dbx.ctColors) do
			self.ctColorCurve:AddPoint(dbx.ctThresholds[i] or 0, color)
		end
	end
	-- backdrop
	self.backdrop = self.borderSize>0 and Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize) or nil
end

local function Icon_GetMouseOverStatus(self, unit, parent, frame)
	return frame.status, true, frame.slotID, frame
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
