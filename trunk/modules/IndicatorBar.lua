--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local GetTime = GetTime
local min = min

local AlignPoints = Grid2.AlignPoints
local defaultBackColor = { r=0, g=0, b=0, a=1 }

local function Bar_CreateHH(self, parent)
	local bar = self:CreateFrame("StatusBar", parent)
	bar.indicator = self
	bar:SetStatusBarColor(0,0,0,0)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	if self.backColor then
		bar.bgTex = bar.bgTex or bar:CreateTexture()
	end
end

local function Bar_Layout(self, parent)
	local Bar    = parent[self.name]
	local bgTex  = Bar.bgTex
	local orient = self.orientation
	local points = AlignPoints[orient][not self.reverseFill]
	local level  = parent:GetFrameLevel() + self.frameLevel
	Bar:SetParent(parent)
	Bar:ClearAllPoints()
	Bar:SetOrientation(orient)
	Bar:SetStatusBarTexture(self.texture)
	Bar:SetReverseFill(self.reverseFill)
	local parentName = self.parentName
	if parentName then
		local PBar = parent[parentName]
		Bar:SetFrameLevel( PBar:GetFrameLevel() )
		Bar:SetSize( PBar:GetWidth(), PBar:GetHeight() )
		Bar:SetPoint( points[1], PBar:GetStatusBarTexture(), points[2], 0, 0)
		Bar:SetPoint( points[3], PBar:GetStatusBarTexture(), points[4], 0, 0)
		if bgTex then bgTex:Hide() end
	else
		local w = self.width  or parent.container:GetWidth()
		local h = self.height or parent.container:GetHeight()	
		Bar:SetFrameLevel(level)
		Bar:SetSize(w, h)
		Bar:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)			
		local color = self.backColor
		if color then
			local tex = Bar:GetStatusBarTexture()
			local layer, sublayer = tex:GetDrawLayer()
			bgTex:SetDrawLayer(layer, sublayer-1)
			bgTex:SetTexture(self.texture)
			bgTex:ClearAllPoints()
			if self.dbx.invertColor then
				bgTex:SetAllPoints(Bar)				
			else	
				bgTex:SetPoint( points[1], tex, points[2], 0, 0)
				bgTex:SetPoint( points[3], tex, points[4], 0, 0)
				bgTex:SetPoint( points[2], Bar, points[2], 0, 0)
				bgTex:SetPoint( points[4], Bar, points[4], 0, 0)
				bgTex:SetVertexColor( color.r, color.g, color.b, color.a )				
			end
			bgTex:Show()
		elseif bgTex then 
			bgTex:Hide() 
		end
	end
	Bar:Show()
end

local function Bar_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Bar_SetValue(self, parent, value)
	parent[self.name]:SetValue(value)
end

local function Bar_SetValueParent(self, parent, value)
	parent[self.name]:SetValue(value)
	local barChild = parent[self.childName]
	if value+barChild:GetValue()>1 then barChild:SetValue(1-value) end
end

local function Bar_SetValueChild(self, parent, value)
	local v = parent[self.parentName]:GetValue()
	if value+v>1 then value = 1-v end
	parent[self.name]:SetValue(value)	
end

--{{{ Bar OnUpdate
local timers = {}
local function tdestroy(bar)
	local timer = timers[bar]
	if timer then
		timers[bar], timer._bar = nil, nil
		Grid2:CancelTimer(timer)
	end
end
local function tevent(timer)
	local bar = timer._bar
	local timeLeft = bar._expiration - GetTime()
	if timeLeft>0 then
		timeLeft = timeLeft / bar._duration
	else
		timeLeft = 0; tdestroy(bar)
	end
	bar.indicator:SetValue( bar:GetParent(), timeLeft ) 
end
local function tcreate(bar, duration, expiration)
	local delay = duration>3 and 0.2 or 0.1
	local timer = timers[bar] 
	if not timer then
		timer = Grid2:CreateTimer(tevent, delay)
		timer._bar = bar
		timers[bar] = timer
	elseif duration<=3 then	
		timer:SetDuration(delay)
	end
	bar._duration   = duration
	bar._expiration = expiration
	return timer
end

local function Bar_OnUpdateD(self, parent, unit, status)
	local bar,value = parent[self.name],0
	if status then
		local expiration = status:GetExpirationTime(unit)
		if expiration then
			local timeLeft = expiration - GetTime()
			if timeLeft>0 then
				local duration = status:GetDuration(unit) or timeLeft
				value = timeLeft / duration
				tcreate(bar, duration, expiration)
			else
				tdestroy(bar)
			end
		end	
	else
		tdestroy(bar)
	end
	self:SetValue(parent,value)
end

local function Bar_OnUpdateS(self, parent, unit, status)
	self:SetValue( parent, status and status:GetCount(unit)/status:GetCountMax(unit) or 0)
end

local function Bar_OnUpdate(self, parent, unit, status)
	self:SetValue(parent, status and status:GetPercent(unit) or 0)
end
--}}}

