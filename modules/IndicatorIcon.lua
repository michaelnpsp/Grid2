--[[ Icon indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local fmt = string.format

local issecretvalue = Grid2.issecretvalue
local canaccessvalue = Grid2.canaccessvalue
local UpdateCooldownColorCurve = Grid2.UpdateCooldownColorCurve
local RemoveCooldownColorCurve = Grid2.RemoveCooldownColorCurve
local TruncateWhenZero = C_StringUtil.TruncateWhenZero

local function Icon_Create(self, parent)
	local f = self:Acquire("Frame", parent, "BackdropTemplate")
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetAllPoints()
	Icon:Show()
	if not self.disableCooldown then
		local Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
		Cooldown:SetDrawEdge(false)
		Cooldown:SetReverse(self.dbx.reverseCooldown)
		Cooldown:SetDrawSwipe(self.showSwipe)
		Cooldown:SetHideCountdownNumbers(not self.showCoolText)
		Cooldown:Hide()
		f.Cooldown = Cooldown
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
		local CooldownText = f.CooldownText or f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		CooldownText:SetParent(TextFrame)
		if self.fontSize>=1 then CooldownText:SetFont(self.textfont, self.fontSize, self.dbx.fontFlags or "OUTLINE" ) end
		local c = self.dbx.stackColor
		if c then CooldownText:SetTextColor(c.r, c.g, c.b, c.a) end
		CooldownText:Hide()
		f.CooldownText = CooldownText
	end
	self:EnableFrameTooltips(f, self.dbx.tooltipEnabled)
end


local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not status then Frame:Hide(); return; end
	local Icon = Frame.Icon
	Icon:SetTexCoord(status:GetTexCoord(unit))
	Icon:SetVertexColor(status:GetVertexColor(unit))
	if status.GetIconData then
		local tex, cnt, exp, dur, color, slot = status:GetIconData(unit)
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
			Frame.CooldownText:SetText( TruncateWhenZero(cnt or 0) )
		end
		if not self.disableCooldown and exp and dur then
			Frame.Cooldown:SetCooldownFromExpirationTime(exp, dur)
			if self.showColors then
				UpdateCooldownColorCurve(Frame.Cooldown, status:GetDurationObject(unit, slot))
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
			local CooldownText = Frame.CooldownText
			if CooldownText.fontSize then -- This is a ugly fix for github issue #152
				CooldownText:SetFont(self.textfont, CooldownText.fontSize, self.dbx.fontFlags or "OUTLINE" )
				CooldownText.fontSize = nil
			end
			local count = status:GetCount(unit)
			if issecretvalue(count) then
				CooldownText:SetText( TruncateWhenZero(count) )
				CooldownText:Show()
			elseif count>1 then
				CooldownText:SetText( count )
				CooldownText:Show()
			else
				CooldownText:Hide()
			end
		end
		if not self.disableCooldown then
			local Cooldown = Frame.Cooldown
			local expiration, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
			if expiration and duration then
				if canaccessvalue(duration) then
					Cooldown:SetCooldown(expiration - duration, duration)
				else
					Cooldown:SetCooldownFromExpirationTime(expiration, duration)
				end
				if self.showColors then
					UpdateCooldownColorCurve(Cooldown, status:GetDurationObject(unit))
				end
				Cooldown:Show()
			else
				Cooldown:Hide()
			end
		end
	end
	Frame:Show()
end

local function Icon_Layout(self, parent)
	local f = parent[self.name]
	local level = parent:GetFrameLevel() + self.frameLevel
	f:SetParent(parent)
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)

	local Icon = f.Icon
	local r,g,b,a = f:GetBackdropBorderColor()
	local borderSize = self.borderSize
	if borderSize then
		Icon:SetPoint("TOPLEFT", borderSize, -borderSize)
		Icon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
	else
		Icon:SetAllPoints(f)
	end
	Grid2:SetFrameBackdrop(f, self.backdrop)
	if r then f:SetBackdropBorderColor(r, g, b, a) end
	local size = self.iconSize
	if size<=1 then
		size = size * parent:GetHeight()
	end
	f:SetSize(size,size)

	if self.showCoolText then
		local Cooldown = f.Cooldown
		local color, text = self.ctColor, f.Cooldown:GetCountdownFontString()
		text:SetFont(self.ctFont, self.ctFontSize, self.ctFontFlags)
		text:SetTextColor(color.r, color.g, color.b, color.a)
		text:ClearAllPoints()
		text:SetPoint(self.ctFontPoint, self.ctFontOffsetX, self.ctFontOffsetY)
		text:SetMaxLines(1)
		if self.showColors then
			Cooldown.colorCurveObject = self.ctColorCurve
		elseif Cooldown.countdownTextObject then -- executed only if the user changed the settings to remove possible color update timer
			RemoveCooldownColorCurve(Cooldown)
		end
	end

	if not self.disableStack then
		if f.TextFrame then	f.TextFrame:SetFrameLevel(level+2) end
		local CooldownText = f.CooldownText
		CooldownText:ClearAllPoints()
		CooldownText:SetPoint(self.textPoint, self.textOffsetX, self.textOffsetY)
		if self.fontSize<1 then CooldownText.fontSize = self.fontSize*size end	-- we cannot set font here, see github issue #152
	end
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
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
	self.showSwipe       = not (dbx.disableCooldown or dbx.disableCooldownAnim or dbx.disableIcon)
	self.showCoolText    = dbx.enableCooldownText
	self.disableCooldown = dbx.disableCooldown and not dbx.enableCooldownText
	self.disableStack    = dbx.disableStack
	self.frameLevel      = dbx.level
	self.borderSize      = dbx.borderSize
	self.useStatusColor  = dbx.useStatusColor
	self.iconSize        = dbx.size or theme.iconSize or 14
	self.color           = Grid2:MakeColor(dbx.color1)
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
	self.ctColor         = Grid2:MakeColor(dbx.ctColor or (dbx.ctColors and dbx.ctColors[1]), "WHITE")
	self.showColors      = dbx.ctColors~=nil
	if dbx.ctColors then
		self.ctColorCurve =  self.ctColorCurve or C_CurveUtil.CreateColorCurve()
		self.ctColorCurve:SetType(Enum.LuaCurveType.Step)
		self.ctColorCurve:ClearPoints()
		for i,color in ipairs(dbx.ctColors) do
			self.ctColorCurve:AddPoint(dbx.ctThresholds[i] or 0, color)
		end
	end
	-- backdrop
	self.backdrop = Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize or 1)
end

local function CreateIcon(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx 			= dbx
	indicator.Create        = Icon_Create
	indicator.Layout        = Icon_Layout
	indicator.OnUpdate      = Icon_OnUpdate
	indicator.Disable       = Icon_Disable
	indicator.UpdateDB      = Icon_UpdateDB
	indicator.GetBlinkFrame = indicator.GetFrame
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
