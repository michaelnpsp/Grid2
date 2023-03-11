local L = Grid2Options.L

if Grid2.isClassic then
	local APIS = { [0] = 'Blizzard API', [1] = 'LibHealComm-4' }
	local TIME_VALUES = { [0] = L['None'] }
	for i=1,15 do TIME_VALUES[i] = string.format(L["%d seconds"], i)	end
	local COMM_ERROR = L['|cFFe0e000\nWarning: LibHealComm-4 is not installed, Blizzard API will be used instead. You must install the LibHealComm-4.0 addon to enable LibHealComm-4 API.']
	function Grid2Options:MakeStatusHealsClassicOptions(status, options)
		local LHC = LibStub("LibHealComm-4.0", true)
		if LHC and not Grid2.db.global.HealsUseBlizAPI then
			options.classicTimeBand = {
				type = "select",
				name = L["Heals Time Band"],
				desc = L["Show only heals that are going to land within the selected time period. Select None to display all heals."],
				order = 290,
				get = function() return status.dbx.healTimeBand or 0 end,
				set = function(_, v)
					status.dbx.healTimeBand = v~=0 and v or nil
					status:UpdateDB()
				end,
				values = TIME_VALUES
			}
			options.classicHealTypes = {
				type = "multiselect",
				order = 300,
				name = L["Heal Types"],
				get = function(info, value)
					return bit.band(status.dbx.healTypeFlags or LHC.ALL_HEALS, value) ~= 0
				end,
				set = function(info, value)
					status.dbx.healTypeFlags = bit.bxor(status.dbx.healTypeFlags or LHC.ALL_HEALS, value)
					if status.dbx.healTypeFlags == LHC.ALL_HEALS then status.dbx.healTypeFlags = nil end
					status:UpdateDB()
				end,
				values = { [LHC.DIRECT_HEALS] = L['Casted'], [LHC.CHANNEL_HEALS] = L['Channeled'], [LHC.HOT_HEALS]=L['HOTs'], [LHC.BOMB_HEALS] = L['Bomb'] }
			}
		end
		options.shortenNumbers = {
			type = "toggle",
			tristate = false,
			width = "full",
			order = 350,
			name = L["Shorten Heal Numbers"],
			desc = L["Shorten Heal Numbers"],
			get = function () return not status.dbx.displayRawNumbers end,
			set = function (_, v)
				status.dbx.displayRawNumbers = not v or nil
				status:Refresh()				
			end,
		}
		if Grid2.versionCli<40000 then
			options.healsApiSep = { type = "header", order = 359,  name = "" }
			options.healsApi = {
				type = "select",
				name = L["Heals API"],
				desc = L["Select which API should be invoked to get the incoming heals."],
				order = 360,
				get = function()
					return Grid2.db.global.HealsUseBlizAPI and 0 or 1
				end,
				set = function(_, v)
					if v==0 then -- Blizzard API
						Grid2.db.global.HealsUseBlizAPI = true
					elseif LHC then -- LibHealComm
						Grid2.db.global.HealsUseBlizAPI = nil
					else
						self:MessageDialog(COMM_ERROR)
					end
					if LHC then ReloadUI() end
				end,
				values = APIS,
				confirm = function() return LHC and L["UI will be reloaded to change this option. Are you sure?"] or nil end,
			}
			options.healsApiWarning = {
				type = "description",
				order = 365,
				name = COMM_ERROR,
				hidden = function()
					return LHC~=nil or Grid2.db.global.HealsUseBlizAPI
				end
			}
		end
	end
end

