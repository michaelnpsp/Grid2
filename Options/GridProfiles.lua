--
-- Dialog to select a profile template to update a new created profile.
-- Selected profile template index is is stored in Grid2.defaultProfileIndex and used later
-- by Grid2:MakeDatabaseDefaults() to add settings,indicators,statuses in the new profile.
--

local L  = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

local Options = {}

Options.RootTable = {
	name = "Grid2: Profile Selection",
	type = "group",
	args = {
		title = {
			type = "description",
			order = 1,
			name = function()
				if Options.isFirstBoot then
					return "This is the first time Grid2 is running for this character. You must select a profile configuration for this character:"
				else
					return "Select a profile template to apply to your new profile:"
				end
			end,
		},
		separator = {
			type = "header",
			order = 2,
			name = "",
		},
	},
}

Options.ProfileTable = {
	__load = { type = "header", order = 0, name = "", hidden = function(info)
		local key = info[#info-1]
		Options.selectedProfile = tonumber(key) or key -- and index in Grid2.defaultProfiles or a profileName
		return true
	end },
	desc = {
		order = 1,
		type = "description",
		name = function()
			if type(Options.selectedProfile)=='number' then
				return Grid2.defaultProfiles[Options.selectedProfile].desc .. ' \n \n'
			else
				return "This is an already existing profile from other character.\nClick Accept button if you want to use this profile for your new character.\n"
			end
		end,
	},
	image = {
		order = 2,
		type = "description",
		name = "",
		fontSize = 'large',
		image = function()
			local index = Options.selectedProfile
			if type(index)=='number' then
				local pf = Grid2.defaultProfiles[index]
				return pf.image, pf.imageWidth, pf.imageHeight
			else
				return "Interface\\Calendar\\MeetingIcon"
			end
		end,
	},
}

function Options:Initialize(firstBoot)
	self.isFirstBoot = firstBoot
	local args = self.RootTable.args
	for key,data in pairs(args) do -- wipe old data
		if data.order>=10 then args[key] = nil end
	end
	for index,info in pairs(Grid2.defaultProfiles) do -- add default profile templates
		args[tostring(index)] = {
			order = 10+index,
			type = "group",
			name = info.name,
			args = self.ProfileTable,
		}
	end
	if firstBoot then -- if first boot for the character, add already created profiles
		local curProfile = Grid2.db:GetCurrentProfile()
		for index,profileName in pairs(Grid2.db:GetProfiles()) do
			if profileName~=curProfile then
				args[profileName] = {
					order = 100+index,
					type = "group",
					name = profileName,
					args = self.ProfileTable,
				}
			end
		end
	end
	return self.RootTable
end

-- Open profiles templates dialog, called from "new profile" option
function Grid2Options:OpenProfilesDialog(newProfileName)
	self:OpenAdvancedDialog('Grid2ProfilesDialog', Options:Initialize(false), 600, 275, function()
		Grid2.defaultProfileIndex = Options.selectedProfile or 0
		Grid2.db:SetProfile(newProfileName)
		Grid2Options:NotifyChange()
	end, Grid2.Dummy)
end

-- Open first boot profiles templates dialog
function Grid2Options:OpenFirstBootProfilesDialog()
	Grid2.firstBootDialogEnabled = true -- used by Grid2Layout to hide main grid2 window
	self:OpenAdvancedDialog('Grid2ProfilesDialog', Options:Initialize(true), 600, 275, function()
		Grid2.firstBootDialogEnabled = nil
		local profile = Options.selectedProfile
		if type(profile)=='number' then -- update current profile with the selected default profile template
			Grid2.defaultProfileIndex = profile
			Grid2:ProfileChanged()
		else -- An already existing profile was selected, change to the existing profile and remove current profile
			local oldProfile = Grid2.db:GetCurrentProfile()
			Grid2.db:SetProfile(profile)
			Grid2.db:DeleteProfile(oldProfile)
		end
	end)
end
