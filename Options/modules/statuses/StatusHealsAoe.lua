local AOEM = Grid2:GetModule("Grid2AoeHeals")

local L = Grid2Options.L
local select = select
local GetSpellInfo = GetSpellInfo

local classHeals = Grid2.isClassic and {
	SHAMAN  = { 1064 }, -- Chain Heal
	PRIEST  = { 596 },  -- Prayer of Healing
	DRUID   = { 740 },  -- Tranquility
} or {
	SHAMAN  = { 1064, 73921, 127944 },     	  -- Chain Heal, Healing Rain, Tide Totem
	PRIEST  = { 34861, 23455, 88686, 64843 }, -- Circle of Healing, Holy Nova, Holy Word: Sanctuary, Divine Himn
	PALADIN = { 85222, 114871, 119952 },   	  -- Light of Dawn, Holy Prism, Arcing Light(Light Hammer's effect)
	DRUID   = { 81269, 740 }, 			      -- Wild Mushroom, Tranquility
	MONK    = { 124040, 130654, 124101, 132463, 115310 }, -- Chi Torpedo, Chi Burst, Zen Sphere: Detonate, Chi Wave, Revival
	ZRAID   = {
				740,    -- Druid Traquility
				127944, -- Shaman Tide Totem
				64843,  -- Priest Divine Himn
				115310, -- Monk Revival
	}
}

local dmgEvents = {
	SPELL_DAMAGE = true,
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	SPELL_BUILDING_DAMAGE = true,
}

-- Misc util functions
local function GetSpellID(name, defaultSpells)
	if tonumber(name) then
		return tonumber(name)
	end
	for _,spells in next, defaultSpells do
		for _,spell in next, spells do
			local spellName = GetSpellInfo(spell)
			if spellName == name then
				return spell
			end
		end
	end
	local id = 0
	local texture = select(3, GetSpellInfo(name))
	for i=300000, 1, -1  do
		if GetSpellInfo(i) == name then
			id = i
			local _,_,tex = GetSpellInfo(i)
			if tex == texture then
				return i
			end
		end
	end
	return id
end

local function SetSpellsByCategory(typ, tab)
	if typ then
		for className,spells in pairs(classHeals) do
			if typ==className or (typ=="" and className~="ZRAID") then
				for _,spellID in pairs(spells) do
					table.insert(tab, spellID)
				end
			end
		end
	end
end

local function GetSpellsByCategory(flag)
	local list = {}
	for class in pairs(classHeals) do
		list[class] = LOCALIZED_CLASS_NAMES_MALE[class] or L["Raid Cooldowns"]
	end
	list[""] = L["All Classes"]
	list["~"] = flag and L["None"] or nil
	return list
end

-- MakeStatusOutgoingOptions()
local function MakeStatusOutgoingOptions(self, status, options)
	self:MakeStatusColorOptions(status, options)
	options.showIfMine = {
		type = "toggle",
		order = 30,
		name = L["Show if mine"],
		desc = L["Show my spells only."],
		get = function () return status.dbx.mine == true end,
		set = function (_, v)
			status.dbx.mine = v or nil
			status:UpdateDB()
		end,
	}
	options.showIfNotMine = {
		type = "toggle",
		order = 35,
		name = L["Show if not mine"],
		desc = L["Show others spells only."],
		get = function () return status.dbx.mine == false end,
		set = function (_, v)
			if v then
				status.dbx.mine = false
			else
				status.dbx.mine = nil
			end
			status:UpdateDB()
		end,
	}
	options.spacer1 = { type = "header", order = 39, name = "" }
	options.activeTime = {
		name = L["Active time"],
		desc = L["Show the status for the specified number of seconds."],
		order = 40,
		type = "range", min = 0.2, max = 5, step = 0.1,
		get = function()
			return status.dbx.activeTime or 2
		end,
		set = function( _, v )
			status.dbx.activeTime = v
			status:UpdateDB()
		end,
	}
	options.auras = {
		type = "input",
		order = 50,
		width = "full",
		name = L["Spells"],
		desc = L["You can type spell IDs or spell names."],
		multiline= 10,
		get = function()
				local auras = {}
				for _,spell in pairs(status.dbx.spellList) do
					local name = GetSpellInfo(spell)
					if name then
						auras[#auras+1] = name
					end
				end
				return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.spellList)
			local auras = { strsplit("\n,", v) }
			for i,v in pairs(auras) do
				local aura = strtrim(v)
				if #aura>0 then
					local spellID = tonumber(aura)
					if spellID then
						spellID = GetSpellInfo(spellID) and spellID or 0
					else
						spellID = GetSpellID(aura, classHeals)
					end
					if spellID > 0 then
						table.insert(status.dbx.spellList, spellID)
					end
				end
			end
			status:UpdateDB()
		end,
	}
	if status.dbx.type=='aoe-heals' then
		options.addSpells = {
			type = "select",
			order = 45,
			name = L["Add heal spells"],
			desc = L[""],
			get = function () end,
			set = function(_,v)
				SetSpellsByCategory( v, status.dbx.spellList)
				status:UpdateDB()
			end,
			values = GetSpellsByCategory,
		}
	else
		if status.dbx.events==nil then status.dbx.events = {} end
		options.eventsSpacer = { type = "header", order = 45, name = L["Activation conditions"] }
		options.eventsHeal = {
			type = "toggle",
			order = 46,
			width = 0.62,
			name = L["Healing"],
			desc = L["Enable the status when a spell is healing a player."],
			get = function () return status.dbx.events.SPELL_HEAL end,
			set = function (_, v)
				status.dbx.events.SPELL_HEAL = v or nil
				status.dbx.events.SPELL_PERIODIC_HEAL = v or nil
				status:UpdateDB()
			end,
		}
		options.eventsDamage = {
			type = "toggle",
			order = 47,
			width = 0.62,
			name = L["Damage"],
			desc = L["Enable the status when a spell is causing damage to a player."],
			get = function () return status.dbx.events.SPELL_DAMAGE	end,
			set = function (_, v)
				v = v or nil
				for event in pairs(dmgEvents) do
					status.dbx.events[event] = v
				end
				status:UpdateDB()
			end,
		}
		--[[options.eventsCastStart = {
			type = "toggle",
			order = 48,
			width = 0.62,
			name = L["Cast Start"],
			desc = L["Enable the status when a spell cast starts."],
			get = function () return status.dbx.events.SPELL_CAST_START	end,
			set = function (_, v)
				status.dbx.events.SPELL_CAST_START = v or nil
				status:UpdateDB()
			end,
		}--]]
		options.eventsCastSuccess = {
			type = "toggle",
			order = 49,
			width = 0.62,
			name = L["Cast Success"],
			desc = L["Enable the status when a spell cast finish or on instant spells."],
			get = function () return status.dbx.events.SPELL_CAST_SUCCESS end,
			set = function (_, v)
				status.dbx.events.SPELL_CAST_SUCCESS = v or nil
				status:UpdateDB()
			end,
		}
	end
end

-- MakeCategoryOptions()
local function MakeCategoryOptions()
	local NewStatusName, NewClassHeals, NewSpellType
	return {
		newOutgoingStatusName = {
			type = "input",
			order = 50,
			width = "double",
			name = L["Type New Status Name"],
			desc = L["You can type any descriptive text to identify the new status."],
			get = function() return NewStatusName end,
			set = function(_, v)
				NewStatusName = strtrim(v)
			end,
			validate = function(_,v)
				v = strtrim(v)
				return (v == "" or Grid2:DbGetValue( "statuses", "aoe-" .. v ) or Grid2:DbGetValue( "statuses", "spells-" .. v )) and L["Invalid status name or already in use."] or true
			end,
		},
	    newline = { type = "description", order = 51, name = "\n" },
		spellsType = {
			type = "select",
			order = 52,
			name = L["Spells type"],
			desc = L["Select what type of incoming spells to track."],
			get = function ()
				return NewSpellType or 1
			end,
			set = function(_,v)
				NewSpellType = v
				NewClassHeals = nil
			end,
			values = { L["AOE Heal"], L["Any Spell"] }
		},
		spellsCategory = {
			type = "select",
			order = 53,
			name = L["Spells group"],
			desc = L[""],
			get = function ()
				return NewClassHeals or '~'
			end,
			set = function(_,v)
				NewClassHeals = v
			end,
			values = GetSpellsByCategory,
			disabled = function() return NewSpellType==2 end,
		},
	    separator2 = { type = "header", order = 54, name = "" },
		createOutgoingStatus = {
			type = "execute",
			order = 55,
			width = "half",
			name = L["Create"],
			func = function()
				local sPrefix = NewSpellType~=2 and "aoe-" or "spells-"
				local sType   = NewSpellType~=2 and "aoe-heals" or "inc-spells"
				local sEvents = NewSpellType==2 and Grid2.CopyTable(dmgEvents) or nil
				local baseKey = sPrefix .. NewStatusName
				if not Grid2:DbGetValue("statuses",baseKey) then
					local dbx = { type = sType, spellList = {}, activeTime = 2, color1 = {r=0, g=0.8, b=1, a=1}, events = sEvents }
					SetSpellsByCategory(NewSpellType~=2 and NewClassHeals, dbx.spellList)
					Grid2:DbSetValue("statuses", baseKey, dbx)
					local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
					Grid2Options:MakeStatusOptions( status )
					Grid2Options:SelectGroup('statuses', Grid2Options:GetStatusCategory(status), status.name)
				end
				NewStatusName, NewSpellType, NewClassHeals = nil, nil, nil
			end,
			disabled = function() return NewStatusName==nil end,
		},
	}
end

Grid2Options:RegisterStatusCategory("incoming-spells", {
	name  = L["AOE & Dmg"],
	title = L["New AOE/DMG tracker"],
	desc  = L["Incoming heal or damage spells"],
	icon  = "Interface\\Icons\\Spell_holy_holynova",
	options = MakeCategoryOptions(),
} )

Grid2Options:RegisterStatusOptions("aoe-heals",  "incoming-spells", MakeStatusOutgoingOptions, {
	title = L["Incoming AOE Heals"],
	titleIcon ="Interface\\Icons\\Spell_holy_holybolt",
	groupOrder= 50, isDeletable = true, displayPrefix = true
} )
Grid2Options:RegisterStatusOptions("inc-spells", "incoming-spells", MakeStatusOutgoingOptions, {
	title = L["Incoming Spells"],
	titleIcon ="Interface\\Icons\\inv_wand_01",
	groupOrder= 51, isDeletable = true, displayPrefix = true,
} )
