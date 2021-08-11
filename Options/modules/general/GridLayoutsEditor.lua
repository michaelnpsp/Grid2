--=====================================================================================
-- Layouts Editor
--=====================================================================================

local L  = Grid2Options.L
local LG = Grid2Options.LG

local Grid2Layout = Grid2:GetModule("Grid2Layout")

--=====================================================================================

local RETAIL = not Grid2.isClassic

local EDITOR_IDENTIFIER = "LayoutEditor"

local CHARACTER_PLUS_TEXTURE = "Interface\\PaperDollInfoFrame\\Character-Plus"

local CLASSES_SORTED = "DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR"

local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,DEMONHUNTER,ROGUE,MONK,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"

local DEFAULT_PET_ORDER   = "HUNTER,WARLOCK,MAGE,DEATHKNIGHT,DRUID,PRIEST,SHAMAN,MONK,PALADIN,DEMONHUNTER,ROGUE,WARRIOR"

local COLUMN_VALUES = {	["1"]="1", ["2"]="2", ["3"]="3", ["4"]="4", ["5"]="5", ["6"]="6", ["7"]="7", ["8"]="8" }

local GROUPBY_VALUES ={ CLASS = L["Class"], GROUP = L["Group"], ASSIGNEDROLE = RETAIL and L["Role"] or nil, ROLE = L["Role(Raid)"], NONE = L["None"] }

local SORTBYN_VALUES= { INDEX = L["Index"], NAME = L["Name"], NAMELIST = L["List"],	NIL = L["Def."] }

local SORTBY_VALUES= { INDEX = L["Index"], NAME = L["Name"], NIL = L["Def."] }

--=====================================================================================

local editorOptions
local generalOptions
local layoutOptions
local headerOptions

local editedHeader
local editedHeaderIndex
local editedLayout
local editedLayoutName

--=====================================================================================

