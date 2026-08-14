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

-------------------------------------------------------------
-- shared
-------------------------------------------------------------

local function Icon_Create(self, parent)
	self:Acquire("Frame", parent, "BackdropTemplate")
end

local function Icon_ButtonCreate(self, parent, f, filter)
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:ClearAllPoints()
	Icon:SetAllPoints()
	Icon:SetColorTexture(0,0,0,0)
	Icon:Show()
	if filter then -- icon & border
		if self.disableIcon then
			f:ClearIcon()
		else
			f:SetIcon(Icon)
		end
	end
	if not self.disableCooldown then
		local Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
		Cooldown:SetDrawEdge(not not self.dbx.drawEdge)
		Cooldown:SetReverse(not not self.dbx.reverseCooldown)
		Cooldown:SetDrawSwipe(self.showSwipe)
		Cooldown:SetHideCountdownNumbers(not self.showCoolText)
		Cooldown:SetAllPoints()
		Cooldown:Show()
		if filter then f:SetDurationCooldown(Cooldown) end
		f.Cooldown = Cooldown
		if self.showCoolText then
			f.coolText = Cooldown:GetCountdownFontString()
			-- Icon_UpdateDB() clears ctOptions whenever the status color is used
			if filter then
				f:SetDurationText(f.coolText, self.useStatusColorText and filter.cooldownTextOptions or self.cooldownTextOptions)
			end
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
		local stackText = f.stackText
		if not stackText then
			stackText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			stackText:SetParent(TextFrame)
			f.stackText = stackText
		end
		if self.fontSize>=1 then stackText:SetFont(self.textfont, self.fontSize, self.dbx.fontFlags or "OUTLINE" ) end
		local c = self.dbx.stackColor
		if c then stackText:SetTextColor(c.r, c.g, c.b, c.a) end
		stackText:Show()
		f.stackText = stackText
		if filter then f:SetApplicationCount(stackText, {}) end
	end
	if filter then -- border
		f:ClearAuraBorder()
		-- the border texture covers the whole button and is masked by the icon, so it only
		-- reads as a border when there is a border size to inset the icon by
		if self.borderSize then
			local border = f.border or f:CreateTexture(nil, "BACKGROUND")
			border:ClearAllPoints()
			border:SetAllPoints()
			border:SetColorTexture(1,1,1,1)
			if self.useStatusColor then
				f:SetAuraBorder(border, filter.borderOptions)
			else
				border:SetColorTexture(UnpackColor(self.color))
			end
			border:Show()
			f.border = border
		elseif f.border then
			f.border:Hide()
		end
	end
	if self.showCoolBar then
		local bar = f.coolBar or CreateFrame("StatusBar", nil, f)
		bar:Hide()
		f.coolBar = bar
		local background = bar.background or bar:CreateTexture(nil, "BACKGROUND")
		background:ClearAllPoints()
		background:SetAllPoints()
		bar.background = background
		if filter then f:SetDurationBar(bar, self.cbOptions) end
	elseif f.coolBar then
		f.coolBar:Hide()
	end
end

local function Icon_ButtonLayout(self, parent, f, filter, size, level, status)
	local Icon = f.Icon
	local borderSize = self.borderSize
	if filter then -- 12.1+ aura container
		if borderSize then
			Icon:SetPoint("TOPLEFT", borderSize, -borderSize)
			Icon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
		else
			Icon:SetAllPoints(f)
		end
		if not self.disableIcon then
			Icon:SetTexCoord(Grid2.statusPrototype.GetTexCoord())
			Icon:Show()
		elseif self.disableIcon==true then
			Icon:SetTexCoord(0,1,0,1)
			Icon:SetColorTexture(status:GetColor())
			Icon:Show()
		else -- 0 => icon hidden
			Icon:Hide()
		end
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
		if self.useStatusColorText then
			-- the status alpha is meant for the icon and border, applying it here can make
			-- the countdown text unreadable, so only the status hue is used
			if status and not (filter and filter.cooldownTextOptions) then
				local r,g,b = status:GetColor()
				text:SetTextColor(r, g, b, 1)
			end
		else
			text:SetTextColor(color.r, color.g, color.b, color.a)
		end
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

	if not filter then
		f.colorCurveObject = self.showColors and self.ctColorCurve
		f.colorCurveText   = self.showColorsText and f.coolText
		f.colorCurveBar    = self.showColorsBar and f.coolBar
		f.colorCurveBorder = self.showColorsBorder and f.SetBackdropBorderColor
	end
