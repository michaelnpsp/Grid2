local AOEM = Grid2:GetModule("Grid2AoeHeals")

local L

local function MakeStatusAoeHealOptions(self, status, options)
	options = options or {}
	options = Grid2Options:MakeStatusColorOptions(status, options)
	if status.name == "aoe-highlighter" then
		local statuses= { ["Autodetect"] = L["Autodetect"] }
		for name in next, AOEM.hlStatuses do
			statuses[name]= L[ strsub(name,5) ]
		end 
		options.highlightStatus = {
			type  = "select",
			order = 20,
			name  = L["Highlight status"],
			desc  = L["Select the status the Highlighter will use."],
			get   = function () return status.dbx.highlightStatus or "Autodetect" end,
			set   = function (_, v)
				if v == "Autodetect" then v = nil end
				status.dbx.highlightStatus= v  
				status:UpdateDB()	
			end,
			values= statuses,
		}
		options.spacer1 = {
			type = "header",
			order = 23,
			name = "",
		}
		options.delayEnter = {
			type = "range",
			order = 25,
			name = L["Mouse Enter Delay"],
			desc = L["Delay in seconds before showing the status."],
			min = 0,
			max = 2,
			step = 0.05,
			get = function () return status.dbx.delayEnter or 0.1 end,
			set = function (_, v)
				status.dbx.delayEnter = v
				status:UpdateDB()
			end,
		}
		options.delayLeave = {
			type = "range",
			order = 30,
			name = L["Mouse Leave Delay"],
			desc = L["Delay in seconds before hiding the status."],
			min = 0,
			max = 2,
			step = 0.05,
			get = function () return status.dbx.delayLeave or 0.25 end,
			set = function (_, v)
				status.dbx.delayLeave = v
				status:UpdateDB()
			end,
		}
	else
		options.spacer1 = {
			type = "header",
			order = 20,
			name = "",
		}
		options.minPlayers = {
			type = "range",
			order = 40,
			name = L["Min players"],
			desc = L["Minimum players to enable the status."],
			min = 1,
			max = 6,
			step = 1,
			get = function () return status.dbx.minPlayers end,
			set = function (_, v) 
				status.dbx.minPlayers = v  
				status:UpdateDB() 
			end,
		}
		options.radius = {
			type = "range",
			order = 29,
			name = L["Radius"],
			desc = L["Max distance of nearby units."],
			min = 0,
			softMax = 50,
			step = 0.5,
			get = function () return status.dbx.radius end,
			set = function (_, v) 
				status.dbx.radius = v  
				status:UpdateDB() 
			end,
		}
		if status.name ~= "aoe-neighbors" then
			options.healThreshold = {
				type = "range",
				order = 30,
				name = L["Health deficit"],
				desc = L["Minimum health deficit of units to enable the status."],
				min = 0,
				softMax = 50000,
				step = 1,
				get = function () return status.dbx.healthDeficit end,
				set = function (_, v) 
					status.dbx.healthDeficit = v  
					status:UpdateDB() 
				end,
			}
			if status.name ~= "aoe-PrayerOfHealing" then
				options.keepPrevHeals = {
					type = "toggle",
					order = 17,
					name = L["Keep same targets"],
					desc = L["Try to keep same heal targets solutions if posible."],
					get = function () return status.dbx.keepPrevHeals end,
					set = function (_, v) 
						status.dbx.keepPrevHeals = v	 
						status:UpdateDB() 
					end,
				}
			end	
			if status.name=="aoe-WildGrowth" or status.name=="aoe-CircleOfHealing" then
				options.maxSolutions = {
					type = "range",
					order = 45,
					name = L["Max solutions"],
					desc = L["Maximum number of solutions to display."],
					min = 1,
					max = 10,
					step = 1,
					get = function () return status.dbx.maxSolutions end,
					set = function (_, v) 
						status.dbx.maxSolutions= v  
						status:UpdateDB() 
					end,
				}
				options.hideOnCooldown = {
					type = "toggle",
					order = 15,
					name = L["Hide on cooldown"],
					desc = L["Hide the status while the spell is on cooldown."],
					tristate = true,
					get = function () return status.dbx.hideOnCooldown end,
					set = function (_, v) 
						status.dbx.hideOnCooldown = v	 
						status:UpdateDB() 
					end,
				}
			elseif status.name=="aoe-ChainHeal" then
				options.showOverlapHeal = {
					type = "toggle",
					order = 15,
					name = L["Show overlapping heals"],
					desc = L["Show heal targets even if they overlap with other heals."],
					get = function () return status.dbx.showOverlapHeals end,
					set = function (_, v)  
						status.dbx.showOverlapHeals = v  
						status:UpdateDB() 
					end,
				}
			end	
		end	
	end	
	return options, "AOE Heals"
end

local function MakeStatusRainOptions(self, status, options)
	options = options or {}
	options = Grid2Options:MakeStatusColorOptions(status, options)
	return options, "AOE Heals"
end

local prev_MakeGroups
local function MakeGroupsOptions(self, reset)
	local options= {
		showInCombat = {
			type = "toggle",
			order = 10,
			name = L["Show only in combat"],
			desc = L["Enable the statuses only in combat."],
			get = function () return AOEM.db.profile.showInCombat end,
			set = function (_, v)  
				AOEM.db.profile.showInCombat = v	
				AOEM:RefreshDisplayState()
			end,
		},
		showInRaid = {
			type = "toggle",
			order = 20,
			name = L["Show only in raid"],
			desc = L["Enable the statuses only in raid."],
			get = function () return AOEM.db.profile.showInRaid end,
			set = function (_, v) 
				AOEM.db.profile.showInRaid = v 
				AOEM:RefreshDisplayState()
			end,
		},
		spacer1 = {
			type = "header",
			order = 25,
			name = "",
		},		
		updateRate = {
			type = "range",
			order = 30,
			name = L["Update rate"],
			desc = L["Rate at which the status gets updated"],
			min = 0.1,
			max = 5,
			step = 0.05,
			get = function () return AOEM.db.profile.updateRate end,
			set = function (_, v)
				AOEM.db.profile.updateRate = v
				AOEM:RefreshUpdateRate()
			end,
		},
	}
	prev_MakeGroups(self,reset)
	self:AddElementSubTypeGroup("statuses", "AOE Heals", L["AOE Heals"],  options, reset)
end

-- Hook to load options
local prev_LoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
	L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

	Grid2Options:AddOptionHandler("aoe-heal", MakeStatusAoeHealOptions )
	Grid2Options:AddOptionHandler("aoe-HealingRain", MakeStatusRainOptions )

	prev_MakeGroups = Grid2Options.MakeGroupsOptions
	Grid2Options.MakeGroupsOptions= MakeGroupsOptions
	
	prev_LoadOptions()
end
