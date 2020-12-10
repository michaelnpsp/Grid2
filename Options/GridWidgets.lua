local AceGUI= LibStub("AceGUI-3.0", true)

-------------------------------------------------------------------------------------------------
-- Modified Multiline Editbox that vertical fills the parent container even in AceConfigDialog Flow layouts.
-- The multiline editbox must be the last defined element in an AceConfigTable, to avoid an infinite recursion.
-------------------------------------------------------------------------------------------------
do
	local WidgetType, container = "Grid2ExpandedEditBox"
	local function Resize(frame, width, height)
		if not container then -- container used as recursion lock
			container = frame.obj.parent
			if container.children[#container.children] == frame.obj then
				frame:SetHeight( frame:GetTop() - container.frame:GetBottom() )
			end
			container = nil
		end
	end
	AceGUI:RegisterWidgetType( WidgetType, function()
		local widget = AceGUI:Create("MultiLineEditBox")
		widget.type = WidgetType
		widget.frame:HookScript("OnSizeChanged", Resize)
		return widget
	end , 1)
end

-------------------------------------------------------------------------------------------------
-- Title displayed on top of the configuration panel for items like statuses, indicators, etc
-- optional action icons displayed on the top right can be defined
--	{
--		size = 32, padding = 2, spacing = 4 , offsetx = 0, offsety = 0, anchor = 'TOPRIGHT',
--		[1] = { image = "Path to icon texture", tooltip = "Delete Item", func = deleteFunction },
--		[2] = { image = "Path to icon texture", tooltip = 'Create Item', func = createFunction },
--	} )
-------------------------------------------------------------------------------------------------
do
	local Type, Version = "Grid2Title", 1

	-- tooltips management
	local function ShowTooltip(frame, text)
		local tooltip = AceGUI.tooltip
		tooltip:SetOwner(frame, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("TOP",frame,"BOTTOM", 0, -8)
		tooltip:ClearLines()
		-- tooltip:SetText( text , 1, .82, 0, 1, true)
		tooltip:AddLine( text , 1, 1, 1, true)
		tooltip:Show()
	end

	local function OnEnter(frame)
		self = frame.obj
		local desc = frame.obj.userdata.option.desc
		if desc then
			ShowTooltip(frame, desc)
		end
	end

	local function OnLeave(frame)
		AceGUI.tooltip:Hide()
	end

	local function OnIconEnter(self)
		local parent = self.frame:GetParent().obj
		local option = parent.options[self.index]
		if option.tooltip then
			ShowTooltip(self.frame, option.tooltip)
		end
	end

	local function OnIconClick(self)
		local parent = self.frame:GetParent().obj
		local option = parent.options[self.index]
		if option.func then
			option.func( parent.userdata, self.index )
		end
	end

	-- create action icons when userdata configuration is available (is set by AceConfigDialog after widget creation)
	local function OnShow(frame)
		local self = frame.obj
		local options = self.userdata and self.userdata.option
		if options then
			frame:SetScript("OnShow",nil)
			self.options = options.arg and options.arg.icons or options.arg
			if self.options then
				self:AcquireIcons()
			end
		end
	end

	local methods = {
		["OnAcquire"] = function(self)
			self:SetWidth(200)
			self:SetText()
			self:SetColor()
			self:SetFontObject()
			self:SetJustifyH("LEFT")
			self:SetJustifyV("TOP")
			self:SetImage()
			self:SetImageSize(32,32)
			self.frame:SetScript("OnShow",OnShow)
		end,
		["OnRelease"] = function(self)
			for _,icon in ipairs(self.icons) do
				icon:Release()
			end
			wipe(self.icons)
			self.options = nil
		end,
		["SetImageSize"] = function(self, width, height)
			self.image:SetWidth(width)
			self.image:SetHeight(height)
			self:SetHeight(height)
		end,
		["SetImage"] = function(self, path,...)
			self.image:SetTexture(path)
			local n = select("#", ...)
			if n == 4 or n == 8 then
				self.image:SetTexCoord(...)
			else
				self.image:SetTexCoord(0, 1, 0, 1)
			end
		end,
		["SetText"] = function(self, text)
			self.label:SetText(text)
		end,
		["SetColor"]= function(self, r, g, b)
			self.label:SetVertexColor(r or 1, g or 1, b or 1)
		end,
		["SetFont"] = function(self, font, height, flags)
			self.label:SetFont(font, height, flags)
		end,
		["SetFontObject"] = function(self, font)
			self:SetFont((font or GameFontHighlightSmall):GetFont())
		end,
		["SetJustifyH"] = function(self, justifyH)
			self.label:SetJustifyH(justifyH)
		end,
		["SetJustifyV"] = function(self, justifyV)
			self.label:SetJustifyV(justifyV)
		end,
		["AcquireIcons"] = function(self)
			local options  = self.options
			local spacing  = options.spacing or 0
			local iconSize = options.size or 32
			local offsetx  = options.offsetx or 0
			local offsety  = options.offsety or 0
			local imgSize  = iconSize - (options.padding or 0)*2
			local multx    = string.find(options.anchor,'LEFT') and (iconSize+spacing) or -(iconSize+spacing)
			for i,option in ipairs(options) do
				local icon = AceGUI:Create("Icon")
				icon.index = i
				icon:SetImage(option.image)
				icon:SetImageSize(imgSize,imgSize)
				icon:SetHeight(iconSize)
				icon:SetWidth(iconSize)
				icon:SetCallback( "OnClick", OnIconClick )
				icon:SetCallback( "OnEnter", OnIconEnter )
				icon:SetCallback( "OnLeave", OnLeave )
				icon.frame:SetParent( self.frame )
				icon.frame:SetPoint( options.anchor, (i-1)*multx+offsetx, offsety )
				icon.image:ClearAllPoints()
				icon.image:SetPoint( "CENTER" )
				icon.frame:Show()
				self.icons[i] = icon
			end
		end
	}

	local function Constructor()
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:EnableMouse(true)
		frame:SetScript("OnEnter", OnEnter)
		frame:SetScript("OnLeave", OnLeave)
		frame:Hide()

		local image = frame:CreateTexture(nil, "BACKGROUND")
		image:SetPoint("TOPLEFT")

		local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)

		local line = frame:CreateTexture(nil, "BACKGROUND")
		line:SetHeight(6)
		line:SetPoint("BOTTOMLEFT", 0, -5)
		line:SetPoint("BOTTOMRIGHT", 0, -5)
		line:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
		line:SetTexCoord(0.81, 0.94, 0.5, 1)

		local widget = { label = label, image = image, frame = frame, type  = Type, line = line, icons = {} }
		for method, func in pairs(methods) do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
