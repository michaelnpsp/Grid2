--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local string_sub = string.subutf8 or string.sub

local justifyH = {
	CENTER = "CENTER",
	TOP = "CENTER",
	BOTTOM = "CENTER",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	TOPLEFT = "LEFT",
	TOPRIGHT = "RIGHT",
	BOTTOMLEFT = "LEFT",
	BOTTOMRIGHT = "RIGHT",
}
local justifyV = {
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
	LEFT = "CENTER",
	RIGHT = "CENTER",
	TOPLEFT = "TOP",
	TOPRIGHT = "TOP",
	BOTTOMLEFT = "BOTTOM",
	BOTTOMRIGHT = "BOTTOM",
}

local function Text_Create(self, parent)
	local f= self:CreateFrame("Frame", parent)
	f:SetAllPoints()
	if not f:IsShown() then
		f:SetBackdrop(nil)
		f:Show()
	end
	
	local Text = f.Text or f:CreateFontString(nil, "OVERLAY")
	f.Text = Text
	Text:SetFontObject(GameFontHighlightSmall)
	Text:SetFont(self.textfont, self.dbx.fontSize, self.dbx.fontFlags)
	Text:SetJustifyH("CENTER")
	Text:SetJustifyV("CENTER")
end

local function Text_GetBlinkFrame(self, parent)
	return parent[self.name]:GetParent()
end

local function Text_Layout(self, parent)
	local Text = parent[self.name].Text
	Text:ClearAllPoints()
	Text:GetParent():SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Text:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	Text:SetJustifyH(justifyH[self.anchorRel])
	Text:SetJustifyV(justifyV[self.anchorRel])
	Text:SetWidth(parent:GetWidth())
end

