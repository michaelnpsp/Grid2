--[[
	General -> Profiles Tab -> General & Advanced Tabs
--]]

local L = Grid2Options.L

--==============================

local GetAllProfiles, GetUnusedProfiles, GetDefaultProfiles
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
		elseif showCurrent==0 then
			values[0] = string.format("-- %s --", L['New Profile'])
		end
		return values
	end
	GetAllProfiles     = function() return GetProfiles(true)  end
	GetUnusedProfiles  = function() return GetProfiles(false) end
	GetDefaultProfiles = function() return GetProfiles(0) end
end

--==============================

local options = {}

options.title = {
	order = 1,
	type = "description",
	name = L["You can change the active database profile, so you can have different settings for every character.\n"],
}

options.current = {
	type   = "select",
	name   = L["Current Profile"],
	desc   = L["Select one of your currently available profiles."],
	order  = 2,
	get    = function() return Grid2.db:GetCurrentProfile() end,
	set    = function(_, v) Grid2.db:SetProfile(v) end,
	validate = function() return not InCombatLockdown() or L["Profile cannot be changed in combat"] end,
	disabled = InCombatLockdown,
	values = GetAllProfiles,
}

options.reset = {
	order = 3,
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
}

--==============
if Grid2.versionCli>=20000 then

	options.proenabled = {
		type = "toggle",
		name = "|cffffd200".. L["Enable profiles by Specialization"] .."|r",
		desc = L["When enabled, your profile will be set according to the character specialization."],
		descStyle = "inline",
		order = 5,
		width = "full",
		get = function(info)
			return Grid2.profiles.char[1] and Grid2.profiles.char.enabled
		end,
		set = function(info, value)
			Grid2:EnableProfilesPerSpec(value)
		end,
	}

	for i=Grid2.GetNumSpecializations(),1, -1 do
		options['profile'..i] = {
			type  = "select",
			name  = select( 2, Grid2Options.GetSpecializationInfo(i) ),
			desc  = "",
			order = 6+i,
			get = function() return Grid2.profiles.char[i] end,
			set = function(_, v)
				Grid2.profiles.char[i] = v
				Grid2:ReloadProfile()
			end,
			values = GetAllProfiles,
			hidden = function() return type(Grid2.profiles.char[1])~='string' end,
		}
	end

	options.miscsep = {
		order = 14,
		type = "header",
		name = L["Maintenance"],
	}

end

--==============

options.newdesc = {
	order = 15,
	type = "description",
	name = "\n" .. L["Create a new empty profile by entering a name in the editbox."],
}

options.new = {
	name = L["New Profile"],
	desc = L["Create a new empty profile by entering a name in the editbox."],
	type = "input",
	order = 20,
	get = false,
	set = function(_, v) Grid2.db:SetProfile(v) end,
}

--==============

options.renamedesc = {
	order = 50,
	type = "description",
	name = "\n" .. L["Change the name of the current profile."],
}

options.rename = {
	name = L["Rename Profile"],
	desc = L["Change the name of the current profile."],
	type = "input",
	order = 55,
	get = false,
	set = function(_, v)
		local old = Grid2.db:GetCurrentProfile()
		Grid2.db:SetProfile(strtrim(v))
		Grid2:ProfileShutdown()
		Grid2.db:CopyProfile(old)
		Grid2.db:DeleteProfile(old)
	end,
	validate = function(info, v)
		return (strlen(v)>3 and not GetAllProfiles()[v])
	end,
}

--==============

options.copydesc = {
	order = 25,
	type = "description",
	name = "\n" .. L["Copy the settings from one existing profile into the currently active profile."],
}

options.copyfrom = {
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
}

--==============

options.deletedesc = {
	order = 35,
	type = "description",
	name = "\n" .. L["Delete existing and unused profiles from the database."],
}

options.delete = {
	type   = "select",
	name   = L['Delete a Profile'],
	desc   = L["Delete existing and unused profiles from the database."],
	order  = 40,
	get    = false,
	set    = function(_, v) Grid2.db:DeleteProfile(v) end,
	values = GetUnusedProfiles,
	confirm = true,
	confirmText = L["Are you sure you want to delete the selected profile?"],
}

--==============

options.defaultdesc = {
	order = 60,
	type = "description",
	name = "\n" .. L["Select the profile to use if no profile is assigned to the character."],
}

options.default = {
	type   = "select",
	name   = L['Default Profile'],
	desc   = L["Select the profile to use if no profile is assigned to the character."],
	order  = 65,
	get = function()
		return Grid2.db.global.defaultProfileName or 0
	end,
	set = function(_, v)
		Grid2.db.global.defaultProfileName = (v~=0) and v or nil
	end,
	values = GetDefaultProfiles,
}

--==============================

Grid2Options:AddGeneralOptions("Profiles", nil, {
	type = "group",
	childGroups = "tab",
	order = 100,
	name = L["Profiles"],
	desc = "",
	args = {
		general  = { type = "group", order= 100, name = L["General"],  desc = "", args = options  },
		import   = Grid2Options.AdvancedProfileOptions or {},
	},
}, 490 )
