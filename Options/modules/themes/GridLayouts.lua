--[[
	General > Layouts Tab > General & Advanced Tabs
--]]

local L = Grid2Options.L
local LG = Grid2Options.LG

local theme = Grid2Options.editedTheme

local GetTableValue = Grid2Options.GetTableValueSafe
local SetTableValue = Grid2Options.SetTableValueSafe

-- enable test mode
local TestMode
do
	local frame, text, textbg
	local function DisplayTestInfo(self)
		frame = CreateFrame("Frame",nil, self.frame)
		frame:SetFrameStrata('DIALOG')
		frame:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, -4)
		frame:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT", 0, -4)
		frame:SetHeight(24)
		frame:SetScript("OnMouseUp", Grid2Layout.frame:GetScript("OnMouseUp") )
		frame:SetScript("OnMouseDown", Grid2Layout.frame:GetScript("OnMouseDown") )
		frame:SetScript("OnEnter", Grid2Layout.frame:GetScript("OnEnter") )
		frame:EnableMouse(true)
		textbg = frame:CreateTexture(nil, "OVERLAY")
		textbg:SetPoint('CENTER')
		textbg:SetColorTexture( .1, .1, .1, 1)
		text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		text:SetPoint('CENTER')
		DisplayTestInfo = function(self)
			if Grid2Frame.dba.profile.extraThemes~=nil then
				text:SetFormattedText("|cFFffffff%s:|r %s |cFFffffff%s:|r %s", L["Theme"], select(2,Grid2:GetCurrentTheme()), L["Layout"], LG[self.layoutName])
			else
				text:SetFormattedText("|cFFffffff%s:|r %s", L["Layout"], LG[self.layoutName])
			end
			textbg:SetWidth( text:GetWidth() + 8 )
			textbg:SetHeight( text:GetHeight() + 4 )
			frame:Show()
		end
		DisplayTestInfo(self)
	end

	local function SetupTestInfo(enabled)
		if enabled then
			DisplayTestInfo(Grid2Layout)
		elseif frame then
			frame:Hide()
		end
	end

	function TestMode(info)
		local layouts, layoutName, maxPlayers = theme.layout.layouts
		if info.handler[1] then
			maxPlayers = info.handler[1]
			layoutName = layouts[maxPlayers] or layouts[ (maxPlayers==1 and "solo") or (maxPlayers==5 and "party") or "raid" ]
		else
			maxPlayers = strfind(info.arg,"raid") and 40 or 5
			layoutName = layouts[info.arg] or layouts["raid"]
		end
		local enabled = (not Grid2.testMaxPlayers) or (theme.index~=Grid2.testThemeIndex or layoutName~=Grid2Layout.testLayoutName or maxPlayers~=Grid2.testMaxPlayers)
		Grid2Layout:SetTestMode(enabled, theme.index, layoutName, maxPlayers)
		SetupTestInfo(enabled)
	end

	function Grid2Options:SetLayoutTestMode(enabled)
		if enabled == nil then enabled = not Grid2.testMaxPlayers end
		Grid2Layout:SetTestMode( enabled, Grid2.currentTheme or 0, Grid2Layout.layoutName, math.max(select(3,Grid2:GetGroupType()),5) )
		SetupTestInfo(enabled)
	end
end

-- special header setup
local function SetupSpecialHeader(key, enabled)
	theme.layout.specialHeaders = theme.layout.specialHeaders or {}
	theme.layout.specialHeaders[key] = enabled or nil
	if enabled then
		local dbx = Grid2.db.profile.statuses.name
		if dbx and not dbx.defaultName then
			dbx.defaultName = 1
			Grid2:GetStatusByName('name'):UpdateDB()
		end
	elseif not next(theme.layout.specialHeaders) then
		theme.layout.specialHeaders = nil
	end
	Grid2Layout:RefreshLayout()
end

