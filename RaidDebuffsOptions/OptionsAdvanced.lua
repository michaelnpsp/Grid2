-- Raid Debuffs Management options
local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local GSRD = Grid2:GetModule("Grid2RaidDebuffs")
local RDO = Grid2Options.RDO
local RDDB = RDO.RDDB
-- raid-debuffs statuses
local statuses         = RDO.statuses
local statusesIndexes  = RDO.statusesIndexes
local statusesNames    = RDO.statusesNames
-- bosses in visible instance
local bosses        = {} -- bosses[index]          = bossKey
local bossesIndexes = {} -- bossesIndexes[bossKey] = index in bosses or bossesNames tables
local bossesNames   = {} -- bosses[index]          = boss localized name
-- enabled debuffs in visible instance (assigned to some status)
local debuffsStatuses = {} -- debuffsStatuses[spellID] = status
local debuffsIndexes  = {} -- debuffsIndexes[spellID]  = index  <=> status.dbx.debuffs[curInstance][index] == spellId
-- selected module & instance
local visibleModule   = nil
local visibleInstance = nil
-- make some tables accesible for other modules
RDO.OPTIONS_ADVANCED = {} -- Options Root
RDO.OPTIONS_ITEMS    = {}
RDO.OPTIONS_INSTANCE = {}
RDO.OPTIONS_BOSS     = {}
RDO.OPTIONS_DEBUFF   = {}
RDO.debuffsStatuses  = debuffsStatuses
RDO.debuffsIndexes   = debuffsIndexes
-- Encounter Journal functions
local EJ_GetInstanceInfo  = EJ_GetInstanceInfo  or Grid2.Dummy
local EJ_GetEncounterInfo = EJ_GetEncounterInfo or Grid2.Dummy
local EJ_GetCreatureInfo  = EJ_GetCreatureInfo  or Grid2.Dummy

--============================================================
-- Misc utils functions
--============================================================

local DbGetValue      = RDO.DbGetValue
local DbSetValue      = RDO.DbSetValue
local DbDelTableValue = RDO.DbDelTableValue
local DbAddTableValue = RDO.DbAddTableValue

local function GetBossTag(bossKey, field)
	return DbGetValue(RDDB, visibleModule, visibleInstance, bossKey, field) or
		   DbGetValue(RDO.db.profile.debuffs, visibleInstance, bossKey, field)
end

local function SetBossTag(bossKey, field, value)
	DbSetValue(value, RDO.db.profile.debuffs, visibleInstance, bossKey, field)
end

local function GetInstanceName(module, instance)
	if module and instance then
		local info = RDDB[module][instance][1]
		local name = info and (info.id and EJ_GetInstanceInfo(info.id) or info.name) or EJ_GetInstanceInfo(instance) or string.format( "unknown(%d)", instance )
		local key  = string.format( '%s%s<<%d>>', info and info.raid and "R" or "G", name, instance )
		return name, key
	end
	return ""
end

--=================================================================
-- Options interface management
--=================================================================

local function LoadEnabledDebuffs()
	wipe(debuffsStatuses)
	wipe(debuffsIndexes)
	if visibleInstance then
		for _,status in ipairs(statuses) do
			local dbx = status.dbx.debuffs[visibleInstance]
			if dbx then
				for index,value in ipairs(dbx) do
					local spellId = math.abs(value)
					debuffsStatuses[ spellId ] = status
					debuffsIndexes[ spellId ] = index
				end
			end
		end
	end
end

