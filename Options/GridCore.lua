--[[
Created by Grid2 original authors, modified by Michael
--]]

local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

local Grid2Options = {
	options = {
		name = "Grid2",
		type = "group",
		handler = Grid2,
		args = {
			["Tabs"] = {
				order = 10,
				type = "group",
				name = L["General Settings"],
				desc = L["General Settings"],
				childGroups = "tab",
				args = {}, -- Settings tabs here		
			},
		},
	},
	typeMakeOptions = {},
	optionParams = {},	
}

local TABS_ORDER_DISPLAY = 10
local SECT_ORDER_DISPLAY = 10

function Grid2Options:AddModuleOptions(TabName, SectionName, extraOptions)
	local Tabs  = Grid2Options.options.args["Tabs"]
	local CurTab= Tabs.args[TabName]
	if (not CurTab) and (SectionName or (not extraOptions.args)) then
		CurTab= { type = "group", order = TABS_ORDER_DISPLAY,	name = L[TabName], args = {} }
		TABS_ORDER_DISPLAY= TABS_ORDER_DISPLAY + 1
		Tabs.args[TabName]= CurTab
	end
	if SectionName then
		local CurSec= CurTab.args[SectionName]
		if CurSec then
			for key,value in pairs(extraOptions) do
				CurSec.args[key]= value
			end
		else
			if extraOptions.args  then
				extraOptions.order= SECT_ORDER_DISPLAY
				CurTab.args[SectionName]= extraOptions
			else	
				CurTab.args[SectionName]= { type = "group", inline= true, order = SECT_ORDER_DISPLAY, 
											name = L[SectionName],	desc = L["Options for %s."]:format(L[SectionName]),
											args = extraOptions,	}
			end
			SECT_ORDER_DISPLAY = SECT_ORDER_DISPLAY + 1
		end			
	else
		if extraOptions.args then
			extraOptions.order= TABS_ORDER_DISPLAY
			TABS_ORDER_DISPLAY= TABS_ORDER_DISPLAY + 1
			Tabs.args[TabName]= extraOptions
		else
			for key,value in pairs(extraOptions) do
				CurTab.args[key]= value
			end
		end
	end
	
end