-- MakeLayoutsOptions()
local MakeLayoutsOptions
do
	local function GetValues(info)
		local layouts = Grid2Options:GetLayouts(info.arg)
		if strfind(info.arg,"raid@") then
			local raid = theme.layout.layouts["raid"] or "undefined"
			layouts["default"] = "*" .. L["Use Raid layout"] .. " ("..LG[raid]..")*"
		end
		return layouts
	end
	local function GetLayout(info)
		return theme.layout.layouts[info.arg] or "default"
	end
	local function SetLayout(info,v)
		theme.layout.layouts[info.arg] = (v~="default") and v or nil
		Grid2Layout:ReloadLayout()
	end

	function MakeLayoutsOptions(forGroupType)
		local options = {}
		local order = 10
		local function MakeSeparatorOption(description)
			options["sep"..order] = { type = "header",  name = L[description],  order = order }
			order = order + 100
		end
		local function MakeLayoutOptions(raidType, name)
			options[raidType]= {
				type   = "select",
				name   = L[name],
				desc   = L["Select which layout to use for: "] .. L[name],
				order  = order + 5,
				width  = "double",
				get    = GetLayout,
				set    = SetLayout,
				values = GetValues,
				arg    = raidType,
			}
			options[raidType.."Test"] = {
				type     = "execute",
				name     = "",
				image    = "Interface\\MINIMAP\\TRACKING\\None",
				imageWidth = 24,
				imageHeight = 22,
				width    = 0.15,
				desc     = L["Test the layout."],
				order    = order + 10,
				func     = TestMode,
				disabled = InCombatLockdown,
				arg      = raidType,
			}

			options[raidType.."sep"] = { type = "description",  name = "",  order = order + 99 }
			order = order + 100
		end

		if forGroupType then

			options.title = {
				order = 1,
				type = "description",
				name = L["A Layout defines which unit frames will be displayed and the way in which they are arranged. Here you can set different layouts for each group or raid type."]
			}

			-- partyTypes = solo party arena raid
			MakeLayoutOptions( "solo"       , "Solo"  )
			MakeLayoutOptions( "party"      , "Party" )
			MakeLayoutOptions( "raid"       , "Raid"  )
			MakeLayoutOptions( "arena"      , "Arena" )

		else

			-- instTypes  = none pvp lfr flex mythic other
			options.titleraid = {
				order = order + 10,
				type = "description",
				name = "\n" .. L["Select layouts for different Raid types."]
			}
			order = order + 10

			MakeLayoutOptions( "raid@pvp"   , "PvP Instances (BGs)" )
			MakeLayoutOptions( "raid@lfr"   , "LFR Instances" )
			MakeLayoutOptions( "raid@flex"  , "Flexible raid Instances (normal/heroic)" )
			MakeLayoutOptions( "raid@mythic", "Mythic raids Instances" )
			MakeLayoutOptions( "raid@other" , "Other raids Instances" )
			MakeLayoutOptions( "raid@none"  , "In World" )

		end

		return options
	end
end

-- MakeFrameSizesOptions()
local MakeFrameSizesOptions
do
	local layout
	local new_sizes = {}
	local size_values = {1,5,10,15,20,25,30,35,40}

	local options_item = {
		layoutName = {
			type   = "select",
			name   = L["Layout"],
			desc   = L["Layout"],
			order  = 1,
			width  = "normal",
			get    = function(info)
				return theme.layout.layouts[info.handler[1]] or "default"
			end,
			set    = function(info,v)
				new_sizes[info.handler[1]] = v
				theme.layout.layouts[info.handler[1]] = (v~="default") and v or nil
				Grid2Layout:ReloadLayout()
			end,
			values = function(info)
				local v = info.handler[1]
				local layouts = Grid2Options:GetLayouts( (v==1 and "solo") or (v==5 and "party") or "raid" )
				layouts["default"] = "*" .. L["Default"] .. "*"
				return layouts
			end,
			hidden = false,
		},
		frameWidth = {
			type = "range",
			name = L["Frame Width"],
			desc = L["Select zero to use default Frame Width"],
			order = 2,
			softMin = 0,
			softMax = 100,
			step = 1,
			get = function(info) return theme.frame.frameWidths[info.handler[1]] or 0 end,
			set = function(info, v)
					new_sizes[info.handler[1]] = v
					theme.frame.frameWidths[info.handler[1]] = (v~=0) and v or nil
					if info.handler[1] == Grid2Layout.instMaxPlayers then
						Grid2Layout:UpdateDisplay()
					end
				  end,
			hidden = false,
		},
		frameHeight = {
			type = "range",
			name = L["Frame Height"],
			desc = L["Select zero to use default Frame Height"],
			order = 3,
			softMin = 0,
			softMax = 100,
			step = 1,
			get = function (info) return theme.frame.frameHeights[info.handler[1]] or 0 end,
			set = function (info, v)
					new_sizes[info.handler[1]] = v
					theme.frame.frameHeights[info.handler[1]] = (v~=0) and v or nil
					if info.handler[1] == Grid2Layout.instMaxPlayers then
						Grid2Layout:UpdateDisplay()
					end
				  end,
			hidden = false,
		},
		test = {
			type = "execute",
			width = "half",
			order = 1.25,
			name = L["Test"],
			desc = L["Test"],
			disabled = InCombatLockdown,
			func = TestMode,
			hidden = false,
		},
		delete = {
			type = "execute",
			width = "half",
			order = 1.5,
			name = L["Delete"],
			desc = L["Delete"],
			func = function (info)
				local v = info.handler[1]
				new_sizes[v] = nil
				theme.layout.layouts[v] = nil
				theme.frame.frameWidths[v] = nil
				theme.frame.frameHeights[v] = nil
				if v == Grid2Layout.instMaxPlayers then
					Grid2Layout:UpdateDisplay()
					Grid2Layout:ReloadLayout()
				end
			end,
			confirm = function() return L["Are you sure?"] end,
			hidden = false,
		},
	}

	local options = {
		tit = {
			order = 0,
			type = "description",
			name = L["A Layout defines which unit frames will be displayed and the way in which they are arranged. Here you can set different layouts for each raid size."],
			hidden = function()
				-- To detect if edited theme has changed
				if theme.layout ~= layout then
					layout = theme.layout
					wipe(new_sizes)
				end
			end,
		},
		typ = {
			type = 'select',
			order = 0.1,
			width = 1.5,
			name = L["Choose the Raid Size calculation method"],
			desc = L["Choose the Raid Size calculation method"],
			get = function()
				return Grid2.db.profile.raidSizeType or 0
			end,
			set = function(_,v)
				Grid2.db.profile.raidSizeType = (v~=0) and v or nil
				Grid2:GroupChanged()
			end,
			values = Grid2Options.raidSizeValues,
		},
		add ={
			type = 'select',
			order = 0.2,
			width = "half",
			name = L["Add Raid Size"],
			desc = L["Add Raid size"],
			get = function() end,
			set = function(_,v)
				new_sizes[ size_values[v] ] = true
			end,
			values = size_values,
		}
	}

	local function IsHidden(info)
		local size = info.handler[1]
		return not ( theme.layout.layouts[size] or theme.frame.frameWidths[size] or theme.frame.frameHeights[size] or new_sizes[size] )
	end

	for _,m in pairs(size_values) do
		options['instance'..m] = {
			type  = "group",
			inline = true,
			order = m,
			name  = m>1 and string.format(L["%d man raid size"],m) or L["Solo"],
			handler = { m },
			args = options_item,
			hidden = IsHidden,
		}
	end

	MakeFrameSizesOptions = function() return options end
