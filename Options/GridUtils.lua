--[[
	Miscelaneous/shared functions and variables
--]]

local Grid2Options = Grid2Options
local L  = Grid2Options.L
local LG = Grid2Options.LG

-- Helper points tables
Grid2Options.pointMap = {
	TOPLEFT = "1",
	LEFT = "2",
	BOTTOMLEFT = "3",
	TOP = "4",
	CENTER = "5",
	BOTTOM = "6",
	TOPRIGHT = "7",
	RIGHT = "8",
	BOTTOMRIGHT = "9",
	["1"] = "TOPLEFT",
	["2"] = "LEFT",
	["3"] = "BOTTOMLEFT",
	["4"] = "TOP",
	["5"] = "CENTER",
	["6"] = "BOTTOM",
	["7"] = "TOPRIGHT",
	["8"] = "RIGHT",
	["9"] = "BOTTOMRIGHT",
}

Grid2Options.pointMapText = {
	LEFTTOP = "1",
	LEFTMIDDLE = "2",
	LEFTBOTTOM = "3",
	CENTERTOP = "4",
	CENTERMIDDLE = "5",
	CENTERBOTTOM = "6",
	RIGHTTOP = "7",
	RIGHTMIDDLE = "8",
	RIGHTBOTTOM = "9",
	["1"] = { "LEFT", "TOP" },
	["2"] = { "LEFT", "MIDDLE" },
	["3"] = { "LEFT", "BOTTOM" },
	["4"] = { "CENTER", "TOP" },
	["5"] = { "CENTER", "MIDDLE" },
	["6"] = {"CENTER", "BOTTOM" },
	["7"] = { "RIGHT", "TOP" },
	["8"] = { "RIGHT", "MIDDLE" },
	["9"] = { "RIGHT", "BOTTOM" },
}

Grid2Options.pointValueList = {
	["1"] = L["TOPLEFT"],
	["2"] = L["LEFT"],
	["3"] = L["BOTTOMLEFT"],
	["4"] = L["TOP"],
	["5"] = L["CENTER"],
	["6"] = L["BOTTOM"],
	["7"] = L["TOPRIGHT"],
	["8"] = L["RIGHT"],
	["9"] = L["BOTTOMRIGHT"],
}

Grid2Options.pointValueListExtra = {
	["0"] = L["None"],
	["1"] = L["TOPLEFT"],
	["2"] = L["LEFT"],
	["3"] = L["BOTTOMLEFT"],
	["4"] = L["TOP"],
	["5"] = L["CENTER"],
	["6"] = L["BOTTOM"],
	["7"] = L["TOPRIGHT"],
	["8"] = L["RIGHT"],
	["9"] = L["BOTTOMRIGHT"],
}

-- Font Flags and Shadow
do
	local soft   = L["Soft"]
	local sharp  = L["Sharp"]
	local thin   = L["Thin"]
	local thick  = L["Thick"]
	local shadow = L["Shadow"]
	local fontFlagsValues = {
		["NONE"] = soft,
		["OUTLINE"] = string.format( "%s,%s", soft, thin ),
		["THICKOUTLINE"] = string.format( "%s,%s", soft, thick ),
		["MONOCHROME"] = sharp,
		["MONOCHROME, OUTLINE"] = string.format( "%s,%s", sharp, thin ),
		["MONOCHROME, THICKOUTLINE"] = string.format( "%s,%s", sharp, thick ),
	}
	local fontFlagsShadowValues = {
		["0;NONE"] = soft,
		["0;OUTLINE"] = string.format( "%s,%s", soft, thin ),
		["0;THICKOUTLINE"] = string.format( "%s,%s", soft, thick ),
		["0;MONOCHROME"] = sharp,
		["0;MONOCHROME, OUTLINE"] = string.format( "%s,%s", sharp, thin ),
		["0;MONOCHROME, THICKOUTLINE"] = string.format( "%s,%s", sharp, thick ),
		["1;NONE"] = string.format( "%s+%s", soft, shadow ),
		["1;OUTLINE"] = string.format( "%s,%s+%s", soft, thin, shadow ),
		["1;THICKOUTLINE"] = string.format( "%s,%s+%s", soft, thick, shadow ),
		["1;MONOCHROME"] = string.format( "%s+%s", sharp, shadow ),
		["1;MONOCHROME, OUTLINE"] = string.format( "%s,%s+%s", sharp, thin, shadow ),
		["1;MONOCHROME, THICKOUTLINE"] = string.format( "%s,%s+%s", sharp, thick, shadow ),
	}
	local FONT_FLAGS_DEFAULT = '0'
	local fontFlagsShadowDefValues = Grid2.CopyTable(fontFlagsShadowValues)
	fontFlagsShadowDefValues[FONT_FLAGS_DEFAULT] = string.format( "*%s*", L["Default"] )
	-- public
	Grid2Options.fontFlagsValues          = fontFlagsValues
	Grid2Options.fontFlagsShadowValues    = fontFlagsShadowValues
	Grid2Options.fontFlagsShadowDefValues = fontFlagsShadowDefValues
	Grid2Options.FONT_FLAGS_DEFAULT       = FONT_FLAGS_DEFAULT
