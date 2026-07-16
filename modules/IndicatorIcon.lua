--[[ Icon indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local fmt = string.format

local UnpackColor = Grid2.UnpackColor
local issecretvalue = Grid2.issecretvalue
local canaccessvalue = Grid2.canaccessvalue
local UpdateIconColorCurve = Grid2.UpdateIconColorCurve
local RemoveIconColorCurve = Grid2.RemoveIconColorCurve
local TruncateWhenZero = C_StringUtil.TruncateWhenZero

local BORDER_SETTINGS = {
	showIcon = true,
	showWhenHarmful = true,
	showWhenHelpful = true,
	style = 1 -- Atlas = 0, Color = 1
}

-------------------------------------------------------------
-- shared
-------------------------------------------------------------

local function Icon_Create(self, parent)
	self:Acquire("Frame", parent, "BackdropTemplate")
end

local function Icon_ButtonCreate(self, parent, f, auraContainer)
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:ClearAllPoints()
	Icon:SetAllPoints()
	Icon:Show()
	if auraContainer then f:SetIcon(Icon) end
	if not self.disableCooldown then
		local Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
		Cooldown:SetDrawEdge(not not self.dbx.drawEdge)
		Cooldown:SetReverse(not not self.dbx.reverseCooldown)
		Cooldown:SetDrawSwipe(self.showSwipe)
		--Cooldown:SetSwipeColor(0, 0, 0, 0.58)
		Cooldown:SetHideCountdownNumbers(not self.showCoolText)
		Cooldown:SetAllPoints()
		Cooldown:Show()
		if auraContainer then f:SetDurationCooldown(Cooldown) end
		f.Cooldown = Cooldown
		if self.showCoolText then
			f.coolText = Cooldown:GetCountdownFontString()
			if auraContainer then f:SetDurationText(f.coolText) end
		end
	end
	if not self.disableStack then
		local TextFrame
		if self.disableCooldown then
			if f.TextFrame then f.TextFrame:Hide() end
			TextFrame = f
		else
			TextFrame = f.TextFrame or CreateFrame("Frame", nil, f)
			TextFrame:SetAllPoints()
			TextFrame:Show()
			f.TextFrame = TextFrame
		end
		local stackText = f.stackText or f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		stackText:SetParent(TextFrame)
		if self.fontSize>=1 then stackText:SetFont(self.textfont, self.fontSize, self.dbx.fontFlags or "OUTLINE" ) end
		local c = self.dbx.stackColor
		if c then stackText:SetTextColor(c.r, c.g, c.b, c.a) end
		stackText:Show()
		f.stackText = stackText
		if auraContainer then f:SetApplicationCount(stackText, {}) end
	end
	if auraContainer and self.borderSize then
		-- dispel border
		if self.useStatusColor then
			local border = f.border or f:CreateTexture(nil, "OVERLAY")
			border:SetColorTexture(1,1,1,1)
			if auraContainer then f:SetAuraBorder(border, BORDER_SETTINGS) end
			f.border = border
			border:Show()
		end
		-- default border
		local borderBack = f.borderBack or f:CreateTexture(nil, "BACKGROUND")
		borderBack:ClearAllPoints()
		borderBack:SetAllPoints()
		borderBack:SetColorTexture(UnpackColor(self.color))
		borderBack:SetAlpha(1)
		borderBack:Show()
		f.borderBack = borderBack
	end
	if self.showCoolBar then
		local bar = f.coolBar or CreateFrame("StatusBar", nil, f)
		bar:Hide()
		f.coolBar = bar
		local background = bar.background or bar:CreateTexture(nil, "BACKGROUND")
		background:ClearAllPoints()
		background:SetAllPoints()
		bar.background = background
	elseif f.coolBar then
		f.coolBar:Hide()
	end
	if not auraContainer then
		self:EnableFrameTooltips(f, self.dbx.tooltipEnabled)
	end
end

local function Icon_ButtonLayout(self, parent, f, auraContainer, level)
	local Icon = f.Icon
	local borderSize = self.borderSize
	if auraContainer then -- 12.1+ aura container
		f:SetAllPoints()
		f:SetAlpha(1)
		if borderSize then
			Icon:SetPoint("TOPLEFT", borderSize, -borderSize)
			Icon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		else
			Icon:SetAllPoints(f)
		end
		Icon:SetTexCoord(Grid2.statusPrototype.GetTexCoord())
	else -- non aura statuses
		local r,g,b,a = f:GetBackdropBorderColor()
		if borderSize then
			Icon:SetPoint("TOPLEFT", borderSize, -borderSize)
			Icon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		else
			Icon:SetAllPoints(f)
		end
		Grid2:SetFrameBackdrop(f, self.backdrop)
		if r then f:SetBackdropBorderColor(r, g, b, a) end
	end

	if not self.disableCooldown then
		f.Cooldown:SetFrameLevel(f:GetFrameLevel()+1)
	end

	if self.showCoolText then
		local color, text = self.ctColor, f.coolText
		text:SetFont(self.ctFont, self.ctFontSize, self.ctFontFlags)
		text:SetTextColor(color.r, color.g, color.b, color.a)
		text:ClearAllPoints()
		text:SetPoint(self.ctFontPoint, self.ctFontOffsetX, self.ctFontOffsetY)
		text:SetMaxLines(1)
	end

	if not self.disableStack then
		if f.TextFrame then	f.TextFrame:SetFrameLevel(level+2) end
		local stackText = f.stackText
		stackText:ClearAllPoints()
		stackText:SetPoint(self.textPoint, self.textOffsetX, self.textOffsetY)
		if self.fontSize<1 then stackText.fontSize = self.fontSize*size end	-- we cannot set font here, see github issue #152
	end

	if self.showCoolBar then
		local bsize = size-(borderSize or 0)*2
		local bar = f.coolBar
		bar.background:SetTexture(self.cbTexture)
		bar.background:SetVertexColor(UnpackColor(self.cbColorBack))
		bar:SetFrameLevel(level+2)
		bar:ClearAllPoints()
		bar:SetPoint(self.cbPoint, f, self.cbPoint, self.cbOffsetX, self.cbOffsetY)
		bar:SetOrientation(self.cbOrientation)
		bar:SetWidth( self.cbOrientation=='VERTICAL' and self.cbThickness or bsize )
		bar:SetHeight( self.cbOrientation=='HORIZONTAL' and self.cbThickness or bsize )
		bar:SetStatusBarTexture(self.cbTexture)
		bar:SetStatusBarColor(UnpackColor(self.cbColor))
		bar:SetReverseFill(self.cbReverse)
		bar:Show()
	end

	if not auraContainer then
		f.colorCurveObject = self.showColors and self.ctColorCurve
		f.colorCurveText   = self.showColorsText and f.coolText
		f.colorCurveBar    = self.showColorsBar and f.coolBar
		f.colorCurveBorder = self.showColorsBorder and f.SetBackdropBorderColor
	end
end

local function Icon_DisableIconContainer(f)
	if f.auraContainer then return end
	local function Hide(f)
		if f then f:Hide() end
	end
	Hide(f.Icon)
	Hide(f.Cooldown)
	Hide(f.stackText)
	Hide(f.coolBar)
end

local function Icon_DisableAuraContainer(f)
	if not f.auraContainer then return end
	f.auraContainer:SetEnabled(false)
	f.auraContainer:SetShown(false)
	f.auraContainer:SetParent(nil)
	f.auraContainer = nil
	f.myUnit = nil
end

local function Icon_LayoutShared(self, parent, f)
	local f = parent[self.name]
	local level = parent:GetFrameLevel() + self.frameLevel
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	local size = self.iconSize
	if size<=1 then
		size = size * parent:GetHeight()
	end
	f:SetSize(size,size)
	f:Show()
	return level
end

-------------------------------------------------------------
-- standard non-secret statuses
-------------------------------------------------------------

local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if Frame.auraContainer then return; end
	if not status then Frame:Hide(); return; end
	local Icon = Frame.Icon
	Icon:SetTexCoord(status:GetTexCoord(unit))
	Icon:SetVertexColor(status:GetVertexColor(unit))
	local slot, durObject
	if status.GetIconData then
		local tex, cnt, exp, dur, color
		tex, cnt, exp, dur, color, slot = status:GetIconData(unit)
		if self.disableIcon then
			Icon:SetColorTexture(color.r, color.g, color.b)
		else
			Icon:SetTexture(tex)
		end
		if self.borderSize then
			local c = self.useStatusColor and color or self.color
			Frame:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		end
		Icon:SetAlpha(color.a or 1)
		if not self.disableStack then
			Frame.stackText:SetText( TruncateWhenZero(cnt or 0) )
			Frame.stackText:Show()
		end
		if not self.disableCooldown and exp and dur then
			if canaccessvalue(exp) then
				Frame.Cooldown:SetCooldownFromExpirationTime(exp, dur)
			else
				durObject = status:GetDurationObject(unit, slot)
				if durObject then
					Frame.Cooldown:SetCooldownFromDurationObject( durObject )
				end
			end
		end
	else
		local r,g,b,a = status:GetColor(unit)
		if self.disableIcon then
			Icon:SetColorTexture(r,g,b)
		else
			Icon:SetTexture(status:GetIcon(unit))
		end
		local border = status:GetBorder()
		if border==1 or self.useStatusColor then 	-- border=1 => always draw a border with the status color
			Frame:SetBackdropBorderColor(r,g,b,a)
		elseif border and self.borderSize then   	-- border=0 => status supports a border
			local c = self.color
			Frame:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		else										-- border=nil => never draw a border for the status
			Frame:SetBackdropBorderColor(0,0,0,0)
		end
		Icon:SetAlpha(a or 1)
		if not self.disableStack then
			local stackText = Frame.stackText
			if stackText.fontSize then -- This is a ugly fix for github issue #152
				stackText:SetFont(self.textfont, stackText.fontSize, self.dbx.fontFlags or "OUTLINE" )
				stackText.fontSize = nil
			end
			local count = status:GetCount(unit)
			if issecretvalue(count) then
				stackText:SetText( TruncateWhenZero(count) )
				stackText:Show()
			elseif count>1 then
				stackText:SetText( count )
				stackText:Show()
			else
				stackText:Hide()
			end
		end
		if not self.disableCooldown then
			local Cooldown = Frame.Cooldown
			local expiration, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
			if expiration and duration then
				if canaccessvalue(expiration) then
					Cooldown:SetCooldownFromExpirationTime(expiration, duration)
				else
					durObject = status:GetDurationObject(unit)
					if durObject then
						Cooldown:SetCooldownFromDurationObject( durObject )
					end
				end
				Cooldown:Show()
			else
				Cooldown:Hide()
			end
		end
	end
	if self.needDur then
		durObject = durObject or status:GetDurationObject(unit, slot)
		if self.showCoolBar then
			if durObject then
				Frame.coolBar:SetTimerDuration(durObject, 0, self.cbDirection)
				Frame.coolBar:Show()
			else
				Frame.coolBar:Hide()
			end
		end
		if self.showColors then
			UpdateIconColorCurve(Frame, durObject)
		end
	end
	Frame:Show()
end

local function Icon_Layout(self, parent)
	local f = parent[self.name]
	Icon_DisableAuraContainer(f)
	local level = Icon_LayoutShared(self, parent, f)
	Icon_ButtonCreate(self, parent, f, nil, level)
	Icon_ButtonLayout(self, parent, f, nil, level)
end

-------------------------------------------------------------
-- 12.1+ aura containers
-------------------------------------------------------------

local function Icon_UpdateAura(self, parent, unit)
	local f = parent[self.name]
	if not (f and f.auraContainer) then return end
	local unit = parent.unit
	if unit==f.myUnit then return end
	f.myUnit = unit
	f.auraContainer:SetShown(unit~=nil)
	f.auraContainer:SetUnit(unit)
	f.auraContainer:SetEnabled(unit~=nil)
end

local function Icon_LayoutAura(self, parent)
	local f = parent[self.name]
	Icon_DisableIconContainer(f)
	Icon_DisableAuraContainer(f)
	local level = Icon_LayoutShared(self, parent, f)
	local auraContainer = CreateFrame("AuraContainer", nil, f, "CustomAuraContainerTemplate")
	f.auraContainer = auraContainer
	auraContainer:ClearAllPoints()
	auraContainer:SetAllPoints()
	local aura_filter = self.statuses[1]:GetAurasFilter()
	auraContainer:AddAuraSlot( "1", aura_filter.filter, {
		sortMethod = aura_filter.sortMethod or 0,
		sortDirection = aura_filter.sortDirection or 0,
		candidateFilters = aura_filter.candidateFilters,
		initializeFrame = function(button)
			auraContainer._button = button
			button:SetFrameLevel(level)
			Icon_ButtonCreate(self, parent, button, auraContainer, level)
			Icon_ButtonLayout(self, parent, button, auraContainer, level)
		end
	} )
	auraContainer:Show()
end

-------------------------------------------------------------
-- shared
-------------------------------------------------------------

local function Icon_SetAuraMode(self, auraMode)
	if auraMode then
		self.Layout = Icon_LayoutAura
		self.UpdateO = Icon_UpdateAura
	else
		self.Layout = Icon_Layout
		self.UpdateO = Grid2.indicatorPrototype.Update
	end
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
	f.myUnit = nil
	if f.auraContainer then
		f.auraContainer:SetParent(nil)
		f.auraContainer = nil
	end
end

local function Icon_UpdateDB(self)
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	-- location
	local l = dbx.location
	self.anchor    = l.point
	self.anchorRel = l.relPoint
	self.offsetx   = l.x
	self.offsety   = l.y
	-- misc variables
	self.showSwipe       = not (dbx.disableCooldown or dbx.disableCooldownAnim)
	self.showCoolBar     = dbx.enableCooldownBar
	self.showCoolText    = dbx.enableCooldownText
	self.disableCooldown = dbx.disableCooldown and not dbx.enableCooldownText
	self.disableStack    = dbx.disableStack
	self.frameLevel      = dbx.level
	self.borderSize      = dbx.borderSize
	self.useStatusColor  = dbx.useStatusColor
	self.iconSize        = dbx.size or theme.iconSize or 14
	self.color           = Grid2.MakeColor(dbx.color1)
	-- stacks text
	local jV,jH = dbx.fontJustifyV or 'MIDDLE', dbx.fontJustifyH or 'CENTER'
	self.textPoint = (jV=='MIDDLE' and jH) or (jH=='CENTER' and jV) or jV..jH
	self.textOffsetX = dbx.fontOffsetX or 0
	self.textOffsetY = dbx.fontOffsetY or 0
	self.fontSize    = dbx.fontSize
	self.textfont    = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	-- ignore icon and use a solid square texture
	self.disableIcon  = dbx.disableIcon
	-- cooldown text
	local ctJV,ctJH      = dbx.ctFontJustifyV or 'MIDDLE', dbx.ctFontJustifyH or 'CENTER'
	self.ctFontFlags     = dbx.ctFontFlags or "OUTLINE"
	self.ctFontSize      = dbx.ctFontSize or 9
	self.ctFont          = Grid2:MediaFetch("font", dbx.ctFont or theme.font) or STANDARD_TEXT_FONT
	self.ctFontPoint     = (ctJV=='MIDDLE' and ctJH) or (ctJH=='CENTER' and ctJV) or ctJV..ctJH
	self.ctFontOffsetX   = dbx.ctFontOffsetX or 0
	self.ctFontOffsetY   = dbx.ctFontOffsetY or -1
	self.ctColor         = Grid2.MakeColor((dbx.ctColorsText and dbx.ctColors and dbx.ctColors[1] or dbx.ctColor), "WHITE")
	-- coldown bar
	local borderSize   = self.borderSize or 0
	self.cbPoint        = dbx.cbPoint or 'BOTTOM'
	self.cbOrientation  = (self.cbPoint=='LEFT' or self.cbPoint=='RIGHT') and 'VERTICAL' or 'HORIZONTAL'
	self.cbThickness    = dbx.cbThickness~=0 and (dbx.cbThickness or 2) or nil
	self.cbDirection    = dbx.cbDirection or 1
	self.cbReverse      = dbx.cbReverse or false
	self.cbTexture		= Grid2:MediaFetch("statusbar", dbx.cbTexture or 'Grid2 Flat', 'Grid2 Flat')
	self.cbOffsetX      = (self.cbPoint=='LEFT' or self.cbPoint=='BOTTOM') and borderSize or -borderSize
	self.cbOffsetY      = 0
	if self.cbOrientation=='HORIZONTAL' then self.cbOffsetX, self.cbOffsetY = self.cbOffsetY, self.cbOffsetX end
	self.cbColor        = Grid2.MakeColor(dbx.cbColor, "WHITE")
	self.cbColorBack    = Grid2.MakeColor(dbx.cbColorBack, "RED")
	-- color curve
	self.showColors      = dbx.ctColors~=nil
	self.showColorsText  = dbx.ctColorsText
	self.showColorsBorder= dbx.ctColorsBorder
	self.showColorsBar   = dbx.ctColorsBar
	if dbx.ctColors then
		self.ctColorCurve =  self.ctColorCurve or C_CurveUtil.CreateColorCurve()
		self.ctColorCurve:SetType(Enum.LuaCurveType.Step)
		self.ctColorCurve:ClearPoints()
		for i,color in ipairs(dbx.ctColors) do
			self.ctColorCurve:AddPoint(dbx.ctThresholds[i] or 0, color)
		end
	end
	self.needDur = self.showColors or self.showCoolBar
	-- backdrop
	self.backdrop = Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize or 1)
end

local function CreateIcon(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx 		  = dbx
	indicator.Create      = Icon_Create
	indicator.Layout      = Icon_Layout
	indicator.OnUpdate    = Icon_OnUpdate
	indicator.Disable     = Icon_Disable
	indicator.UpdateDB    = Icon_UpdateDB
	indicator.SetAuraMode = Icon_SetAuraMode
	-- indicator.GetBlinkFrame = indicator.GetFrame    -- NBot compatible with 12.1 auras container TODO / fix
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
