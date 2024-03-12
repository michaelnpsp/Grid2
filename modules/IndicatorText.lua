--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local string_cut = Grid2.strcututf8
local min = math.min
local next = next

local justifyH = { CENTER = "CENTER", TOP = "CENTER", BOTTOM = "CENTER", LEFT = "LEFT",   RIGHT = "RIGHT",  TOPLEFT = "LEFT", TOPRIGHT = "RIGHT", BOTTOMLEFT = "LEFT",   BOTTOMRIGHT = "RIGHT"  }
local justifyV = { CENTER = "CENTER", TOP = "TOP",    BOTTOM = "BOTTOM", LEFT = "CENTER", RIGHT = "CENTER", TOPLEFT = "TOP",  TOPRIGHT = "TOP",   BOTTOMLEFT = "BOTTOM", BOTTOMRIGHT = "BOTTOM" }

Grid2.defaults.profile.formatting = {
	longDecimalFormat        = "%.1f",
	shortDecimalFormat       = "%.0f",
	longDurationStackFormat  = "%.1f:%d",
	shortDurationStackFormat = "%.0f:%d",
	invertDurationStack      = false,
	secondsElapsedFormat     = "%ds",
	minutesElapsedFormat     = "%dm",
	percentFormat            = "%.0f%%",
}

local timers = {}
local stacks = {}
local expirations = {}

local curTime -- Here goes current time to minimize GetTime() calls

-- {{ Timer management
local TimerStart, TimerStop
do
	local timer
	function TimerStart(text, func)
		timer = Grid2:CreateTimer( function()
			curTime = GetTime()
			for text, func in next, timers do
				func(text)
			end
		end, 0.1 )
		timers[text] = func
		TimerStart = function(text, func)
			if not next(timers) then timer:Play() end
			timers[text] = func
		end
	end
	function TimerStop(text)
		timers[text], expirations[text], stacks[text] = nil, nil, nil
		if not next(timers) then timer:Stop() end
	end
end
--}}

-- {{ Update functions
local FmtDE  = {} -- masks for duration|elapsed
local FmtDES = {} -- masks for duration|elapsed & stacks
-- elapsed + stacks
local function _UpdateES(text)
	text:SetFormattedText( FmtDES[false], curTime - expirations[text] , stacks[text] or 1  )
end
-- stacks + elapsed
local function _UpdateSE(text)
	text:SetFormattedText( FmtDES[false], stacks[text] or 1, curTime - expirations[text] )
end
-- duration + stacks
local function _UpdateDS(text)
	local timeLeft = expirations[text] - curTime
	if timeLeft>0 then
		text:SetFormattedText( FmtDES[timeLeft<1], timeLeft, stacks[text] or 1 )
	else
		text:SetText("")
	end
end
-- stacks + duration
local function _UpdateSD(text)
	local timeLeft = expirations[text] - curTime
	if timeLeft>0 then
		text:SetFormattedText( FmtDES[timeLeft<1], stacks[text] or 1, timeLeft )
	else
		text:SetText("")
	end
end
-- elapsed
local FmtEM, FmtES
local function UpdateE(text)
	local t = curTime - expirations[text]
	if t>=60 then
		text:SetFormattedText( FmtEM, t/60 )
	else
		text:SetFormattedText( FmtES, t  )
	end
end
-- duration
local function UpdateD(text)
	local timeLeft = expirations[text] - curTime
	if timeLeft>0 then
		text:SetFormattedText( FmtDE[timeLeft<1], timeLeft )
	else
		text:SetText("")
	end
end
-- elapsed+stacks | stacks+elapsed
local UpdateES = _UpdateES
-- duration+stacks | stacks+duration
local UpdateDS = _UpdateDS
-- }}

