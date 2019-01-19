--[[
	General Settings
--]]

local L = Grid2Options.L

local tabs_order = 10
local sect_order = 10

function Grid2Options:AddGeneralOptions(TabName, SectionName, extraOptions, order)
	local Tabs   = Grid2Options.options.args.general
	local CurTab = Tabs.args[TabName]
	if (not CurTab) and (SectionName or (not extraOptions.args)) then
		CurTab = { type = "group", order = order or tabs_order,	name = L[TabName], args = {}, childGroups = "tab" }
		if not order then tabs_order = tabs_order + 1 end
		Tabs.args[TabName]= CurTab
	end
	if SectionName then
		local CurSec = CurTab.args[SectionName]
		if CurSec then
			for key,value in pairs(extraOptions) do
				CurSec.args[key] = value
			end
		else
			if extraOptions.args  then
				extraOptions.order = sect_order
				CurTab.args[SectionName] = extraOptions
			else
				CurTab.args[SectionName] = { type = "group", inline = true, order = sect_order,
											name = L[SectionName],	desc = L["Options for %s."]:format(L[SectionName]),
											args = extraOptions,	}
			end
			sect_order = sect_order + 1
		end
	else
		if extraOptions.args then
			extraOptions.order = order or tabs_order
			if not order then tabs_order = tabs_order + 1 end
			Tabs.args[TabName] = extraOptions
		else
			for key,value in pairs(extraOptions) do
				CurTab.args[key] = value
			end
		end
	end
	return Tabs.args[TabName]
end

function Grid2Options:DelGeneralOptions(TabName)
	self.options.args[TabName] = nil
end

function Grid2Options:GetGeneralOptions(TabName)
	return self.options.args[TabName]
end