--[[
	General > Layouts Tab > General & Advanced Tabs
--]]

local L = Grid2Options.L
local LG = Grid2Options.LG

local theme = Grid2Options.editedTheme 

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
	local function TestMode(info)
		local maxPlayers = (info.arg=="solo" and 1) or (info.arg=="party" and 5) or (info.arg=="arena" and 5) or 40
		Grid2Options:LayoutTestEnable( theme.layout.layouts[info.arg] or theme.layout.layouts["raid"], nil,nil, maxPlayers )
	end
	function MakeLayoutsOptions(advanced)
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
		
		options.title = {
			order = 1,
			type = "description",
			name = L["A Layout defines which unit frames will be displayed and the way in which they are arranged. Here you can set different layouts for each group or raid type."]
		}
		-- partyTypes = solo party arena raid
		-- instTypes  = none pvp lfr flex mythic other
		if advanced then
			MakeLayoutOptions( "raid@pvp"   , "PvP Instances (BGs)" )
			MakeLayoutOptions( "raid@lfr"   , "LFR Instances" )
			MakeLayoutOptions( "raid@flex"  , "Flexible raid Instances (normal/heroic)" )
			MakeLayoutOptions( "raid@mythic", "Mythic raids Instances" )
			MakeLayoutOptions( "raid@other" , "Other raids Instances" )
			MakeLayoutOptions( "raid@none"  , "In World" )
		else
			MakeLayoutOptions( "solo"       , "Solo"  )
			MakeLayoutOptions( "party"      , "Party" )
			MakeLayoutOptions( "raid"       , "Raid"  )
			MakeLayoutOptions( "arena"      , "Arena" )
		end
		return options
	end
end

-- MakeFrameSizesOptions()
local MakeFrameSizesOptions
do
	local layout
	local new_sizes = {}
	local size_values = {1,5,10,20,25,30,40}

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
			func = function(info)
				local v = info.handler[1]
				Grid2Options:LayoutTestEnable(
					theme.layout.layouts[v] or theme.layout.layouts[ (v==1 and "solo") or (v==5 and "party") or "raid" ],
					theme.frame.frameWidths[v],
					theme.frame.frameHeights[v],
					v
				)
			end,
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
		title = {
			order = 0,
			type = "description",
			name = L["A Layout defines which unit frames will be displayed and the way in which they are arranged. Here you can set different layouts for each instance size."],
			hidden = function()
				-- To detect if edited theme has changed 
				if theme.layout ~= layout then
					layout = theme.layout
					wipe(new_sizes)
				end
			end,
		},		
		add ={
			type   = 'select',
			order  = 500,
			width = "half",
			name   = L["Add"],
			desc   = L["Add instance size"],
			get    = function() end,
			set    = function(_,v)
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
			name  = m>1 and string.format(L["%d man instances"],m) or L["Solo"],
			handler = { m },
			args = options_item,
			hidden = IsHidden,
		}
	end
	
	MakeFrameSizesOptions = function() return options end
end

--===================================================================================================

Grid2Options:AddThemeOptions( "layouts", "Layouts" , {

bygroup = {
	type = "group",
	order= 200,
	name = L["By Group Type"],
	args = MakeLayoutsOptions(false),
},

byraid = {
	type = "group",
	order= 201,
	name = L["By Raid Type"],
	args = MakeLayoutsOptions(true),
},

frameSizes = {
	type = "group",
	order= 202,
	name = L["By Raid Size"],
	args = MakeFrameSizesOptions(),
}

} )

--}}
