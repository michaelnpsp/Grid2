local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")
local Grid2 = Grid2
local GetTime = GetTime

local function Text_Create(self, parent)
	local media = LibStub("LibSharedMedia-3.0", true)
	local font = media and media:Fetch("font", self.dbx.font or Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT

	local f = CreateFrame("Frame", nil, parent)
	f:SetAllPoints()
	local t = f:CreateFontString(nil, "OVERLAY")
	t:SetFontObject(GameFontHighlightSmall)
	t:SetFont(font, self.dbx.fontSize)
	t:SetJustifyH("CENTER")
	t:SetJustifyV("CENTER")
	parent[self.name] = t
end

local function Text_GetBlinkFrame(self, parent)
	return parent[self.name]:GetParent()
end

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
local function Text_Layout(self, parent)
	local Text = parent[self.name]
	Text:ClearAllPoints()
	Text:GetParent():SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Text:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	Text:SetJustifyH(justifyH[self.anchorRel])
	Text:SetJustifyV(justifyV[self.anchorRel])
	Text:SetWidth(parent:GetWidth())
end

local string_sub = string.utf8sub or string.sub
local durationFormat = "%.1f"
local durationFormatLarge = "%.0f"
local durationLarge = 5

local durationTimers = {}
local expirations = {}
local function f(Text)
	local now = GetTime()
	local timeLeft = expirations[Text] - now
	if (timeLeft < 0) then
		timeLeft = 0
	end
	if (timeLeft < durationLarge) then
		Text:SetText(durationFormat:format(timeLeft))
	else
		Text:SetText(durationFormatLarge:format(timeLeft))
	end
end

local function Text_OnUpdate(self, parent, unit, status)
	local Text = parent[self.name]
	local duration = self.dbx.duration

	if (status) then
		local content
		if (duration) then
			if (status.GetExpirationTime and status.GetDuration) then
				local expirationTime = status:GetExpirationTime(unit)
				local now = GetTime()
				local timeLeft = expirationTime - now
				if (timeLeft < 0) then
					timeLeft = 0
				end
				if (timeLeft < durationLarge) then
					content = durationFormat:format(timeLeft)
				else
					content = durationFormatLarge:format(timeLeft)
				end

				expirations[Text] = expirationTime
				if (not durationTimers[Text]) then
					if (expirationTime > now) then
						durationTimers[Text] = Grid2:ScheduleRepeatingTimer(f, 0.1, Text)
					end
				else
					if (expirationTime <= now) then
						Grid2:CancelTimer(durationTimers[Text])--, true)
						durationTimers[Text] = nil
						expirations[Text] = nil
					end
				end
			end
		elseif (status.GetText) then
			content = status:GetText(unit)
		end
		if (content and content ~= "") then
			Text:SetText(string_sub(content, 1, self.dbx.textlength))
			Text:Show()
		else
			Text:Hide()
		end
	else
		if (duration) then
			if (durationTimers[Text]) then
				Grid2:CancelTimer(durationTimers[Text])--, true)
				durationTimers[Text] = nil
				expirations[Text] = nil
			end
		end
		Text:Hide()
	end
end

local function Text_SetTextFont(self, parent, font, size)
	parent[self.name]:SetFont(font, size)
end


local TextColor_Create = function (self)
end

local TextColor_Layout = function (self)
end

local function TextColor_OnUpdate(self, parent, unit, status)
	local Text = parent[self.textname]
	if (status) then
		Text:SetTextColor(status:GetColor(unit))
	else
if (not Text.SetTextColor) then
print("TextColor_OnUpdate", self.textname, unit, Text)
end
		Text:SetTextColor(1, 1, 1, 1)
	end
end

local function Create(indicatorKey, dbx)
	local colorKey = indicatorKey .. "-color"
	local location = Grid2.locations[dbx.location]

	local Text = Grid2.indicatorPrototype:new(indicatorKey)
	Text.frameLevel = dbx.level
	Text.anchor = location.point
	Text.anchorRel = location.relPoint
	Text.offsetx = location.x
	Text.offsety = location.y
	Text.Create = Text_Create
	Text.GetBlinkFrame = Text_GetBlinkFrame
	Text.Layout = Text_Layout
	Text.OnUpdate = Text_OnUpdate
	Text.SetTextFont = Text_SetTextFont

	Text.dbx = dbx
	Grid2:RegisterIndicator(Text, { "text", "duration" })

	local TextColor = Grid2.indicatorPrototype:new(colorKey)
	TextColor.textname = indicatorKey
	TextColor.Create = TextColor_Create
	TextColor.Layout = TextColor_Layout
	TextColor.OnUpdate = TextColor_OnUpdate

	TextColor.dbx = dbx
	Grid2:RegisterIndicator(TextColor, { "color" })

	return Text, TextColor
end

Grid2.setupFunc["text"] = Create

--ToDo: Is there a better way to handle this dual indicator creation?
local function CreateColor(indicatorKey, dbx)
--	TextColor.dbx = dbx
end
Grid2.setupFunc["text-color"] = CreateColor