Grid2Options:RegisterStatusOptions("health-current", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.healthUpdate = {
		type  = "select",
		order = 35,
		name  = L["Update frequency"],
		desc  = L["Select the health update frequency."],
		get   = function ()	return status.dbx.quickHealth and "q" or "n" end,
		set   = function (_, v)
			status.dbx.quickHealth = (v=="q") or nil
			status:Refresh()
		end,
		values= { n = L["Normal"], q = L["Instant"] },
	}
	if Grid2.isClassic then
		options.healthShorten = {
			type = "toggle",
			tristate = false,
			width = "full",
			order = 50,
			name = L["Shorten Health Numbers"],
			desc = L["Shorten Health Numbers"],
			get = function () return not status.dbx.displayRawNumbers end,
			set = function (_, v)
				status.dbx.displayRawNumbers = not v or nil
				status:Refresh()
			end,
		}
	else
		options.healthShield = {
			type = "toggle",
			tristate = false,
			width = "full",
			order = 50,
			name = L["Add shields to health percent"],
			desc = L["Add shields to health percent"],
			get = function () return status.dbx.addPercentShield end,
			set = function (_, v)
				status.dbx.addPercentShield = v or nil
				status:Refresh()
			end,
		}	
	end
	options.deadAsFullHealth = {
		type = "toggle",
		tristate = false,
		width = "full",
		order = 70,
		name = L["Show dead as having Full Health"],
		get = function () return status.dbx.deadAsFullHealth end,
		set = function (_, v)
			status.dbx.deadAsFullHealth = v or nil
			status:Refresh()
		end,
	}
end, {
	width = "full",
	color1 = L["Full Health"],
	color2 = L["Medium Health"],
	color3 = L["Low Health"],
	titleIcon = "Interface\\Icons\\Inv_potion_51",
})

Grid2Options:RegisterStatusOptions("heals-incoming", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	if Grid2.isClassic then
		self:MakeStatusHealsClassicOptions(status, options)
	else
		options.includeHealAbsorbs = {
			type = "toggle",
			order = 115,
			name = L["Substract heal absorbs"],
			desc = L["Substract heal absorbs shields from the incoming heals"],
			tristate = false,
			get = function () return status.dbx.includeHealAbsorbs end,
			set = function (_, v)
				status.dbx.includeHealAbsorbs = v or nil
				status:Refresh()
			end,
		}
	end
	options.includePlayerHeals = {
		type = "toggle",
		order = 110,
		name = L["Include player heals"],
		desc = L["Include heals casted by me, if unchecked only other players heals are displayed."],
		tristate = false,
		get = function () return status.dbx.includePlayerHeals end,
		set = function (_, v)
			status.dbx.includePlayerHeals = v or nil
			status:Refresh()
			Grid2:GetStatusByName('overhealing'):Refresh()
		end,
	}
	options.minimumValue = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Minimum value"],
		desc = L["Incoming heals below the specified value will not be shown."],
		get = function ()
			return tostring(status.dbx.flags or 0)
		end,
		set = function (_, v)
			status.dbx.flags = tonumber(v) or nil
			status:Refresh()			
		end,
	}
	options.multiplier = {
		type = "range",
		order = 130,
		name = L["Heals multiplier"],
		desc = L["Apply this multiplier value to incoming heals."],
		min = 1,
		max = 10,
		step = 0.01,
		bigStep = 0.1,
		get = function () return status.dbx.multiplier	end,
		set = function (_, v)
			status.dbx.multiplier = tonumber(v) or 1
			status:Refresh()			
		end,
	}
end, {
	titleIcon = Grid2.isClassic and "Interface\\Icons\\Spell_Holy_Heal" or "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("my-heals-incoming", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	options.minimumValue = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Minimum value"],
		desc = L["Incoming heals below the specified value will not be shown."],
		get = function ()
			return tostring(status.dbx.flags or 0)
		end,
		set = function (_, v)
			status.dbx.flags = tonumber(v) or nil
			status:Refresh()			
		end,
	}
	options.multiplier = {
		type = "range",
		order = 130,
		name = L["Heals multiplier"],
		desc = L["Apply this multiplier value to incoming heals."],
		min = 1,
		max = 10,
		step = 0.01,
		bigStep = 0.1,
		get = function () return status.dbx.multiplier	end,
		set = function (_, v)
			status.dbx.multiplier = tonumber(v) or 1
			status:Refresh()			
		end,
	}
	if Grid2.isClassic then
		self:MakeStatusHealsClassicOptions(status, options)
	end
