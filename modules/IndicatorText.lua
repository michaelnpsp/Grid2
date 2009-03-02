local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local function Text_Create(self, parent)
	local media = LibStub("LibSharedMedia-3.0", true)
	local font = media and media:Fetch("font", Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT

	local f = CreateFrame("Frame", nil, parent)
	f:SetAllPoints()
	local t = f:CreateFontString(nil, "OVERLAY")
	t:SetFontObject(GameFontHighlightSmall)
	t:SetFont(font, self.db.profile.fontSize)
	t:SetJustifyH("CENTER")
	t:SetJustifyV("CENTER")
	parent[self.name] = t
end

local function Text_GetBlinkFrame(self, parent)
	return parent[self.name]:GetParent()
end

local function Text_Layout(self, parent)
	local Text = parent[self.name]
	Text:ClearAllPoints()
	Text:GetParent():SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Text:SetPoint(self.anchor, parent, self.anchorRel, self.offsetx, self.offsety)
	Text:SetWidth(parent:GetWidth())
end

local string_sub = string.utf8sub or string.sub

local function Text_OnUpdate(self, parent, unit, status)
	local Text = parent[self.name]
	local content = status and status:GetText(unit)
	if content and content ~= "" then
		Text:Show()
		Text:SetText(string_sub(content, 1, self.db.profile.textlength))
	else
		Text:Hide()
	end
end

local function Text_SetTextFont(self, parent, font, size)
	parent[self.name]:SetFont(font ,size)
end

local Text_defaultDB = {
	profile = {
		textlength = 4,
		fontSize = 8,
		font = "Friz Quadrata TT",
	}
}

local TextColor_Create = function (self)
end

local TextColor_Layout = function (self)
end

local function TextColor_OnUpdate(self, parent, unit, status)
	local Text = parent[self.textname]
	if status then
		Text:SetTextColor(status:GetColor(unit))
	else
		Text:SetTextColor(1, 1, 1, 1)
	end
end

function Grid2:CreateTextIndicator(name, level, anchor, anchorRel, offsetx, offsety)
	name = "text-"..name
	if type(level) == "string" then
		level, anchor, anchorRel, offsetx, offsety = 0, level, anchor, anchorRel, offsetx
	end
	local Text = self.indicatorPrototype:new(name)

	Text.frameLevel = level
	Text.anchor = anchor
	Text.anchorRel = anchorRel
	Text.offsetx = offsetx
	Text.offsety = offsety
	Text.Create = Text_Create
	Text.GetBlinkFrame = Text_GetBlinkFrame
	Text.Layout = Text_Layout
	Text.OnUpdate = Text_OnUpdate
	Text.SetTextFont = Text_SetTextFont
	Text.defaultDB = Text_defaultDB

	self:RegisterIndicator(Text, { "text" })

	local TextColor = self.indicatorPrototype:new(name.."-color")

	TextColor.textname = name
	TextColor.Create = TextColor_Create
	TextColor.Layout = TextColor_Layout
	TextColor.OnUpdate = TextColor_OnUpdate

	self:RegisterIndicator(TextColor, { "color" })

	return Text, TextColor
end
