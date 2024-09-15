-- Raid Debuffs general options

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local GSRD = Grid2:GetModule("Grid2RaidDebuffs")
local RDO = Grid2Options.RDO

----------------------------------------------------------------------
-- Statuses
----------------------------------------------------------------------

local options = {}
RDO.OPTIONS_STATUSES = options

local function InitStatusOptions()
	Grid2Options:MakeStatusTitleOptions( RDO.statuses[1], options)
end

do
	local function GetStatus(info)
		return RDO.statuses[info.handler[1]]
	end
	local statusOptions = {
		type = 'group', inline = true,
		name = function(info) local status = RDO.statuses[info.handler[1]]; return status and L[status.name] or ''; end,
		hidden = function(info) return info.handler[1]>#RDO.statuses end,
		args = {
			name = {
				type = "input",
				order = 1,
				width = "full",
				name = L["Status Name"],
				desc = L["You can type a more descriptive name for this status. You can leave the field blank to recover the default name."],
				get = function(info)
					return RDO:GetStatusName(GetStatus(info))
				end,
				set = function(info,v)
					RDO:SetStatusName(GetStatus(info), strtrim(v))
				end,
			},
			color = {
				type = "color",
				order = 2,
				width = "half",
				name = L['color'],
				hasAlpha = true,
				get = function(info)
					local c = GetStatus(info).dbx.color1
					return c.r, c.g, c.b, c.a
				end,
				set = function(info, r,g,b,a)
					local c = GetStatus(info).dbx.color1
					c.r, c.g, c.b, c.a = r, g, b, a
				 end,
			},
			debuffTypeColor = {
				type = "toggle",
				order = 3,
				width = 1,
				name = L["Use debuff Type color"],
				desc = L["Use the debuff Type color first. The specified color will be applied only if the debuff has no type."],
				get = function(info)
					return GetStatus(info).dbx.debuffTypeColorize
				end,
				set = function(info, v)
					local status = GetStatus(info)
					status.dbx.debuffTypeColorize = v or nil
					if status.enabled then
						status:UpdateDB()
						GSRD:RefreshAuras()
					end
				end,
			},
			icons = {
				type = "toggle",
				order = 4,
				width = 1,
				name = L["multiple icons support"],
				desc = L["Enable multiple icons support for icons indicators."],
				get = function(info)
					return GetStatus(info).dbx.enableIcons
				end,
				set = function(info, v)
					local status = GetStatus(info)
					status.dbx.enableIcons = v or nil
					if status.enabled then
						status:UpdateDB()
						GSRD:RefreshAuras()
					end
				end,
			},
	} }
	local meta = { __index = statusOptions }
	options.status1 = setmetatable( { order = 10 , handler= {1} }, meta )
	options.status2 = setmetatable( { order = 11 , handler= {2} }, meta )
	options.status3 = setmetatable( { order = 12 , handler= {3} }, meta )
	options.status4 = setmetatable( { order = 13 , handler= {4} }, meta )
	options.status5 = setmetatable( { order = 14 , handler= {5} }, meta )
end

