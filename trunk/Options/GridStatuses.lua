--[[
	Statuses options
--]]

local Grid2Options = Grid2Options
local L = Grid2Options.L

local pairs = pairs
local fmt = string.format

-- status types indicators icons
Grid2Options.statusTypesIcons = {
	generic = Grid2Options.indicatorIconPath .. "color",
	color   = Grid2Options.indicatorIconPath .. "square",
	icon    = Grid2Options.indicatorIconPath .. "icon",
	icons   = Grid2Options.indicatorIconPath .. "icons",
	text    = Grid2Options.indicatorIconPath .. "text",
	percent = Grid2Options.indicatorIconPath .. "bar",
}
-- categories
Grid2Options.categories = {
	buff   = { name = L["Buffs"],               order = 10, icon = "Interface\\Icons\\Spell_Holy_HealingAura.",     title = L["New Buff"],   },
	debuff = { name = L["Debuffs"], 			order = 20, icon = "Interface\\Icons\\Ability_creature_disease_05", title = L["New Debuff"], },
	color  = { name = L["Colors"], 				order = 30, icon = "Interface\\Addons\\Grid2\\media\\icon",         title = L["New Color"],  },
	health = { name = L["Health&Heals"], 		order = 40, icon = "Interface\\Icons\\INV_Potion_167", },
	mana   = { name = L["Mana&Power"], 			order = 50, icon = "Interface\\Icons\\INV_Potion_168", },
	combat = { name = L["Combat"], 				order = 60, icon = "Interface\\ICONS\\Inv_axe_88", },
	target = { name = L["Targeting&Distances"],	order = 70, icon = "Interface\\ICONS\\Ability_Hunter_RunningShot", },
	role   = { name = L["Raid&Party Roles"], 	order = 80, icon = "Interface\\GroupFrame\\UI-Group-LeaderIcon", },
	misc   = { name = L["Miscellaneous"],		order = 90, icon = "Interface\\ICONS\\Inv_misc_groupneedmore", },
}
-- debuff type icons
Grid2Options.debuffTypeIcons = {
	Magic   = "Interface\\Icons\\Spell_holy_nullifydisease",
	Poison  = "Interface\\Icons\\Spell_nature_nullifydisease",
	Disease = "Interface\\Icons\\Spell_nature_removedisease",
	Curse   = "Interface\\Icons\\Spell_nature_removedisease",
	Default = "Interface\\Icons\\Spell_holy_harmundeadaura",
}
-- status.dbx.type -> categoryKey
Grid2Options.typeCategories = {}

-- Grid2Options:GetStatusSetupFunc()
function Grid2Options:GetStatusSetupFunc(status)
	local key = status.dbx.type
	return self.typeMakeOptions[key] or self.MakeStatusStandardOptions, self.optionParams[key]
end

-- Grid2Options:GetStatusCategory()
function Grid2Options:GetStatusCategory(status)
	return self.typeCategories[status.dbx.type] or "misc"
end

-- Insert status category options into AceConfigTable: ex: "Health&Healths"
function Grid2Options:AddStatusCategoryOptions(catKey, category)
	if catKey ~= "hidden" then
		local options = self:CopyOptionsTable(category.options)
		local group = {
			type  = "group",
			name  = category.name,
			desc  = L["Options for %s."]:format(category.name),
			order = category.order,
			args  = options,
		}
		if category.options and (not category.options.title) and (not category.title) then
			category.title = category.name
		end
		if category.title then
			self:MakeTitleOptions(options, category.title, category.desc or group.desc, nil, category.icon )
		end
		self.statusesOptions[catKey] = group
	end
end

function Grid2Options:GetStatusDescription(status)
	local dbx = status.dbx
	if dbx.type == "buff" or dbx.type == "debuff" then
		local spellId = tonumber(dbx.spellName)
		if spellId then
			local tip = Grid2Options.Tooltip
			tip:ClearLines()
			tip:SetHyperlink("spell:"..spellId)
			local count = tip:NumLines()
			if count > 1 then
				return tip[count]:GetText()
			end
		end
	elseif dbx.type == 'buffs' and dbx.subType == "blizzard" then
		return L["Show relevant buffs for each unit frame (the same buffs displayed by the Blizzard raid frames)."]
	end
end

-- returns AceConfigTable status group option
function Grid2Options:GetStatusGroup(status)
	local key = self:GetStatusCategory(status)
	return self.statusesOptions[key].args[status.name]
end

-- returns the AceConfigTable status options (the args field in group option)
function Grid2Options:GetStatusOptions(status, reset)
	local options = self:GetStatusGroup(status).args
	if reset then wipe(options) end
	return options
end

-- Calculate status information necessary to create the status and group options
do
	local iconCoords = { 0.05, 0.95, 0.05, 0.95 }
	function Grid2Options:GetStatusInfo(status)
		local params = self.optionParams[status.dbx.type]
		if not ( params and params.masterStatus and  params.masterStatus ~= status.name ) then
			local catKey   = self:GetStatusCategory(status)
			local catGroup = self.statusesOptions[catKey]
			if catGroup then
				local name, desc, icon, coords, _
				local category = self.categories[catKey]
				local dbx = status.dbx
				if dbx.type == "buff" or dbx.type == "debuff" then
					name,_,icon = GetSpellInfo( tonumber(dbx.spellName) or dbx.spellName )
					desc = string.format( "%s: %s", L[dbx.type], name or dbx.spellName )
				elseif dbx.type == "buffs" then
					desc = L["Buffs Group"]
				elseif dbx.type == "debuffs" then
					desc = L["Debuffs Group"]
				elseif dbx.type=="debuffType" then
					icon = self.debuffTypeIcons[dbx.subType or 'Default']
					desc = L[dbx.type]
				end
				name   = self.LocalizeStatus(status, true)
				desc   = desc or (params and params.title) or L["Options for %s."]:format(name)
				icon   = icon or (params and params.titleIcon) or category.icon
				coords = params and params.titleIconCoords or iconCoords
				return catGroup, name, desc, icon, coords, params
			end
		end
	end
