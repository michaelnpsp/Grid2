--[[
	General -> Profiles Tab -> General & Advanced Tabs
--]]

local L = Grid2Options.L

--==============================

local GetAllProfiles, GetUnusedProfiles
do
	local profiles, values = {}, {}
	local function GetProfiles(showCurrent)
		wipe(profiles)
		wipe(values)
		Grid2.db:GetProfiles(profiles)
		for _,k in pairs(profiles) do
			values[k] = k
		end
		if not showCurrent then
			values[Grid2.db:GetCurrentProfile()] = nil
		end
		return values
	end
	GetAllProfiles    = function() return GetProfiles(true)  end
	GetUnusedProfiles = function() return GetProfiles(false) end
end

local function GroupValueExists(key)
	local db  = Grid2.profiles.char
	if type(db[1])=='table' then
		return db[1][key] and db.enabled
	else
		return db[key] and db.enabled
	end
end

local function SetDefaults(spec, typ, adv, nowipe)	
	local db  = Grid2.profiles.char
	local pro = Grid2.db:GetCurrentProfile()
	local function GetTypesDefaults(t)
		local val = adv and pro or nil
		t = type(t)=='table' and t or {}
		t['solo']  = t['solo']  or pro 
		t['party'] = t['party'] or pro 
		t['arena'] = t['arena'] or pro
		t['raid']  = t['raid']  or pro
		t['raid@pvp']    = val 
		t['raid@lfr']    = val
		t['raid@flex']   = val
		t['raid@mythic'] = val 
		return t
	end
	if not nowipe then
		wipe(db)
	end	
	if spec then
		for i=1,GetNumSpecializations() or 0 do
			db[i] = typ and GetTypesDefaults(db[i]) or pro
		end
	elseif typ then
		GetTypesDefaults(db)
	end
	db.enabled = (spec or typ) and true or nil
end	

