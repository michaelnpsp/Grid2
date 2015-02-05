-- Aura Icons indicator

local Grid2 = Grid2

local function Icon_Create(self, parent)
	local f = self:CreateFrame("Frame", parent)
	f.auras = f.auras or {}
	f.visibleCount = 0
end

local function Icon_OnUpdate(self, parent, unit, status)
	local f = parent[self.name]
	if not status then f:Hide()	return end
	local i, auras = 1, f.auras
	if status.IterateAuras then
		local auras = f.auras
		for name, texture, count, expiration, duration in status:IterateAuras(unit) do
			local aura = auras[i]
			aura.icon:SetTexture(texture)
			if self.showStack    then aura.text:SetText(count>1 and count or "") end
			if self.showCooldown then aura.cooldown:SetCooldown(expiration - duration, duration) end
			aura:Show()
			i = i + 1
			if i>self.maxIcons then break end
		end
	else
		local aura = auras[1]
		aura.icon:SetTexture(status:GetIcon(unit))
		if self.showStack then 
			local count = status:GetCount(unit)
			aura.text:SetText(count>1 and count or "") 
		end
		if self.showCooldown then 
			local expiration, duration = status:GetExpirationTime(unit) or 0, status:GetDuration(unit) or 0
			aura.cooldown:SetCooldown(expiration - duration, duration) 
		end
		aura:Show()
		i = i + 1
	end	
	for j=i,f.visibleCount do
		auras[j]:Hide()
	end
	f.visibleCount = i-1
	f:Show()
end

local pointsX = { TOPLEFT =  1,	TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT = -1 }
local pointsY = { TOPLEFT = -1, TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT =  1 }
local function Icon_Layout(self, parent)
	local f = parent[self.name]
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchor, self.offsetx, self.offsety)
	f:SetSize(1,1)
	f:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	local x,y,ux,uy,vx,vy = 0, 0, pointsX[self.anchor], 0, 0, pointsY[self.anchor]
	if self.orientation=="VERTICAL" then
		ux,vx = vx,ux; uy,vy = vy,uy
	end
	local size = self.iconSize + self.iconSpacing	
	local auras = f.auras
	for i=1,self.maxIcons do
		local frame = auras[i]
		if not frame then
			frame = CreateFrame("Frame", nil, f)
			frame.icon = frame:CreateTexture(nil, "ARTWORK")
			frame.text = frame:CreateFontString(nil, "OVERLAY")	
			frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
			frame.cooldown:SetHideCountdownNumbers(true)
			auras[i] = frame			
		end
		frame:SetSize( self.iconSize, self.iconSize )		
		-- frame container
		if self.borderSize>0 then
			local c = self.colorBorder
			frame:SetBackdrop(self.backdrop)
			frame:SetBackdropBorderColor(c.r,c.g,c.b,c.a)
		else
			frame:SetBackdrop(nil)
		end	
		frame:ClearAllPoints()
		frame:SetPoint( self.anchor, f, self.anchor, (x*ux+y*vx)*size, (x*uy+y*vy)*size )
		-- stack count text
		if self.showStack then
			local text = frame.text
			text:SetFontObject(GameFontHighlightSmall)
			text:SetFont(self.font, self.fontSize, self.fontFlags or "OUTLINE" )
			local c = self.colorStack
			text:SetTextColor(c.r, c.g, c.b, c.a)
			local justifyH = self.dbx.fontJustifyH or "CENTER"
			local justifyV = self.dbx.fontJustifyV or "MIDDLE"
			text:SetJustifyH( justifyH )
			text:SetJustifyV( justifyV  )
			text:ClearAllPoints()
			text:SetPoint("TOP")
			text:SetPoint("BOTTOM")
			text:SetPoint("LEFT" , justifyH=="LEFT"  and 0 or -self.iconSize, 0)
			text:SetPoint("RIGHT", justifyH=="RIGHT" and 2 or  self.iconSize+2, 0)
			text:Show()
		else	
			frame.text:Hide()
		end
		-- cooldown animation
		if self.showCooldown then
			frame.cooldown:SetReverse(self.dbx.reverseCooldown)
			frame.cooldown:SetAllPoints()
			frame.cooldown:Show()
		else
			frame.cooldown:Hide()
		end	
		-- icon texture
		frame.icon:SetPoint("TOPLEFT",     frame ,"TOPLEFT",  self.borderSize, -self.borderSize)
		frame.icon:SetPoint("BOTTOMRIGHT", frame ,"BOTTOMRIGHT", -self.borderSize, self.borderSize)
		frame.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		--
		frame:Hide()
		x = x + 1
		if x>=self.maxIconsPerRow then x = 0; y = y + 1 end
	end
	f.visibleCount = 0
end

local function Icon_Disable(self, parent)
	parent[self.name]:Hide()
	self.Layout = nil
	self.OnUpdate = nil
end

local function Icon_UpdateDB(self, dbx)
	dbx = dbx or self.dbx
	self.dbx = dbx
	-- location
	local l = dbx.location
	self.anchor    = l.point
	self.offsetx   = l.x
	self.offsety   = l.y
	-- misc variables
	self.borderSize      = dbx.borderSize or 0
	self.orientation     = dbx.orientation or "HORIZONTAL"
	self.frameLevel      = dbx.level or 1
	self.maxIcons        = dbx.maxIcons or 6
	self.maxIconsPerRow  = dbx.maxIconsPerRow or 3
	self.iconSize        = dbx.iconSize or 12
	self.iconSpacing     = dbx.iconSpacing or 1
	self.showCooldown    = not dbx.disableCooldown
	self.showStack       = not dbx.disableStack
	self.colorBorder     = Grid2:MakeColor(dbx.color1, "WHITE")
	self.colorStack      = Grid2:MakeColor(dbx.colorStack, "WHITE")
	self.fontFlags       = dbx.fontFlags
	self.fontSize        = dbx.fontSize or 9
	self.font            = Grid2:MediaFetch("font", dbx.font or Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT
	-- backdrop
	if self.borderSize>0 then
		local backdrop         = self.backdrop   or {}
		backdrop.insets        = backdrop.insets or {}
		backdrop.edgeFile      = "Interface\\Addons\\Grid2\\media\\white16x16"
		backdrop.edgeSize      = self.borderSize
		backdrop.insets.left   = self.borderSize
		backdrop.insets.right  = self.borderSize
		backdrop.insets.top    = self.borderSize
		backdrop.insets.bottom = self.borderSize
		self.backdrop          = backdrop	
	end	
	-- methods
	self.Create        = Icon_Create
	self.Layout        = Icon_Layout
	self.OnUpdate      = Icon_OnUpdate
	self.Disable       = Icon_Disable
	self.UpdateDB      = Icon_UpdateDB
end

Grid2.setupFunc["icons"] = function(indicatorKey, dbx)
	local indicator = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	Icon_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end
