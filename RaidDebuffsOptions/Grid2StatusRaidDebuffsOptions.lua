local Grid2StatusRaidDebuffsOptions = {}

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")


function ResetRaidDebuffsStatuses()
	local setup = Grid2.db.profile.setup
--	Grid2:SetupDefaultStatus(setup)
	Grid2Frame:UpdateAllFrames()
	Grid2StatusRaidDebuffsOptions:AddSetupStatusesOptions(setup, true)
end

local function MakeStatusRaidDebuffsOptions(reset)
	local options = {
		resetRaidDebuffsStatuses = {
			type = "execute",
			order = 11,
			name = L["Reset Statuses"],
			desc = L["Reset statuses to defaults."],
			func = ResetRaidDebuffsStatuses,
		},
	}
	return options
end


function Grid2StatusRaidDebuffsOptions:AddSetupStatusesOptions(setup, reset)
	local status, options

	options = MakeStatusRaidDebuffsOptions()
	Grid2Options:AddElementSubTypeGroup("status", "raid-debuff", options, reset)
	for statusKey, info in pairs(setup.raidDebuffs) do
		local status = Grid2.statuses[statusKey] -- TODO: fix names more better.  Type should not get baked in.
		if status then
			options = Grid2Options:MakeStatusColorOption(status)
			options = Grid2Options:MakeStatusMissingOption(status, options)
			options = Grid2Options:MakeStatusBlinkThresholdOption(status, options)
			Grid2Options:AddElementSubType("status", "raid-debuff", status, options)
		end
	end

end

Grid2StatusRaidDebuffsOptions:AddSetupStatusesOptions(Grid2.db.profile.setup)
