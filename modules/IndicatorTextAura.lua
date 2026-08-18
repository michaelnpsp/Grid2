--[[ Created by Michael ]]--

local Grid2 = Grid2

local justifyH = { CENTER = "CENTER", TOP = "CENTER", BOTTOM = "CENTER", LEFT = "LEFT",   RIGHT = "RIGHT",  TOPLEFT = "LEFT", TOPRIGHT = "RIGHT", BOTTOMLEFT = "LEFT",   BOTTOMRIGHT = "RIGHT"  }
local justifyV = { CENTER = "MIDDLE", TOP = "TOP",    BOTTOM = "BOTTOM", LEFT = "MIDDLE", RIGHT = "MIDDLE", TOPLEFT = "TOP",  TOPRIGHT = "TOP",   BOTTOMLEFT = "BOTTOM", BOTTOMRIGHT = "BOTTOM" }

-- helper functions

local function Text_CreateDurationOptions(self, filter)
	local options = {}
	options.textFormatter = Grid2:GetGeneralElapsedTimeFormatter() -- text format general options
	if not self.textColor then
		local foptions = filter.cooldownTextOptions
		if foptions then -- options from the status filter to change the text color if avaiable
			options.textColor = foptions.textColor
			options.property = foptions.property
		end
		self.textOptions = options
	end
	return options
end

local function Text_ApplyColor(self, status, Text)
	local color = self.textColor
	if color then
		Text:SetTextColor( color.r, color.g, color.b, color.a )
	else
		local r, g, b = status:GetColor()
		Text:SetTextColor( r, g, b, 1 )
	end
end

-- indicator methods

local function Text_Create(self, parent)
	self:Acquire("Frame", parent)
end

local function Text_Layout(self, parent)
	if not self.auraMode then
		self:ReleaseAuraSlotButton(parent)
		return
	end
	local Frame = parent[self.name]
	Frame:SetParent(parent)
	Frame:ClearAllPoints()
	Frame:SetAllPoints()
	Frame:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	self:AcquireAuraSlotButton(parent, nil, function(_, _, button, filter, status)
		button.coolText = button.coolText or button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		local Text = button.coolText
		Text_ApplyColor(self, status, Text)
		Text:SetFont(self.textfont, self.textsize, self.fontFlags)
		Text:ClearAllPoints()
		Text:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
		Text:SetJustifyH(justifyH[self.anchorRel])
		Text:SetJustifyV(justifyV[self.anchorRel])
		Text:SetWidth(parent:GetWidth())
		Text:SetShadowOffset(self.shadowOffset, -self.shadowOffset)
		Text:SetShadowColor(0,0,0, self.shadowAlpha)
		Text:SetMaxLines(1)
		button:SetDurationText(Text, self.textOptions or Text_CreateDurationOptions(self, filter) )
		Frame:Show()
	end)
end

local function Text_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f:SetParent(nil)
	f:ClearAllPoints()
end

local function Text_UpdateDB(self)
	local dbx = self.dbx
	local theme = Grid2Frame.db.profile
	local l = dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level or 8
	self.textlength = dbx.textlength or 16
	self.textfont = Grid2:MediaFetch("font", dbx.font or theme.font) or STANDARD_TEXT_FONT
	self.textsize = dbx.fontSize or theme.fontSize or 11
	self.shadowOffset = (dbx.shadowDisabled and 0) or dbx.shadowOffset or 1
	if dbx.fontFlags then
		self.shadowAlpha = dbx.shadowDisabled and 0 or 1
		self.fontFlags   = dbx.fontFlags~='NONE' and dbx.fontFlags or ''
	else
		self.shadowAlpha = theme.shadowDisabled and 0 or 1
		self.fontFlags   = theme.fontFlags~='NONE' and theme.fontFlags or ''
	end
	self.textColor = dbx.textColor
	self.textOptions = nil
end

local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicatorPrototype:new(indicatorKey)
	indicator.dbx = dbx
	indicator.Create = Text_Create
	indicator.Layout = Text_Layout
	indicator.Disable = Text_Disable
	indicator.UpdateDB = Text_UpdateDB
	indicator.OnUpdate = Grid2.Dummy
	Grid2:RegisterIndicator(indicator, { "aura" })

	return indicator
end

Grid2.setupFunc["textaura"] = Create
