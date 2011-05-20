--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime

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
	local Text = parent[self.name].Text
	Text:ClearAllPoints()
	Text:GetParent():SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Text:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	Text:SetJustifyH(justifyH[self.anchorRel])
	Text:SetJustifyV(justifyV[self.anchorRel])
	Text:SetWidth(parent:GetWidth())
end

local string_sub = string.subutf8 or string.sub
local durationFormat = "%.1f"
local durationFormatLarge = "%.0f"
local durationLarge = 1
local stackDurationFormat = "%s-%s"

local durationTimers = {}
local expirations = {}
local stacks = {}
local function f(Text)
	local timeLeft = expirations[Text] - GetTime()
	if timeLeft>0 then
		local content
		if timeLeft < durationLarge then
			content = durationFormat:format(timeLeft)
		else
			content = durationFormatLarge:format(timeLeft)
		end
		local stack = stacks[Text]
		if stack then
			content = stackDurationFormat:format(content, stack)
		end
		Text:SetText(content)
	else
		Text:SetText("")
	end	
end
local function fcancel(Text)
	if durationTimers[Text] then
		Grid2:CancelTimer(durationTimers[Text])
		durationTimers[Text], expirations[Text], stacks[Text] = nil, nil, nil
	end	
end

local function Text_OnUpdateDS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local duration = self.dbx.duration
		local stack = self.dbx.stack
		local contentDuration, contentStack
		if stack and status.GetCount then
			contentStack = tostring(status:GetCount(unit))
		end
		if duration and status.GetExpirationTime then
			local expiration= status:GetExpirationTime(unit)
			local timeLeft = expiration - GetTime()
			if stack then
				stacks[Text] = contentStack or ""
			end
			if timeLeft>0 then
				if timeLeft < durationLarge then
					contentDuration = durationFormat:format(timeLeft)
				else
					contentDuration = durationFormatLarge:format(timeLeft)
				end
				expirations[Text] = expiration
				if not durationTimers[Text] then
					durationTimers[Text] = Grid2:ScheduleRepeatingTimer(f, 0.1, Text)
				end
			else
				fcancel(Text)
			end
		end
		local content
		if contentStack and contentDuration then
			content = stackDurationFormat:format(contentDuration, contentStack)
		elseif contentDuration then
			content = contentDuration
		elseif contentStack then
			content = contentStack
		elseif status.GetText then
			content = status:GetText(unit)
		end
		if content and content ~= "" then
			Text:SetText(string_sub(content, 1, self.dbx.textlength))
			Text:Show()
			return
		end
	else
		fcancel(Text)
	end
	Text:Hide()
end

local function Text_OnUpdate(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status and status.GetText then
		local content = status:GetText(unit)
		if content and content ~= "" then
			Text:SetText(string_sub(content, 1, self.dbx.textlength))
			Text:Show()
			return
		end
	end
	Text:Hide()
end

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
	self.Create = Text_Create
	self.GetBlinkFrame = Text_GetBlinkFrame
	self.Layout = Text_Layout
	self.SetTextFont = Text_SetTextFont
	self.Disable = Text_Disable
	self.UpdateDB = Text_UpdateDB
	self.dbx = dbx
	if dbx.duration or dbx.stack then
		self.OnUpdate = Text_OnUpdateDS
	else
		self.OnUpdate = Text_OnUpdate
	end
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
	Grid2:RegisterIndicator(indicator, { "text", "duration" })

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

