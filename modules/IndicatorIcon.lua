--[[ Icon indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local fmt = string.format

local function Icon_Create(self, parent)
	local f = self:Acquire("Frame", parent, "BackdropTemplate")
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetAllPoints()
	Icon:Show()

	if not self.disableCooldown then
		local Cooldown
		if self.dbx.disableOmniCC then
			Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
			Cooldown.noCooldownCount = true
		else
			local name = self.name:gsub("%-","")
			local i,j = parent:GetName():match("Grid2LayoutHeader(%d+)UnitButton(%d+)")
			Cooldown = f.Cooldown or CreateFrame("Cooldown", fmt("Grid2%s%02d%02d",name,i,j) , f, "CooldownFrameTemplate")
			Cooldown.noCooldownCount = nil
			Cooldown:SetDrawEdge(false) -- Without this omnicc uses only "Recharges color"
		end
		Cooldown:SetReverse(self.dbx.reverseCooldown)
		Cooldown:SetHideCountdownNumbers(true)
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
end

local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not status then Frame:Hide(); return; end

	local Icon = Frame.Icon
	local r,g,b,a = status:GetColor(unit)

	if self.disableIcon then
		Icon:SetColorTexture(r,g,b)
	else
		Icon:SetTexture(status:GetIcon(unit))
	end
	Icon:SetTexCoord(status:GetTexCoord(unit))
	Icon:SetVertexColor(status:GetVertexColor(unit))

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
		local count = status:GetCount(unit)
		if count>1 then
			if CooldownText.fontSize then -- This is a ugly fix for github issue #152
				CooldownText:SetFont(self.textfont, CooldownText.fontSize, self.dbx.fontFlags or "OUTLINE" )
				CooldownText.fontSize = nil
			end
			CooldownText:SetText( count )
			CooldownText:Show()
		else
			CooldownText:Hide()
		end
	end

	if not self.disableCooldown then
		local expiration, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
		if expiration and duration then
			Frame.Cooldown:SetCooldown(expiration - duration, duration)
			Frame.Cooldown:Show()
		else
			Frame.Cooldown:Hide()
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

	if f.Cooldown and self.disableIcon then
		f.Cooldown:SetSwipeTexture(0)
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
	self.disableCooldown = dbx.disableCooldown
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