end

-- Generates a text with the status compatible indicators icons
function Grid2Options:GetStatusCompIndicatorsText(status)
	local icons, text, flag = self.statusTypesIcons, ""
	for type,statuses in pairs(Grid2.statusTypes) do
		local icon = icons[type]
		if icon then
			for i=1,#statuses do
				if status==statuses[i] then
					text = fmt( "%s|T%s:0|t", text, icon )
					flag = flag or type=='color'
					break
				end
			end
		end
	end
	return flag and fmt( "%s|T%s:0|t", text, icons.generic ) or text
end

-- Add a title option to the status options
function Grid2Options:MakeStatusTitleOptions(status, options, optionParams)
	if not (options.title or (optionParams and optionParams.hideTitle) ) then
		local name, desc, icon, iconCoords, _
		local group = self:GetStatusGroup(status)
		if group and false then
			name, desc, icon, iconCoords = group.name, group.desc, group.icon, group.iconCoords
		else
			_, name, desc, icon, iconCoords = self:GetStatusInfo(status)
		end
		self:MakeTitleOptions(
			options,
			fmt( "%s  |cFF8681d1[%s]|r", name, self:GetStatusCompIndicatorsText(status) ),
			desc,
			optionParams and optionParams.titleDesc or self:GetStatusDescription(status),
			icon,
			iconCoords
		)
	end
end

-- Create status options in AceConfigTable (this function is hooked by open manager)
function Grid2Options:MakeStatusChildOptions(status, options)
	options = options or self:GetStatusOptions(status, true)
	local setupFunc, optionParams = self:GetStatusSetupFunc(status)
	if setupFunc then
		if not (optionParams and optionParams.hideTitle) then
			self:MakeStatusTitleOptions(status, options, optionParams)
			options.settings   = { type = "group", order = 100, name = L['status'],   args = {} }
			options.indicators = { type = "group", order = 200, name = L['indicators'], args = {} }
			self:MakeStatusIndicatorsOptions( status, options.indicators.args )
			options = options.settings.args
		end
		setupFunc(self, status, options, optionParams)
	end
end

--============================================================================================================
-- Public methods
--============================================================================================================

-- Register options for a status
-- Variables to control title appearance in optionParams:
--   title = string        subtitle text (title text is always the status name)
--   titleDesc = string    description/comments
--   titleIcon = string    icon path
--   titleIconCoords = {}  icon texture coordinates
--   hideTitle = boolean   true to cancel the creation of title options
function Grid2Options:RegisterStatusOptions( type, categoryKey, funcMakeOptions, optionParams)
	if funcMakeOptions then self.typeMakeOptions[type] = funcMakeOptions end
	if optionParams    then self.optionParams[type]    = optionParams    end
	if categoryKey     then self.typeCategories[type]  = categoryKey     end
end

-- Register a status category
-- See params table structure in Grid2Options.categories table above
function Grid2Options:RegisterStatusCategory(catKey, params)
	self.categories[catKey] = params
end

-- Register options for a category (category must exists)
function Grid2Options:RegisterStatusCategoryOptions(catKey, options)
	local category = self.categories[catKey]
	if category then category.options = options	end
end

-- Creates the parent group option and the options of the status in AceConfigTable
function Grid2Options:MakeStatusOptions(status)
	local catGroup, name, desc, icon, coords, params = self:GetStatusInfo(status)
	if catGroup then
		local order = params and params.groupOrder
		local group = catGroup.args[status.name]
		if group then
			wipe(group.args)
		else
			group = { type = "group", args = {} }
			catGroup.args[status.name] = group
		end
		group.name = name
		group.desc = desc
		group.icon = icon
		group.iconCoords = coords
		group.childGroups = params and params.childGroups or "tab"
		group.order = (type(order)=='function' and order(status) or order) or (status.name==status.dbx.type and 100 or 200)
		if status:IsSuspended() then
			group.order = group.order+500
			group.name  = string.format('|cFF808080%s|r',group.name)
		end
		self:MakeStatusChildOptions(status, group.args)
	end
end

-- Remove status options from AceConfigTable
function Grid2Options:DeleteStatusOptions(catKey, status)
	self.statusesOptions[catKey].args[status.name] = nil
end

-- Create options for all statuses (Don't remove options param is used by LoadOnDemand code that hooks this function)
function Grid2Options:MakeStatusesOptions(options)
	-- remove old options
	options = options or self.statusesOptions
	wipe(options)
	-- title for statuses section
	self:MakeTitleOptions(options, L["statuses"], L["available statuses"], nil, "Interface\\Addons\\Grid2\\media\\icon")
	-- statuses general options
	if self.MakeNewStatusOptions then self:MakeNewStatusOptions() end
	-- make categories options
	for key,category in pairs(self.categories) do
		self:AddStatusCategoryOptions( key, category )
	end
	-- make statuses options
	local statuses = Grid2.db.profile.statuses
	for baseKey, dbx in pairs(statuses) do
		local status = Grid2.statuses[baseKey]
		if status then
			self:MakeStatusOptions( status )
		end
	end
end
