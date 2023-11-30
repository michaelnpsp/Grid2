--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local GetTime = GetTime
local min = min
local TimerCreate  = Grid2.CreateTimer
local TimerDestroy = Grid2.CancelTimer

local AlignPoints = Grid2.AlignPoints
local defaultBackColor = { r=0, g=0, b=0, a=1 }

local function Bar_CreateHH(self, parent)
	local bar = self:Acquire("StatusBar", parent)
	bar.indicator = self
	bar:SetStatusBarColor(0,0,0,0)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	if self.backColor then
		bar.bgTex = bar.bgTex or bar:CreateTexture()
	end
end

function Bar_CanCreateChild(self, parent)
	return parent[self.parentName]~=nil
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
			bgTex:SetTexture(self.backTexture)
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

-- normal setvalue function
local function Bar_SetValue(self, parent, value)
	parent[self.name]:SetValue(value)
end

-- workaround to fix a bug in statusbar (https://github.com/Stanzilla/WoWUIBugs/issues/498)
local function Bar_SetValueBg(self, parent, value)
	parent[self.name]:SetValue(value==0 and 0.00001 or value)
end

local function Bar_SetValueParent(self, parent, value)
	parent[self.name]:SetValue(value==0 and 0.00001 or value) -- workaround to statusbar bug
	local barChild = parent[self.childName]
	local childValue = barChild.realValue or 0
	if childValue>0 then
		barChild:SetValue( value+childValue>1 and 1-value or childValue)
	end
end

local function Bar_SetValueChild(self, parent, value)
	local parentIndicator = parent[self.parentName]
	if parentIndicator then
		local parentValue = parentIndicator:GetValue()
		local barChild = parent[self.name]
		barChild:SetValue(value+parentValue>1 and 1-parentValue or value)
		barChild.realValue = value
	end
end

--{{{ Bar OnUpdate
local timers = {}
local function tdestroy(bar)
	local timer = timers[bar]
	if timer then
		timers[bar], timer._bar = nil, nil
		TimerDestroy(nil, timer)
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
		timer = TimerCreate(nil, tevent, delay)
		timer._bar = bar
		timers[bar] = timer
	elseif duration<=3 then
		timer:SetDuration(delay)
	end
	bar._duration   = duration
	bar._expiration = expiration
	return timer
end

-- standard updates, bar always visible
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

-- special updates when background is enabled, bar hidden if no status active
local function Bar_OnUpdateD2(self, parent, unit, status)
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
		self:SetValue(parent,value)
		bar:Show()
	else
		tdestroy(bar)
		bar:Hide()
	end
end

local function Bar_OnUpdateS2(self, parent, unit, status)
	self:SetValue( parent, status and status:GetCount(unit)/status:GetCountMax(unit) or 0)
	parent[self.name]:SetShown(status~=nil)
end

local function Bar_OnUpdate2(self, parent, unit, status)
	self:SetValue(parent, status and status:GetPercent(unit) or 0)
	parent[self.name]:SetShown(status~=nil)
end
--}}}

local function Bar_SetOrientation(self, orientation)
	self.orientation     = orientation or Grid2Frame.db.profile.orientation
	self.dbx.orientation = orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	bar:Hide()
	bar:SetParent(nil)
	bar:ClearAllPoints()
	tdestroy(bar)
end

local function Bar_Destroy(self, parent, bar)
	tdestroy(bar)
	bar.indicator = nil
end

local function Bar_UpdateDB(self)
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	local l = dbx.location
	self.texture     = Grid2:MediaFetch("statusbar", dbx.texture or theme.barTexture, "Gradient")
	self.backTexture = dbx.backTexture and Grid2:MediaFetch("statusbar", dbx.backTexture, "Gradient") or self.texture
	self.orientation = dbx.orientation or theme.orientation
	self.frameLevel  = dbx.level or 1
	self.anchor      = l.point
	self.anchorRel   = l.relPoint
	self.offsetx     = l.x
	self.offsety     = l.y
	self.width       = dbx.width
	self.height      = dbx.height
	self.reverseFill = not not dbx.reverseFill
	self.backColor   = dbx.backColor or (dbx.invertColor and defaultBackColor) or nil
	if dbx.hideWhenInactive then
		self.OnUpdate = (dbx.duration and Bar_OnUpdateD2) or (dbx.stack and Bar_OnUpdateS2) or Bar_OnUpdate2
	else
		self.OnUpdate = (dbx.duration and Bar_OnUpdateD) or (dbx.stack and Bar_OnUpdateS) or Bar_OnUpdate
	end
	if dbx.anchorTo then
		local barParent = Grid2.indicators[dbx.anchorTo]
		barParent.childName = self.name
		barParent.SetValue  = Bar_SetValueParent
		self.SetValue       = Bar_SetValueChild
		self.CanCreate      = Bar_CanCreateChild
		self.parentName     = dbx.anchorTo
		self.reverseFill    = barParent.reverseFill
		self.orientation    = barParent.orientation
	else
		self.SetValue = dbx.backColor and Bar_SetValueBg or Bar_SetValue
		self.CanCreate = self.prototype.CanCreate
		self.parentName = nil
		if self.childName then -- fix changing orientation on themes, CF issue #1227
			Grid2.indicators[self.childName].orientation = self.orientation
		end
	end
end

local function BarColor_OnUpdate(self, parent, unit, status)
	local bar = parent[self.parentName]
	if bar then
		if status then
			local r, g, b, a = status:GetColor(unit)
			bar:SetStatusBarColor(r, g, b, min(self.opacity, a or 1) )
		else
			bar:SetStatusBarColor(0,0,0,0)
		end
	end
end

local function BarColor_OnUpdateInverted(self, parent, unit, status)
	local bar = parent[self.parentName]
	if bar then
		local r, g, b, a
		if status then
			r, g, b, a = status:GetColor(unit)
		else
			r, g, b, a = 0, 0, 0, 0
		end
		local c = self.backColor
		bar:SetStatusBarColor(c.r, c.g, c.b, min(self.opacity, 0.8))
		if not self.dbx.anchorTo then
			bar.bgTex:SetVertexColor(r, g, b, (a or 1)*c.a)
		end
	end
end

local function BarColor_UpdateDB(self)
	local dbx = self.dbx
	self.OnUpdate  = dbx.invertColor and BarColor_OnUpdateInverted or BarColor_OnUpdate
	self.backColor = dbx.backColor or defaultBackColor
	self.opacity   = dbx.opacity or 1
end

local function Create(indicatorKey, dbx)
	local Bar = Grid2.indicatorPrototype:new(indicatorKey)
	Bar.dbx            = dbx
	Bar.Create         = Bar_CreateHH
	Bar.Destroy        = Bar_Destroy
	Bar.OnUpdate       = Bar_OnUpdate
	Bar.SetOrientation = Bar_SetOrientation
	Bar.Disable        = Bar_Disable
	Bar.Layout         = Bar_Layout
	Bar.UpdateDB       = Bar_UpdateDB
	Bar.GetBlinkFrame  = Bar.GetFrame
	Grid2:RegisterIndicator(Bar, { "percent" } )

	local BarColor      = Grid2.indicatorPrototype:new(indicatorKey.."-color")
	BarColor.dbx        = dbx
	BarColor.parentName = indicatorKey
	BarColor.Create     = Grid2.Dummy
	BarColor.Layout     = Grid2.Dummy
	BarColor.OnUpdate   = BarColor_OnUpdate
	BarColor.UpdateDB   = BarColor_UpdateDB
	Grid2:RegisterIndicator(BarColor, { "color" })

	Bar.sideKick = BarColor

	return Bar, BarColor
end

Grid2.setupFunc["bar"] = Create

Grid2.setupFunc["bar-color"] = Grid2.Dummy
