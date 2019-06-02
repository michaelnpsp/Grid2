--[[ Icon indicator, created by Grid2 original authors, modified by Michael ]]-- 

local Grid2 = Grid2
local GetTime = GetTime
local fmt = string.format

local function Icon_Create(self, parent)
	local f = self:CreateFrame("Frame", parent)
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
		CooldownText:SetFont(self.textfont, self.dbx.fontSize, self.dbx.fontFlags or "OUTLINE" )
		local c = self.dbx.stackColor
		if c then CooldownText:SetTextColor(c.r, c.g, c.b, c.a) end	
		CooldownText:Hide()
		f.CooldownText = CooldownText
	end
end

local function Icon_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Icon_AnimationOnUpdate(frame, elapsed)
	local status = frame.status
	local duration = status.animDuration
	elapsed = elapsed + frame.animElapsed
	if elapsed < duration then
		frame.animElapsed = elapsed
		elapsed = elapsed / duration
		if elapsed>0.5 then elapsed = 1-elapsed end
		frame:SetScale( 1 + elapsed*status.animScale )
	else
		frame.animElapsed = nil
		frame:SetScript("OnUpdate", nil)
		frame:SetScale(1)
	end
end

local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not status then Frame:Hide() return end
	
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
		local count = status:GetCount(unit)
		if count>1 then 
			Frame.CooldownText:SetText(count)
			Frame.CooldownText:Show()
		else
			Frame.CooldownText:Hide()
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

	if self.animEnabled and (not Frame.animElapsed) and (self.animOnUpdate or not Frame:IsVisible()) then
		Frame.status = self
		Frame.animElapsed = 0
		Frame:SetScript("OnUpdate", Icon_AnimationOnUpdate )
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
		Icon:SetPoint("TOPLEFT", f ,"TOPLEFT", borderSize, -borderSize)
		Icon:SetPoint("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -borderSize, borderSize)
	else
		Icon:SetAllPoints(f)
	end
	Grid2:SetFrameBackdrop(f, self.backdrop)
	f:SetBackdropBorderColor(r, g, b, a)
	local size = self.iconSize
	f:SetSize(size,size)
	
	if not self.disableStack then
		if f.TextFrame then	f.TextFrame:SetFrameLevel(level+2) end
		local CooldownText = f.CooldownText
		local justifyH = self.dbx.fontJustifyH or "CENTER"
		local justifyV = self.dbx.fontJustifyV or "MIDDLE"
		CooldownText:SetJustifyH( justifyH )
		CooldownText:SetJustifyV( justifyV )
		CooldownText:ClearAllPoints()
		CooldownText:SetPoint("TOP")
		CooldownText:SetPoint("BOTTOM")
		CooldownText:SetPoint("LEFT" , justifyH=="LEFT"  and 0 or -size, 0)
		CooldownText:SetPoint("RIGHT", justifyH=="RIGHT" and 2 or  size+2, 0)
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
	self.textfont        = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	-- animation
	self.animEnabled  = dbx.animEnabled
	if dbx.animEnabled then
		self.animScale    = ((dbx.animScale or 1.5)-1) * 2
		self.animDuration = dbx.animDuration or 0.7
		self.animOnUpdate = not dbx.animOnEnabled
	end
	-- ignore icon and use a solid square texture
	self.disableIcon  = dbx.disableIcon
	-- backdrop
	self.backdrop = Grid2:GetBackdropTable("Interface\\Addons\\Grid2\\media\\white16x16", self.borderSize or 1)
end


local function CreateIcon(indicatorKey, dbx)
	local indicator = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx 			= dbx
	indicator.Create        = Icon_Create
	indicator.GetBlinkFrame = Icon_GetBlinkFrame
	indicator.Layout        = Icon_Layout
	indicator.OnUpdate      = Icon_OnUpdate
	indicator.Disable       = Icon_Disable
	indicator.UpdateDB      = Icon_UpdateDB
	Icon_UpdateDB(indicator)
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
