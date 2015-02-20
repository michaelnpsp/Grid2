--[[
Created by MichaelAddBossDebuffOptions
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

local GSRD = Grid2:GetModule("Grid2RaidDebuffs")

local select = select
local fmt = string.format
local tonumber = tonumber

local RDDB = {}

local statuses = {}

local curModule
local curInstance
local curDebuffs = {}
local curDebuffsOrder = {}
local curBossesList = {}
local curBossesOrder = {}
local curBossesTrans = {}
local moduleList = {}
local statusesList = {}

local optionModules
local optionInstances
local optionDebuffs
local optionsDebuffsCache= {}

local newSpellId
local newDebuffName

-- true if autodetection system is enabled and collecting new raid debuffs
local auto_enabled
-- spells to be ignored by the autodetection system because they are already known or black_listed
local known_debuffs = {} 
-- black listed spells
local black_debuffs = { 160029, 36032, 6788, 95223, 114216 }

-- forward declarations
local AddBossDebuffOptions, MakeDebuffsOptions

local ICON_SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local ICON_CHECKED = READY_CHECK_READY_TEXTURE
local ICON_UNCHECKED = READY_CHECK_NOT_READY_TEXTURE

function Grid2Options:GetRaidDebuffsTable()
	return RDDB
end

local function DbTreeGetValue(db, ...)
   local count = select("#",...)
   for i = 1, count do
      local field = select(i,...)
      if not (field and db[field]) then return end
      db = db[field]
   end
   return db
end

local function DbTreeSetValue(value, db, ...)
   local count = select("#",...)
   for i = 1, count-1 do
      local field = select(i,...)
      if not db[field] then db[field] = {} end
      db = db[field]
   end
   local field = select(count,...)
   db[ field=="#" and #db+1 or field] = value
   return #db
end

local function DbTreeDelTableValue(value, db, ...)
   local count = select("#",...)
   local function Remove(dbi, index, ...)
		if index<=count then
			local field = select(index, ...)
			local data = dbi[field]
			if data then
				Remove(data, index+1, ...)
				if not next(data) then dbi[field] = nil end
			end    
		else
			local i = 1
			while i<=#dbi do
				if dbi[i] == value then
					table.remove(dbi,i)
				else
					i = i + 1
				end
			end
			if #dbi==0 then wipe(dbi) end
		end
   end
   Remove(db, 1, ...)
end

local function UpdateZoneSpells()
	if curInstance == GSRD:GetCurrentZone() then
		GSRD:UpdateZoneSpells()
	end
end

--{{ Debuffs options cache management
local function GetOptionsFromCache(module, instance)
	return optionsDebuffsCache[ module..instance ]
end

local function SetOptionsToCache(module, instance, options)
	optionsDebuffsCache[ module..instance ] = options
end

local function ClearOptionsCache(module, instance)
	if module and instance then
		optionsDebuffsCache[ module..instance ] = nil
	else
		wipe(optionsDebuffsCache)
	end	
end

local function ClearCacheExceptModule(module)
	for k,v in pairs(optionsDebuffsCache) do
		if strfind(k,module)~=1 then
			optionsDebuffsCache[k] = nil
		end
	end
end
--}}

local function GetLocalizedStatusName(key)
	local localizedText = L["raid-debuffs"]
	local index = strmatch(key, "(%d+)") or 1
    return index==1 and localizedText or fmt( "%s(%d)",localizedText,index)
end

local function GetDebuffOrder(boss, spellId, isCustom, priority)
	local status = curDebuffs[spellId]
	if status then
		return curBossesOrder[boss] * 1000 + statuses[status]*50 + curDebuffsOrder[spellId]
	else
		return curBossesOrder[boss] * 1000 + (isCustom and 750 or 500) + (priority or 200)
	end
end

local function CalculateAvailableStatuses()
	wipe(statuses)
	for _,status in Grid2:IterateStatuses() do
		if status.dbx and status.dbx.type == "raid-debuffs" then
			statuses[#statuses+1] = status
		end
	end
	table.sort( statuses, function(a,b) return (tonumber(strmatch(a.name,"(%d+)")) or 1) < (tonumber(strmatch(b.name,"(%d+)")) or 1) end )
	wipe(statusesList)
	for index,status in ipairs(statuses) do
		statuses[status] = index
		statusesList[index] = GetLocalizedStatusName( status.name )
	end	
end

local function ClearEnabledDebuffs()
	wipe(curDebuffs)
	wipe(curDebuffsOrder)
end

local function LoadEnabledDebuffs()
	ClearEnabledDebuffs()
	for _,status in ipairs(statuses) do
		local dbx = status.dbx.debuffs[curInstance] or {}
		for index,value in ipairs(dbx) do
			local key = math.abs(value)
			curDebuffs[ key ] = status
			curDebuffsOrder[ key ] = index
		end	
	end
end

local function FormatBossName( ejid, order, bossName, isCustom)
	local mask   = isCustom and "|T%s:0|t|cFFff8080%s%s|r" or "|T%s:0|t|cFFff4040%s%s|r"
	local name   = ejid>0 and EJ_GetEncounterInfo(ejid) or curBossesTrans[bossName] or bossName
	local prefix = (not isCustom) and order and order<30 and order..") " or ""
	return fmt( mask, ICON_SKULL, prefix, name ), name
end

local function GetBossTag(bossName, field)
	return DbTreeGetValue(RDDB, curModule, curInstance, bossName, field) or DbTreeGetValue(GSRD.db.profile.debuffs, curInstance, bossName, field)
end

local function SetBossTag(bossName, field, value)
	DbTreeSetValue(value, GSRD.db.profile.debuffs, curInstance, bossName, field)
end	

local function LoadBosses()
	-- fixing inconsistencies between custom debuffs bosses keys and modules bosses keys, 
	-- if the same boss has different keys, the boss key in the custom database is changed.
	local function FixCustomBossesKeys( zone, zoneToFix )
		local function findkey(zone,ejid)
			for k,v in pairs(zone) do
				if ejid==v.ejid then return k,v end
			end
		end
		if zoneToFix then
			for k,v in pairs(zone) do
				if v.ejid and v.ejid~=0 then
					local key,data = findkey(zoneToFix,v.ejid) 
					if key and k ~= key then
						zoneToFix[k] = data
						zoneToFix[key] = nil
					end
				end
			end
		end
	end
	local function Load(db)
		if db then
			for boss in pairs(db) do
				if not curBossesOrder[boss] then
					curBossesOrder[boss] = GetBossTag(boss, "order") or 100
					curBossesList[#curBossesList+1] = boss
				end
			end
		end
	end
	wipe(curBossesList)
    wipe(curBossesOrder)
	wipe(curBossesTrans)
	Load( RDDB[curModule][curInstance] )
	if curModule ~= "[Custom Debuffs]" then 
		FixCustomBossesKeys( RDDB[curModule][curInstance], GSRD.db.profile.debuffs[curInstance])
		Load( GSRD.db.profile.debuffs[curInstance] ) 
	end	
	table.sort( curBossesList, function(a,b) return curBossesOrder[a]<curBossesOrder[b] end )
	for i,boss in ipairs(curBossesList) do
		local ejid = GetBossTag(boss, "ejid") or 0
		curBossesOrder[boss] = i
		curBossesTrans[boss] = ejid>0 and EJ_GetEncounterInfo(ejid) or boss
	end	
end

local function LoadModuleList()
	wipe(moduleList)
	local modules = GSRD.db.profile.enabledModules or {}
	for name in pairs(modules) do
		moduleList[name] = L[name]
	end
	moduleList["[Custom Debuffs]"] = L["[Custom Debuffs]"]
	RDDB["[Custom Debuffs]"] = GSRD.db.profile.debuffs
end

local function ResetAdvancedOptions()
	curModule= ""
	curInstance= ""
    ClearEnabledDebuffs()
	ClearOptionsCache()
	LoadModuleList()
end

local function FormatDebuffName(spellId) 
	local name = GetSpellInfo(spellId)
	local status = curDebuffs[spellId]
	local index = statuses[status]
	if status then
		if index==1 then
			return fmt("  |T%s:0|t%s", ICON_CHECKED, name or spellId)
		else
			return fmt("  |T%s:0|t%s(%d)", ICON_CHECKED, name or spellId, index)
		end		
	else
		return fmt("  |T%s:0|t%s", ICON_UNCHECKED, name or spellId)
	end
end

local GetSpellDescription
do
	local lines = {}
	function GetSpellDescription(spellId)
		local tipDebuff = Grid2Options.Tooltip
		wipe(lines)
		tipDebuff:ClearLines()
		local name = GetSpellInfo(spellId)
		if GSRD.debugging then 
			local link = GetSpellLink(spellId)
			if not link then -- unavailable spellLink may indicate wrong spellId, thus not providing correct tooltip
				if name then -- this may still work due to having the same name
					GSRD:Debug("|cFF00FFFFSpellLink not Available|r: %s  (%s)", spellId, name)
				else -- this wont work
					GSRD:Debug("|cFFFF0000Invalid spellId|r: %s", spellId) 
				end
			end
		end
		if not name then return "" end --invalid spellIds break the tooltip
		tipDebuff:SetHyperlink("spell:"..spellId) 
		for i=2, min(5,tipDebuff:NumLines()) do
			lines[i-1]= tipDebuff[i]:GetText() 
		end
		return table.concat(lines,"\n")
	end
end

local function SetEnableDebuff(boss, status, spellId, value)
	if not status then return end
	if value then
		curDebuffs[spellId] = status
		curDebuffsOrder[spellId] = DbTreeSetValue(spellId, status.dbx.debuffs, curInstance, "#")
	else
		local index = curDebuffsOrder[spellId]
		DbTreeDelTableValue( spellId, status.dbx.debuffs, curInstance)
		curDebuffs[spellId] = nil
		curDebuffsOrder[spellId] = nil
		for k,v in pairs(curDebuffs) do
			if status==v and curDebuffsOrder[k]>index then 
				curDebuffsOrder[k] = curDebuffsOrder[k] - 1 
			end
		end
	end
	UpdateZoneSpells()
	local option = optionDebuffs.args[ tostring(spellId) ]
	option.name  = FormatDebuffName(spellId)
	option.order = GetDebuffOrder(boss, spellId)
end

local function GetDebuffStatus(spellId)
	local status = curDebuffs[spellId]
	if status then
		return status, curDebuffsOrder[spellId]
	end
end

local function SetDebuffSpellIdTracking(spellId, value)
	local spellName = GetSpellInfo(spellId)
	for spell,status in pairs(curDebuffs) do
		if spellName == GetSpellInfo(spell) then
			local index = curDebuffsOrder[spell]
			status.dbx.debuffs[curInstance][index] = value and -spell or spell
		end
	end
	UpdateZoneSpells()
end

local function EnableInstanceAllDebuffs(curModule, curInstance)
	local debuffs = {}
	local status = statuses[1]
	local dbx = status.dbx
	if not dbx.debuffs then dbx.debuffs= {}	end
	local debuffsall = RDDB[curModule][curInstance]
	for instance,values in pairs(debuffsall) do
		for boss,spellId in ipairs(values) do
			debuffs[#debuffs+1] = spellId
		end
	end
	-- Enable user defined debuffs
	local rddbx = GSRD.db.profile.debuffs
	if rddbx and rddbx[curInstance] then
		for instance,boss in pairs(rddbx[curInstance]) do
			for _,spellId in ipairs(boss) do
				debuffs[#debuffs+1] = spellId
			end
		end
	end	
	dbx.debuffs[curInstance]= debuffs
end

local function DisableInstanceAllDebuffs(curInstance)
	for index,status in ipairs(statuses) do
		status.dbx.debuffs[curInstance] = nil
	end
end

local function RefreshDebuffsOptions()
	local items = optionDebuffs.args
	for key,value in pairs(items) do
		local spellId = tonumber(key)
		if spellId then
			items[key].name= FormatDebuffName(spellId)
		end
	end
end

local function EnableDisableModule(module, state)
	local rddbx = GSRD.db.profile
	if not rddbx.enabledModules then rddbx.enabledModules= {} end
	local instances = RDDB[module]
	if state then
		for instance in pairs(instances) do
			EnableInstanceAllDebuffs(module,instance)
			ClearOptionsCache(module, instance)
		end
		rddbx.enabledModules[module]= true
		moduleList[module] = L[module]	
	else
		for instance in pairs(instances) do
			DisableInstanceAllDebuffs(instance)
		end
		if rddbx.enabledModules[module] then rddbx.enabledModules[module]= nil end
		if not next(rddbx.enabledModules) then rddbx.enabledModules= nil end
		moduleList[module] = nil
	end
	curModule= ""
	UpdateZoneSpells()
end

local function CreateStandardDebuff(bossName,spellId,spellName)
	local baseKey = fmt("debuff-%s>%s", strmatch(bossName, "^(.-) .*$") or bossName, spellName):gsub("[ %.\"!']", "")
	if not Grid2:DbGetValue("statuses", baseKey) then
		-- Save status in database
		local dbx = {type = "debuff", spellName = spellId, color1 = {r=1, g=0, b=0, a=1} }
		Grid2:DbSetValue("statuses", baseKey, dbx) 
		--Create status in runtime
		local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
		--Create the status options
		Grid2Options:MakeStatusOptions(status)
	end
end

local function CreateNewRaidDebuff(boss)
	local spellId = newSpellId
	local spellName = GetSpellInfo(newSpellId)
	if spellId and spellName then
		local priority = DbTreeSetValue( spellId, GSRD.db.profile.debuffs, curInstance, boss, '#' )
		AddBossDebuffOptions( optionDebuffs.args, boss, spellId, true, priority)
		if curModule~="[Custom Debuffs]" then
			SetBossTag( boss, "ejid", GetBossTag(boss,"ejid") )
			SetBossTag( boss, "order", GetBossTag(boss,"order") )
		end
	end
	known_debuffs[spellId] = true
	newDebuffName = nil
	newSpellId = nil
end

local function DeleteRaidDebuff(boss, spellId,  noDisable)
	known_debuffs[spellId] = nil
	if not noDisable then SetEnableDebuff(boss, curDebuffs[spellId], spellId, false) end
	DbTreeDelTableValue(spellId, GSRD.db.profile.debuffs, curInstance, boss)
	optionDebuffs.args[tostring(spellId)]= nil	
end

-- Called from Grid2RaidDebuffs.lua when zone change and debuffs Autodetection is enabled
local function GetKnownDebuffs(curZoneId)
	wipe(known_debuffs)
	-- Add already known debuffs
	for moduleName in pairs(moduleList) do
		local zone = RDDB[moduleName][curZoneId] 
		if zone then
			for _,boss in pairs(zone) do
				for _,spell in ipairs(boss) do
					known_debuffs[spell] = true
				end	
			end
		end	
	end
	-- Add blacklisted debuffs
	for _,spellId in ipairs(black_debuffs) do
		known_debuffs[spellId] = true
	end	
	return known_debuffs
end

local function SetAutodetect(value)
	if value then
		local status = statuses[GSRD.db.profile.autodetect.status or 1] or statuses[1]
		GSRD:EnableAutodetect( status, GetKnownDebuffs )
	else
		GSRD:DisableAutodetect()
	end
	auto_enabled = value
end

local function RefreshAutodetect()
	if auto_enabled then
		SetAutodetect(false)
		SetAutodetect(true)
	end
end

local function OpenJournal(info)
	local EJ_ID = info.arg.EJ_ID
	if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
	local instanceID, encounterID, sectionID = EJ_HandleLinkPath(1, EJ_ID)
	local _,_,difficulty = GetInstanceInfo()
	if instanceID ~= EJ_GetCurrentInstance()  then
		difficulty = GSRD.db.profile.defaultEJ_difficulty or 14
	end
	if InterfaceOptionsFrame:IsShown() then
		InterfaceOptionsFrameOkay:Click()
		GameMenuButtonContinue:Click()
	end
	EncounterJournal_OpenJournal(difficulty, instanceID, encounterID, sectionID)
	if not EJ_InstanceIsRaid() then -- Fix for 5 man instances: 1=normal party/2=heroic party/8=challenge mode		
		EJ_SetDifficulty( (difficulty == 15 and 2) or (difficulty==16 and 8) or 1 )
	end
end

local function GetInstances()
	local values = {}
	if curModule and curModule~="" then
		local instances = RDDB[curModule]
		if instances then
			for mapid,_ in pairs(instances) do
				values[mapid] = GetMapNameByID(mapid)
			end
		end
	end
	return values
end

local function ChangeModuleInstance(module, instance)
	curModule = module
	curInstance = instance or ""
	optionInstances.values = GetInstances()
	MakeDebuffsOptions()
end	

local RegisterAutodetectedDebuffs
do
	-- bosses_localized[localized_encounter_name] = encounter_key = RDDB[module][mapId][encounter_key] = usually english encounter name  
	local bosses_localized
	-- bosses_encounters[encounterID] = encounter_key
	local bosses_encounters
	-- bosses_creatures[instanceID][creatureName] = { encounterID, encounterNameLocalized, encounterIndex }
	local bosses_creatures = {}
    -- When a debuff is autodetected, we have a localized boss name and maybe the encounter ID, and we want to know the encounter
	-- key in the RDDB database (to avoid duplicating bosses), the encounter key usually is the english encounter name, but this info is 
	-- not available in non-english clients. Using two aproaches, first trying to identify the bossKey using the encounter journal ID,
	-- and if not available, using a boss_localized>boss_english table, here we generate two hash tables for fast search the info.
	local function GenerateBossesLocalizationTable()
		if bosses_localized then return end
		bosses_localized, bosses_encounters = {}, {}
		for moduleName,module in pairs(RDDB) do
			if moduleName~="[Custom Debuffs]" then
				for _,zone in pairs(module) do
					for bossKey,boss in pairs(zone) do
						if boss.ejid and boss.ejid>0 then
							 local name_localized = EJ_GetEncounterInfo(boss.ejid)
							 if name_localized then 
								bosses_localized[name_localized] = bossKey 
								bosses_encounters[boss.ejid] = bossKey
							 end
						end
					end
				end
			end	
		end
	end
	-- Collecting all bosses from an Instance. This is a hackish way to identify a boss encounter knowing 
	-- a boss localized name (We want the Encounter Journal Identifier (ejid) because is locale independent)
	local function GetJournalInstanceCreatures(instanceID)
	   local creatures = bosses_creatures[instanceID]
	   if not creatures then
		   creatures = {}; bosses_creatures[instanceID] = creatures
		   if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
		   EJ_SelectInstance(instanceID)
		   local encounterIndex = 1
		   while true do
			  local encounterName, _, encounterID = EJ_GetEncounterInfoByIndex(encounterIndex, instanceID)
			  if not encounterID then break end
			  local creatureIndex = 1
			  while true do
				 local _, creatureName = EJ_GetCreatureInfo( creatureIndex, encounterID ) 
				 if not creatureName then break end
				 creatures[creatureName] = { encounterID, encounterName, encounterIndex }
				 creatureIndex = creatureIndex + 1
			  end    
			  encounterIndex = encounterIndex + 1        
		   end
		end 
		return creatures
	end
	-- instanceID = Encounter Journal instance ID / bossName = Localized boss name
	local function GetJournalEncounterInfo(instanceID, bossName)
		if instanceID and instanceID>0 and bossName then
			local encounter = GetJournalInstanceCreatures(instanceID)[bossName]
			if encounter then
				return encounter[1], encounter[2], encounter[3]
			end
		end	
	end
	RegisterAutodetectedDebuffs = function()
		local result
		-- Register new zones
		local new_zones = GSRD.db.profile.autodetect.zones
		if next(new_zones) then
			for zone in pairs(new_zones) do
				if not GSRD.db.profile.debuffs[zone] then
					GSRD.db.profile.debuffs[zone] = {}
					result = true
				end	
			end
			wipe(new_zones)
		end
		-- Register new debuffs
		local new_debuffs = GSRD.db.profile.autodetect.debuffs
		if next(new_debuffs) then 
			GenerateBossesLocalizationTable()
			for spellId,zoneboss in pairs(new_debuffs) do
				local zoneName, instanceID, bossName = strsplit("@", zoneboss)
				zoneName, instanceID = tonumber(zoneName), tonumber(instanceID)
				bossName = bossName~="" and bossName or nil
				if zoneName>0 then
					local encounterID, encounterName, encounterIndex = GetJournalEncounterInfo(instanceID, bossName)
					local bossKey = (encounterID and bosses_encounters[encounterID]) or (bossName and bosses_localized[bossName]) or encounterName or bossName or "Unknown"
					DbTreeSetValue( spellId, GSRD.db.profile.debuffs, zoneName, bossKey, '#')
					if not DbTreeGetValue(GSRD.db.profile.debuffs, zoneName, bossKey, "order") then
						DbTreeSetValue( encounterIndex or (bossKey ~= "Unknown" and 50 or 100), GSRD.db.profile.debuffs, zoneName, bossKey, "order" )
					end	
					if encounterID and (not DbTreeGetValue(GSRD.db.profile.debuffs, zoneName, bossKey, "ejid")) then
						DbTreeSetValue( encounterID, GSRD.db.profile.debuffs, zoneName, bossKey, "ejid" )
					end
					ClearOptionsCache( "[Custom Debuffs]", zoneName )
				end	
			end
			wipe(new_debuffs)
			result = true
		end	
		return result
	end
end

-- Trying to fix or delete instances in old database formats, now the 
-- instance keys must be integers, we don't allow strings.
local function FixWrongInstances()
	local saved = {}
	for mapid, data in pairs(GSRD.db.profile.debuffs) do
		if type(mapid)~="number" then
			if tonumber(mapid) then saved[tonumber(mapid)] = data end
			GSRD.db.profile.debuffs[mapid] = nil
		end
	end
	for k,v in pairs(saved) do
		GSRD.db.profile.debuffs[k] = v
	end
end

-- {{ Generate Raid debuffs Database Lua Code
local function GenerateZoneLuaCode(moduleName, zoneName)
	local spells, order = {}, {}
	local function CollectBossSpells(bossdata)
		if not bossdata then return end
		for index,spellId in ipairs(bossdata) do
			if not order[spellId] and (GetSpellInfo(spellId)) then
				local status = curDebuffs[spellId]
				spells[#spells+1] = spellId
				order[spellId] = status and (statuses[status]*100+curDebuffsOrder[spellId]) or  index * 10000
			end
		end
	end
	local function GenerateBossCode(bossName, bossdata)
		local lines = string.format('\t\t["%s"] = {\n',bossName)
		lines = lines .. string.format('\t\torder = %s, ejid = %s,\n', tonumber(bossdata.order) or "nil", tonumber(bossdata.ejid) or "nil")
		wipe(spells); wipe(order)
		CollectBossSpells(bossdata)
		CollectBossSpells(DbTreeGetValue(GSRD.db.profile.debuffs, zoneName, bossName))
		table.sort(spells, function(a,b) return order[a]<order[b] end)
		for _,spellId in ipairs(spells) do
			lines = lines .. string.format("\t\t%d, -- %s\n", spellId, GetSpellInfo(spellId) )
		end
		lines = lines .. "\t\t},\n"
		return lines, bossdata.order or 100
	end
	--
	local bosses, order = {}, {}
	for bossName,bossdata in pairs(RDDB[moduleName][zoneName]) do
		local code, index = GenerateBossCode(bossName,bossdata)
		bosses[#bosses+1], order[code] = code, index
	end
	if moduleName ~= "[Custom Debuffs]" then
		local zone = GSRD.db.profile.debuffs[zoneName]
		if zone then
			for bossName,bossdata in pairs(zone) do
				if not RDDB[moduleName][zoneName][bossName] then
					local code, index = GenerateBossCode(bossName,bossdata)
					bosses[#bosses+1], order[code] = code, index
				end	
			end
		end	
	end
	table.sort(bosses, function(a,b) return order[a]<order[b] end)
	--
	local lines = string.format("\t[%d] = { -- %s \n", zoneName, GetMapNameByID(zoneName) or "" )	
	lines = lines .. table.concat(bosses)
	lines = lines .. "\t},\n"
	return lines
end

local function GenerateModuleLuaCode(moduleName)
	local lines = string.format('local RDDB = Grid2Options:GetRaidDebuffsTable()\n\nRDDB["%s"] = {\n', moduleName ~= "[Custom Debuffs]" and moduleName or "WoW Raid Debuffs")
	for zoneName in pairs(RDDB[moduleName]) do
		lines = lines .. GenerateZoneLuaCode(moduleName, zoneName)
	end
	lines = lines ..  "}\n"
	return lines
end

local function GenerateLuaCode()
	local data = GenerateModuleLuaCode(curModule)
	local AceGUI = LibStub("AceGUI-3.0")
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("LUA CODE Export")
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); collectgarbage() end)
	frame:SetWidth(350)
	frame:SetHeight(150)
	local edit = AceGUI:Create("MultiLineEditBox")
	edit:SetFullWidth(true)
	edit:SetFullHeight(true)
	frame:AddChild(edit)
	edit:SetLabel("Press CTRL-C to copy data to Clipboard")
	edit:DisableButton(true)
	edit:SetText(data)
	edit.editBox:SetFocus()
	edit.editBox:HighlightText()
end
-- }}

local function MakeDebuffOptions(bossName, spellId, isCustom)
	local spellName,_, spellIcon = GetSpellInfo(spellId)
	local options= {
		spellname={
			type="description",
			order= 10,
			name= fmt ( "%s\n(%d)", spellName or "Unknow", spellId),
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
			get = function() return curDebuffs[spellId]~=nil end,
			set = function(_, v)    
				SetEnableDebuff(bossName, curDebuffs[spellId] or statuses[1], spellId, v)
			end,
		},	
		header3={
			type= "header",
			order= 140,
			name="",
		},
		assignedStatus = {	
			type = "select",
			order = 144,
			name = L["Assigned to"],
			-- desc = "",
			get = function () 
				return statuses[ curDebuffs[spellId] or statuses[1] ]
			end,
			set = function (_, v) 
				SetEnableDebuff(bossName, curDebuffs[spellId], spellId, false) 
				SetEnableDebuff(bossName, statuses[v]        , spellId, true)
			end,
			values = statusesList,
			hidden = function() return not curDebuffs[spellId] end,
		},
		idTracking={
			type="toggle",
			order = 145,
			name = L["Track by SpellId"],
			desc = L["Track by spellId instead of aura name"],
			get = function()
				local status,index = GetDebuffStatus(spellId)
				if status then 
					return status.dbx.debuffs[curInstance][index] < 0	
				end	
			end,
			set = function(_, v) 
				SetDebuffSpellIdTracking(spellId, v)
			end,
			hidden = function() return not curDebuffs[spellId] end,
		},					
		header4={
			type= "header",
			order= 147,
			name="",
			hidden = function() return not curDebuffs[spellId] end,
		},
		chatLink={
			type = "execute",
			order = 149,
			width = "full",			
			name = L["Link to Chat"],
			func = function() 
				local link = GetSpellLink(spellId)
				if link then
					local ChatBox = ChatEdit_ChooseBoxForSend()
					if not ChatBox:HasFocus() then
						ChatFrame_OpenChat(link)
					else
						ChatBox:Insert(link) 
					end
				end
			end,
		},
		createDebuff= {
			type = "execute",
			order = 150,
			width = "full",			
			name = L["Copy to Debuffs"],
			func = function() CreateStandardDebuff(bossName,spellId,spellName) end,
		}
	}
	if isCustom then
		options.moveDebuff= {
			type = "select",
			order = 156,
			width = "full",			
			name = L["Move To"],
			get = function() end,
			set = function(_,newName)
				if newName~=bossName then
					DeleteRaidDebuff(bossName, spellId, true)
					newSpellId = spellId
					CreateNewRaidDebuff(newName)
					ClearCacheExceptModule(curModule)
				end	
			end,
			values = function() return curBossesTrans end,
			hidden = function() return #curBossesList<=1 end,
		}
		options.removeDebuff= {
			type = "execute",
			order = 155,
			width = "full",
			name = L["Delete raid debuff"],
			func = function() 
				DeleteRaidDebuff(bossName, spellId) 
				if not RDDB[curModule][curInstance] then ChangeModuleInstance(curModule) end	
				ClearCacheExceptModule(curModule)
			end,
		}
	end
	return options
end

local function MakeDebuffGroup(bossName, spellId, order, isCustom)
	return {
		type = "group",
		name = FormatDebuffName(spellId),
		desc = fmt("     (%d)", spellId ),
		order = order,
		args = MakeDebuffOptions(bossName,spellId,isCustom)
	}
end

local function AddInstanceOptions(options)
	options.debuffsSep = {type = "header", order = 100, name = L["Debuffs"] }
	options.enableall={
		type ="execute",
		order= 105,
		width = "full",
		name = L["Enable All"],
		func= function() 
			EnableInstanceAllDebuffs(curModule,curInstance)
			LoadEnabledDebuffs()
			UpdateZoneSpells()
			RefreshDebuffsOptions()
		end
	}
	options.disableall={
		type ="execute",
		order= 110,
		width = "full",
		name = L["Disable All"],
		func= function() 
			DisableInstanceAllDebuffs(curInstance)
			ClearEnabledDebuffs()
			UpdateZoneSpells()
			RefreshDebuffsOptions()
		end
	}
	EJ_ID = GetBossTag( curBossesList[1], "ejid" ) or 0
	if EJ_ID>0 or curModule == "[Custom Debuffs]" then
		options.spacer = { type = "header", order = 1, name = L["Instance"] }
	end		
	if EJ_ID>0 then
		options.link = {
			type = "execute",
			order = 2,
			width = "full",
			name = L["Show in Encounter Journal"],
			func = OpenJournal,
			arg = { EJ_ID = EJ_ID },
		}
	end
	if curModule == "[Custom Debuffs]" then
		options.deleteInstance = {	
			type = "execute",
			order = 3,
			width = "full",
			name = L["Delete this Instance"],
			func = function()
					GSRD.db.profile.debuffs[curInstance] = nil
					ClearOptionsCache("[Custom Debuffs]",curInstance)
					DisableInstanceAllDebuffs(curInstance)
					RefreshAutodetect()
					ChangeModuleInstance(curModule)
			end,
			confirm = function() 
				local zone = GSRD.db.profile.debuffs[curInstance]
				return (zone and next(zone)) and L["This instance is not empty. Are you sure you want to remove it ?"] or true
			end
		}
	end
	options.newBossSep = {type = "header", order = 150, name = L["Bosses"] }
	options.newBoss = {
		type = "input",
		order = 155,
		width = "full",
		name = L["Add a New Boss"],
		desc = "",
		get = function() end,
		set = function(_, bossName)
			local bossId = tonumber(bossName)
			if bossId then bossName = EJ_GetEncounterInfo(bossId) end
			if bossName and bossName~="" and (not curBossesOrder[bossName]) then
				DbTreeSetValue({}, GSRD.db.profile.debuffs, curInstance, bossName)
				MakeDebuffsOptions(true)
				ClearCacheExceptModule(curModule)
			end
		end,
	}
end

local function AddBossOptions(options, bossName, isCustom)
	local order = curBossesOrder[bossName] * 1000
	local EJ_ID = GetBossTag(bossName,"ejid") or 0
	local EJ_ORDER = GetBossTag(bossName,"order") 
	local nameFull, nameLoc = FormatBossName( EJ_ID, EJ_ORDER, bossName, isCustom)
	options[bossName]= {
		type = "group",
		name =  nameFull,
		desc = string.format("    %d/%d", EJ_ID or 0, EJ_ORDER or 0),
		order = order,
		args= {
			debuffs = {type = "header", order = 50, name = nameLoc },
			name = {
				type = "input",
				order = 55,
				width = "full",
				name = L["New raid debuff"],
				desc = L["Type the SpellId of the new raid debuff"],
				get = function()  return newDebuffName end,
				set = function(_,v)	
					newSpellId = tonumber(v)
					newDebuffName= newSpellId and GetSpellInfo(newSpellId) or nil
					if not newDebuffName or newDebuffName=="" then newSpellId= nil end
				end,
			},
			exec = {
				type = "execute",
				order = 60,
				width = "full",				
				name = L["Create raid debuff"],
				func = function(info) 
					CreateNewRaidDebuff( bossName ) 
					ClearCacheExceptModule(curModule)
				end,
				disabled= function() return not newSpellId or optionDebuffs.args[tostring(newSpellId)] end
			},
		},
	}
	if EJ_ID>0 then
		local id, _, _, _, iconImage = EJ_GetCreatureInfo(1, EJ_ID)
		if id then
			options[bossName].args.bossImage = {
				type = "execute",
				width= "full",
				order = 10,
				name = "",
				image= iconImage,
				imageWidth = 150,
				imageHeight = 70,
				func =  OpenJournal,
				arg = { EJ_ID = EJ_ID },
			}
		end	
	end
	if isCustom then
		options[bossName].args.renameSep = {type = "header", order = 100, name = "" }
		if EJ_ID==0 then 	
			options[bossName].args.rename = {
				type = "input",
				order = 105,
				width = "full",
				name = L["Rename Boss"],
				desc = "",
				get = function()  end,
				set = function(_, newName)	
					if newName~="" and (not curBossesOrder[newName]) then
						local zone = GSRD.db.profile.debuffs[curInstance]
						if zone and zone[bossName] then
							local pivot = zone[bossName]
							zone[bossName] = nil
							zone[newName]  = pivot
						end	
						MakeDebuffsOptions(true)
					end
				end,
			}
			options[bossName].args.MoveTop = {
				type = "execute",
				order = 110,
				width = "full",
				name = L["Move to Top"],
				func = function(info) 
					local firstBoss = curBossesList[1]
					SetBossTag( bossName, "order", (GetBossTag(firstBoss, "order") or 0) - 1 )
					MakeDebuffsOptions(true)
					ClearCacheExceptModule(curModule)
				end,
				disabled = function() return curBossesOrder[bossName]<=1 end
			}
			options[bossName].args.MoveBottom = {
				type = "execute",
				order = 115,
				width = "full",
				name = L["Move to Bottom"],
				func = function(info) 
					local lastBoss = curBossesList[#curBossesList]
					SetBossTag( bossName, "order", (GetBossTag(lastBoss, "order") or 500) + 1 )
					MakeDebuffsOptions(true)
					ClearCacheExceptModule(curModule)
				end,
				disabled = function() return curBossesOrder[bossName]>=#curBossesList end
			}
		end	
		options[bossName].args.delete = {
			type = "execute",
			order = 120,
			width = "full",
			name = L["Delete Boss"],
			func = function(info)
				DbTreeSetValue(nil, GSRD.db.profile.debuffs, curInstance, bossName)
				MakeDebuffsOptions(true)
				ClearCacheExceptModule(curModule)
			end,
			disabled = function()
				local spells = DbTreeGetValue(GSRD.db.profile.debuffs, curInstance, bossName)
				return (spells and #spells>0)
			end
		}
	end	
end

-- Forward declared, dont add "local function"
function AddBossDebuffOptions( options, boss, spellId, isCustom, priority )
	local order = GetDebuffOrder(boss, spellId, isCustom, priority)
	options[tostring(spellId)] = MakeDebuffGroup(boss, spellId, order, isCustom)
end

local function AddBossDebuffsOptions( options, boss, debuffs, isCustom)
	if not debuffs then return end
	local index = 1
	while index<=#debuffs do
		local spellId = debuffs[index]
		if not options[tostring(spellId)] then
			AddBossDebuffOptions( options, boss, spellId, isCustom, index)
			index = index + 1
		elseif isCustom then
			-- Removing a duplicated debuff
			table.remove(debuffs, index) 
		else
			index = index + 1
		end		
	end
end

-- Forward declared, dont add "local function"
function MakeDebuffsOptions(discardCache)
	if tonumber(curInstance) then
		LoadBosses()
		LoadEnabledDebuffs()
		local options
		if not discardCache then options = GetOptionsFromCache(curModule,curInstance) end
		if not options then
			options = {}
			local debuffs = RDDB[curModule][curInstance]
			local custom  = GSRD.db.profile.debuffs[curInstance]
			local deletable = curModule == "[Custom Debuffs]"
			AddInstanceOptions(options)
			for boss in pairs(curBossesOrder) do
				AddBossOptions(options, boss, deletable or (not debuffs[boss]) )
				AddBossDebuffsOptions(options, boss, debuffs[boss], deletable)
				if custom and (not deletable) then
					AddBossDebuffsOptions(options, boss, custom[boss], true )
					if custom[boss] and #custom[boss]==0 then 
						custom[boss] = nil
						ClearOptionsCache("[Custom Debuffs]", curInstance)
					end
				end
			end
			SetOptionsToCache(curModule, curInstance, options)
			if not (deletable or (custom and next(custom))) then GSRD.db.profile.debuffs[curInstance] = nil end
		end
		optionDebuffs.name = GetMapNameByID(curInstance) or ""		
		optionDebuffs.args = options
	else
		optionDebuffs.name = ""
		optionDebuffs.args = {}
	end
end

local function MakeModulesListOptions(options)
	local modules = {}
	for name in pairs(RDDB) do
		modules[name] = L[name]
	end
	options.modules= {
		type = "multiselect",
		name = L["Enabled raid debuffs modules"],
		order = 150,
		width = "full",
		get= function(info,key)
			return (moduleList[key] ~= nil)
		end,
		set= function(_,key,value)
			EnableDisableModule(key,value)
		end,
		values = modules,
		disabled = function() return auto_enabled end
	}
end

local function MakeOneStatusStandardOptions(options, status, index)
	local statusOptions = {}
	options[status.name] = { 
		type  = "group", 
		order = index+10, 
		inline = true, 
		name  = "",
		args  = statusOptions,
	}
	Grid2Options:MakeStatusStandardOptions(status, statusOptions, { color1 = GetLocalizedStatusName(status.name), width = "full" } )
end

local function MakeStandardOptions(options)
	for index,status in ipairs(statuses) do
		MakeOneStatusStandardOptions( options, status, index )
	end
	options.add = {
		type = "execute",
		order = 50,
		width = "half",
		name = L["New"],
		desc = L["New Status"],
		func = function(info) 
			local name = fmt("raid-debuffs%d", #statuses+1)
			Grid2:DbSetValue( "statuses", name, {type = "raid-debuffs", debuffs={}, color1 = {r=1,g=.5,b=1,a=1}} )
			local status = Grid2.setupFunc["raid-debuffs"]( name, Grid2:DbGetValue("statuses", name) )
			CalculateAvailableStatuses()
			MakeOneStatusStandardOptions( options, status, #statuses )
		end,
		hidden = function() return #statuses>=10 end
	}
	options.del = {
		type = "execute",
		order = 51,
		width = "half",
		name = L["Delete"],
		desc = L["Delete Status"],
		func = function(info) 
			local status = statuses[#statuses]
			options[status.name] = nil
			Grid2:DbSetValue( "statuses", status.name, nil)
			Grid2:UnregisterStatus( status )
			CalculateAvailableStatuses()
		end,
		disabled = function()
			local status = statuses[#statuses]
			return status.enabled or next(status.dbx.debuffs)
		end,
		hidden = function() 
			return #statuses<=1  
		end,
	}
	options.header3 = { type = "header", order = 52, name = "" }
end

local function MakeAutodetectOptions(options)
	options.autoGroup = { type = "group", order = 149,	name = L["Debuffs Autodetection"], inline= true, args = {} }
	options = options.autoGroup.args
	options.autodetect = {
		type = "toggle",
		order = 1,
		name = L["Enable Autodetection"],
		desc = L["Enable Zones and Debuffs autodetection"],
		get = function() return auto_enabled end,
		set = function(_, v) SetAutodetect(v) end,
	}	
	options.statusauto = {	
		type = "select",
		order = 2,
		name = L["Assigned to"],
		desc = L["Assign autodetected raid debuffs to the specified status"],
		get = function () return GSRD.db.profile.autodetect.status or 1	end,
		set = function (_, v) 
			local status = statuses[v]
			if status then
				GSRD.db.profile.autodetect.status = v>1 and v or nil
				GSRD:EnableAutodetect( status )
			end
		end,
		values = statusesList,
		disabled = function() return auto_enabled end
	}
end

local function MakeDefaultDifficultyEJ_LinkOption(options)
	options.difficulty = {
		type = "select",
		order = 200,
		name = L["Encounter Journal difficulty"],
		desc = "Default difficulty for Encounter Journal links",
		get = function () return GSRD.db.profile.defaultEJ_difficulty or 14 end,
		set = function (_, v) 
			GSRD.db.profile.defaultEJ_difficulty = v
		end,
		values = {
			[14] = PLAYER_DIFFICULTY1, -- Normal
			[15] = PLAYER_DIFFICULTY2, -- Heroic
			[16] = PLAYER_DIFFICULTY6, -- Mythic
			[17] = PLAYER_DIFFICULTY3  -- LFR
		},
	}
end

local function MakeAdvancedOptions(self)
	local options = {}
	FixWrongInstances()
	ResetAdvancedOptions()
	optionModules = {
		type = "select",
		order = 10,
		name = L["Select module"],
		desc = "",
		get = function ()
			if curModule=="" then
				local curZone, curZoneModule = GSRD:GetCurrentZone()
				local lastInst, lastInstModule = GSRD.db.profile.lastSelectedInstance
				for module in next, moduleList do
					if RDDB[module][curZone] then
						curZoneModule = module
					elseif RDDB[module][lastInst] then
						lastInstModule = module
					end
				end
				if curZoneModule then
					curModule = curZoneModule
					curInstance = curZone
				elseif lastInstModule then
					curModule = lastInstModule
					curInstance = lastInst
				else
					curModule = next(moduleList) or ""
					curInstance = ""
				end	
				ChangeModuleInstance( curModule,curInstance )
			end
			return curModule
		end,
		set = function (info, v) ChangeModuleInstance(v) end,
		values = moduleList,
	}
	optionInstances= {
		type = "select",
		order = 20,
		name = L["Select instance"],
		desc = "",
		get = function () return curInstance end,
		set = function (_, v)
			curInstance = v
			MakeDebuffsOptions()
			GSRD.db.profile.lastSelectedInstance = v
		end,
		values = {},
	}
	optionDebuffs = {
		type ="group",
		name ="",
		order = 30,
		childGroups = "tree",
		args = {},
	}
	options.RefreshInstances= {
		type = "execute",
		order = 31,
		name = L["Refresh"],
		width = "half",
		func = function() 
			RegisterAutodetectedDebuffs()
			optionInstances.values = GetInstances()
			if curInstance and curInstance~="" then
				MakeDebuffsOptions(true)
			end
		end,
		hidden = function() 
			RegisterAutodetectedDebuffs()
			return not auto_enabled
		end
	}
	options.GenerateLuaCode = {
		type = "execute",
		order = 35,
		width = "half",
		name = L["Gen Lua"],
		desc = L["Generate LUA Code for the current Module"],
		func = GenerateLuaCode,
		hidden = function() return not GSRD.debugging end
	}
	options.modules  = optionModules
	options.instances= optionInstances
	options.debuffs  = optionDebuffs
	return options
end

local function MakeGeneralOptions(self)
	local options = {}
	CalculateAvailableStatuses()
	self:MakeStatusTitleOptions( statuses[1], options)
	MakeStandardOptions(options)
	MakeModulesListOptions(options)
	MakeAutodetectOptions(options)
	MakeDefaultDifficultyEJ_LinkOption(options)
	return options
end

-- Notify Grid2Options howto create the options for our status
Grid2Options:RegisterStatusOptions("raid-debuffs", "debuff", function(self, status, options)
	options.general= {
			type = "group",
			name = L["General Settings"],
			order = 20,
			args = MakeGeneralOptions(self),
		}
	options.advanced= {
			type = "group",
			name = L["Debuff Configuration"],
			order = 10,
			args = MakeAdvancedOptions(self),
		}
	RegisterAutodetectedDebuffs()
end, {
	hideTitle    = true,
	childGroups  = "tab",
	groupOrder   = 5,
	masterStatus = "raid-debuffs", 
	titleIcon    = "Interface\\Icons\\Spell_Shadow_Skull", -- DemonicEmpathy",
})
