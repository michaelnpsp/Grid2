Grid2ProfileAPI = {}

function Grid2ProfileAPI:ExportProfile(profileKey)
	return Grid2.ExportProfileByKey(profileKey, true)
end

function Grid2ProfileAPI:ImportProfile(profileString, profileKey)
	return Grid2.ImportProfileIntoKey(profileKey, profileString, true, true)
end

function Grid2ProfileAPI:DecodeProfileString(profileString)
	local success, profileData = Grid2.UnserializeProfile(profileString, true)
	if not success then
		return nil
	end
	return profileData
end

function Grid2ProfileAPI:SetProfile(profileKey)
	Grid2.db:SetProfile(profileKey)
end

function Grid2ProfileAPI:GetProfileKeys()
	local profileKeys = {}
	if Grid2DB and Grid2DB.profiles then
		for profileKey in pairs(Grid2DB.profiles) do
			profileKeys[profileKey] = true
		end
	end
	return profileKeys
end

function Grid2ProfileAPI:GetCurrentProfileKey()
	return Grid2.db:GetCurrentProfile()
end

function Grid2ProfileAPI:GetProfileAssignments()
	return Grid2DB and Grid2DB.profileKeys or nil
end

function Grid2ProfileAPI:OpenConfig()
	Grid2:OpenGrid2Options()
end

function Grid2ProfileAPI:CloseConfig()
	if Grid2Options.optionsFrame then
		Grid2Options.optionsFrame:Hide()
	end
end
