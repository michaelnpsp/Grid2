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
			image = "Interface\\Addons\\Grid2\\media\\icon",
			imageWidth = 16,
			imageHeight = 16,
			order = 1,
			name = function()
				if Options.isFirstBoot then
					return L["Welcome to Grid2. Select a configuration profile for your character:"]
				else
					return L["Select a configuration template to use for your new profile:"]
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
		Options.selectedProfile = tonumber(key) or key -- index in Grid2.defaultProfiles or a profileName
		return true
	end },
	desc = {
		order = 1,
		type = "description",
		name = function()
			if type(Options.selectedProfile)=='number' then
				return Grid2.defaultProfiles[Options.selectedProfile].desc .. " \n \n"
			else
				return L["This is an already existing profile from other character."] .. " \n \n"
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
				return pf.image, pf.imageWidth or 64, pf.imageHeight or 64
			else
				return "Interface\\Calendar\\MeetingIcon", 64, 64
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


function Grid2Options:SelectDialogGroup(dialogName, ...)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:SelectGroup(dialogName, ...)
	C_Timer.After(0, function()
		local frame = self.dialogFrame
		local user = frame:GetUserDataTable()
		ACD:Open(dialogName, frame, unpack(user.basepath or {}))
	end)
end

-- Open profiles templates dialog, called from "new profile" option
function Grid2Options:OpenProfilesDialog(newProfileName)
	self:OpenAdvancedDialog('Grid2ProfilesDialog', Options:Initialize(false), 600, 275, function()
		Grid2.defaultProfileIndex = Options.selectedProfile or 0
		Grid2.db:SetProfile(newProfileName)
		Grid2Options:NotifyChange()
	end, Grid2.Dummy)
	self:SelectDialogGroup( 'Grid2ProfilesDialog', "1" )
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
	self:SelectDialogGroup( 'Grid2ProfilesDialog', "1" )
end
