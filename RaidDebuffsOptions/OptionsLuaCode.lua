-- Generate static LUA CODE for a Raid Debuffs module database
-- See for example: RaidDebuffsWoD.lua

local RDO = Grid2Options.RDO
local RDDB = RDO.RDDB

local EJ_GetInstanceInfo = EJ_GetInstanceInfo or Grid2.Dummy

-- Generates lua code containing the instances/bosses/raid debuffs of the especified module.
function RDO:GenerateModuleLuaCode(moduleName)

	local function GenerateZoneLuaCode(moduleName, zoneName)
		local spells, order = {}, {}
		local function CollectBossSpells(bossdata)
			if not bossdata or bossdata.id then return end
			for index,spellId in ipairs(bossdata) do
				if not order[spellId] and (GetSpellInfo(spellId)) then
					local status = self.debuffsStatuses[spellId]
					spells[#spells+1] = spellId
					order[spellId] = status and self.statusesIndexes[status]*100+self.debuffsIndexes[spellId] or index*10000
				end
			end
		end
		local function GenerateBossCode(bossName, bossdata)
			local custombosses = self.db.profile.debuffs[zoneName]
			local lines = string.format('\t\t["%s"] = {\n',bossName)
			lines = lines .. string.format('\t\torder = %s, ejid = %s,\n', tonumber(bossdata.order) or "nil", tonumber(bossdata.ejid) or "nil")
			wipe(spells); wipe(order)
			CollectBossSpells(bossdata)
			CollectBossSpells(custombosses and custombosses[bossName])
			table.sort(spells, function(a,b) return order[a]<order[b] end)
			for _,spellId in ipairs(spells) do
				lines = lines .. string.format("\t\t%d, -- %s\n", spellId, GetSpellInfo(spellId) )
			end
			lines = lines .. "\t\t},\n"
			return lines, bossdata.order or 100
		end
		local zonedata = RDDB[moduleName][zoneName]
		local bosses, order = {}, {}
		for bossName,bossdata in pairs(zonedata) do
			if not tonumber(bossName) then
				local code, index = GenerateBossCode(bossName,bossdata)
				bosses[#bosses+1], order[code] = code, index
			end
		end
		if moduleName ~= "[Custom Debuffs]" then
			local zone = self.db.profile.debuffs[zoneName]
			if zone then
				for bossName,bossdata in pairs(zone) do
					if not zonedata[bossName] then
						local code, index = GenerateBossCode(bossName,bossdata)
						bosses[#bosses+1], order[code] = code, index
					end
				end
			end
		end
		table.sort(bosses, function(a,b) return order[a]<order[b] end)
		local info = zonedata[1]
		local name = (info and info.id and EJ_GetInstanceInfo(info.id)) or info.name or tostring(zoneName)
		local lines = string.format("\t[%d] = {\n", zoneName )
		lines = lines .. string.format( '\t\t{ id = %s, name = "%s" },\n', info and tostring(info.id) or "nil", name )
		lines = lines .. table.concat(bosses)
		lines = lines .. "\t},\n"
		return lines
	end

	local lines = string.format('local RDDB = Grid2Options:GetRaidDebuffsTable()\n\nRDDB["%s"] = {\n', moduleName ~= "[Custom Debuffs]" and moduleName or "WoW Raid Debuffs")
	for zoneName in pairs(RDDB[moduleName]) do
		lines = lines .. GenerateZoneLuaCode(moduleName, zoneName)
	end
	lines = lines ..  "}\n"
	return lines

end

-- Extracts Instances & Bosses from the Game Encounter journal, generates lua code with raid debuffs module format.
function RDO:GenerateEncounterJournalData(isRaid)

	local lines = ""

	local function println(line)
		lines  = lines .. line .. "\n"
	end

	println('local RDDB = Grid2Options:GetRaidDebuffsTable()')
	println('RDDB["Shadowlands"] = {')
	println( isRaid and "\t-- Raid instances" or "\t-- 5 man instances" )

	EJ_SelectTier( EJ_GetNumTiers() )
	for index=1,100 do
		local instanceID, name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceByIndex(index, isRaid)
		if not instanceID then break end
		println( string.format( '\t[%d] = {', instanceID ) )
		println( string.format('\t\t{ id = %d, name = "%s"%s },',instanceID, name, isRaid and ", raid = true" or "") )
		EJ_SelectInstance(instanceID)
		for index=1,100 do
		local encounterName, _, encounterID = EJ_GetEncounterInfoByIndex(index, instanceID)
		if not encounterName then break end
		println( string.format('\t\t["%s"] = {',encounterName) )
		println( string.format('\t\torder = %d, ejid = %d,', index, encounterID ) )
		println('\t\t},')
		end
		println('\t},')
	end

	println("}")

	return lines

end