end

-- safe get value from table, returns def value if array table does not exist
function Grid2Options.GetTableValueSafe(t, k, def)
	if t then
		local v = t[k]
		if v~=nil then
			return v
		end
	end
	return def
end

-- safe set key,value pair to table, creates the table if not exist
function Grid2Options.SetTableValueSafe(db, tableKey, key, value)
	local t = db[tableKey]
	if t then
		t[key] = value
	else
		db[tableKey] = { [key] = value }
	end
end

-- Grid2Option:UnpackColor()
function Grid2Options:UnpackColor( color, colorKey )
	color = color or Grid2.defaultColors[colorKey or "TRANSPARENT"]
	return color.r, color.g, color.b, color.a
end

-- Grid2Option:PackColor()
function Grid2Options:PackColor( r,g,b,a, dbx, key )
	if dbx then
		local c = dbx[key]
		if not c then c={}; dbx[key]=c;	end
		c.r,c.g,c.b,c.a = r,g,b,a
		return c
	end
	return { r=r, g=g, b=b, a=a }
end

-- Refresh AceConfig options window
function Grid2Options:NotifyChange() -- do not use self variable inside this function (self can be nil or ~=Grid2Options)
	LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid2")
end

-- Grid2Options:EnableLoadOnDemand()
-- Delays the creation of indicators and statuses options, until the user clicks on each option,
-- reducing initial memory usage and load time. Instead of the real options, a "description" type option
-- is inserted in the options table. When the user clicks on the parent option, the "hidden" callback
-- of our "description" option is called, and at this point the module creates the real options.
-- This function can be safety removed, Grid2Option will continue working without this feature.
do
	local methods = {
		themes      = "MakeThemesOptions",
		indicators  = "MakeIndicatorsOptions",
		statuses    = "MakeStatusesOptions",
		statuses_   = "MakeStatusChildOptions",
		indicators_ = "MakeIndicatorChildOptions",
	}
	local option = {
		type = "description", order = 0, name = "",
		hidden = function(info)
			local typ, key = info[1], info[#info-1]
			if methods[key] then
				methods[key]( Grid2Options )
			else
				methods[typ..'_']( Grid2Options, Grid2[typ][key] )
			end
			Grid2Options:NotifyChange()
		end
	}
	local function hook(self, options, extraOptions)
		options = extraOptions or options
		wipe(options)
		options._openmanager_ = option
	end
	function Grid2Options:EnableLoadOnDemand(enabled)
		if enabled then
			for key,method in pairs(methods) do
				methods[key], self[method] = self[method], hook
			end
		end
		self.EnableLoadOnDemand = nil
	end
end

-- player known spells
do
	local spells, sorted
	function Grid2Options:GetPlayerSpells()
		if not spells then
			spells = {}
			for i=1,1000 do
			   local type, spellID = GetSpellBookItemInfo(i,'spell')
			   if not spellID then break end
			   if type == 'SPELL' then
				   spells[spellID] = GetSpellInfo(spellID)
				end
			end
			sorted = {}
			for k in next, spells do sorted[#sorted+1] = k end
			sort(sorted, function(a, b) return spells[a] < spells[b] end)
		end	
		return spells, sorted
	end
end

-- specialization helper functions
do
	Grid2Options.GetSpecializationInfo = GetSpecializationInfo or function(index)
		local name = index==2 and L['Secondary'] or L['Primary']
		local icon = index==2 and "Interface\\Icons\\WoW_Token02" or "Interface\\Icons\\WoW_Token01"
		return index, name, name, icon
	end
	Grid2Options.GetNumSpecializationsForClassID = GetNumSpecializationsForClassID or Grid2.GetNumSpecializations
	Grid2Options.GetSpecializationInfoForClassID = GetSpecializationInfoForClassID or function(classID, index)
		local _, name, _, icon = Grid2Options.GetSpecializationInfo(index)
		local info = C_CreatureInfo.GetClassInfo(classID)
		name = string.format("%s: %s", info and info.className or '', name)
		return index, name, name, icon
	end
end

-- Grid2Options.Tooltip generic tooltip to parse hyperlinks
do
	local tip
	tip = CreateFrame("GameTooltip", "Grid2OptionsTooltip", nil, "GameTooltipTemplate")
	tip:SetOwner(WorldFrame, "ANCHOR_NONE")
	for i = 1, 10 do
		tip[i] = _G["Grid2OptionsTooltipTextLeft"..i]
		if not tip[i] then
			tip[i] = tip:CreateFontString()
			tip:AddFontStrings(tip[i], tip:CreateFontString())
		end
	end
	Grid2Options.Tooltip = tip
end

-- Grid2Options:MakeHeaderOptions()
do
	local headers = {
		-- shared headers
		Delete     = { type = "header", order = 250, name = "" },
		-- indicators headers
		General    = { type = "header", order = 1.9, name = L["General"]   },
		Location   = { type = "header", order = 2,   name = L["Location"]   },
		Appearance = { type = "header", order = 10,  name = L["Appearance"] },
		Icon	   = { type = "header", order = 10,  name = L["Icon"] },
		Shape	   = { type = "header", order = 10,  name = L["Shape"] },
		Border     = { type = "header", order = 20,  name = L["Border"]     },
		Shadow     = { type = "header", order = 30,  name = L["Shadow"]     },
		Effect     = { type = "header", order = 30,  name = L["Effect"] },
		Background = { type = "header", order = 60,  name = L["Background"] },
		Special    = { type = "header", order = 70,  name = L["Special"] },
		Display    = { type = "header", order = 80,  name = L["Display"]    },
		StackText  = { type = "header", order = 90,  name = L["Stack Text"] },
		Cooldown   = { type = "header", order = 125, name = L["Cooldown"]	},
		ZoomIn     = { type = "header", order = 150, name = L["Zoom In"]	},
		Highlight  = { type = "header", order = 200, name = L["Highlight"]	},
		-- statuses headers
		Stacks	      = { type = "header", order = 4.9, name = L["Stacks"]      },
		Colors	      = { type = "header", order = 10,  name = L["Colors"]      },
		Thresholds    = { type = "header", order = 50,  name = L["Thresholds"], },
		Value         = { type = "header", order = 90,  name = L["Value"] },
		Text          = { type = "header", order = 95,  name = L["Text"] },
		Misc          = { type = "header", order = 100, name = L["Misc"]        },
		Duration      = { type = "header", order = 105, name = L["Duration"] },
		Highlights    = { type = "header", order = 110, name = L["Highlight"], },
		Auras	      = { type = "header", order = 150, name = L["Auras"]       },
		DebuffFilter  = { type = "header", order = 175, name = L["Filtered debuffs"] },
		AurasExpanded = { type = "header", order = 300, name = L["Display"] },
	}
	function Grid2Options:MakeHeaderOptions( options, key )
		options[ "header"..key ] = headers[key]
	end
end

-- Grid2Options:MakeSpacerOptions()
do
	local spacers = {}
	function Grid2Options:MakeSpacerOptions( options, order )
		local header = spacers[order]
		if not header then
			header = { type = "header", order = order, name = "" }
			spacers[order] = header
		end
		options[ "spacer"..order ] = header
	end
end

-- Grid2:MakeTitleOptions(options, title, subtitle, desc, icon, coords, order)
do
	local titleCoords = { 0.05, 0.95, 0.05, 0.95 }
	local titleMask   = NORMAL_FONT_COLOR_CODE .. "%s|r\n%s"
	function Grid2Options:MakeTitleOptions(options, title, subtitle, tipText, icon, coords, arg)
		options.title = {
			type  = "description", order = 0, width = "full", fontSize = "large", dialogControl = "Grid2Title",
			image = icon, imageWidth = 34, imageHeight = 34, imageCoords = coords or titleCoords,
			name  = string.format(titleMask, title, subtitle),
			desc  = tipText,
			arg   = arg, -- optional argument to inject action icons configuration, see Grid2Title widget in GridWidget.lua
		}
	end
end

-- Grid2Options.LocalizeStatus()
do
	local fmt = string.format
	local HexDigits = "0123456789ABCDEF"
	local prefixes = { "color-", "buff-", "debuff-", "buffs-", "debuffs-", "aoe-" }
	local suffixes = { "-not-mine", "-mine" }
	local prefixes_colors = {
		["buff-"]   = "|cFF00ff00%s|r",
		["debuff-"] = "|cFFff0000%s|r",
		["buffs-"]   = "|cFF00ffa0%s|r",
		["debuffs-"] = "|cFFff00a0%s|r",
		["aoe-"]    = "|cFF0080ff%s|r",
		["color-"]  = "|cFFffff00%s|r",
	}
	local function byteToHex(byte)
		local L = byte % 16 + 1
		local H = math.floor( byte / 16 ) + 1
		return HexDigits:sub(H,H) .. HexDigits:sub(L,L)
	end
	local function rgbToHex(c)
		return byteToHex(math.floor(c.r*255)) .. byteToHex(math.floor(c.g*255)) .. byteToHex(math.floor(c.b*255))
	end
	local function SplitStatusName(name)
		local prefix= ""
		local suffix= ""
		local body
		for _, value in ipairs(prefixes) do
			if strsub(name,1,strlen(value))==value then
				prefix = value
				break
			end
		end
		for _, value in ipairs(suffixes) do
			if strsub(name,-strlen(value))==value then
				suffix = value
				break
			end
		end
		body = strsub( name, strlen(prefix)+1, strlen(name)-strlen(suffix) )
		return prefix, body, suffix
	end
	function Grid2Options.LocalizeStatus(status, RemovePrefix)
		local name = status.name
		local prefix, body, suffix = SplitStatusName(name)
		if RemovePrefix then
			prefix = ""
		end
		if prefix=="color-" then
			body = "|cFF" .. rgbToHex(status.dbx.color1) .. L[body] .. "|r"
		else
			body = L[body]
		end
		if prefix~="" then
			prefix = fmt( prefixes_colors[prefix] or "%s", L[prefix])
		end
		if suffix~="" then
			suffix = L[suffix]
		end
		return prefix .. body .. suffix
	end
end

-- Grid2Options.LocalizeIndicator()
function Grid2Options:LocalizeIndicator(indicator, all)
	local icon, suffix
	local type = indicator.dbx.type
	local name = indicator.name
	if strsub(name,-6)=="-color" then
		name = strsub(name,1,-7)
		icon = self.indicatorIconPath .. 'color'
		suffix = '(color)'
	else
		icon = self.indicatorIconPath .. (self.indicatorTypesOrder[type] and type or "default")
		suffix = ''
	end

	return string.format( (all or type~='multibar') and "|T%s:0|t%s%s" or "|T%s:0|t|cFF808080%s%s|r", icon, self.LI[name] or L[name], suffix )
end

-- checking that the status provides at least one of the required indicator types
function Grid2Options:IsCompatiblePair(indicator, status)
	if status.name~="/@@@test@@@/" then
		for type, list in pairs(Grid2.indicatorTypes) do
			if list[indicator.name] then
				for _, s in Grid2:IterateStatuses(type) do
					if s == status then
						return type
					end
				end
			end
		end
	end	
end

-- Grid2Options:GetAvailableStatusValues()
function Grid2Options:GetAvailableStatusValues(indicator, statusAvailable, statusToKeep)
	statusAvailable = statusAvailable or {}
	wipe(statusAvailable)
	for statusKey, status in Grid2:IterateStatuses() do
		if self:IsCompatiblePair(indicator, status) and not status.priorities[indicator] and not indicator.priorities[status] then 
			statusAvailable[statusKey] = self.LocalizeStatus(status)
		end
	end
	return statusAvailable
end

-- Grid2Options:GetAvailableIndicatorValues()
function Grid2Options:GetAvailableIndicatorValues(status, indicatorAvailable)
	indicatorAvailable = indicatorAvailable or {}
	wipe(indicatorAvailable)
	for key, indicator in Grid2:IterateIndicators() do
		if self:IsCompatiblePair(indicator, status) then
			indicatorAvailable[key] = self:LocalizeIndicator( indicator )
		end
	end
	return indicatorAvailable
end

-- Grid2Options:GetAvailableIndicatorColorValues()
function Grid2Options:GetAvailableIndicatorColorValues(status, indicatorAvailable)
	indicatorAvailable = indicatorAvailable or {}
	wipe(indicatorAvailable)
	for key, indicator in Grid2:IterateIndicators('color') do
		indicatorAvailable[key] = self:LocalizeIndicator( indicator )
	end
	return indicatorAvailable
end

-- Grid2Options:UpdateIndicatorDB()
function Grid2Options:UpdateIndicatorDB(indicator)
	if indicator then
		indicator:UpdateDB()
		indicator:UpdateFilter()
		indicator:UpdateHighlight()
		self:UpdateIndicatorDB( indicator.sideKick )
		self:UpdateIndicatorDB( Grid2:GetIndicatorByName(indicator.childName) )
	end
end

-- Grid2Options:LayoutFrames()
function Grid2Options:LayoutFrames()
	Grid2Frame:LayoutFrames(true)
	Grid2Frame:UpdateIndicators()
end

-- Reload indicator database configuration and refresh the indicator frames.
-- indicator:UpdateDB() is always called to reload indicator database config
-- method = "Create" | "Update" | key | nil
-- 	"Create" > Recreate the indicator
--  "Update"|nil > Update all indicators in all registered frame units
--  key > method defined inside indicator to be executed
function Grid2Options:RefreshIndicator(indicator, method)
	self:UpdateIndicatorDB(indicator)
	if method then
		if method == "Create" then
			for _,f in next, Grid2Frame.registeredFrames do
				if indicator:GetFrame(f) then
					indicator:Disable(f)
					indicator:Create(f)
					indicator:Layout(f)
				end
			end
		elseif method == 'Layout' then
			indicator:LayoutAllFrames()
		elseif method ~= 'Update' then
			Grid2Frame:WithAllFrames(indicator, method)
		end
	end
	Grid2Frame:UpdateIndicators()
end

-- Create or recreate indicator
function Grid2Options:CreateIndicatorFrames(indicator)
	for _,f in next, Grid2Frame.registeredFrames do
		if indicator:CanCreate(f) then
			indicator:Release(f)
			indicator:Create(f)
			indicator:Layout(f)
		end
	end
end

-- Register indicator statuses from database
function Grid2Options:RegisterIndicatorStatuses(indicator)
	if indicator then
		local map = Grid2:DbGetValue("statusMap", indicator.name)
		if map then
			for statusKey, priority in pairs(map) do
				local status = Grid2.statuses[statusKey]
				if (status and tonumber(priority)) then
					indicator:RegisterStatus(status, priority)
				end
			end
		end
	end
end

-- Update & Layout all enabled indicators of all frames
function Grid2Options:UpdateIndicators(typ)
	for _, indicator in ipairs(Grid2:GetIndicatorsEnabled()) do
		if indicator.parentName==nil and ( typ==nil or indicator.dbx.type == typ ) then
			self:UpdateIndicatorDB(indicator)
			indicator:LayoutAllFrames()
			if indicator.childName then
				Grid2:GetIndicatorByName(indicator.childName):LayoutAllFrames()
			end
		end
	end
	Grid2Frame:UpdateIndicators()
end

-- Grid2Options:GetLayouts()
function Grid2Options:GetLayouts( meta )
    local list= { }
	local raid = strfind(meta,"raid")
	for name, layout in pairs(Grid2Layout.layoutSettings) do
      if layout.meta[meta] or (raid and layout.meta["raid"]) then
	     list[name]= LG[name]
	  end
	end
	return list
end

-- Grid2Options:GetValidatedName()
function Grid2Options:GetValidatedName(name)
	name = name:gsub("[\"%.]", "")
	name = name:gsub(" ", "-")
	return name
end

-- Copy elements of a table into another table,
-- Does not wipe the destination table
-- Does not do a deep copy, only root keys are copied
-- If dst is not specified creates an empty table to copy src into
-- If src is not specified returns an empty table
function Grid2Options:CopyOptionsTable(src, dst)
	dst = dst or {}
	if src then
		for k,v in pairs(src) do
			dst[k] = v
		end
	end
	return dst
end

-- Goto the specified options section.
function Grid2Options:SelectGroup( ... )
	LibStub("AceConfigDialog-3.0"):SelectGroup( "Grid2", ... )
end

-- Grid2Options.MEDIA_FONT_DEFAULT
-- Grid2Options.MEDIA_VALUE_DEFAULT
-- Grid2Options.GetFontsValues()
-- Grid2Optoins.GetStatusBarValues()
do
	local fonts
	local bars
	local self = Grid2Options
	local media = LibStub("LibSharedMedia-3.0", true)
	-- Calculate and save libSharedMedia font key for STANDARD_TEXT_FONT
	for key, font in pairs( media:HashTable('font') or {} ) do
		if font == STANDARD_TEXT_FONT then
			Grid2Options.MEDIA_FONT_DEFAULT = key
			break
		end
	end
	Grid2Options.MEDIA_VALUE_DEFAULT = string.format( "*%s*", L["Default"] )
	Grid2Options.GetFontValues = function()
		fonts = fonts or self:CopyOptionsTable(AceGUIWidgetLSMlists.font)
		fonts[ self.MEDIA_VALUE_DEFAULT ] = media:Fetch('font', Grid2Frame.db.profile.font or self.MEDIA_FONT_DEFAULT) or STANDARD_TEXT_FONT
		return fonts
	end
	Grid2Options.GetStatusBarValues = function()
		bars = bars or self:CopyOptionsTable(AceGUIWidgetLSMlists.statusbar)
		bars[ self.MEDIA_VALUE_DEFAULT ] = media:Fetch('statusbar', Grid2Frame.db.profile.barTexture or 'Gradient') or 'Gradient'
		return bars
	end
end

-- Grid2Options.PLAYER_CLASSES
-- Grid2Options.HEADER_TYPES
Grid2Options.PLAYER_CLASSES = {}
for class, translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	local coord = CLASS_ICON_TCOORDS[class]
	if coord then
		Grid2Options.PLAYER_CLASSES[class] = string.format("|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:0:0:0:0:256:256:%f:%f:%f:%f:0|t%s",coord[1]*256,coord[2]*256,coord[3]*256,coord[4]*256,translation)
	end
end
Grid2Options.HEADER_TYPES = { player = L['Players'], pet = L['Pets'], boss = L['Bosses'], target = L['Target'], focus = L['Focus'], self = L['Player'] }

-- Grid2Options:ConfirmDialog(), Grid2Options:ShowEditDialog()
do
	StaticPopupDialogs["GRID2OPTIONS_GENERAL_DIALOG"] = { timeout = 0, whileDead = 1, hideOnEscape = 1, button1 = ACCEPT, button2 = CANCEL }

	local function ShowDialog(message, textDefault, funcAccept, funcCancel, textAccept, textCancel)
		local t = StaticPopupDialogs["GRID2OPTIONS_GENERAL_DIALOG"]
		t.OnShow = function (self)	if textDefault then self.editBox:SetText(textDefault) end; self:SetFrameStrata("TOOLTIP") end
		t.OnHide = function(self) self:SetFrameStrata("DIALOG")	end
		t.hasEditBox = textDefault and true or nil
		t.text = message
		t.button1 = funcAccept and (textAccept or ACCEPT) or nil
		t.button2 = funcCancel and (textCancel or CANCEL) or nil
		t.OnCancel = funcCancel
		t.OnAccept = funcAccept and function (self)	funcAccept( textDefault and self.editBox:GetText() ) end or nil
		StaticPopup_Show ("GRID2OPTIONS_GENERAL_DIALOG")
	end

	function Grid2Options:MessageDialog(message, funcAccept)
		ShowDialog(message, nil, funcAccept or Grid2.Dummy)
	end

	function Grid2Options:ConfirmDialog(message, funcAccept, funcCancel, textAccept, textCancel)
		ShowDialog(message, nil, funcAccept, funcCancel or Grid2.Dummy, textAccept, textCancel )
	end

	function Grid2Options:ShowEditDialog(message, text, funcAccept, funcCancel)
		ShowDialog(message, text or "", funcAccept, funcCancel or Grid2.Dummy)
	end
end
