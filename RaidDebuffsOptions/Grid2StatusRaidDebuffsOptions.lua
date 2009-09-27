local Grid2StatusRaidDebuffsOptions = {}
Grid2Options.plugins["Grid2StatusRaidDebuffsOptions"] = Grid2StatusRaidDebuffsOptions

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

function Grid2StatusRaidDebuffsOptions:MakeDefaultSetup(setup, class)
	local setupIndicator = setup.status
	if (not setup.raidDebuffs) then
		Grid2Options:SetupIndicatorStatus(setupIndicator, "icon-center", "raid-debuffs", 1000)
		setup.raidDebuffs = true
	end
end

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


local prev_MakeOptions = Grid2Options.MakeOptions
function Grid2Options:MakeOptions(setup, reset, ...)
	prev_MakeOptions(self, setup, reset, ...)
	local status, options

	status = Grid2.statuses["raid-debuffs"]
	if (status) then
--		options = MakeStatusRaidDebuffsOptions()
		options = Grid2Options:MakeStatusColorOption(status)
		options = Grid2Options:MakeStatusMissingOption(status, options)
		options = Grid2Options:MakeStatusBlinkThresholdOption(status, options)
		Grid2Options:AddElement("status", status, options)
	end

--[[
	options = MakeStatusRaidDebuffsOptions()
	Grid2Options:AddElementSubTypeGroup("status", "raid-debuffs", options, reset)
	for statusKey, info in pairs(setup.raidDebuffs) do
		local status = Grid2.statuses[statusKey] -- TODO: fix names more better.  Type should not get baked in.
		if status then
			options = Grid2Options:MakeStatusColorOption(status)
			options = Grid2Options:MakeStatusMissingOption(status, options)
			options = Grid2Options:MakeStatusBlinkThresholdOption(status, options)
			Grid2Options:AddElementSubType("status", "raid-debuffs", status, options)
		end
	end
--]]
end