--{{{ Text OnUpdate
local function dFormat(t)
	return t<1 and "%.1f" or "%.0f"
end

local function dsFormat(t)
	return t<1 and "%.1f:%s" or "%.0f:%d"
end

local durationTimers = {}
local expirations = {}
local stacks = {}
local function fD(Text)
	local timeLeft = expirations[Text] - GetTime()
	if timeLeft>0 then
		Text:SetFormattedText( dFormat(timeLeft), timeLeft )
	else
		Text:SetText("")
	end
end

local function fDS(Text)
	local timeLeft = expirations[Text] - GetTime()
	if timeLeft>0 then
		Text:SetFormattedText( dsFormat(timeLeft), timeLeft, stacks[Text] )
	else
		Text:SetText("")
	end	
end
local function fE(Text)
	Text:SetFormattedText( "%.0f", GetTime() - expirations[Text]  )
end
local function fES(Text)
	Text:SetFormattedText( "%.0f:%d", GetTime() - expirations[Text] , stacks[Text]  )
end

local function fcancel(Text)
	if durationTimers[Text] then
		Grid2:CancelTimer(durationTimers[Text])
		durationTimers[Text], expirations[Text], stacks[Text] = nil, nil, nil
	end	
end

local function GetDurationValue(expiration, Text, func)
	if expiration then
		local timeLeft = expiration - GetTime()
		if timeLeft>0 then
			expirations[Text] = expiration
			if not durationTimers[Text] then
				durationTimers[Text] = Grid2:ScheduleRepeatingTimer(func, 0.1, Text)
			end
			return timeLeft
		end
		fcancel(Text)
	end	
end

local function GetElapsedTimeValue(expiration, duration, Text, func)
	if expiration and duration then
		local curTime= GetTime()
		local timeLeft = expiration - curTime
		if timeLeft>0 then
			local startTime   = expiration - duration
			local timeElapsed = curTime - startTime
			expirations[Text] = startTime
			if not durationTimers[Text] then
				durationTimers[Text] = Grid2:ScheduleRepeatingTimer(func, 0.1, Text)
			end
			return timeElapsed
		end
		fcancel(Text)
	end	
end

local function SetDefaultText(self, Text, status, unit)
	Text:SetText( string_sub(status:GetText(unit) or "", 1, self.textlength) )
end

local function Text_OnUpdateDS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local stack= status:GetCount(unit) or 1
		local duration= GetDurationValue( status:GetExpirationTime(unit), Text, fDS )
		if duration then
			stacks[Text]= stack
			Text:SetFormattedText( dsFormat(duration), duration, stack )
		else
			SetDefaultText(self, Text, status, unit)
		end
		Text:Show()
	else
		fcancel(Text)
		Text:Hide()
	end
end

local function Text_OnUpdateES(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local stack  = status:GetCount(unit) or 1
		local elapsed= GetElapsedTimeValue( status:GetExpirationTime(unit), status:GetDuration(unit),  Text, fES )
		if elapsed then
			stacks[Text]= stack
			Text:SetFormattedText( "%.0f:%d", elapsed, stack )
		else
			SetDefaultText(self, Text, status, unit)
		end
		Text:Show()
	else
		fcancel(Text)
		Text:Hide()
	end
end

local function Text_OnUpdateD(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local duration= GetDurationValue( status:GetExpirationTime(unit), Text, fD )
		if duration then
			Text:SetFormattedText( dFormat(duration), duration )
		else
			SetDefaultText(self, Text, status, unit)
		end
		Text:Show()
	else
		fcancel(Text)
		Text:Hide()
	end
end

local function Text_OnUpdateE(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local elapsed= GetElapsedTimeValue( status:GetExpirationTime(unit), status:GetDuration(unit), Text, fE )
		if elapsed then
			Text:SetFormattedText( "%.0f", elapsed )
		else
			SetDefaultText(self, Text, status, unit)
		end
		Text:Show()
	else
		fcancel(Text)
		Text:Hide()
	end
end

local function Text_OnUpdateS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local content= status:GetCount(unit)
		if content then
			Text:SetFormattedText( "%d", content )
		else
			SetDefaultText(self, Text, status, unit)
		end
		Text:Show()
	else
		fcancel(Text)
		Text:Hide()
	end
end

local function Text_OnUpdateP(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local percent= status:GetPercent(unit)
		if percent then
			Text:SetFormattedText( "%.0f%%", percent*100 )
		else
			SetDefaultText(self, Text, status, unit)
		end
		Text:Show()
	else
		Text:Hide()
	end
end

local function Text_OnUpdate(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		Text:SetText( string_sub(status:GetText(unit) or "", 1, self.textlength) )
		Text:Show()
	else
		Text:Hide()
	end	
end
--}}}

local function Text_SetTextFont(self, parent, font, size, flags)
	parent[self.name].Text:SetFont(font or self.textfont, size or self.dbx.fontSize, flags or self.dbx.fontFlags)
end

local dummy = function (self)
end

local function TextColor_OnUpdate(self, parent, unit, status)
	local Text = parent[self.textname].Text
	if (status) then
		Text:SetTextColor(status:GetColor(unit))
	else
		Text:SetTextColor(1, 1, 1, 1)
	end
end

local function Text_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	local Text = f.Text
	Text:Hide()

	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
	self.SetTextFont = nil

	local TextColor = self.sideKick
	self.OnUpdate = dummy
end

local function Text_UpdateDB(self, dbx)
	dbx= dbx or self.dbx
	local l= dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level
	self.textlength= dbx.textlength or 16
	self.textfont  = Grid2:MediaFetch("font", dbx.font or Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT
	self.Create = Text_Create
	self.GetBlinkFrame = Text_GetBlinkFrame
	self.Layout = Text_Layout
	self.SetTextFont = Text_SetTextFont
	self.Disable = Text_Disable
	self.UpdateDB = Text_UpdateDB
	self.OnUpdate= 	(dbx.duration  and dbx.stack and Text_OnUpdateDS) or 
					(dbx.elapsed   and dbx.stack and Text_OnUpdateES) or
					(dbx.duration  and Text_OnUpdateD) or 
					(dbx.elapsed   and Text_OnUpdateE) or
					(dbx.stack 	   and Text_OnUpdateS) or 
					(dbx.percent   and Text_OnUpdateP) or
					Text_OnUpdate
	self.dbx = dbx
end

local function TextColor_UpdateDB(self, dbx)
	self.Create = dummy
	self.Layout = dummy
	self.OnUpdate = TextColor_OnUpdate
	self.dbx = dbx
end

local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	Text_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "text" })

	local colorKey = indicatorKey .. "-color"
	local TextColor = Grid2.indicators[colorKey] or Grid2.indicatorPrototype:new(colorKey)
	TextColor_UpdateDB(TextColor, dbx)
	TextColor.textname = indicatorKey
	Grid2:RegisterIndicator(TextColor, { "color" })

	indicator.sideKick = TextColor

	return indicator, TextColor
end

Grid2.setupFunc["text"] = Create

--ToDo: Is there a better way to handle this dual indicator creation?
local function CreateColor(indicatorKey, dbx)
end
Grid2.setupFunc["text-color"] = CreateColor