options.newStatus = {
	type = "execute",
	order = 50,
	width = "half",
	name = L["New"],
	desc = L["New Status"],
	func = function(info)
		local name = string.format("raid-debuffs%d", #RDO.statuses+1)
		Grid2:DbSetValue( "statuses", name, {type = "raid-debuffs", debuffs={}, color1 = {r=1,g=.5,b=1,a=1}} )
		Grid2.setupFunc["raid-debuffs"]( name, Grid2:DbGetValue("statuses", name) )
		RDO:LoadStatuses()
	end,
	hidden = function() return #RDO.statuses>=5 end
}

options.deleteStatus = {
	type = "execute",
	order = 51,
	width = "half",
	name = L["Delete"],
	desc = L["Delete last status"],
	func = function(info)
		local status = RDO.statuses[#RDO.statuses]
		options[status.name] = nil
		Grid2:DbSetValue( "statuses", status.name, nil)
		Grid2:UnregisterStatus( status )
		RDO:LoadStatuses()
	end,
	confirm = function(info)
		return string.format( L["Are your sure you want to delete %s status ?"], RDO.statusesNames[#RDO.statuses] )
	end,
	disabled = function()
		local status = RDO.statuses[#RDO.statuses]
		return status.enabled or next(status.dbx.debuffs) or RDO.auto_enabled
	end,
	hidden = function()
		return #RDO.statuses<=1
	end,
}

----------------------------------------------------------------------
-- Modules
----------------------------------------------------------------------

local options = {}
RDO.OPTIONS_MODULES = options

local InitModulesOptions
do
	local function get(info)
		local key = info[#info]
		return RDO.db.profile.enabledModules[key] ~= nil
	end
	local function set(info,state)
		local module = info[#info]
		local mpdata = (module=="Mythic+ Dungeons" or RDO:IsModuleEnabled("Mythic+ Dungeons")) and RDO.MPlusDungeonModule
		RDO.db.profile.enabledModules[module] = state or nil
		for instance, data in pairs(RDO.RDDB[module]) do
			local skip = mpdata and mpdata[instance] and (module~="Mythic+ Dungeons" or RDO:IsModuleEnabled(mpdata[instance])) -- if the instance is shared with another enabled module do not enable/disable the debuffs
			if not skip then
				if state then
					RDO:EnableInstanceAllDebuffs(module,instance)
				else
					RDO:DisableInstanceAllDebuffs(instance)
				end
			end
		end
		RDO:UpdateZoneSpells()
		RDO:RefreshAdvancedOptions()
	end
	local function confirm(info)
		local key = info[#info]
		return RDO.db.profile.enabledModules[key] and L["All custom settings and spells for the selected module will be removed.\nAre you sure you want to disable this module ?"] or nil
	end
	function InitModulesOptions()
		if not next(options) then
			options.tit1 = { order = 1, type = "description", fontSize = 'medium', name = string.format("\n|cFFe0e000%s", L["Select the expansion modules to enable:\n"]) }
			options.sep1 = { type = "header", order = 2, name = '' }
			for index,name in ipairs(RDO.RDDK) do
				if name~="[Custom Debuffs]" then
					options[name] = { type = "toggle", width = "full",	order = 100-index, name = L[name], desc = '', get = get, set = set, confirm = confirm }
					if name=='Mythic+ Dungeons' then
						options[name].order = 110
						options.tit2 = { order = 101, type = "description", fontSize = 'medium', name = string.format("\n|cFFe0e000%s", L["Select extra modules to enable:\n"]) }
						options.sep2   = { type = "header", order = 102, name = '' }
					end
				end
			end
		end
	end
end

----------------------------------------------------------------------
-- Miscellaneus
----------------------------------------------------------------------

local options = {}
RDO.OPTIONS_MISCELLANEOUS = options

-- encounter journal
do
	options.journal = { type = "group", order = 10, name = L["Encounter Journal"], inline= true, args = {
		difficulty = {
			type = "select",
			order = 100,
			name = L["Encounter Journal difficulty"],
			desc = L["Default difficulty for Encounter Journal links"],
			get = function ()
				return RDO.db.profile.defaultEJ_difficulty or 14
			end,
			set = function (_, v)
				RDO.db.profile.defaultEJ_difficulty = v
			end,
			values = {
				[14] = PLAYER_DIFFICULTY1, -- Normal
				[15] = PLAYER_DIFFICULTY2, -- Heroic
				[16] = PLAYER_DIFFICULTY6, -- Mythic
				[17] = PLAYER_DIFFICULTY3  -- LFR
			},
			hidden = function() return Grid2.isClassic end,
		},
		syncInstance = {
			type = "toggle",
			order = 200,
			width = "full",
			name = L["Auto open debuffs for current instance"],
			desc = L["Auto open debuffs for current instance"],
			get = function(info)
				return RDO.db.profile.syncInstance
			end,
			set = function(info, v)
				RDO.syncInstance = v or nil
				RDO.db.profile.syncInstance = v or nil
			end,
		},
	} }
end

-- debuffs autodetection
do
	local function AddToTooltip(tooltip)
		tooltip:AddDoubleLine( L["RaidDebuffs Autodetection"], L["Enabled"], 255,255,255, 255,255,0)
	end

	options.autodetect = { type = "group", order = 20,	name = L["Debuffs Autodetection"], inline= true, args = {
		autoenable = {
			type = "toggle",
			order = 1,
			name = L["Enable Autodetection"],
			desc = L["Enable Zones and Debuffs autodetection"],
			get = function()
				return RDO.auto_enabled
			end,
			set = function(_, v)
				RDO:SetAutodetect(v)
				if not v then
					RDO:RefreshAdvancedOptions()
				end
				Grid2.tooltipFunc["RaidDebuffsAuto"] = v and AddToTooltip or nil
			end,
		},
		autostatus = {
			type = "select",
			order = 2,
			name = L["Assigned to"],
			desc = L["Assign autodetected raid debuffs to the specified status"],
			get = function ()
				return RDO.db.profile.auto_status or 1
			end,
			set = function (_, v)
				local status = RDO.statuses[v]
				if status then
					RDO.db.profile.auto_status = v>1 and v or nil
					RDO:RefreshAutodetect()
				end
			end,
			values = RDO.statusesNames,
			disabled = function() return RDO.auto_enabled end
		}
	} }
end

----------------------------------------------------------------------
--
----------------------------------------------------------------------

function RDO:InitGeneralOptions()
	InitStatusOptions()
	InitModulesOptions()
end

----------------------------------------------------------------------
--
----------------------------------------------------------------------

local prev_OnChatCommand = Grid2Options.OnChatCommand
function Grid2Options:OnChatCommand()
	RDO.syncInstance = RDO.db.profile.syncInstance
	prev_OnChatCommand(self)
end