local MakeOptionsTypes
do
	local specIndex = { s1=1, s2=2, s3=3, s4=4, s5=5 }

	local function GetValue(info)
		return Grid2.profiles.char[ info[#info] ] 
	end
	
	local function SetValue(info, value)
		Grid2.profiles.char[info[#info]] = value
		Grid2Layout:ReloadProfile()
	end

	local function IsHidden(info)
		return not GetValue(info)
	end

	local function GetValueSpec(info)
		local key   = info[#info]
		local index = specIndex[ info[#info-1] ]
		return Grid2.profiles.char[index][key]
	end
	
	local function SetValueSpec(info, value)
		local key   = info[#info]
		local index = specIndex[ info[#info-1] ]
		Grid2.profiles.char[index][key] = value
		Grid2Layout:ReloadProfile()
	end

	local function IsHiddenSpec(info)
		return not GetValueSpec(info)
	end
	
	local function MakeOptionType(spec, name, order)
		return {
			type   = "select",
			name   = L[name],
			desc   = L["Select which profile to use for: "] .. L[name],
			order  = order+100,
			get    = spec and GetValueSpec or GetValue,
			set    = spec and SetValueSpec or SetValue,
			values = GetAllProfiles,
			hidden = spec and IsHiddenSpec or IsHidden,
		}
	end
	
	MakeOptionsTypes = function(spec, options)
		options = options or {}
		options['solo']  = MakeOptionType(spec,'Solo',1) 
		options['party'] = MakeOptionType(spec,'Party',2)
		options['arena'] = MakeOptionType(spec,'Arena',3)
		options['raid']  = MakeOptionType(spec,'Raid',4)
		options['raid@pvp']    = MakeOptionType(spec,'Raid (PvP)',5)
		options['raid@lfr']    = MakeOptionType(spec,'Raid (LFR)',6)
		options['raid@flex']   = MakeOptionType(spec,'Raid (Normal&Heroic)',7)
		options['raid@mythic'] = MakeOptionType(spec,'Raid (Mythic)',8)
		return options
	end
end

--==============================

local optionsGeneral = {

title = {
	order = 1,
	type = "description",
	name = L["You can change the active database profile, so you can have different settings for every character.\n"],
},
	
current = {
	type   = "select",
	name   = L["Current Profile"],
	desc   = L["Select one of your currently available profiles."],
	order  = 10,
	get    = function() return Grid2.db:GetCurrentProfile() end,
	set    = function(_, v) Grid2.db:SetProfile(v) end,
	values = GetAllProfiles,
},

reset = {
	order = 11,
	type = "execute",
	width = "half",	
	name = L["Reset"],
	desc = L["Reset the current profile back to its default values."],
	confirm = true,
	confirmText = L["Are you sure you want to reset current profile?"],
	func = function() 
		Grid2:ProfileShutdown()
		Grid2.db:ResetProfile()	
	end,
},

newdesc = {
	order = 15,
	type = "description",
	name = "\n" .. L["Create a new empty profile by entering a name in the editbox."],
},

new = {
	name = L["New Profile"],
	desc = L["Create a new empty profile by entering a name in the editbox."],
	type = "input",
	order = 20,
	get = false,
	set = function(_, v) Grid2.db:SetProfile(v) end,
},

copydesc = {
	order = 25,
	type = "description",
	name = "\n" .. L["Copy the settings from one existing profile into the currently active profile."],
},
	
copyfrom = {
	type   = "select",
	name   = L['Copy From'],
	desc   = L["Copy the settings from one existing profile into the currently active profile."],
	order  = 30,
	get    = false,
	set    = function(_, v) 
		Grid2:ProfileShutdown()
		Grid2.db:CopyProfile(v)	
	end,
	values = GetUnusedProfiles,
	confirm = true,
	confirmText = L["Are you sure you want to overwrite current profile values?"],
},

deletedesc = {
	order = 35,
	type = "description",
	name = "\n" .. L["Delete existing and unused profiles from the database."],
},

delete = {
	type   = "select",
	name   = L['Delete a Profile'],
	desc   = L["Delete existing and unused profiles from the database."],
	order  = 40,
	get    = false,
	set    = function(_, v) Grid2.db:DeleteProfile(v) end,
	values = GetUnusedProfiles,
	confirm = true,
	confirmText = L["Are you sure you want to delete the selected profile?"],
},

}

--==============================

local optionsAdvanced = {

title = {
	order = 1,
	type = "description",
	name = L["You can assign a different database profile for each specialization, type of group or raid type."],
},

enabled1 = {
	type = "toggle",
	name = "|cffffd200".. L["Enable profiles by Specialization"] .."|r",
	desc = L["When enabled, your profile will be set according to the character specialization."],
	order = 2,
	width = "full",
	get = function(info) return Grid2.profiles.char[1] and Grid2.profiles.char.enabled end,
	set = function(info, value)
		SetDefaults( value, GroupValueExists('solo'), GroupValueExists('raid@lfr') )
		Grid2Layout:ReloadProfile()
	end,
},

enabled2 = {
	type = "toggle",
	name = "|cffffd200".. L["Enable profiles by Type of Group"] .."|r",
	desc = L["When enabled, your profile will be set according to the type of group."],
	order = 3,
	width = "full",
	get = function(info) return GroupValueExists('solo') end,
	set = function(info, value)
		SetDefaults(Grid2.profiles.char[1], value)
		Grid2Layout:ReloadProfile()
	end,
}, 

enabled3 = {
	type = "toggle",
	name = L["Enable profiles by Raid Type"],
	desc = L["When enabled, profiles by raid type can be configured."],
	order = 4,
	width = "full",
	get = function(info) return GroupValueExists('raid@lfr') end,
	set = function(info, value)
		SetDefaults(Grid2.profiles.char[1], GroupValueExists('solo'), value, true)
		Grid2Layout:ReloadProfile()
	end,
	hidden = function() return not GroupValueExists('solo') end,
}, 

}

--== By Spec

for i=GetNumSpecializations(),1, -1 do
	optionsAdvanced['prosep'..i] = {
		order = 10+i,
		type = "description",
		name = "",
	}
	optionsAdvanced['profile'..i] = {
		type  = "select",
		name  = select( 2, GetSpecializationInfo(i) ),
		desc  = "",
		order = 10.5+i,
		get = function() return Grid2.profiles.char[i] end,
		set = function(_, v) 
			Grid2.profiles.char[i] = v
			Grid2Layout:ReloadProfile()
		end,
		values = GetAllProfiles,
		hidden = function() return type(Grid2.profiles.char[1])~='string' end,
	}
end

--== By Type
	
MakeOptionsTypes(false, optionsAdvanced)	

--== By Spec & Type

optionsAdvanced.specs = { type = "group", order= 100, inline = true, name = "", desc = "", args = {}, hidden = function() return type(Grid2.profiles.char[1])~='table' end }

local optionsTypes = MakeOptionsTypes(true)
for i=GetNumSpecializations(),1, -1 do
	optionsAdvanced.specs.args['s'..i] = { type = "group", order= i, name = select(2,GetSpecializationInfo(i)), desc = "", args = optionsTypes }
end

--==============================

Grid2Options:AddGeneralOptions("Profiles", nil, {
	type = "group",
	childGroups = "tab",
	order = 100,
	name = L["Profiles"],
	desc = "",
	args = {
		general  = { type = "group", order= 100, name = L["General"],  desc = "", args = optionsGeneral  },
		advanced = { type = "group", order= 110, name = L["Advanced"], desc = "", args = optionsAdvanced },
		import   = Grid2Options.AdvancedProfileOptions or {},
	},
} )
