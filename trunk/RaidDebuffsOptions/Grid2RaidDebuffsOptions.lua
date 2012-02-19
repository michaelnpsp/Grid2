--[[
Created by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local BZ = LibStub("LibBabble-Zone-3.0"):GetUnstrictLookupTable()
--local BB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable() -- Disabled because uses too much memory
local BB = {}

local GSRD= Grid2:GetModule("Grid2RaidDebuffs")
local RDDB= {}

local moduleList
local moduleListAll
local selectedModule
local selectedInstance
local selectedDebuffs 
local optionModules
local optionInstances
local optionDebuffs
local optionsDebuffsCache= {}
local tipDebuff
local newSpellId
local newDebuffName
local fmt= string.format

local MakeDebuffOptions
local MakeDebuffGroup

local ICON_SKULL= "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local ICON_CHECKED = READY_CHECK_READY_TEXTURE
local ICON_UNCHECKED = READY_CHECK_NOT_READY_TEXTURE

function Grid2Options:GetRaidDebuffsTable()
	return RDDB
end

local function UpdateZoneSpells(status)
	if IsInInstance() then
		status:UpdateZoneSpells(true)
	end	
end

local function ResetAdvancedOptions()
	moduleList= nil
	moduleListAll= nil
	selectedModule= ""
	selectedInstance= ""
    selectedDebuffs= nil
	wipe(optionsDebuffsCache)
end

local function GetSpellDescription(spellId)
	if not tipDebuff then
		tipDebuff = CreateFrame("GameTooltip", "Grid2RaidDebuffsTooltip", nil, "GameTooltipTemplate")
		tipDebuff:SetOwner(UIParent, "ANCHOR_NONE")
		for i = 1, 5 do
			tipDebuff[i] = _G["Grid2RaidDebuffsTooltipTextLeft"..i]
			if not tipDebuff[i] then
				tipDebuff[i] = tipDebuff:CreateFontString()
				tipDebuff:AddFontStrings(tipDebuff[i], tipDebuff:CreateFontString())
			end
		end
	end
	local result= {}
	tipDebuff:ClearLines()
	tipDebuff:SetHyperlink("spell:"..spellId)
	for i=2, min(5,tipDebuff:NumLines()) do
		result[i-1]= tipDebuff[i]:GetText() 
	end
	return table.concat(result,"\n")
end

local function GetModules(all)
	if not moduleList then
		moduleList= {}
		local enabledModules= GSRD.db.profile.enabledModules or {}
		for name,_ in pairs(enabledModules) do
			moduleList[name]= L[name]
		end
	end
	if not moduleListAll then
		moduleListAll= {}
		for name,_ in pairs(RDDB) do
			moduleListAll[name]= L[name]
		end
	end
	return all and moduleListAll or moduleList
end

local function GetInstances(module)
	local values= {}
	if module and module~="" then
		local instances= RDDB[module]
		if instances then
			for name,_ in pairs(instances) do
				values[name]= BZ[name] or name
			end
		end
	end	
	return values
end

local function SetEnableDebuff(status,instance, spellId, value)
	local dbx = status.dbx
	if value then
		if not dbx.debuffs then 
			dbx.debuffs= {}	
		end
		if not dbx.debuffs[instance] then
			dbx.debuffs[instance]= {}
		end
		local debuffs = dbx.debuffs[instance]
		debuffs[#debuffs+1] = spellId
		selectedDebuffs[spellId] = #debuffs
	else
		local debuffs = dbx.debuffs[instance]
		local index   = selectedDebuffs[spellId]
		table.remove( debuffs,  index )
		selectedDebuffs[spellId]= nil
		for k,v in pairs(selectedDebuffs) do
			if v>index then 
				selectedDebuffs[k] = v-1 
			end
		end
	end
	UpdateZoneSpells(status)
end

local function SetDebuffSpellIdTracking(status, instance, spellId, value)
	local index    = selectedDebuffs[spellId]
	local debuffs  = status.dbx.debuffs[instance]
	debuffs[index] = value and -spellId or spellId
	UpdateZoneSpells(status)
end

local function FormatDebuffName(spellName,spellId) 
	local icon= selectedDebuffs[spellId] and ICON_CHECKED or ICON_UNCHECKED
	return fmt("  |T%s:0|t%s", icon, spellName or spellId)
end

local function EnableInstanceAllDebuffs(status)
	local debuffs = {}
	local module = selectedModule
	local instance = selectedInstance
	local dbx = status.dbx
	if not dbx.debuffs then 
		dbx.debuffs= {}	
	end
	local debuffsall= RDDB[module][instance]
	for _,values in pairs(debuffsall) do
		for _,spellId in ipairs(values) do
			debuffs[#debuffs+1]= spellId
			selectedDebuffs[spellId]= #debuffs
		end
	end
	-- Enable user defined debuffs
	local rddbx= GSRD.db.profile.debuffs
	if rddbx and rddbx[instance] then
		for _,values in pairs(rddbx[instance]) do
			for _,spellId in ipairs(values) do
				debuffs[#debuffs+1]= spellId
				selectedDebuffs[spellId]= #debuffs
			end
		end
	end	
	dbx.debuffs[instance]= debuffs
	UpdateZoneSpells(status)
end

local function DisableInstanceAllDebuffs(status)
	local instance= selectedInstance
	local debuffs= status.dbx.debuffs
	if debuffs and debuffs[instance] then
		debuffs[instance] = nil
		selectedDebuffs = {}
		UpdateZoneSpells(status)
	end
end

local function RefreshDebuffsOptions()
	local items= optionDebuffs.args
	for key,value in pairs(items) do
		local spellId = tonumber(key)
		if spellId then
			items[key].name= FormatDebuffName(value.nameBackup,spellId)
		end
	end
end

local function EnableDisableModule(status, module, state)
	local dbx= status.dbx
	if not dbx.debuffs then 
		dbx.debuffs= {}	
	end
	local rddbx= GSRD.db.profile
	if not rddbx.enabledModules then
		rddbx.enabledModules= {}
	end
	if state then
		local instances= RDDB[module]
		for name,instance in pairs(instances) do
			local debuffs= {}
			for _,boss in pairs(instance) do
				for _,spellId in ipairs(boss) do
					debuffs[#debuffs+1]= spellId
				end
			end	
			dbx.debuffs[name]= debuffs
			local cacheKey= module..name
			if optionsDebuffsCache[cacheKey] then
				optionsDebuffsCache[cacheKey]= nil
			end	
		end
		rddbx.enabledModules[module]= true
		moduleList[module]= L[module]	
	else
		local instances= RDDB[module]
		for instance,_ in pairs(instances) do
			if dbx.debuffs[instance] then 
				dbx.debuffs[instance]= nil 
			end
		end
		if rddbx.enabledModules[module] then rddbx.enabledModules[module]= nil end
		if not next(rddbx.enabledModules) then rddbx.enabledModules= nil end
		if moduleList[module] then moduleList[module]= nil end
	end
	selectedModule= ""
	optionModules.values= GetModules()
	UpdateZoneSpells(status)
end

local function CreateStandardDebuff(bossName,spellId,spellName)
	local baseKey = fmt("%s>%s", string.match(bossName, "^(.-) .*$") or bossName, spellName):gsub("[ %.\"!']", "")
	if not Grid2:DbGetValue("statuses", baseKey) then
		-- Save status in database
		local dbx = {type = "debuff", spellName = spellId, color1 = {r=1, g=0, b=0, a=1} }
		Grid2:DbSetValue("statuses", baseKey, dbx) 
		--Create status in runtime
		local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
		--Create the status options
		local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
		local optionParams = Grid2Options.optionParams[dbx.type]
		local options, subType = funcMakeOptions(Grid2Options, status, options, optionParams)
		Grid2Options:AddElementSubType("statuses", subType, status, options)
	end
end

local function CreateRaidDebuff(status,boss)
	local spellId= newSpellId
	local spellName= GetSpellInfo(newSpellId)
	if spellId and spellName then
		local dbx= GSRD.db.profile
		if not dbx.debuffs then	dbx.debuffs= {}	end
		dbx= dbx.debuffs
		if not dbx[selectedInstance] then dbx[selectedInstance]= {}	end
		dbx= dbx[selectedInstance]
		if not dbx[boss] then dbx[boss]= {}	end
		dbx= dbx[boss]
		dbx[#dbx+1]= spellId
		SetEnableDebuff(status,selectedInstance,spellId,true)
		local order = optionDebuffs.args[boss].order + selectedDebuffs[spellId]
		optionDebuffs.args[tostring(spellId)] = MakeDebuffGroup(status, boss, spellId, order, true)
	end
	newDebuffName= nil
	newSpellId= nil
end

local function DeleteRaidDebuff(status, spellId)
	local dbx= GSRD.db.profile
	SetEnableDebuff(status,selectedInstance,spellId,false)
	for boss, spells in pairs(dbx.debuffs[selectedInstance]) do
		for i= 1, #spells do
			if spellId == spells[i] then
				optionDebuffs.args[tostring(spellId)]= nil
				table.remove(spells,i)
				if #spells==0 then
					dbx.debuffs[selectedInstance][boss]= nil
					if not next(dbx.debuffs[selectedInstance]) then
						dbx.debuffs[selectedInstance]= nil
						if not next(dbx.debuffs) then
							dbx.debuffs= nil
						end
					end
				end
				return
			end
		end
	end
end

local function MakeDebuffOptions(status,bossName,spellId,spellName,spellIcon, isCustom)
	local options= {
		spellname={
			type="description",
			order= 10,
			name= spellName,
			fontSize= "large",
			image= spellIcon,
		},
		header1={
			type= "header",
			order= 12,
			name="",
		},		
		description= {
			type="description",
			order= 50,
			fontSize= "medium",
			name= GetSpellDescription(spellId),
		},
		header2={
			type= "header",
			order= 40,
			name="",
		},
		enableSpell={
			type="toggle",
			order = 30,
			name = L["Enabled"],
			get = function() return selectedDebuffs[spellId] end,
			set = function(_, v)    
				SetEnableDebuff(status,selectedInstance,spellId,v)
				local option = optionDebuffs.args[ tostring(spellId) ]
				option.name  = FormatDebuffName(spellName,spellId)
				option.order = math.floor( option.order / 200) * 200 + (selectedDebuffs[spellId] or 100)
			end,
		},	
		header3={
			type= "header",
			order= 140,
			name="",
		},
		idTracking={
			type="toggle",
			order = 145,
			width = "full",
			name = fmt( "%s ( %d )", L["Track by SpellId"], spellId ),
			desc = L["Track by spellId instead of aura name"],
			get = function() 
				local index = selectedDebuffs[spellId]
				if index then return status.dbx.debuffs[selectedInstance][index] < 0 end	
			end,
			set = function(_, v) 
				SetDebuffSpellIdTracking(status, selectedInstance, spellId, v)	
			end,
			disabled = function() return not selectedDebuffs[spellId] end,
		},					
		header4={
			type= "header",
			order= 147,
			name="",
		},
		createDebuff= {
			type = "execute",
			order = 150,
			name = L["Copy to Debuffs"],
			func = function() CreateStandardDebuff(bossName,spellId,spellName) end,
			disabled = false,
		}
	}
	if isCustom then
		options.removeDebuff= {
			type = "execute",
			order = 155,
			name = L["Delete raid debuff"],
			func = function() DeleteRaidDebuff(status,spellId) end,
			disabled = false,
		}
	end
	return options
end

function MakeDebuffGroup(status, bossName, spellId, order, isCustom)
	local spellName,_, spellIcon = GetSpellInfo(spellId)
	return {
		type = "group",
		name = FormatDebuffName(spellName,spellId),
		nameBackup = spellName,
		desc = fmt("     (%d)", spellId ),
		order = order,
		args = MakeDebuffOptions(status,bossName,spellId,spellName,spellIcon,isCustom)
	}
end

function MakeDebuffsOptions(status)
	local module = selectedModule
	local instance = selectedInstance
	--
	selectedDebuffs= {}
	local dbx = status.dbx.debuffs and status.dbx.debuffs[instance] or {}
	for index,value in ipairs(dbx) do
		selectedDebuffs[ math.abs(value) ] = index
	end
	--
	local dbx = GSRD.db.profile.debuffs and GSRD.db.profile.debuffs[selectedInstance]
	local cacheKey = module..instance
	local options = optionsDebuffsCache[cacheKey]
	if not options then
		options= {}
		options.enableall={
			type ="execute",
			order= 5,
			name = L["Enable All"],
			func= function() 
				EnableInstanceAllDebuffs(status)
				RefreshDebuffsOptions()
			end
		}
		options.disableall={
			type ="execute",
			order= 7,
			name = L["Disable All"],
			func= function() 
				DisableInstanceAllDebuffs(status)
				RefreshDebuffsOptions()
			end
		}
		local debuffs= RDDB[module][instance]
		local ORDER = 200
		for name,values in pairs(debuffs) do
			local bossName= BB[name] or name
			options[name]= {
				type= "group",
				name=  fmt("|T%s:0|t%s", ICON_SKULL, bossName),
				order= ORDER,
				args= {
					name = {
						type = "input",
						order = 1,
						width = "full",
						name = L["New raid debuff"],
						desc = L["Type the SpellId of the new raid debuff"],
						get = function()  return newDebuffName end,
						set = function(_,v)	
							newSpellId= tonumber(v)
							newDebuffName= newSpellId and GetSpellInfo(newSpellId) or nil
							if not newDebuffName or newDebuffName=="" then newSpellId= nil end
						end,
					},
					exec = {
						type = "execute",
						order = 9,
						name = L["Create raid debuff"],
						func = function(info) CreateRaidDebuff( status, info[#info-1] ) end,
						disabled= function() return not newSpellId or optionDebuffs.args[tostring(newSpellId)] end
					},
				},
			}
			for index,spellId in ipairs(values) do
				local childOrder = ORDER + (selectedDebuffs[spellId] or (100+index))
				options[tostring(spellId)]= MakeDebuffGroup(status, bossName, spellId, childOrder)
			end
			local userDebuffs= dbx and dbx[name]
			if userDebuffs then
				for index,spellId in ipairs(userDebuffs) do
					local childOrder = ORDER + (selectedDebuffs[spellId] or (150+index))
					options[tostring(spellId)]= MakeDebuffGroup(status, bossName, spellId, childOrder, true)
				end
			end
			ORDER= ORDER + 200
		end
		optionsDebuffsCache[cacheKey]= options
	end
	return options
end

local function MakeModulesListOptions(self,status,options,optionParams)
	options.header= {
		type="header",
		order= 149,
		name="",
	}
	options.modules= {
		type= "multiselect",
		name= L["Enabled raid debuffs modules"],
		order= 150,
		width= "full",
		get= function(info,key)
			return (moduleList[key] ~= nil)
		end,
		set= function(_,key,value)
			EnableDisableModule(status,key,value)
		end,
		values= GetModules(true)
	}
	return options
end

local function MakeGeneralOptions(self, status, options, optionParams)
	options= options or {}
	options = Grid2Options:MakeStatusStandardOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = MakeModulesListOptions(self,status,options,optionParams)
	return options
end

local function MakeAdvancedOptions(self,status,options,optionPararms)
	ResetAdvancedOptions()
	optionModules= {
		type = "select",
		order = 10,
		name = L["Select module"],
		desc = "",
		get = function ()
			if selectedModule=="" then
				selectedModule= next(GetModules()) or ""
				selectedInstance= ""
				optionInstances.values= GetInstances(selectedModule)
				optionDebuffs.name= ""
				optionDebuffs.args= {}
			end
			return selectedModule
		end,
		set = function (info, v)
			selectedModule= v
			selectedInstance=""
			optionInstances.values= GetInstances(v)
			optionDebuffs.name= ""
			optionDebuffs.args= {}
		end,
		values= GetModules()
	}
	optionInstances= {
		type = "select",
		order = 20,
		name = L["Select instance"],
		desc = "",
		get = function () return selectedInstance end,
		set = function (_, v)
			selectedInstance = v
			optionDebuffs.name= BZ[v] or v
			optionDebuffs.args= MakeDebuffsOptions(status)
		end,
		values= {}
	}
	optionDebuffs= {
		type="group",
		name="",
		order= 30,
		childGroups= "tree",
		args= {},
	}
	local options= {}
	options.modules  = optionModules
	options.instances= optionInstances
	options.debuffs  = optionDebuffs
	return options
end

local function MakeStatusOptions(self, status, options, optionParams)
	local generalOptions = MakeGeneralOptions(self,status,options,optionParams) 
	local advancedOptions= MakeAdvancedOptions(self,status)
	local options = {
		type = "group",
		order= 25,
		childGroups= "tab",
		args= {
			general= {
				type= "group",
				name= L["General"],
				order= 10,
				args= generalOptions,
			},
			advanced= {
				type= "group",
				name= L["Advanced"],
				order= 20,
				args= advancedOptions,
			},
		},
	}
	return options, "root"
end

-- Notify Grid2Options howto create the options for our status

Grid2Options:AddOptionHandler("raid-debuffs", MakeStatusOptions)