end, {
	titleIcon = Grid2.isClassic and "Interface\\Icons\\Spell_Holy_Heal" or "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("overhealing", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	options.minimumOver = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Minimum value"],
		desc = L["Incoming overheals below the specified value will not be shown."],
		get = function ()
			return tostring(status.dbx.minimum or 0)
		end,
		set = function (_, v)
			v = tonumber(v) or 0
			status.dbx.minimum = v>0 and v or nil
			status:Refresh()			
		end,
	}
	if Grid2.isClassic then
		options.shortenNumbers = {
			type = "toggle",
			tristate = false,
			width = "full",
			order = 300,
			name = L["Shorten Overhealing Numbers"],
			desc = L["Shorten Overhealing Numbers"],
			get = function () return not status.dbx.displayRawNumbers end,
			set = function (_, v)
				status.dbx.displayRawNumbers = not v or nil
				status:Refresh()				
			end,
		}
	end
end, {
	title = L["display heals above max hp"],
	titleIcon = Grid2.isClassic and "Interface\\Icons\\Spell_Holy_Heal" or "Interface\\Icons\\Spell_Holy_DivineProvidence"
})


Grid2Options:RegisterStatusOptions("health-low", "health", function(self, status, options, optionParams)
	local per,min,max,step = true
	if status.dbx.threshold>10 then
		min,max,step,per = 1000, 250000, 500, nil
	end
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusThresholdOptions(status, options, optionParams, min, max, step, per)
	options.useAbsoluteHealth = {
		type = "toggle",
		order = 110,
		width = 'full',
		name = L["Use Health Percent"],
		desc = L["Use Health Percent"],
		get = function () return status.dbx.threshold<10 end,
		set = function (_, v)
			status.dbx.threshold = v and 0.4 or 10000
			status:Refresh()			
			self:MakeStatusOptions(status)
		end,
	}
	options.invertActivation = {
		type = "toggle",
		order = 115,
		width = 'full',
		name = L["Invert status activation"],
		desc = L["Invert status activation"],
		get = function () return status.dbx.invert end,
		set = function (_, v)
			status.dbx.invert = v or nil
			status:Refresh()			
		end,
	}
end, {
	titleIcon = Grid2.isClassic and "Interface\\Icons\\Ability_Rogue_Rupture" or "Interface\\Icons\\Ability_rogue_bloodyeye"
})

Grid2Options:RegisterStatusOptions("health-deficit", "health", function(self, status, options, optionParams)
	Grid2Options:MakeStatusColorThresholdOptions(status, options, optionParams)
	options.addIncomingHeals = {
		type = "toggle",
		order = 99,
		width = "full",
		name = L["Add Incoming Heals"],
		desc = L["Add incoming heals to health deficit."],
		tristate = false,
		get = function () return status.dbx.addIncomingHeals end,
		set = function (_, v)
			status.dbx.addIncomingHeals = v or nil
			status:Refresh()			
		end,
	}
	if Grid2.isClassic then
		options.healthShorten = {
			type = "toggle",
			tristate = false,
			width = "full",
			order = 100,
			name = L["Shorten Health Numbers"],
			desc = L["Shorten Health Numbers"],
			get = function () return not status.dbx.displayRawNumbers end,
			set = function (_, v)
				status.dbx.displayRawNumbers = not v or nil
				status:Refresh()				
			end,
		}
	end
	options.displayPercent = {
		type = "toggle",
		tristate = false,
		width = "full",
		order = 110,
		name = L["Display health percent text for enemies"],
		desc = L["Display health percent text instead of health deficit for non friendly units."],
		get = function () return status.dbx.displayPercentEnemies end,
		set = function (_, v)
			status.dbx.displayPercentEnemies = v or nil
			status:Refresh()			
		end,
	}
end, {
	titleIcon = "Interface\\Icons\\Spell_shadow_lifedrain"
})

Grid2Options:RegisterStatusOptions( "death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_creature_cursed_05",
} )

Grid2Options:RegisterStatusOptions( "feign-death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_fiegndead"
} )
