--[[ Icon indicator, created by Grid2 original authors, modified by Michael ]]-- 

local Grid2= Grid2
local GetTime = GetTime
local fmt= string.format
local media = LibStub("LibSharedMedia-3.0", true)

local function Icon_Create(self, parent)
	local f = self:CreateFrame("Frame", parent)
	if not f:IsShown() then	f:Show() end
	
	local borderSize = self.borderSize or 1
	f:SetBackdrop({
		edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = borderSize,
		insets = {left = borderSize, right = borderSize, top = borderSize, bottom = borderSize},
	})
	
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetAllPoints()
	if not Icon:IsShown() then Icon:Show() end

	if not self.disableCooldown then
		local Cooldown
		if self.dbx.disableOmniCC then
			Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
			Cooldown.noCooldownCount= true 
		else
			local name= self.name:gsub("%-","")
			local i,j = parent:GetName():match("Grid2LayoutHeader(%d+)UnitButton(%d+)")
			Cooldown = f.Cooldown or CreateFrame("Cooldown", fmt("Grid2%s%02d%02d",name,i,j) , f, "CooldownFrameTemplate")
			Cooldown.noCooldownCount= nil
		end
		Cooldown:SetAllPoints(f)
		Cooldown:SetReverse(self.dbx.reverseCooldown)
		Cooldown:Hide()
		f.Cooldown = Cooldown
	end
	
	if not self.disableStack then
		local CooldownText = f.CooldownText or f:CreateFontString(nil, "OVERLAY")
		CooldownText:SetAllPoints()
		CooldownText:SetFontObject(GameFontHighlightSmall)
		local font = self.dbx.font and media and media:Fetch("font", self.dbx.font) or CooldownText:GetFont()
		CooldownText:SetFont(font, self.dbx.fontSize)
		CooldownText:SetJustifyH( self.dbx.fontJustifyH or "CENTER" )
		CooldownText:SetJustifyV( self.dbx.fontJustifyV or "MIDDLE" )
		local c= self.dbx.stackColor
		if c then CooldownText:SetTextColor(c.r, c.g, c.b, c.a) end	
		CooldownText:SetShadowOffset(1, -1)
		CooldownText:Hide()
		f.CooldownText = CooldownText
	end	

end

local function Icon_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not status then Frame:Hide()	return end
	
	local Icon= Frame.Icon
	
	Icon:SetTexture(status:GetIcon(unit))
	Icon:SetTexCoord(status:GetTexCoord(unit))
	Icon:SetVertexColor(status:GetVertexColor(unit))

	local r,g,b,a= status:GetColor(unit)
	if status:GetBorder(unit) then
		Frame:SetBackdropBorderColor(r,g,b,a) 
	elseif self.borderSize then
		local c= self.color
		Frame:SetBackdropBorderColor(c.r, c.g, c.b, c.a) 
	else
		Frame:SetBackdropBorderColor(0,0,0,0)
	end
	Icon:SetAlpha(a or 1)

	if not self.disableStack then
		local count= status:GetCount(unit)
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
	
	Frame:Show()
end

local function Icon_SetIndicatorSize(self, parent, size)
	parent[self.name]:SetSize(size,size)
end

local function Icon_SetBorderSize(self, parent, borderSize)
	local f = parent[self.name]
	local backdrop = f:GetBackdrop()

	local Icon = f.Icon
	if borderSize then
		Icon:SetPoint("TOPLEFT", f ,"TOPLEFT", borderSize, -1 * borderSize)
		Icon:SetPoint("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -1 * borderSize, borderSize)
		backdrop.edgeSize = borderSize
	else
		Icon:SetAllPoints(f)
		backdrop.edgeSize = 1
		borderSize = 1
	end
	backdrop.insets.left = borderSize
	backdrop.insets.right = borderSize
	backdrop.insets.top = borderSize
	backdrop.insets.bottom = borderSize

	local r, g, b, a = f:GetBackdropBorderColor()

	f:SetBackdrop(backdrop)
	f:SetBackdropBorderColor(r, g, b, a)
end

local function Icon_Layout(self, parent)
	local Icon = parent[self.name]
	Icon:ClearAllPoints()
	Icon:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Icon:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	Icon_SetBorderSize(self, parent, self.borderSize)
	local size = self.dbx.size
	Icon:SetSize(size,size)
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f.Icon:Hide()
	if f.Cooldown then f.Cooldown:Hide() end
	if f.CooldownText then f.CooldownText:Hide() end
	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
	self.SetIndicatorSize = nil
	self.SetBorderSize = nil
end

local function Icon_UpdateDB(self, dbx)
	dbx= dbx or self.dbx
	local l= dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.disableCooldown= dbx.disableCooldown
	self.disableStack= dbx.disableStack
	self.frameLevel = dbx.level
	self.borderSize= dbx.borderSize
	self.color= Grid2:MakeColor(dbx.color1)
	self.Create = Icon_Create
	self.GetBlinkFrame = Icon_GetBlinkFrame
	self.Layout = Icon_Layout
	self.OnUpdate = Icon_OnUpdate
	self.SetIndicatorSize = Icon_SetIndicatorSize
	self.SetBorderSize = Icon_SetBorderSize
	self.Disable = Icon_Disable
	self.UpdateDB = Icon_UpdateDB
	self.dbx = dbx
end


local function CreateIcon(indicatorKey, dbx)
	local existingIndicator = Grid2.indicators[indicatorKey]
	local indicator = existingIndicator or Grid2.indicatorPrototype:new(indicatorKey)
	Icon_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
