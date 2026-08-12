local Grid2 = Grid2

local L = Grid2Options.L

local GetSpellInfo = Grid2.API.GetSpellInfo

--{{ Buff Creation options
do

	local new_type = "mbuff"
	local new_name = ""
	local new_mine = 1
	local new_spell = nil

	local function Reset(typ)
		new_type = typ or "mbuff"
		new_name = ""
		new_spell = nil
		new_mine = new_type=='mbuff' and 1 or nil
	end

	local function GetKey()
		new_name = new_name:gsub("[ %.\"]", "")
		if new_name ~= "" then
			local mine = (new_mine==2 and "-not-mine") or (new_mine and "-mine") or ""
			local key = string.format("%s-%s%s", strsub(new_type,2), new_name, mine )
			return (Grid2.statuses[key]==nil) and key
		end
	end

	Grid2Options:RegisterStatusCategoryOptions("buff", {
		buffType = {
			type = "select",
			order = 10,
			width="full",
			name = L["Select Type"],
			desc = L["Select Type"],
			get = function()
				return new_type
			end,
			set = function(info, value)
				Reset(value)
			end,
			values = { mbuff = L["Single Buff"], mbuffs = L["Multiple Buffs"] },
		},
		singleBuffName = {
			type = "input", dialogControl = "EditBoxGrid2Buffs",
			order = 20,
			width = "full",
			name = L["Name or SpellId"],
			usage = L["You can include a descriptive prefix using separators \"@#>\""].." "..L["examples: Druid@Regrowth Chimaeron>Low Health"],
			get = function()
				return new_name
			end,
			set = function(_, value)
				local prefix, spell = string.match(value, "^(.-[@#>])(.*)$")
				if not spell then spell, prefix = value, "" end
				local spellID = tonumber(spell) or spell
				if type(spellID)=="number" then
					spell = GetSpellInfo(spellID)
					if spell==nil then
						spell, spellID= "", nil
					end
				end
				new_spell = spellID
				new_name = prefix .. spell
			end,
			hidden = function() return new_type~='mbuff' end,
		},
		multipleBuffsName = {
			type = "input",
			order = 20,
			width = "full",
			name = L["Type a descriptive name for this status"],
			get = function()
				return new_name
			end,
			set = function(_, value)
				new_name = value
				new_spell = nil
			end,
			hidden = function() return new_type=='mbuff' end,
		},
		buffMine = {
			type = "toggle",
			order = 30,
			name = L["Show if mine"],
			desc = L["Display status only if the buff was cast by you."],
			get = function()
				return new_mine==1
			end,
			set = function(info, value)
				new_mine= value and 1
			end,
			hidden = function() return new_type~='mbuff' end,
		},
		buffNotMine = {
			type = "toggle",
			order = 40,
			name = L["Show if not mine"],
			desc = L["Display status only if the buff was not cast by you."],
			get = function()
				return new_mine==2
			end,
			set = function(info, value)
				new_mine = value and 2
			end,
			hidden = function() return new_type~='mbuff' end,
		},
		buffSpacer = {
			type = "header",
			order = 50,
			name = "",
		},
		buffCreate = {
			type = "execute",
			order = 60,
			name = L["Create"],
			desc = L["Create a new Buff."],
			func = function (self)
				local dbx = { type = new_type, aura_filter = nil, color1 = {r=1,g=1,b=1,a=1} }
				-- casted by me / not casted by me
				if new_mine then
					dbx.aura_filter = { filter = (new_mine==1) and 'HELPFUL|PLAYER' or 'HELPFUL|!PLAYER' }
				end
				-- single buff, store specified spellID
				if new_type=='mbuff' then
					local spells = Grid2:GetSimilarPlayerBuffs(new_spell)
					if spells then
						dbx.auras = Grid2.CopyTable(spells)
					else
						dbx.auras = type(new_spell) == 'number' and {new_spell} or {}
					end
					dbx.aura_filter = dbx.aura_filter or {}
					dbx.aura_filter.candidateFilters = { includeSpellIDs = true }
				end
				-- create status
				local baseKey = GetKey()
				Grid2.db.profile.statuses[baseKey]= dbx
				local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
				-- create status options
				Grid2Options:MakeStatusOptions(status)
				Grid2Options:SelectGroup('statuses', Grid2Options:GetStatusCategory(status), status.name)
				Reset()
			end,
			disabled = function()
				return GetKey()==nil
			end,
		},
	} )

end
--}}

--{{ Debuff Creation options

do

	local new_name = ""

	local function GetKey()
		local key = new_name:gsub("[ %.\"]", "")
		if key~="" then
			key = "debuffs-"..key
			return (Grid2.statuses[key]==nil) and key
		end
	end

	Grid2Options:RegisterStatusCategoryOptions("debuff", {
		name = {
			type = "input",
			order = 5,
			width = "full",
			name = L["Type a descriptive name for the new debuffs status"],
			get = function()
				return new_name
			end,
			set = function(info, value)
				new_name = value
			end,
		},
		create = {
			type = "execute",
			order = 10,
			name = L["Create"],
			desc = L["Create a new Debuffs status."],
			func = function()
				local baseKey = GetKey()
				local dbx = { type = "mdebuffs", color1 = {r=1,g=0,b=0,a=1} } -- TODO: maybe remove color1
				Grid2.db.profile.statuses[baseKey]= dbx
				local status = Grid2.setupFunc['mdebuffs'](baseKey, dbx)
				Grid2Options:MakeStatusOptions(status)
				Grid2Options:SelectGroup('statuses', Grid2Options:GetStatusCategory(status), status.name)
				new_name = ""
			end,
			disabled = function ()
				return GetKey()==nil
			end,
		},
	})

end
--}}