local tmpTable = {}
local function SelectGroup( info, layoutName, headerIndex )
	if not layoutName then
		editedLayout, editedLayoutName = nil, nil
	end
	wipe(tmpTable)
	local options = Grid2Options.options
	repeat
		tmpTable[#tmpTable+1] = info[#tmpTable+1]
		options = options.args[ info[#tmpTable] ]
	until #tmpTable>=#info or options.arg==EDITOR_IDENTIFIER
	tmpTable[#tmpTable+1] = layoutName
	tmpTable[#tmpTable+1] = tostring(headerIndex)
	LibStub("AceConfigDialog-3.0"):SelectGroup( "Grid2", unpack(tmpTable) )
end

local function GetLayoutsSorted()
	local sorted  = {}
	for name,layout in pairs(Grid2Layout.customLayouts) do
		sorted[#sorted+1] = name
	end
	table.sort(sorted)
	return sorted
end

local function GetLayoutsValues()
	local values  = {}
	for name in pairs(Grid2Layout.customLayouts) do
		values[name] = name
	end
	return values
end

local function RefreshLayout(force)
	if Grid2Layout.layoutName==editedLayoutName or force then
		Grid2Layout:RefreshLayout()
	end
end

local function GetValue(attr, defvalue)
	return editedHeader[attr] or (editedLayout.defaults and editedLayout.defaults[attr]) or defvalue
end

local function GetHeaderName(info)
	if editedLayout then
		local index = tonumber(info[#info])
		if index then
			local layout = editedLayout[index]
			if layout then
				return string.format( "%s(%d)", (layout.type=='pet' and L['pets']) or (layout.type=='custom' and L['custom']) or L['players'], index )
			end
		end
	end
end

local function IsHeaderHidden(info)
	return not (editedLayout and editedLayout[tonumber(info[#info])])
end

local function CreateHeader(info, index)
	if type(index)=='number' then
		table.insert( editedLayout, index+1, Grid2.CopyTable(editedLayout[index]) )
		index = index + 1
	else
		table.insert( editedLayout, { type = (index=="pet" and "pet") or (index=="custom" and "custom") or nil, unitsPerColumn = 5, maxColumns = 1 } )
		index= #editedLayout
	end
	RefreshLayout()
	SelectGroup( info, editedLayoutName, index )
	return true
end

local function RemoveLayoutOptions(name)
	editorOptions[name] = nil
end

local layoutMaxOrder = 1
local function CreateLayoutOptions(name)
	editorOptions[name] = {
		type = "group",
		childGroups = "tab",
		order = layoutMaxOrder,
		name = LG[name],
		args = layoutOptions,
	}
	layoutMaxOrder = layoutMaxOrder + 1
end

local function RemoveLayout(info, name)
	name = name or editedLayoutName
	Grid2Layout.customLayouts[name]  = nil
	Grid2Layout.layoutSettings[name] = nil
	Grid2Layout:FixLayouts()
	RemoveLayoutOptions(name)
	RefreshLayout()
	SelectGroup(info)
end

local function RemoveHeader(info, index)
	if #editedLayout>1 then
		index = index or editedHeaderIndex
		table.remove( editedLayout, index )
		SelectGroup( info, editedLayoutName, index>#editedLayout and #editedLayout or index )
		RefreshLayout()
	else
		RemoveLayout(info)
	end
end

local function FilterGet(info)
	local key, field = unpack( info.arg )
	local filter = editedHeader[field]
	return not filter or filter=="auto" or strfind( ","..filter..",", ","..key.."," )~=nil
end

local function FilterSet(info,value)
	local key, field, allkeys = unpack( info.arg )
	local filter = editedHeader[field] or allkeys
	local tbl = filter~="" and { strsplit(",",  filter) } or {}
	if value then
		tbl[#tbl+1] = key
		table.sort(tbl)
	else
		Grid2.TableRemoveByValue(tbl,key)
	end
	filter = table.concat(tbl,",")
	editedHeader[field] =  (filter ~= allkeys) and filter or nil
	editedHeader.strictFiltering = (editedHeader.roleFilter~=nil and editedHeader.groupFilter~=nil) or nil
	RefreshLayout()
end

local function IsOptionHidden()
	return editedHeader.type=='custom'
end

-- Used by Profile Export/Import module
function Grid2Options:AddNewCustomLayoutsOptions()
	for name in pairs(Grid2Layout.customLayouts) do
		if not editorOptions[name] then
			CreateLayoutOptions(name)
		end
	end
end

--=====================================================================================
-- standard header player or pets
--=====================================================================================

headerOptions = {

	__load = { type = "header", order = 0, name = "", hidden = function(info)
			editedHeaderIndex = tonumber(info[#info-1])
			editedHeader = editedLayout[ editedHeaderIndex ]
			return true
	end },

	columns =  {
		type   = 'select',
		order  = 2,
		width = 0.55,
		name   = L["Columns"],
		desc   = L["Maximum number of columns to display"],
		get    = function()  return tostring(GetValue("maxColumns", 1)) end,
		set    = function(_,v)
			editedHeader.maxColumns = tonumber(v)
			RefreshLayout()
		end,
		values = COLUMN_VALUES,
		hidden = false,
	},

	upc =  {
		type   = 'select',
		order  = 3,
		width = 0.55,
		name   = L["Units/Column"],
		desc   = L["Maximum number of units per column to display"],
		get    = function()	return string.format("%02d", GetValue("unitsPerColumn",5))	end,
		set    = function(_,v)
			editedHeader.unitsPerColumn= tonumber(v)
			RefreshLayout()
		end,
		values = { ["01"]="01", ["02"]="02", ["03"]="03", ["04"]="04", ["05"]="05", ["06"]="06", ["07"]="07", ["08"]="08", ["09"]="09", ["10"]="10", ["15"]="15", ["20"]="20", ["25"]="25", ["30"]="30", ["35"]="35", ["40"]="40" },
		hidden = false,
	},

	sortby =  {
		type   = 'select',
		order  = 4,
		width  = 0.55,
		name   = L["Sort by"],
		desc   = L["Index (Raid Order)\nName (Unit Names))\nList (Name List)\nDef (Default)"],
		get    = function() return GetValue("sortMethod", "NIL") end,
		set    = function(_,v)
			editedHeader.sortMethod = v~="NIL" and v or nil
			RefreshLayout()
		end,
		values = function()	return editedHeader.nameList and SORTBYN_VALUES or SORTBY_VALUES end,
		hidden = IsOptionHidden,
	},

	groupby =  {
		type   = 'select',
		order  = 5,
		width  = 0.55,
		name   = L["Group by"],
		desc   = L["Group by"],
		get    = function() return GetValue("groupBy","NONE") end,
		set    = function(_,v)
					if v=="CLASS" then
						editedHeader.groupBy = v
						editedHeader.groupingOrder = editedHeader.type=="pet" and DEFAULT_PET_ORDER or DEFAULT_GROUP_ORDER
					elseif v=="GROUP" then
						editedHeader.groupBy = v
						editedHeader.groupingOrder = "1,2,3,4,5,6,7,8"
					elseif v=="ASSIGNEDROLE" then
						editedHeader.groupBy = "ASSIGNEDROLE"
						editedHeader.groupingOrder = "TANK,HEALER,DAMAGER,NONE"
					elseif v=='ROLE' then
						editedHeader.groupBy = "ROLE"
						editedHeader.groupingOrder = "MAINTANK,MAINASSIST,NONE"
					else
						editedHeader.groupingOrder, editedHeader.groupBy = nil, nil
					end
					RefreshLayout()
		end,
		values = GROUPBY_VALUES,
		disabled = function() return editedHeader.nameList~=nil end,
		hidden = IsOptionHidden,
	},

	nameList = {
		type = "input",
		order = 50,
		width = "full",
		name = L["Name List"],
		desc = L["Type a list of player names"],
		multiline = 5,
		get = function()
			return editedHeader.nameList and table.concat( { strsplit(",", editedHeader.nameList ) } , ", " ) or ""
		end,
		set = function(_, v)
			local t = { strsplit("\n,;:|", v) }
			for i=#t,1,-1 do
				t[i] = strtrim( t[i] )
				if t[i] == '' then
					table.remove(t,i)
				end
			end
			local nameList = table.concat( t, "," )
			if nameList~="" then
				editedHeader.nameList = nameList
				editedHeader.groupBy = nil
				editedHeader.groupingOrder = nil
			else
				editedHeader.nameList = nil
				editedHeader.sortMethod = (editedHeader.sortMethod~="NAMELIST") and editedHeader.sortMethod or nil
			end
			RefreshLayout()
		end,
		hidden = IsOptionHidden,
	},

	unitsList = {
		type = "input",
		order = 50,
		width = "full",
		name = L["Units List"],
		desc = L["Type a list of unit names, valid units:\ntarget, focus\nboss1, boss2, boss3, boss4, boss5\narena1, arena2, arena3, arena4, arena5\nplayer, party1, party2, party3, party4\nraid1, raid2, raid3, .. , raid40"],
		multiline = 9,
		get = function()
			return editedHeader.unitsFilter or ''
		end,
		set = function(_, v)
			local t = { strsplit("\n,;:|", v) }
			for i=#t,1,-1 do
				v = strlower( strtrim( t[i] ) )
				v = strmatch(v,'^target$') or strmatch(v,'^focus$') or strmatch(v,'^player$') or strmatch(v,'^party%d+$') or strmatch(v,'^raid%d+$') or strmatch(v,'^boss%d+$') or strmatch(v,'^arena%d+$')
				if v then
					t[i] = v
				else
					table.remove(t,i)
				end
			end
			editedHeader.unitsFilter = table.concat( t, "," )
			RefreshLayout()
		end,
		hidden = function() return editedHeader.type~='custom' end,
	},

	vehicle = {
		type = "toggle",
		name = L["Toggle vehicle"],
		desc = L["When the player is in a vehicle replace the player frame with the vehicle frame."],
		order = 54,
		width = .8,
		tristate = true,
		get = function()
			return editedHeader.toggleForVehicle
		end,
		set = function(info, value)
			editedHeader.toggleForVehicle = value
			RefreshLayout()
		end,
		hidden = false,
	},

	hidePlayer = {
		type = "toggle",
		name = L["Hide Player"],
		desc = L["Do not display the player frame (only applied when in party)."],
		order = 55,
		width = .8,
		tristate = false,
		get = function()
			return editedHeader.showPlayer==false
		end,
		set = function(info, value)
			if value then
				editedHeader.showPlayer = false
			else
				editedHeader.showPlayer = nil
			end
			RefreshLayout()
		end,
		hidden = IsOptionHidden,
	},

	hideEmptyButtons = {
		type = "toggle",
		name = L["Hide Empty"],
		desc = L["Hide the frame if the unit does not exist."],
		order = 55,
		width = .8,
		get = function()
			return editedHeader.hideEmptyUnits
		end,
		set = function(info, value)
			editedHeader.hideEmptyUnits = value or nil
			RefreshLayout()
		end,
		hidden = function() return editedHeader.type~='custom' end,
	},

	detachHeader = {
		type = "toggle",
		name = L["Detach Header"],
		desc = L["Allow to move this header independent of the other headers."],
		order = 56,
		width = .8,
		get = function()
			return editedHeader.detachHeader
		end,
		set = function(info, value)
			editedHeader.detachHeader = value or nil
			RefreshLayout(true)
		end,
		disabled = function() return editedHeaderIndex==1 end,
		hidden = false,
	},

	actionheader = { type = "header", order = 100, name = "", hidden = false },

	clone =  {
		type   = 'execute',
		order  = 101,
		width  = 0.6,
		name   = string.format( "|T%s:0|t%s", CHARACTER_PLUS_TEXTURE, L["Clone"] ),
		desc   = L["Clone this header"],
		func   = function(info)	CreateHeader(info, editedHeaderIndex) end,
		hidden = false,
	},

	delete =  {
		type   = 'execute',
		order  = 102,
		width  = 0.6,
		name   = string.format( "|T%s:0|t%s", READY_CHECK_NOT_READY_TEXTURE, L["Delete"] ),
		desc   = L["Delete this header"],
		func   = function(info)	RemoveHeader(info, editedHeaderIndex) end,
		confirm = function()
			if #editedLayout>1 then
				return L["Are you sure you want to remove this header?"]
			else
				return L["Are you sure you want to delete the selected layout?"]
			end
		end,
		hidden = false,
	},

}

if RETAIL then
	local roles  = { "TANK", "HEALER", "DAMAGER", "NONE", TANK=1, HEALER=2, DAMAGER=3, NONE=4 }
	local values = { L["Tank"], L["Healer"], L["Damager"], L["None"] }
	local function hidden()
		return editedHeader.groupBy ~= "ASSIGNEDROLE"
	end
	local function get(info)
		local role = select(info.arg, strsplit(",", editedHeader.groupingOrder) )
		return roles[role]
	end
	local function set(info,value)
		local index   = info.arg
		local tbl     = { strsplit(",", editedHeader.groupingOrder) }
		local oldrole = tbl[index]
		local newrole = roles[value]
		for i=1,#tbl do
			if tbl[i]==newrole then
				tbl[i] = oldrole
			end
		end
		tbl[index] = newrole
		editedHeader.groupingOrder = table.concat( tbl, "," )
		RefreshLayout()
	end
	headerOptions.roleorderheader = { type = "header", order = 20, name = L["Roles Order"], hidden = hidden }
	for i,role in ipairs(roles) do
		headerOptions['roleorder'..i] =  {
			type   = 'select',
			order  = 20+i,
			width  = 0.55,
			name   = "",
			desc   = "",
			get    = get,
			set    = set,
			values = values,
			arg    = i,
			hidden = hidden,
		}
	end
end

do
	headerOptions.groupheader = { type = "header", order = 30, name = L["Groups"], hidden = IsOptionHidden }
	for i=1,8 do
		headerOptions['group'..i] = {
			type = "toggle",
			name = tostring(i),
			desc = string.format("%s %d", L["Group"], i),
			order = 30+i,
			width = 0.23,
			get = FilterGet,
			set = FilterSet,
			disabled = function() return editedHeader.groupFilter=="auto" end,
			hidden = IsOptionHidden,
			arg = {  tostring(i), "groupFilter", "1,2,3,4,5,6,7,8" },
		}
	end
	headerOptions.groupauto = {
		type = "toggle",
		name = L["Auto"],
		desc = L["Automatic filter: groups will by filtered according to the instance size, for example for a 10 man raid instance, only players in groups 1&2 will be displayed."],
		order = 39,
		width = 0.4,
		get = function() return editedHeader.groupFilter=="auto" end,
		set = function(info,value)
			editedHeader.groupFilter = value and "auto" or nil
			editedHeader.strictFiltering = (editedHeader.roleFilter~=nil and editedHeader.groupFilter~=nil) or nil
			RefreshLayout()
		end,
		hidden = IsOptionHidden,
	}
end

do
	local roles, names, descs, widths
	if RETAIL then
		roles  = { "TANK", "HEALER", "DAMAGER", "NONE", "MAINTANK", "MAINASSIST" }
		names  = { L["Tank"], L["Healer"], L["Dps"], L["None"], L["MT"], L["MA"] }
		descs  = { L["Tank"], L["Healer"], L["Dps"], L["None"], L["MainTank"], L["MainAssist"] }
		widths = { .4,       .4,           .3,        .5,           .3,          .3,     }
	else
		roles  = { "MAINTANK", "MAINASSIST", "NONE" }
		names  = { L["MainTank"], L["MainAssist"], L["None"] }
		descs  = names
		widths = { .75, .75, .75 }
	end
	headerOptions.roleheader = { type = "header", order = 40, name = L["Roles"], hidden = IsOptionHidden }
	for i,role in ipairs(roles) do
		headerOptions['role'..i] = {
			type = "toggle",
			name = names[i],
			desc = descs[i],
			order = 40+i,
			width = widths[i],
			get = FilterGet,
			set = FilterSet,
			hidden = IsOptionHidden,
			arg = { role, "roleFilter", "DAMAGER,HEALER,MAINASSIST,MAINTANK,NONE,TANK" },
		}
	end
end

--=====================================================================================

layoutOptions = {

	__load = { type = "header", order = 0, name = "", hidden = function(info)
			editedLayoutName      = info[#info-1]
			editedLayout          = Grid2Layout.layoutSettings[editedLayoutName]
			return true
	end },

	new = {
		type  = "group",
		order = 300,
		name  = "+",
		desc  = L["Add a new header.\nA header displays a group of players or pets in a compat way."],

		args  = {

			title = {
				order = 1,
				type = "description",
				name = "|cffffd200".. L["Create New Header"] .."|r",
				fontSize = "medium",
			},

			desc = {
				order = 2,
				type = "description",
				name = L["Select what kind of units you want to display on the new header and click the create button."] .. "\n",
			},

			type ={
				type   = 'select',
				order  = 10,
				name   = L["New Header Type"],
				desc   = L["Select what kind of units you want to display on the new header and click the create button."],
				get    = function(info)	return layoutOptions.new.args.type.arg end,
				set    = function(info,v) layoutOptions.new.args.type.arg = v end,
				values = { player = L["players"], pet = L["pets"], custom = L["custom"] },
				arg    = "player",
				hidden = false,
			},

			create =  {
				type   = 'execute',
				order  = 20,
				width  = 0.6,
				name   = string.format( "|T%s:0|t%s", CHARACTER_PLUS_TEXTURE, L["Create"] ),
				desc   = L["Create New Header"],
				func   = function(info)
					CreateHeader( info, layoutOptions.new.args.type.arg )
					layoutOptions.new.args.type.arg = "player"
				end,
				hidden = false,
			},

		},

		hidden = function() return #editedLayout>=15 end,
	},

}

for i=1,15 do
	layoutOptions[tostring(i)] = {
		type   = "group",
		order  = 10+i,
		name   = GetHeaderName,
		desc = "",
		hidden = IsHeaderHidden,
		args   = headerOptions,
	}
end

--=====================================================================================

generalOptions = {

	createdesc = {
		order = 10,
		type = "description",
		name = "\n" .. L["Create a new user defined layout by entering a name in the editbox."],
	},

	create = {
		type = "input",
		order = 11,
		name = L["Create New Layout"],
		desc = L["Create a new user defined layout by entering a name in the editbox."],
		get = function() end,
		set = function(info, name)
			if Grid2Layout.layoutSettings[name] then return end
			Grid2Layout.customLayouts[name]= {
				meta = { raid = true, party = true, arena = true, solo = true },
				[1]  = { type="player", unitsPerColumn = 5, maxColumns = 1 },
			}
			Grid2Layout:AddLayout(name, Grid2Layout.customLayouts[name])
			CreateLayoutOptions(name)
			SelectGroup(info, name )
		end,
	},

	deletedesc = {
		order = 20,
		type = "description",
		name = "\n" .. L["Delete existing layouts from the database."],
	},

	delete = {
		type   = "select",
		name   = L['Delete Layout'],
		desc   = L['Delete Layout'],
		order  = 21,
		get    = false,
		set    = RemoveLayout,
		values = GetLayoutsValues,
		confirm = true,
		confirmText = L["Are you sure you want to delete the selected layout?"],
		disabled = function() return not next(Grid2Layout.customLayouts) end,
	},

}

--=====================================================================================

editorOptions = {}

editorOptions.__load = { type = "header",	order = 0, name = "", hidden = function()
	for _, name in pairs(GetLayoutsSorted()) do
		CreateLayoutOptions(name)
	end
	editorOptions.__load = nil
	return true
end	}

editorOptions.__general = {
	type  = "group",
	name  = string.format( "|cFFffee00[%s]|r", L["General Options"] ),
	order = 0.1,
	args  = generalOptions,
}

--=====================================================================================

local editorLayouts = {
	order = 500,
	type   = "group",
	name   = L["Editor"],
	childGroups = "select",
	args = editorOptions,
	arg  = EDITOR_IDENTIFIER, -- To locate the editor options in SelectGroup()
}
function Grid2Options:GetLayoutsEditorOptions()
	return editorLayouts
end

--=====================================================================================


