--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local fmt= string.format
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
	local media = LibStub("LibSharedMedia-3.0", true)
	local font = media and media:Fetch("font", self.dbx.font or Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT

	local f= self:CreateFrame("Frame", parent)
	f:SetAllPoints()
	if not f:IsShown() then
		f:SetBackdrop(nil)
		f:Show()
	end
	
	local Text = f.Text or f:CreateFontString(nil, "OVERLAY")
	f.Text = Text
	Text:SetFontObject(GameFontHighlightSmall)
	Text:SetFont(font, self.dbx.fontSize)
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
local function formatDuration(timeLeft)
	return fmt( timeLeft<1 and "%.1f" or "%.0f", timeLeft )
end

local durationTimers = {}
local expirations = {}
local stacks = {}
local function fD(Text)
	local timeLeft = expirations[Text] - GetTime()
	Text:SetText( timeLeft>0 and formatDuration(timeLeft) or "")
end
local function fDS(Text)
	local timeLeft = expirations[Text] - GetTime()
	Text:SetText( timeLeft>0 and fmt("%s:%s",formatDuration(timeLeft),stacks[Text]) or "")
end
local function fcancel(Text)
	if durationTimers[Text] then
		Grid2:CancelTimer(durationTimers[Text])
		durationTimers[Text], expirations[Text], stacks[Text] = nil, nil, nil
	end	
end

local function GetDurationText(expiration, Text, func)
	if expiration then
		local timeLeft = expiration - GetTime()
		if timeLeft>0 then
			expirations[Text] = expiration
			if not durationTimers[Text] then
				durationTimers[Text] = Grid2:ScheduleRepeatingTimer(func, 0.1, Text)
			end
			return formatDuration(timeLeft)
		end
		fcancel(Text)
	end	
end

local function Text_OnUpdateDS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local stack= tostring(status:GetCount(unit)) or "1"
		local duration= GetDurationText( status:GetExpirationTime(unit), Text, fDS )
		if duration then
			stacks[Text]= stack
			Text:SetText( fmt("%s:%s", duration, stack) )
		else
			Text:SetText( string_sub(status:GetText(unit) or "", 1, self.textlength) )
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
		local duration= GetDurationText( status:GetExpirationTime(unit), Text, fD )
		Text:SetText( duration and duration or string_sub(status:GetText(unit) or "", 1, self.textlength) )
		Text:Show()
	else
		fcancel(Text)
		Text:Hide()
	end
end

local function Text_OnUpdateS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local content= tostring(status:GetCount(unit))
		Text:SetText( content and content or string_sub(status:GetText(unit) or "", 1, self.textlength) )
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
			Text:SetText( fmt("%.0f%%", percent*100) )
		else
			Text:SetText(  string_sub( (status:GetText(unit) or ""), 1, self.textlength ) )
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

local function Text_SetTextFont(self, parent, font, size)
	parent[self.name].Text:SetFont(font, size)
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
	self.Create = Text_Create
	self.GetBlinkFrame = Text_GetBlinkFrame
	self.Layout = Text_Layout
	self.SetTextFont = Text_SetTextFont
	self.Disable = Text_Disable
	self.UpdateDB = Text_UpdateDB
	self.OnUpdate= 	(dbx.duration and dbx.stack and Text_OnUpdateDS) or 
					(dbx.duration and Text_OnUpdateD) or 
					(dbx.stack 	  and Text_OnUpdateS) or 
					(dbx.percent  and Text_OnUpdateP) or
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
	local existingIndicator = Grid2.indicators[indicatorKey]
	local indicator = existingIndicator or Grid2.indicatorPrototype:new(indicatorKey)
	Text_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "text" })

	local colorKey = indicatorKey .. "-color"
	existingIndicator = Grid2.indicators[colorKey]
	local TextColor = existingIndicator or Grid2.indicatorPrototype:new(colorKey)
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