function Grid2Options:AddElement(elementType, element, extraOptions)
	--Elementtype: a string representing the options
	--Element: The element itself
	--ExtraOptions: The aceconfig structure
	--
	--Adds options for this element to the main menu.
	--Will create a menu of type elementType if it doesn't already exist.
	--That in turn must be a group, with elements matching 'element'
	--
	--The OO here is a bit laboured :(
	
	extraOptions = extraOptions or element.extraOptions
	element.extraOptions = nil
	if not extraOptions then return end

	local group = self.options.args[elementType]
	if not group then
		group = {
			type = "group",
			name = L[elementType] or elementType,
			desc = L["Options for %s."]:format(elementType),
			args = {},
		}
		self.options.args[elementType] = group
	end
	
	local options
	if extraOptions.type then
		options= extraOptions	
	else
		options= { type = "group",	args = extraOptions }
	end
	options.order = options.order or 100
	options.name  = options.name or L[element.name] or element.name
	options.desc  = options.desc or L["Options for %s."]:format(element.name)
	group.args[element.name]= options
end

function Grid2Options:DeleteElement(elementType, elementKey)
	local args= self.options.args
	local group = args[elementType]
	if group then
		if elementKey then
			group.args[elementKey] = nil
		else
			args[elementType]= nil
		end
	end
end

function Grid2Options:DeleteElementSubType(elementType, subType, elementKey)
	local group = self.options.args[elementType]
	if group then
		local subGroup = group.args[subType]
		if (subGroup) then
			subGroup.args[elementKey] = nil
		end
	end	
end

-- Adds meta options for the list of elements from AddElement
-- Order < 100 is reserved for Grid elements
-- If reset is true then discard the old options
function Grid2Options:AddElementGroup(type, extraOptions, order, reset)
	if not extraOptions then return end

	local group = self.options.args[type]
	if (reset or not group) then
		group = {
			type = "group",
			order = order,
			name = L[type] or type,
			desc = L["Options for %s."]:format(type),
			args = {},
		}
		self.options.args[type] = group
	end
	local options = group.args
	for name, option in pairs(extraOptions) do
		options[name] = option
	end
end

local CategoriesOrder={
	["buff"]  = 10,
	["debuff"]= 20,
	["color"] = 30,
	["health"]= 40,
	["mana"]  = 50,
	["combat"]= 60,
	["target"]= 70,
	["misc"]  = 80,
}

function Grid2Options:AddElementSubTypeGroup(type, subType, subTypeDescription, subTypeOptions, reset)
	local group = self.options.args[type]
	if (not group) then
		group = {
			type = "group",
			name = L[type] or type,
			desc = L["Options for %s."]:format(type),
			args = {},
		}
		self.options.args[type] = group
	end

	local subGroup = group.args[subType]
	local options = {}
	if (reset or not subGroup) then
		if not subTypeDescription then
			subTypeDescription= subType
		end
		subGroup = {
			type = "group",
			name = L[subTypeDescription] or subTypeDescription,
			order = CategoriesOrder[subType] or 100,
			desc = L["Options for %s."]:format(subType),
			args = options,
		}
		group.args[subType] = subGroup
	end
	if (subTypeOptions) then
		for name, option in pairs(subTypeOptions) do
			options[name] = option
		end
	end
	return subGroup
end


function Grid2Options:AddElementSubType(elementType, subType, element, extraOptions)
	extraOptions = extraOptions or element.extraOptions
	element.extraOptions = nil
	if not extraOptions then return end

	local group = self.options.args[elementType]
	if not group then
		group = {
			type = "group",
			name = L[elementType] or elementType,
			desc = L["Options for %s."]:format(elementType),
			args = {},
		}
		self.options.args[elementType] = group
	end

	local subGroup = group.args[subType]
	if (not subGroup) then
		subGroup = self:AddElementSubTypeGroup(elementType, subType)
	end

	local name= Grid2Options.LocalizeStatus(element, true)
	
	-- Calculate order: Magic,Curse,Poison and Disease debuffs first
	local order= element.dbx.subType and 10 or 20

	local options = {}
	subGroup.args[element.name] = {
		type = "group",
		name = name,
		order = order,
		desc = L["Options for %s."]:format(element.name),
		args = options,
	}
	for name, option in pairs(extraOptions) do
		options[name] = option
	end
end

function Grid2Options:DeleteElementSubType(elementType, subType, elementKey)
	local group = self.options.args[elementType]
	if not group then
		return
	end

	local subGroup = group.args[subType]
	if (not subGroup) then
		return
	end
	subGroup.args[elementKey] = nil
end

function Grid2Options:AddOptionHandler(typeKey, funcMakeOptions, optionParams)
	Grid2Options.typeMakeOptions[typeKey] = funcMakeOptions
	Grid2Options.optionParams[typeKey] = optionParams
end

function Grid2Options:GetOptionHandler(typeKey)
	return Grid2Options.typeMakeOptions[typeKey], Grid2Options.optionParams[typeKey]
end

function Grid2Options:GetLayouts( meta )
    local list= { }
	for name, layout in pairs(Grid2Layout.layoutSettings) do
      if layout.meta[meta] == true then
	     list[name]= LG[name]
	  end
	end
	return list
end

---
---
---

function Grid2Options:Initialize()
	self = self or Grid2Options

	self:MakeFrameOptions()
	self:MakeLayoutOptions()
	self:MakeBlinkOptions()
    self:MakeProfileOptions()
	self:MakeDebugOptions()
	self:MakeAboutOptions()
	self:MakeOptions()
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Grid2", self.options)
	local ACD3 = LibStub("AceConfigDialog-3.0")
	local sections= self.options.args
	ACD3:AddToBlizOptions("Grid2", sections.Tabs.name      , "Grid2", "Tabs")
	ACD3:AddToBlizOptions("Grid2", sections.indicators.name, "Grid2", "indicators")
	ACD3:AddToBlizOptions("Grid2", sections.statuses.name  , "Grid2", "statuses")
	
	self.Initialize = nil
end

-- Called from Grid2 core if profile changes
function Grid2Options:MakeOptions()
	if not self.Initialize then   -- Avoid clearing media options on first run
		self:ClearMediaOptions()
	end
    self:MakeStatusOptions(true)	
	self:MakeIndicatorOptions(true)
end

function Grid2Options:MakeProfileOptions(reset)

	local exportOptions= Grid2Options:GetExportImportOptions()
	
	local profileOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(Grid2.db, true)
	local name= profileOptions.name
	profileOptions.name= L["General"]
    local LibDualSpec = LibStub('LibDualSpec-1.0')
	if LibDualSpec then
		LibDualSpec:EnhanceOptions(profileOptions, Grid2.db)
	else
		print("ERROR NOT DUALSPEC LIBRARY")
	end
	
	local options = {
		type = "group",
		childGroups= "tab",
		order= 100,
		name = name,
		desc = L["Options for %s."]:format(name),
		args = {
				general= profileOptions,
				advanced= exportOptions
				},	
	}
	Grid2Options:AddModuleOptions("Profiles", nil, options )
end

function Grid2Options:MakeAboutOptions(reset)
	Grid2Options:AddModuleOptions("About", nil, {
        p1 = { order = 10, type = "description", name = "\n\n"..Grid2.versionstring},
		p2 = { order = 11, type = "description", name = "\nGrid2 is a party and raid unit frame addon." },
        p3 = { order = 12, type = "description", name = "Grid2 displays health and all relevant information about the raid members in a more comprehensible manner.\n" },
	})
end

function Grid2Options:OnChatCommand(input)
	if (LibStub("AceConfigDialog-3.0").OpenFrames["Grid2"]) then
		LibStub("AceConfigDialog-3.0"):Close("Grid2")
	else
		LibStub("AceConfigDialog-3.0"):Open("Grid2")
	end
end

function Grid2Options:GetValidatedName(name)
	name = name:gsub("[\"%.]", "")
	name = name:gsub(" ", "-")
	return name
end


function Grid2Options:ConfirmDialog(message, funcAccept, funcCancel)
	local t
	if StaticPopupDialogs["GRID2OPTIONS_CONFIRM_DIALOG"] then
		t = StaticPopupDialogs["GRID2OPTIONS_CONFIRM_DIALOG"]
		wipe(t)
	else
		t= {}
		StaticPopupDialogs["GRID2OPTIONS_CONFIRM_DIALOG"] = t
	end
	t.text = message
	t.button1 = ACCEPT
	t.button2 = CANCEL
	local dialog, oldstrata
	t.OnAccept = function()
		if funcAccept then (funcAccept)() end
		if dialog and oldstrata then
			dialog:SetFrameStrata(oldstrata)
		end
	end
	t.OnCancel = function()
		if funcCancel then (funcCancel)() end
		if dialog and oldstrata then
			dialog:SetFrameStrata(oldstrata)
		end
	end
	t.timeout = 0
	t.whileDead = 1
	t.hideOnEscape = 1
	dialog = StaticPopup_Show("GRID2OPTIONS_CONFIRM_DIALOG")
	if dialog then
		oldstrata = dialog:GetFrameStrata()
		dialog:SetFrameStrata("TOOLTIP")
	end
end

---

_G.Grid2Options = Grid2Options