end

local function Icon_DisableIconContainer(self, parent)
	local f = parent[self.name]
	if not f.iconContainer then return end
	f:Hide()
	f.iconContainer = nil
end

local function Icon_DisableAuraContainer(self, parent)
	self:ReleaseAuraSlotButton(parent)
end

-------------------------------------------------------------
-- standard non-secret statuses
-------------------------------------------------------------

local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not Frame.iconContainer then
		return
	end
	if not status then
		Frame:Hide()
		return
	end
	local Icon = Frame.Icon
	Icon:SetTexCoord(status:GetTexCoord(unit))
	Icon:SetVertexColor(status:GetVertexColor(unit))
	local durObject
	local r,g,b,a = status:GetColor(unit)
	if self.useStatusColorText then -- implies showCoolText, see Icon_UpdateDB()
		Frame.coolText:SetTextColor(r, g, b, 1)
	end
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
	if self.needDur then
		durObject = durObject or status:GetDurationObject(unit)
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

local function Icon_LayoutIcon(self, parent)
	local f = parent[self.name]
	local level = parent:GetFrameLevel() + self.frameLevel
	local size = self.iconSize
	if size<=1 then size = size * parent:GetHeight() end
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)
	f:SetSize(size,size)
	f:Show()
	Icon_ButtonCreate(self, parent, f)
	Icon_ButtonLayout(self, parent, f, nil, size, level)
	f.iconContainer = f
end

-------------------------------------------------------------
-- 12.1+ aura containers
-------------------------------------------------------------

local function Icon_LayoutAura(self, parent)
	local button, filter, status = self:AcquireAuraSlotButton(parent, filter)
	local level = parent:GetFrameLevel() + self.frameLevel
	local size = self.iconSize
	if size<=1 then size = size * parent:GetHeight() end
	button:ClearAllPoints()
	button:SetFrameLevel(level)
	button:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	button:SetSize(size, size)
	Icon_ButtonCreate(self, parent, button, filter)
	Icon_ButtonLayout(self, parent, button, filter, size, level, status)
end

-------------------------------------------------------------
-- shared
-------------------------------------------------------------

local function Icon_Layout(self, parent)
	if self.auraMode then
		Icon_LayoutAura(self, parent)
	else
		Icon_DisableAuraContainer(self, parent)
	end
	if self.iconMode then
		Icon_LayoutIcon(self, parent)
	else
		Icon_DisableIconContainer(self, parent)
	end
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
	Icon_DisableAuraContainer(self, parent)
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
	self.useStatusColorText = self.showCoolText and dbx.ctUseStatusColor
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
	self.cbOptions      = { direction = self.cbDirection }
	if self.cbOrientation=='HORIZONTAL' then self.cbOffsetX, self.cbOffsetY = self.cbOffsetY, self.cbOffsetX end
	self.cbColor        = Grid2.MakeColor(dbx.cbColor, "WHITE")
	self.cbColorBack    = Grid2.MakeColor(dbx.cbColorBack, "RED")
	-- +12.1 only aura countdown text colorization supported
	-- self.showColors      = dbx.ctColors~=nil
	-- self.showColorsText  = dbx.ctColorsText
	-- self.showColorsBorder= dbx.ctColorsBorder
	-- self.showColorsBar   = dbx.ctColorsBar
	-- self.needDur = self.showColors or self.showCoolBar
	if not self.useStatusColorText and dbx.ctColorsText and dbx.ctColors then
		self.ctColorCurve = self.ctColorCurve or C_CurveUtil.CreateColorCurve()
		self.ctColorCurve:SetType(Enum.LuaCurveType.Step)
		self.ctColorCurve:ClearPoints()
		for i,color in ipairs(dbx.ctColors) do
			self.ctColorCurve:AddPoint(dbx.ctThresholds[i] or 0, color)
		end
		self.cooldownTextOptions = { textColor={ curve=self.ctColorCurve, property=Enum.DurationTextBindingProperty.RemainingDuration } }
	else
		self.cooldownTextOptions = nil
	end
	-- backdrop
	self.backdrop = Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize or 1)
end

local function CreateIcon(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Icon_Create
	indicator.Layout = Icon_Layout
	indicator.Disable = Icon_Disable
	indicator.UpdateDB = Icon_UpdateDB
	indicator.OnUpdate = Icon_OnUpdate
	-- indicator.GetBlinkFrame = indicator.GetFrame    -- Not compatible with 12.1 auras container TODO / fix
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
