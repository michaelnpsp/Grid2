local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local function MakeStatusColorOption(status, options)
	options = options or {}
	options.color = {
		type = "color",
		name = L["Color"],
		desc = L["Color for %s."]:format(status.name),
		get = function ()
			local c = status.db.profile.color
			return c.r, c.g, c.b, c.a
		end,
		set = function (_, r, g, b, a)
			local c = status.db.profile
			c.r, c.g, c.b, c.a = r, g, b, a
			for unit in Grid2:IterateRoster(true) do
				status:UpdateIndicators(unit)
			end
		end,
		hasAlpha = true
	}
	return options
end

for _, name in ipairs{
	"aggro", "heals", "lowmana", "lowhealth", "target", "voice",
	"debuff-Magic", "debuff-Curse", "debuff-Disease", "debuff-Poison",
} do
	local status = Grid2.statuses[name]
	if status then
		Grid2Options:AddElement("status", status, MakeStatusColorOption(status))
	end
end


local function MakeClassColorStatusOptions()
	local status = Grid2.statuses.classcolor
	local profile = status.db.profile
	local options = {
		hostile = {
			type = "toggle",
			name = L["Color Charmed Unit"],
			desc = L["Color Units that are charmed."],
			order = 1,
			get = function ()
				return profile.colorHostile
			end,
			set = function (_, v)
				profile.colorHostile = v
			end,
		},
		colors = {
			type = "group",
			name = L["Unit Colors"],
			args = {
				hostile = {
					type = "color",
					name = L["Charmed unit Color"],
					get = function ()
						local c = profile.colors.HOSTILE
						return c.r, c.g, c.b, c.a
					end,
					set = function (_, r, g, b, a)
						local c = profile.colors.HOSTILE
						c.r, c.g, c.b, c.a = r, g, b, a
						for unit in Grid2:IterateRoster(true) do
							status:UpdateIndicators(unit)
						end
					end,
				},
				defunit = {
					type = "color",
					name = L["Default unit Color"],
					get = function ()
						local c = profile.colors.UNKNOWN_UNIT
						return c.r, c.g, c.b, c.a
					end,
					set = function (_, r, g, b, a)
						local c = profile.colors.UNKNOWN_UNIT
						c.r, c.g, c.b, c.a = r, g, b, a
						for unit in Grid2:IterateRoster(true) do
							status:UpdateIndicators(unit)
						end
					end,
				},
				defpet = {
					type = "color",
					name = L["Default pet Color"],
					get = function ()
						local c = profile.colors.UNKNOWN_PET
						return c.r, c.g, c.b, c.a
					end,
					set = function (_, r, g, b, a)
						local c = profile.colors.UNKNOWN_PET
						c.r, c.g, c.b, c.a = r, g, b, a
						for unit in Grid2:IterateRoster(true) do
							status:UpdateIndicators(unit)
						end
					end,
				},
			},
		},
	}
	for _, type in ipairs{
		LG["Beast"], LG["Demon"], LG["Humanoid"], LG["Elemental"],
		"DRUID", "PALADIN", "MAGE",
		"WARLOCK", "WARRIOR", "PRIEST",
		"SHAMAN", "ROGUE", "HUNTER",
	} do
		options.colors.args[type] = {
			type = "color",
			name = (L["%s Color"]):format(type),
			get = function ()
				local c = profile.colors[type]
				return c.r, c.g, c.b, c.a
			end,
			set = function (_, r, g, b, a)
				local c = profile.colors[type]
				c.r, c.g, c.b, c.a = r, g, b, a
				for unit in Grid2:IterateRoster(true) do
					status:UpdateIndicators(unit)
				end
			end,
		}
	end
	
	return options
end

Grid2Options:AddElement("status",  Grid2.statuses.classcolor, MakeClassColorStatusOptions())

Grid2Options:AddElement("status",  Grid2.statuses.health, {
	deadAsFullHealth = {
		type = "toggle",
		name = L["Show dead as having Full Health"],
		get = function ()
			return Grid2.statuses.health.db.profile.deadAsFullHealth
		end,
		set = function (_, v)
			Grid2.statuses.health.db.profile.deadAsFullHealth = v
		end,
	},
})

Grid2Options:AddElement("status",  Grid2.statuses.range, {
	default = {
		type = "range",
		name = L["Default alpha"],
		desc = L["Default alpha value when units are way out of range."],
		min = 0,
		max = 1,
		step = 0.01,
		get = function ()
			return Grid2.statuses.range.db.profile.default
		end,
		set = function (_, v)
			Grid2.statuses.range.db.profile.default = v
		end,
	},
	update = {
		type = "range",
		name = L["Update rate"],
		desc = L["Rate at which the range gets updated"],
		min = 0,
		max = 5,
		step = 0.1,
		get = function ()
			return Grid2.statuses.range.db.profile.elapsed
		end,
		set = function (_, v)
			Grid2.statuses.range.db.profile.elapsed = v
		end,
	},
})