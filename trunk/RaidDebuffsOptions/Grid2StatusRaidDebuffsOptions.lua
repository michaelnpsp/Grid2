local Grid2StatusRaidDebuffsOptions = {}
Grid2Options.plugins["Grid2StatusRaidDebuffsOptions"] = Grid2StatusRaidDebuffsOptions

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

function Grid2StatusRaidDebuffsOptions.UpgradeDefaults(dblData)
	local versionsSrc = dblData.versionsSrc

	if (versionsSrc.Grid2StatusRaidDebuffsOptions < 1) then
		DBL:SetupLayerObject(dblData, "statuses", "account", "raid-debuffs", {type = "raid-debuffs", color1 = {r=1,g=.5,b=1,a=1}})
		DBL:SetupMapObject(dblData, "statusMap", "account", "icon-center", "raid-debuffs", 1000)

		versionsSrc.Grid2StatusRaidDebuffsOptions = 1
	end
end


local function MakeStatusOptions(self, status, options, optionParams)
	options = options or {}
	options = self:MakeStatusStandardOptions(status, options, optionParams)
	options = self:MakeStatusMissingOptions(status, options, optionParams)
	options = self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	return options
end

local prev_MakeStatusOptions = Grid2Options.MakeStatusOptions
function Grid2Options:MakeStatusOptions(dblData, reset, ...)
	self:AddOptionHandler("raid-debuffs", MakeStatusOptions)

	prev_MakeStatusOptions(self, dblData, reset, ...)
end