local LoadModuleInstance
do
	local function LoadBosses()
		wipe(bosses)
		wipe(bossesNames)
		wipe(bossesIndexes)
		-- join bosses tables with different names but same ejid
		local function FixCustomBossesKeys( refZone, zoneToFix )
			if not zoneToFix then return end
			for keyRef,dataRef in pairs(refZone) do
				if dataRef.ejid and dataRef.ejid~=0 then
					for key,data in pairs(zoneToFix) do
						if data.ejid==dataRef.ejid and key~=keyRef then
							if GSRD.debugging then GSRD:Debug("Fixing Duplicated Boss: %s => %s, ejid: [%d/%s], debuffs count: [%d]", key, keyRef, dataRef.ejid, dataRef.name or "nil", #data); end
							local dataFixed = zoneToFix[keyRef] or { order = dataRef.order, ejid = dataRef.ejid }
							for i,spell in ipairs(data) do table.insert(dataFixed, spell); end
							zoneToFix[keyRef], zoneToFix[key] = dataFixed, nil
							break
						end
					end
				end
			end
		end
		local function Load(db)
			if db then
				for boss in pairs(db) do
					if not tonumber(boss) and not bossesIndexes[boss] then
						bossesIndexes[boss] = GetBossTag(boss, "order") or 100
						bosses[#bosses+1] = boss
					end
				end
			end
		end
		Load( RDDB[visibleModule][visibleInstance] )
		if visibleModule ~= "[Custom Debuffs]" then
			FixCustomBossesKeys( RDDB[visibleModule][visibleInstance], RDO.db.profile.debuffs[visibleInstance])
			Load( RDO.db.profile.debuffs[visibleInstance] )
		end
		table.sort( bosses, function(a,b) return bossesIndexes[a]<bossesIndexes[b] end )
		for i,boss in ipairs(bosses) do
			local ejid = GetBossTag(boss, "ejid") or 0
			bossesIndexes[boss] = i
			bossesNames[boss] = ejid>0 and EJ_GetEncounterInfo(ejid) or boss
		end
	end
	LoadModuleInstance = function(force)
		local module = RDO.db.profile.lastSelectedModule
		module = module and RDO.db.profile.enabledModules[module] and module or "[Custom Debuffs]"
		local instance = RDO.db.profile.lastSelectedInstance
		if instance and not RDDB[module][instance] then
			instance, RDO.db.profile.lastSelectedInstance = nil, nil
		end
		if visibleModule ~= module or visibleInstance ~= instance or force then
			visibleModule,   RDO.db.profile.lastSelectedModule   = module, module
			visibleInstance, RDO.db.profile.lastSelectedInstance = instance, instance
			LoadBosses()
			LoadEnabledDebuffs()
		end
	end
end

local ICON_SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local function FormatBossName(  ejid, order, bossName, isCustom)
	local mask   = isCustom and "|T%s:0|t|cFFff8080%s%s|r" or "|T%s:0|t|cFFff4040%s%s|r"
	local name   = ejid>0 and EJ_GetEncounterInfo(ejid) or bossesNames[bossName] or bossName
	local prefix = (not isCustom) and order and order<30 and order..") " or ""
	return string.format( mask, ICON_SKULL, prefix, name ), name
end

local ICON_CHECKED, ICON_UNCHECKED = READY_CHECK_READY_TEXTURE, READY_CHECK_NOT_READY_TEXTURE
local function FormatDebuffName(spellId, isCustom)
	local mask, icon, suffix
	local status = debuffsStatuses[spellId]
	if status then
		mask   = "  |T%s:0|t%s%s"
		icon   = ICON_CHECKED
		suffix = statusesIndexes[status]>1 and string.format("(%d)",statusesIndexes[status]) or ""
	else
		mask   = "  |T%s:0|t|cFFb0b0b0%s|r%s"
		icon   = ICON_UNCHECKED
		suffix = ""
	end
	return string.format(mask, icon, GetSpellInfo(spellId) or spellId, suffix)
end

local function GetDebuffOrder(boss, spellId, isCustom, priority)
	local status = debuffsStatuses[spellId]
	if status then
		return bossesIndexes[boss] * 1000 + statusesIndexes[status]*100 + debuffsIndexes[spellId]
	else
		return bossesIndexes[boss] * 1000 + (isCustom and 750 or 600) + (priority or 200)
	end
end

local function RefreshDebuffItem(spellId)
	spellId = tonumber(spellId)
	if spellId then
		local option = RDO.OPTIONS_ITEMS[tostring(spellId)]
		if option then
			option.name  = FormatDebuffName(spellId, option.handler.isCustom)
			option.order = GetDebuffOrder(option.handler.bossKey, spellId)
		end
	end
end

local function RefreshDebuffsItemsNames()
	for key,option in pairs(RDO.OPTIONS_ITEMS) do
		local spellId = tonumber(key)
		if spellId then
			option.name = FormatDebuffName(spellId, option.handler.isCustom)
		end
	end
end

local function MakeBossDebuffOptions( boss, spellId, isCustom, priority )
	local order = GetDebuffOrder( boss, spellId, isCustom, priority)
	RDO.OPTIONS_ITEMS[tostring(spellId)] = {
		type = "group",
		name = FormatDebuffName(spellId, isCustom),
		desc = string.format("     (%d)", spellId ),
		order = order,
		args = RDO.OPTIONS_DEBUFF,
		handler = { bossKey = boss, spellId = spellId, isCustom = isCustom },
	}
end

local function MakeBossDebuffsOptions( boss, debuffs, isCustom )
	if not debuffs then return end
	local options = RDO.OPTIONS_ITEMS
	local index = 1
	while index<=#debuffs do
		local spellId = debuffs[index]
		if not options[tostring(spellId)] then
			MakeBossDebuffOptions( boss, spellId, isCustom, index)
			index = index + 1
		elseif isCustom then
			-- Removing a duplicated debuff
			table.remove(debuffs, index)
		else
			index = index + 1
		end
	end
end

local function MakeRaidDebuffsOptions(forceReloadData)
	local first_ejid
	LoadModuleInstance(forceReloadData)
	wipe(RDO.OPTIONS_ITEMS)
	if tonumber(visibleInstance) then
		local module    = visibleModule
		local instance  = visibleInstance
		local options   = RDO.OPTIONS_ITEMS
		local debuffs   = RDDB[module][instance]
		local custom    = RDO.db.profile.debuffs[instance]
		local deletable = module == "[Custom Debuffs]"
		for k,v in pairs(RDO.OPTIONS_INSTANCE) do
			RDO.OPTIONS_ITEMS[k] = v
		end
		for bossKey,bossIndex in pairs(bossesIndexes) do
			local order = bossIndex * 1000
			local EJ_ID = GetBossTag(bossKey,"ejid") or 0
			local EJ_ORDER = GetBossTag(bossKey,"order")
			local isCustom = deletable or (not debuffs[bossKey])
			local nameFull, nameLoc = FormatBossName(  EJ_ID, EJ_ORDER, bossKey, isCustom)
			options[bossKey] = {
				type = "group",
				name = nameFull,
				desc = string.format("    %d/%d", EJ_ID or 0, EJ_ORDER or 0),
				order = order,
				args = RDO.OPTIONS_BOSS,
				handler = { bossKey = bossKey, bossName = nameLoc, ejid= EJ_ID, isCustom = isCustom },
			}
			MakeBossDebuffsOptions(bossKey, debuffs[bossKey], deletable)
			if custom and (not deletable) then
				MakeBossDebuffsOptions(bossKey, custom[bossKey], true )
				if custom[boss] and #custom[boss]==0 then
					custom[boss] = nil
				end
			end
			if EJ_ID>0 and (not first_ejid) then
				first_ejid = EJ_ID
			end
		end
		if not (deletable or (custom and next(custom))) then RDO.db.profile.debuffs[instance] = nil end
	end
	--
	RDO.OPTIONS_ADVANCED.instance.handler.ejid = first_ejid
end

function RDO:RefreshAdvancedOptions()
	MakeRaidDebuffsOptions(true)
end

function RDO:InitAdvancedOptions()
	RDDB["[Custom Debuffs]"] = RDO.db.profile.debuffs
	self:RefreshAdvancedOptions()
end

--=================================================================
-- User Actions
--=================================================================

local function OpenJournal(info)
	if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
	local difficulty
	local instanceID = EJ_HandleLinkPath(1, info.handler.ejid)
	if instanceID ==  EJ_GetInstanceForMap( C_Map.GetBestMapForUnit("player") ) then
		difficulty = select(3,GetInstanceInfo())
	else
		difficulty = RDO.db.profile.defaultEJ_difficulty or 14
	end
	if InterfaceOptionsFrame:IsShown() then
		InterfaceOptionsFrameOkay:Click()
		GameMenuButtonContinue:Click()
	end
	ShowUIPanel(EncounterJournal)
	EJ_ContentTab_Select(EncounterJournal.instanceSelect.dungeonsTab.id)
	EncounterJournal_DisplayInstance(instanceID)
	EncounterJournal.lastInstance = instanceID
	if not EJ_IsValidInstanceDifficulty(difficulty) then
		difficulty = (difficulty==14 and 1) or (difficulty==15 and 2) or (difficulty==16 and 23) or (difficulty==17 and 7) or 0
		if not EJ_IsValidInstanceDifficulty(difficulty) then
			return
		end
	end
	EJ_SetDifficulty(difficulty)
	EncounterJournal.lastDifficulty = difficulty
end

local function StatusEnableDebuff(status, spellId)
	if status then
		debuffsStatuses[spellId] = status
		debuffsIndexes[spellId] = DbAddTableValue(spellId, status.dbx.debuffs, visibleInstance)
		RDO:UpdateZoneSpells(visibleInstance)
		RefreshDebuffItem(spellId)
	end
end

local function StatusDisableDebuff(spellId)
	local status = debuffsStatuses[spellId]
	if status then
		local index = debuffsIndexes[spellId]
		DbDelTableValue( spellId, status.dbx.debuffs, visibleInstance)
		debuffsStatuses[spellId] = nil
		debuffsIndexes[spellId] = nil
		for k,v in pairs(debuffsStatuses) do
			if status==v and debuffsIndexes[k]>index then
				debuffsIndexes[k] = debuffsIndexes[k] - 1
				RefreshDebuffItem(k)
			end
		end
		RDO:UpdateZoneSpells(visibleInstance)
		RefreshDebuffItem(spellId)
	end
end

local function StatusMoveDebuff(spellId1, up)
	local spellId2, order1, order2
	local order = RDO.OPTIONS_ITEMS[tostring(spellId1)].order
	local group = math.floor(order/100)
	if up then
		order1,order2 = 0,order
	else
		order1,order2 = order,10000
	end
	for k,option in pairs(RDO.OPTIONS_ITEMS) do
		if option.order>=1000 and option.handler.spellId and option.order>order1 and option.order<order2 and group == math.floor(option.order/100) then
			if up then
				order1 = option.order
			else
				order2 = option.order
			end
			spellId2 = option.handler.spellId
		end
	end
	if spellId2 and spellId1~=spellId2 then
		local status  = debuffsStatuses[spellId1]
		local debuffs = status.dbx.debuffs[visibleInstance]
		local index1  = debuffsIndexes[spellId1]
		local index2  = debuffsIndexes[spellId2]
		debuffs[index1] = spellId2
		debuffs[index2] = spellId1
		debuffsIndexes[spellId1] = index2
		debuffsIndexes[spellId2] = index1
		RefreshDebuffItem(spellId1)
		RefreshDebuffItem(spellId2)
		return true
	end
end

--============================================================
-- Main Options
--============================================================
do
	local options = RDO.OPTIONS_ADVANCED

	do
		local list = {}
		options.modules = {
			type = "select",
			order = 10,
			name = L["Select module"],
			desc = "",
			get = function ()
				return RDO.db.profile.lastSelectedModule
			end,
			set = function (info, v)
				RDO.db.profile.lastSelectedModule = v
				RDO.db.profile.lastSelectedInstance = nil
				MakeRaidDebuffsOptions()
			end,
			values = function()
				wipe(list)
				local enabledModules = RDO.db.profile.enabledModules or {}
				for name in pairs(enabledModules) do
					if RDDB[name] then
						list[name] = L[name]
					end
				end
				list["[Custom Debuffs]"] = L["[Custom Debuffs]"]
				return list
			end,
		}
	end

	do
		local list = {}
		options.instances = {
			type = "select",
			order = 20,
			name = L["Select instance"],
			desc = "",
			get = function()
				return select(2,GetInstanceName(RDO.db.profile.lastSelectedModule, RDO.db.profile.lastSelectedInstance))
			end,
			set = function(_,instance)
				RDO.db.profile.lastSelectedInstance = tonumber( strmatch(instance, "<<(.+)>>$") or instance )
				MakeRaidDebuffsOptions()
			end,
			values = function()
				wipe(list)
				local module = RDO.db.profile.lastSelectedModule
				if module and RDDB[module] then
					for instance in pairs(RDDB[module]) do
						local name, key = GetInstanceName(module, instance)
						list[key] = name
					end
				end
				return list
			end,
		}
	end

	options.refresh= {
		type = "execute",
		order = 22,
		name = L["Refresh"],
		width = "half",
		func = function()
			MakeRaidDebuffsOptions(true)
		end,
		hidden = function() return not RDO.auto_enabled	end,
	}

	options.develop = {
		type = "select",
		order = 23,
		width = "half",
		name = L["Develop"],
		desc = "Develop&Debug options:\ngen lua: Generate LUA Code for the current Module\n5man: Extract Encounter Journal 5man instances/bosses\nraids: Extract Encounter Journal raids/bosses",
		get = function() end,
		set = function(_,v)
			local lines
			if v==1 then
				lines = RDO:GenerateModuleLuaCode(visibleModule)
			elseif v==2 then
				lines = RDO:GenerateEncounterJournalData(false)
			elseif v==3 then
				lines = RDO:GenerateEncounterJournalData(true)
			end
			RDO:ExportData(lines)
		end,
		values = { "gen lua", "5man", "raids" },
		hidden = function() return not GSRD.debugging end,
	}

	options.instance = {
		type = "group",
		name = function() return GetInstanceName(visibleModule,visibleInstance) end,
		order = 35,
		childGroups = "tree",
		args = RDO.OPTIONS_ITEMS, -- Here Instance options and Bosses/Debuffs items are injected
		handler = {},
	}
end
--============================================================
-- Instance options
--============================================================
do
	local options = RDO.OPTIONS_INSTANCE

	options.spacer = {
		type = "header",
		order = 10,
		name = function() return GetInstanceName(visibleModule,visibleInstance) end,
		hidden = function(info)
			return (not info.handler.ejid) and visibleModule~="[Custom Debuffs]"
		end
	}

	if not isClassic then
		options.link = {
			type = "execute",
			order = 20,
			width = "full",
			name = L["Show in Encounter Journal"],
			func = OpenJournal,
			hidden = function(info) return not info.handler.ejid end
		}
	end

	options.delete = {
		type = "execute",
		order = 30,
		width = "full",
		name = L["Delete this Instance"],
		func = function()
				RDO.db.profile.debuffs[visibleInstance] = nil
				RDO:DisableInstanceAllDebuffs(visibleInstance)
				RDO:RefreshAutodetect()
				MakeRaidDebuffsOptions(true)
		end,
		confirm = function()
			local zone = RDO.db.profile.debuffs[visibleInstance or ""]
			return (zone and next(zone)) and L["This instance is not empty. Are you sure you want to remove it ?"] or true
		end,
		hidden = function(info) return visibleModule ~= "[Custom Debuffs]" end
	}

	options.separatorDebuffs = {
		type = "header",
		order = 40,
		name = L["Debuffs"] ,
	}

	options.enableall = {
		type ="execute",
		order= 50,
		width = "full",
		name = L["Enable All"],
		func= function()
			RDO:EnableInstanceAllDebuffs(visibleModule,visibleInstance)
			LoadEnabledDebuffs()
			RefreshDebuffsItemsNames()
		end
	}

	options.disableall={
		type ="execute",
		order= 60,
		width = "full",
		name = L["Disable All"],
		func= function()
			RDO:DisableInstanceAllDebuffs(visibleInstance)
			LoadEnabledDebuffs()
			RefreshDebuffsItemsNames()
		end
	}

	options.separatorBoss = {
		type = "header",
		order = 70,
		name = L["Bosses"]
	}

	options.createBoss = {
		type = "input",
		order = 80,
		width = "full",
		name = L["Add a New Boss"],
		desc = "",
		get = function() end,
		set = function(_, bossName)
			local bossId = tonumber(bossName)
			if bossId then bossName = EJ_GetEncounterInfo(bossId) end
			if bossName and bossName~="" and (not bossesIndexes[bossName]) then
				DbSetValue({}, RDO.db.profile.debuffs, visibleInstance, bossName)
				if bossId then
					SetBossTag(bossName, "ejid", bossId)
				end
				MakeRaidDebuffsOptions(true)
			end
		end,
	}
end
--============================================================
-- Boss options
--============================================================
do
	local options = RDO.OPTIONS_BOSS

	options.bossImage = {
		type = "execute",
		width= "full",
		order = 10,
		name = "",
		image = function(info) return select(5,EJ_GetCreatureInfo(1, info.handler.ejid)), 150, 70 end,
		func =  function(info) OpenJournal(info) end,
		hidden = function(info) return not (info.handler.ejid and info.handler.ejid>0) end,
	}

	options.bossName = {
		type = "header",
		order = 50,
		name = function(info) return info.handler.bossName end
	}

	do
		local newSpellId
		options.newDebuffName = {
			type = "input",
			order = 55,
			width = "full",
			name = L["New raid debuff"],
			desc = L["Type the SpellId of the new raid debuff"],
			get = function()
				return newSpellId and GetSpellInfo(newSpellId) or ""
			end,
			set = function(_,v)
				newSpellId = tonumber(v)
				local name = newSpellId and GetSpellInfo(newSpellId) or nil
				if (not name) or name=="" then
					newSpellId= nil
				end
			end,
		}
		options.newDebuffExec = {
			type = "execute",
			order = 60,
			width = "full",
			name = L["Create raid debuff"],
			func = function(info)
				if newSpellId and GetSpellInfo(newSpellId) then
					local bossKey = info.handler.bossKey
					local priority = DbAddTableValue( newSpellId, RDO.db.profile.debuffs, visibleInstance, bossKey)
					MakeBossDebuffOptions( bossKey, newSpellId, true, priority)
					if visibleModule~="[Custom Debuffs]" then
						SetBossTag( bossKey, "ejid",  GetBossTag(bossKey,"ejid") )
						SetBossTag( bossKey, "order", GetBossTag(bossKey,"order") )
					end
				end
				newSpellId = nil
			end,
			disabled= function() return (not newSpellId) or RDO.OPTIONS_ITEMS[tostring(newSpellId)] end
		}
	end

	options.separator = {type = "header", order = 100, name = "", hidden = function(info) return not info.handler.isCustom end }

	options.rename = {
		type = "input",
		order = 105,
		width = "full",
		name = L["Rename Boss"],
		desc = "",
		get = function()  end,
		set = function(info, newName)
			local bossKey = info.handler.bossKey
			if newName~="" and (not bossesIndexes[newName]) then
				local zone = RDO.db.profile.debuffs[visibleInstance]
				if zone and zone[bossKey] then
					local pivot = zone[bossKey]
					zone[bossKey] = nil
					zone[newName]  = pivot
					MakeRaidDebuffsOptions(true)
				end
			end
		end,
		hidden = function(info) return (not info.handler.isCustom) or info.handler.ejid~=0 end,
	}

	options.moveTop = {
		type = "execute",
		order = 110,
		width = "full",
		name = L["Move to Top"],
		func = function(info)
			local firstBoss = bosses[1]
			SetBossTag( info.handler.bossKey, "order", (GetBossTag(firstBoss, "order") or 0) - 1 )
			MakeRaidDebuffsOptions(true)
		end,
		hidden = function(info) return (not info.handler.isCustom) or info.handler.ejid>0 end,
		disabled = function(info) return bossesIndexes[info.handler.bossKey]<=1 end
	}

	options.moveBottom = {
		type = "execute",
		order = 115,
		width = "full",
		name = L["Move to Bottom"],
		func = function(info)
			local lastBoss = bosses[#bosses]
			SetBossTag( info.handler.bossKey, "order", (GetBossTag(lastBoss, "order") or 500) + 1 )
			MakeRaidDebuffsOptions(true)
		end,
		hidden = function(info) return (not info.handler.isCustom) or info.handler.ejid>0 end,
		disabled = function(info) return bossesIndexes[info.handler.bossKey]>=#bosses end
	}

	options.delete = {
		type = "execute",
		order = 120,
		width = "full",
		name = L["Delete Boss"],
		func = function(info)
			DbSetValue(nil, RDO.db.profile.debuffs, visibleInstance, info.handler.bossKey)
			MakeRaidDebuffsOptions(true)
		end,
		disabled = function(info)
			local spells = DbGetValue(RDO.db.profile.debuffs, visibleInstance, info.handler.bossKey)
			return (spells and #spells>0)
		end,
		hidden = function(info) return not info.handler.isCustom end
	}
end
--============================================================
-- Debuff options
--============================================================
do
	local options = RDO.OPTIONS_DEBUFF

	options.spellname = {
		type = "description",
		order= 10,
		name = function(info)
			return string.format ( "%s\n(%d)", (GetSpellInfo(info.handler.spellId)) or "Unknow", info.handler.spellId )
		end,
		fontSize= "large",
		image = function(info)
			return select(3, GetSpellInfo(info.handler.spellId)), 34, 34
		end
	}

	options.header1= { type= "header", order= 12, name="", }

	do
		local lines = {}
		options.description= {
			type="description",
			order= 50,
			fontSize= "small",
			name = function(info)
				wipe(lines)
				local spellId = info.handler.spellId
				local tipDebuff = Grid2Options.Tooltip
				tipDebuff:ClearLines()
				local name = GetSpellInfo(spellId)
				if not name then return "" end --invalid spellIds break the tooltip
				tipDebuff:SetHyperlink("spell:"..spellId)
				for i=2, min(5,tipDebuff:NumLines()) do
					lines[i-1]= tipDebuff[i]:GetText()
				end
				return table.concat(lines,"\n")
			end,
		}
	end

	options.header2 ={ type= "header", order= 40, name="", }

	options.enableSpell = {
		type="toggle",
		order = 30,
		name = L["Enabled"],
		get = function(info) return debuffsStatuses[info.handler.spellId]~=nil end,
		set = function(info, v)
			local spellId = info.handler.spellId
			if v then
				StatusEnableDebuff(debuffsStatuses[spellId] or statuses[1], spellId)
			else
				StatusDisableDebuff(spellId)
			end
		end,
	}

	options.header3 = { type= "header", order= 140, name="" }

	options.assignedStatus = {
		type = "select",
		order = 144,
		name = L["Assigned to"],
		get = function (info)
			return statusesIndexes[ debuffsStatuses[info.handler.spellId] or statuses[1] ]
		end,
		set = function (info, v)
			StatusDisableDebuff( info.handler.spellId )
			StatusEnableDebuff( statuses[v], info.handler.spellId )
		end,
		values = statusesNames,
		hidden = function(info) return not debuffsStatuses[info.handler.spellId] end,
	}

	options.idTracking = {
		type="toggle",
		order = 145,
		name = L["Track by SpellId"],
		desc = L["Track by spellId instead of aura name"],
		get = function(info)
			local spellId = info.handler.spellId
			local status = debuffsStatuses[spellId]
			if status then
				local index = debuffsIndexes[spellId]
				return status.dbx.debuffs[visibleInstance][index] < 0
			end
		end,
		set = function(info, value)
			local spellId = info.handler.spellId
			local spellName = GetSpellInfo(spellId)
			for spell,status in pairs(debuffsStatuses) do
				if spellName == GetSpellInfo(spell) then
					local index = debuffsIndexes[spell]
					status.dbx.debuffs[visibleInstance][index] = value and -spell or spell
				end
			end
			RDO:UpdateZoneSpells(visibleInstance)
		end,
		hidden = function(info) return not debuffsStatuses[info.handler.spellId] end,
	}

	options.header4={
		type= "header",
		order= 146,
		name="",
		hidden = function(info) return not debuffsStatuses[info.handler.spellId] end,
	}

	options.moveUp = {
		type = "execute",
		order = 147,
		width = "full",
		name = L["Move Up"],
		desc = L["Move debuff higher in the priority list."],
		func = function(info)
			if not StatusMoveDebuff( info.handler.spellId, true) then
				Grid2Options:MessageDialog(L["This debuff is already at the top of the list."])
			end
		end,
		hidden = function(info)
			return not debuffsStatuses[info.handler.spellId]
		end,
	}

	options.moveDn = {
		type = "execute",
		order = 147.5,
		width = "full",
		name = L["Move Down"],
		desc = L["Move debuff lower in the priority list."],
		func = function(info)
			if not StatusMoveDebuff( info.handler.spellId, false) then
				Grid2Options:MessageDialog(L["This debuff is already at the bottom of the list."])
			end
		end,
		hidden = function(info)
			return not debuffsStatuses[info.handler.spellId]
		end,
	}

	options.header5={
		type= "header",
		order= 148,
		name="",
		hidden = function(info) return not debuffsStatuses[info.handler.spellId] end,
	}

	options.chatLink = {
		type = "execute",
		order = 149,
		width = "full",
		name = L["Link to Chat"],
		func = function(info)
			local link = GetSpellLink(info.handler.spellId)
			if link then
				local ChatBox = ChatEdit_ChooseBoxForSend()
				if not ChatBox:HasFocus() then
					ChatFrame_OpenChat(link)
				else
					ChatBox:Insert(link)
				end
			end
		end,
	}

	options.createStandardDebuff= {
		type = "execute",
		order = 150,
		width = "full",
		name = L["Copy to Debuffs"],
		func = function(info)
			local spellId   = info.handler.spellId
			local spellName = GetSpellInfo(spellId)
			if spellName then
				local bossKey   = info.handler.bossKey
				local bossName  = bossesNames[bossKey] or bossKey
				local baseKey   = string.format("debuff-%s>%s", strmatch(bossName, "^(.-) .*$") or bossName, spellName):gsub("[ %.\"!']", "")
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
		end,
	}

	options.moveDebuff= {
		type = "select",
		order = 156,
		width = "full",
		name = L["Move To"],
		get = function() end,
		set = function(info,newBoss)
			local oldBoss = info.handler.bossKey
			if newBoss~=oldBoss then
				local spellId = info.handler.spellId
				DbDelTableValue( spellId, RDO.db.profile.debuffs, visibleInstance, oldBoss )
				DbAddTableValue( spellId, RDO.db.profile.debuffs, visibleInstance, newBoss )
				MakeRaidDebuffsOptions()
			end
		end,
		values = bossesNames,
		hidden = function(info) return (not info.handler.isCustom) or #bosses<=1 end,
	}

	options.removeDebuff= {
		type = "execute",
		order = 155,
		width = "full",
		name = L["Delete raid debuff"],
		func = function(info)
			local spellId = info.handler.spellId
			local bossKey = info.handler.bossKey
			StatusDisableDebuff(spellId)
			DbDelTableValue( spellId, RDO.db.profile.debuffs, visibleInstance, bossKey )
			RDO.OPTIONS_ITEMS[tostring(spellId)]= nil
		end,
		hidden = function(info) return not info.handler.isCustom end
	}
end

--============================================================