--{{ Indicator methods
local function Text_Create(self, parent)
	local f = self:Acquire("Frame", parent)
	f:SetAllPoints()
	if f.SetBackdrop then f:SetBackdrop(nil) end
	local Text = f.Text or f:CreateFontString(nil, "OVERLAY")
	f.Text = Text
	Text:Show()
end

local function Text_Layout(self, parent)
	local Frame = parent[self.name]
	local Text  = Frame.Text
	Frame:SetParent(parent)
	Frame:ClearAllPoints()
	Frame:SetAllPoints()
	Frame:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Text:SetFont(self.textfont, self.textsize, self.fontFlags)
	Text:ClearAllPoints()
	Text:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	Text:SetJustifyH(justifyH[self.anchorRel])
	Text:SetJustifyV(justifyV[self.anchorRel])
	Text:SetWidth(parent:GetWidth())
	Text:SetShadowOffset(1,-1)
	Text:SetShadowColor(0,0,0, self.shadowAlpha)
	Text:Show()
	Frame:Show()
end

local function Text_OnUpdateDE(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		Text:Show()
		local expiration = status:GetExpirationTime(unit)
		if expiration then
			curTime = GetTime() -- not local because is used later by self.updateFunc
			if expiration > curTime then
				if self.stack then
					stacks[Text] = status:GetCount(unit)
				end
				if self.elapsed then
					expirations[Text] = min( expiration - (status:GetDuration(unit) or 0), curTime )
				else
					expirations[Text] = expiration
				end
				if not timers[Text] then
					TimerStart(Text, self.updateFunc)
				end
				self.updateFunc(Text)
				return
			end
		elseif self.elapsed then
			curTime = GetTime() -- not local because is used later by self.updateFunc
			expirations[Text] = status:GetStartTime(unit) or curTime
			if not timers[Text] then
				TimerStart(Text, self.updateFunc)
			end
			self.updateFunc(Text)
			return
		else
			Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
			if timers[Text] then TimerStop(Text) end
			return
		end
	end
	Text:Hide()
	if timers[Text] then TimerStop(Text) end
end

local function Text_OnUpdateS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local count = status:GetCount(unit)
		if count then
			Text:SetFormattedText( "%d", count )
		else
			Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
		end
		Text:Show()
	else
		Text:Hide()
	end
end

local FmtPercent
local function Text_OnUpdateP(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local percent, text
		if status.GetPercentText then
			text = status:GetPercentText(unit)
		else
			percent, text = status:GetPercent(unit)
		end
		if text then
			Text:SetText( text )
		elseif percent then
			Text:SetFormattedText( FmtPercent, percent*100 )
		else
			Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
		end
		Text:Show()
	else
		Text:Hide()
	end
end

local function Text_OnUpdate(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
		Text:Show()
	else
		Text:Hide()
	end
end

local function Text_OnUpdateTest(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status and status.name=='name' then
		local header = parent:GetParent()
		if header.headerType then
			local str = string_cut(status:GetText(unit) or header.headerType, self.textlength)
			Text:SetText( string.format("%s(%s)", str, header:GetAttribute('testIndex') or '') )
			Text:Show()
			return
		end
	end
	Text:Hide()
end

local function Text_Disable(self, parent)
	local f = parent[self.name]
	local Text = f.Text
	Text:Hide()
	if timers[Text] then TimerStop(Tsext) end
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
end

local function Text_Destroy(self, parent, frame)
	local Text = frame.Text
	if timers[Text] then TimerStop(Text) end
end

local function Text_UpdateDB(self)
	-- text fmt
	local fmt = Grid2.db.profile.formatting
	FmtDE[true] = fmt.longDecimalFormat
	FmtDE[false] = fmt.shortDecimalFormat
	FmtDES[true] = fmt.longDurationStackFormat
	FmtDES[false] = fmt.shortDurationStackFormat
	FmtES = fmt.secondsElapsedFormat
	FmtEM = fmt.minutesElapsedFormat
	FmtPercent = fmt.percentFormat
	UpdateES = fmt.invertDurationStack and _UpdateSE or _UpdateES
	UpdateDS = fmt.invertDurationStack and _UpdateSD or _UpdateDS
	-- indicator dbx
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	local l = dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level
	self.textlength = dbx.textlength or 16
	self.textfont = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	self.textsize = dbx.fontSize or theme.fontSize or 11
	if dbx.fontFlags then
		self.shadowAlpha = dbx.shadowDisabled and 0 or 1
		self.fontFlags   = dbx.fontFlags
	else
		self.shadowAlpha = theme.shadowDisabled and 0 or 1
		self.fontFlags   = theme.fontFlags
	end
	if Grid2.testThemeIndex then -- check layout test mode
		self.OnUpdate = Text_OnUpdateTest
	elseif dbx.duration or dbx.elapsed then
		self.stack = dbx.stack
		self.elapsed = dbx.elapsed
		if dbx.stack then
			self.updateFunc = dbx.elapsed and UpdateES or UpdateDS
		else
			self.updateFunc = dbx.elapsed and UpdateE or UpdateD
		end
		self.OnUpdate = Text_OnUpdateDE
	elseif dbx.stack then
		self.OnUpdate = Text_OnUpdateS
	elseif dbx.percent then
		self.OnUpdate = Text_OnUpdateP
	else
		self.OnUpdate = Text_OnUpdate
	end
end

local function TextColor_OnUpdate(self, parent, unit, status)
	local frame = parent[self.parentName]
	if frame then
		if status then
			frame.Text:SetTextColor(status:GetColor(unit))
		else
			frame.Text:SetTextColor(1, 1, 1, 1)
		end
	end
end

local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Text_Create
	indicator.Destroy = Text_Destroy
	indicator.Layout = Text_Layout
	indicator.Disable = Text_Disable
	indicator.UpdateDB = Text_UpdateDB
	indicator.GetBlinkFrame = indicator.GetFrame
	Grid2:RegisterIndicator(indicator, { "text" })

	local TextColor = Grid2.indicatorPrototype:new(indicatorKey.."-color")
	TextColor.dbx = dbx
	TextColor.parentName = indicatorKey
	TextColor.Create = Grid2.Dummy
	TextColor.Layout = Grid2.Dummy
	TextColor.OnUpdate = TextColor_OnUpdate
	Grid2:RegisterIndicator(TextColor, { "color" })

	indicator.sideKick = TextColor

	return indicator, TextColor
end

Grid2.setupFunc["text"] = Create
Grid2.setupFunc["text-color"] = Grid2.Dummy
-- }}