end

--===================================================================================================

local generalOptions = {

	desc1 = {
		order = 0,
		type = "description",
		name = L["Default settings applied to all user defined layouts and some built-in layouts."] .. "\n"
	},

	insecureHeaders = {
		order = 1,
		type = "toggle",
		name = "|cffffd200".. L["Use Blizzard Unit Frames"] .."|r",
		desc = L["Disable this option to use custom unit frames instead of blizzard frames. This fixes some bugs in blizzard code, but units cannot join/leave the roster while in combat."],
		width = "full",
		get = function(info)
			return not Grid2Layout.db.global.useInsecureHeaders
		end,
		set = function(info,v)
			v = (not v) or nil
			Grid2Layout.db.global.useInsecureHeaders = v
			Grid2Layout.useInsecureHeaders = v
			Grid2Layout:RefreshLayout()
		end,
		hidden = function() return 	not (Grid2.isVanilla or Grid2.debugging or Grid2Layout.db.global.useInsecureHeaders) end,
		confirm = function(info, v) return not v and L["Warning, this is an experimental option. Are you sure you want to disable blizzard frames?"] or nil end
	},

	sortMethod = {
		order = 2,
		type = "toggle",
		name = "|cffffd200".. L["Sort units by name"] .."|r",
		desc = L["Sort the units by player name, if unchecked the units will be displayed in raid order. Not all layouts will obey this setting."],
		width = "full",
		get = function()
			return Grid2Layout.customDefaults.sortMethod=="NAME"
		end,
		set = function(info,v)
			Grid2Layout.customDefaults.sortMethod = (v and "NAME") or nil
			Grid2Layout:RefreshLayout()
		end,
	},

	vehicle = {
		order = 3,
		type = "toggle",
		name = "|cffffd200".. L["Toggle for vehicle"] .."|r",
		desc = L["When the player is in a vehicle replace the player frame with the vehicle frame."],
		width = "full",
		get = function()
			return Grid2Layout.customDefaults.toggleForVehicle
		end,
		set = function(info,v)
			Grid2Layout.customDefaults.toggleForVehicle = v
			Grid2Layout:RefreshLayout()
		end,
	},

	allGroups = {
		order = 4,
		type = "toggle",
		name = "|cffffd200".. L["Display all groups"] .."|r",
		desc = L["Display all raid groups, if unchecked the groups will by filtered according to the instance size. Not all layouts will obey this setting."],
		width = "full",
		get = function(info)
			return theme.layout.displayAllGroups
		end,
		set = function(info,v)
			theme.layout.displayAllGroups= v or nil
			Grid2Layout:RefreshLayout()
		end,
	},

	detachedAllHeaders = {
		order = 5,
		type = "toggle",
		name = "|cffffd200".. L["Detach all groups"] .."|r",
		desc = L["Enable this option to detach unit frame groups, so each group can be moved individually."],
		width = "full",
		get = function(info)
			return theme.layout.detachedHeaders=='player'
		end,
		set = function(info,v)
			theme.layout.detachedHeaders = v and 'player' or nil
			Grid2Layout:RefreshLayout()
		end,
	},

	detachedPetHeaders = {
		order = 6,
		type = "toggle",
		name = "|cffffd200".. L["Detach pets groups"] .."|r",
		desc = L["Enable this option to detach the pets group, so pets group can be moved individually."],
		width = "full",
		get = function(info)
			return theme.layout.detachedHeaders~=nil
		end,
		set = function(info,v)
			theme.layout.detachedHeaders = v and 'pet' or nil
			Grid2Layout:RefreshLayout()
		end,
		disabled = function() return theme.layout.detachedHeaders=='player' end,
	},

	desc2 = {
		order = 99,
		type = "description",
		name = L["Special units headers visibility."] .. "\n"
	},

	displayPlayer = {
		order = 100,
		type = "toggle",
		name = "|cffffd200".. L["Display Player unit"] .."|r",
		desc = L["Enable this option to display the player unit."],
		width = "full",
		get = function(info)
			return theme.layout.specialHeaders and theme.layout.specialHeaders.self~=nil
		end,
		set = function(info,v)
			SetupSpecialHeader('self', v)
		end,
	},

	displayTarget = {
		order = 105,
		type = "toggle",
		name = "|cffffd200".. L["Display Target unit"] .."|r",
		desc = L["Enable this option to display the target unit."],
		width = "full",
		get = function(info)
			return theme.layout.specialHeaders and theme.layout.specialHeaders.target~=nil
		end,
		set = function(info,v)
			SetupSpecialHeader('target', v)
		end,
	},

	displayTargetTarget = {
		order = 110,
		type = "toggle",
		name = "|cffffd200".. L["Display Target of Target unit"] .."|r",
		desc = L["Enable this option to display the target of target unit."],
		width = "full",
		get = function(info)
			return theme.layout.specialHeaders and theme.layout.specialHeaders.targettarget~=nil
		end,
		set = function(info,v)
			SetupSpecialHeader('targettarget', v)
		end,
	},

	displayFocus = {
		order = 115,
		type = "toggle",
		name = "|cffffd200".. L["Display Focus unit"] .."|r",
		desc = L["Enable this option to display the focus unit."],
		width = "full",
		get = function(info)
			return theme.layout.specialHeaders and theme.layout.specialHeaders.focus~=nil
		end,
		set = function(info,v)
			SetupSpecialHeader('focus', v)
		end,
		hidden = function() return Grid2.isVanilla end,
	},

	displayFocusTarget = {
		order = 120,
		type = "toggle",
		name = "|cffffd200".. L["Display Target of Focus unit"] .."|r",
		desc = L["Enable this option to display the target of focus unit."],
		width = "full",
		get = function(info)
			return theme.layout.specialHeaders and theme.layout.specialHeaders.focustarget~=nil
		end,
		set = function(info,v)
			SetupSpecialHeader('focustarget', v)
		end,
		hidden = function() return Grid2.isVanilla end,
	},

	displayBosses = {
		order = 125,
		type = "toggle",
		name = "|cffffd200".. L["Display Bosses units"] .."|r",
		desc = L["Enable this option to display bosses units."],
		width = "full",
		get = function(info)
			return theme.layout.specialHeaders and theme.layout.specialHeaders.boss~=nil
		end,
		set = function(info,v)
			SetupSpecialHeader('boss', v)
		end,
		hidden = function() return Grid2.versionCli<50000 end,
	},

}

--===================================================================================================

Grid2Options:AddThemeOptions( "layouts", "Layouts" , {

general = {
	type = "group",
	order= 199,
	name = L["General"],
	args = generalOptions,
},

bygroup = {
	type = "group",
	order= 200,
	name = L["By Group Type"],
	args = MakeLayoutsOptions(true)
},

byraid = {
	type = "group",
	order= 201,
	name = L["By Raid Type"],
	args = MakeLayoutsOptions(false)
},

frameSizes = {
	type = "group",
	order= 202,
	name = L["By Raid Size"],
	args = MakeFrameSizesOptions(),
},

layoutEditor = Grid2Options:GetLayoutsEditorOptions(),

} )

--}}