local function Bar_SetOrientation(self, orientation)
	self.orientation     = orientation
	self.dbx.orientation = orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	bar:Hide()
	bar:SetParent(nil)
	bar:ClearAllPoints()	
end

local function Bar_UpdateDB(self)
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	local l = dbx.location
	self.texture     = Grid2:MediaFetch("statusbar", dbx.texture or theme.barTexture, "Gradient")
	self.orientation = dbx.orientation or theme.orientation
	self.frameLevel  = dbx.level or 1
	self.anchor      = l.point
	self.anchorRel   = l.relPoint
	self.offsetx     = l.x
	self.offsety     = l.y
	self.width       = dbx.width
	self.height      = dbx.height
	self.reverseFill = dbx.reverseFill	
	self.backColor   = dbx.backColor or (dbx.invertColor and defaultBackColor) or nil
	self.OnUpdate    = (dbx.duration and Bar_OnUpdateD) or (dbx.stack and Bar_OnUpdateS) or Bar_OnUpdate
	if dbx.anchorTo then
		local barParent = Grid2.indicators[dbx.anchorTo]
		barParent.childName = self.name
		barParent.SetValue  = Bar_SetValueParent
		self.parentName     = dbx.anchorTo
		self.SetValue       = Bar_SetValueChild		
		self.reverseFill    = barParent.reverseFill
		self.orientation    = barParent.orientation
	else
		self.SetValue = Bar_SetValue
		self.parentName = nil
	end
end

local function BarColor_OnUpdate(self, parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 0)
	end
end

local function BarColor_SetBarColor(self, parent, r, g, b, a)
	parent[self.parentName]:SetStatusBarColor(r, g, b, min(self.opacity,a or 1) )
end

local function BarColor_SetBarColorInverted(self, parent, r, g, b, a)
	local bar   = parent[self.parentName]
	local color = self.backColor
	bar:SetStatusBarColor(color.r, color.g, color.b, min(self.opacity, 0.8))
 	if not self.dbx.anchorTo then
		bar.bgTex:SetVertexColor(r, g, b, (a or 1)*color.a)
	end
end

local function BarColor_UpdateDB(self)
	if self.dbx.invertColor then
		self.backColor   = self.dbx.backColor or defaultBackColor
		self.SetBarColor = BarColor_SetBarColorInverted
	else
		self.SetBarColor = BarColor_SetBarColor
	end
	self.opacity = self.dbx.opacity or 1
end

local function Create(indicatorKey, dbx)
	local Bar = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	Bar.dbx            = dbx
	Bar.Create         = Bar_CreateHH
	Bar.GetBlinkFrame  = Bar_GetBlinkFrame
	Bar.OnUpdate       = Bar_OnUpdate
	Bar.SetOrientation = Bar_SetOrientation
	Bar.Disable        = Bar_Disable	
	Bar.Layout         = Bar_Layout	
	Bar.UpdateDB       = Bar_UpdateDB
	Bar_UpdateDB(Bar,dbx)
	Grid2:RegisterIndicator(Bar, { "percent" } )

	local colorKey      = indicatorKey .. "-color"
	local BarColor      = Grid2.indicators[colorKey] or Grid2.indicatorPrototype:new(colorKey)
	BarColor.dbx        = dbx
	BarColor.parentName = indicatorKey
	BarColor.Create     = Grid2.Dummy
	BarColor.Layout     = Grid2.Dummy
	BarColor.OnUpdate   = BarColor_OnUpdate
	BarColor.UpdateDB   = BarColor_UpdateDB
	BarColor_UpdateDB(BarColor)
	Grid2:RegisterIndicator(BarColor, { "color" })

	Bar.sideKick = BarColor

	return Bar, BarColor
end

Grid2.setupFunc["bar"] = Create

Grid2.setupFunc["bar-color"] = Grid2.Dummy
