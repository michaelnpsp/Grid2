-- Roster management
local Grid2 = Grid2
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

-- Local variables to speed up things
local ipairs, pairs, next, select = ipairs, pairs, next, select
local UNKNOWNOBJECT = UNKNOWNOBJECT
local IsInRaid = IsInRaid
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local GetRaidRosterInfo = GetRaidRosterInfo
local GetNumGroupMembers = GetNumGroupMembers
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local isClassic = Grid2.isClassic
local isVanilla = Grid2.isVanilla

-- helper tables to check units types/categories
local party_indexes   = {} -- player=>0, party1=>1, ..
local raid_indexes    = {} -- raid1=>1, raid2=>2, ..
local pet_of_unit     = {} -- party1=>partypet1, raid3=>raidpet3, arena1=>arenapet1, ..
local owner_of_unit   = {} -- partypet1=>party1, raidpet3=>raid3, arenapet1=>arena1, ..
local grouped_units   = {} -- party1=>1, raid1=>1 ; units in party or raid
local grouped_players = {} -- party1=>1, raid1=>1 ; only party/raid player/owner units
local grouped_pets    = {} -- partypet1=>1, raidpet2=>1 ; only party/raid pet units
local roster_types    = { target = 'target', focus = 'focus', targettarget = 'targettarget', focustarget = 'focustarget' }
local roster_my_units = { player = true, pet = true, vehicle = true }
local faked_units     = { targettarget = true, focustarget = true, boss6 = true, boss7 = true, boss8 = true } -- eventless units
-- roster tables / storing only existing units
local roster_names    = {} -- raid1=>name, ..
local roster_realms   = {} -- raid1=>realm,..
local roster_guids    = {} -- raid1=>guid,..
local roster_players  = {} -- raid1=>guid ;only non pet units in group/raid
local roster_pets     = {} -- raidpet1=>guid ;only pet units in group/raid
local roster_units    = {} -- guid=>raid1, ..
local roster_faked    = {} -- eventless units
-- roster dead tracking
local roster_deads = {}
local textDeath = L["DEAD"]
local textGhost = L["GHOST"]

-- provide alternative missing api functions for classic
Grid2.GetSpecialization = GetSpecialization or (Grid2.versionCli>=30000 and GetActiveTalentGroup) or function()
	return 0
end

Grid2.GetNumSpecializations = GetNumSpecializations or function()
	return 2
end

Grid2.UnitGroupRolesAssigned = (not Grid2.isVanilla) and UnitGroupRolesAssigned or function(unit)
	local index = raid_indexes[unit]
	return ((index and select(10,GetRaidRosterInfo(index))=='MAINTANK') and 'TANK') or UnitGroupRolesAssigned(unit) or 'NONE'
end

-- populate unit tables
do
	local function register_unit(unit, pet, index, indexes)
		pet_of_unit[unit]  = pet
		owner_of_unit[pet] = unit
		roster_types[unit] = 'player'
		roster_types[pet]  = 'pet'
		if index then
			indexes[unit], grouped_units[unit], grouped_players[unit], grouped_units[pet], grouped_pets[pet] = index, index, index, index, index
		end
	end
	register_unit( "player", "pet", 0, party_indexes )
	for i = 1, MAX_PARTY_MEMBERS do
		register_unit( ("party%d"):format(i), ("partypet%d"):format(i), i, party_indexes )
	end
	for i = 1, MAX_RAID_MEMBERS do
		register_unit( ("raid%d"):format(i), ("raidpet%d"):format(i), i, raid_indexes )
	end
	for i= 1, 5 do
		register_unit( ("arena%d"):format(i), ("arenapet%d"):format(i) )
	end
	for i = 1, 8 do
		roster_types['boss'..i] = 'boss'
	end
end

-- roster management
do
	local roster_unknowns -- flag to track if roster contains unknown units, workaround for blizzard bug (see ticket #628)

	local function UpdateUnit(unit)
		local modified
		local guid = UnitGUID(unit)
		if guid ~= roster_guids[unit] then
			if pet_of_unit[unit] then
				local old_guid = roster_guids[unit]
				if unit == roster_units[old_guid] then
					roster_units[old_guid] = nil
				end
				roster_units[guid] = unit
			end
			roster_guids[unit] = guid
			modified = true
		end
		local name, realm = UnitName(unit)
		if name == UNKNOWNOBJECT then
			roster_unknowns = true
		end
		if name ~= roster_names[unit] then
			roster_names[unit] = name
			modified = true
		end
		if realm == "" then realm = nil end
		if realm ~= roster_realms[unit] then
			roster_realms[unit] = realm
			modified = true
		end
		if modified then
			roster_deads[unit] = Grid2:UnitIsDeadOrGhost(unit)
			Grid2:SendMessage("Grid_UnitUpdated", unit)
			return true
		end
	end

	local function AddUnit(unit)
		local guid = UnitGUID(unit)
		local name, realm = UnitName(unit)
		if realm == "" then realm = nil end
		roster_names[unit]  = name
		roster_realms[unit] = realm
		roster_guids[unit]  = guid
		if grouped_players[unit] then
			roster_units[guid] = unit
			roster_players[unit] = guid
		elseif grouped_pets[unit] then
			roster_units[guid] = unit
			roster_pets[unit] = guid
		end
		roster_faked[unit] = faked_units[unit]
		roster_deads[unit] = Grid2:UnitIsDeadOrGhost(unit)
		Grid2:SendMessage("Grid_UnitUpdated", unit, true)
	end

	local function DelUnit(unit)
		local guid = roster_guids[unit]
		roster_names[unit]  = nil
		roster_realms[unit] = nil
		roster_guids[unit]  = nil
		if grouped_players[unit] then
			roster_players[unit] = nil
		elseif grouped_pets[unit] then
			roster_pets[unit] = nil
		end
		if unit == roster_units[guid] then
			roster_units[guid] = nil
		end
		roster_faked[unit] = nil
		roster_deads[unit] = nil
		Grid2:SendMessage("Grid_UnitLeft", unit)
	end

	local function RefreshUnit(unit)
		if UnitExists(unit) then
			if roster_guids[unit] then
				return UpdateUnit(unit)
			else
				AddUnit(unit)
				return true
			end
		elseif roster_guids[unit] then
			DelUnit(unit)
			return true
		end
	end

	function Grid2:RosterRegisterUnit(unit) -- Called from Grid2Frame:OnAttributeChanged() to maintain roster up to date.
		if UnitExists(unit) and not roster_guids[unit] then
			AddUnit(unit)
		end
	end

	function Grid2:RosterUnregisterUnit(unit) -- Called from Grid2Frame:OnAttributeChanged() to maintain roster up to date.
		if roster_guids[unit] then
			DelUnit(unit)
		end
	end

	function Grid2:UNIT_NAME_UPDATE(_, unit) -- event registered in GridCore.lua because this module does not have a init function
		if roster_guids[unit] then
			UpdateUnit(unit)
			self:UpdateFramesOfUnit(unit)
		end
	end

	function Grid2:UNIT_PET(_, owner) -- event registered in GridCore.lua because this module does not have a init function
		local unit = pet_of_unit[owner]
		if roster_guids[unit] then
			RefreshUnit(unit)
			self:UpdateFramesOfUnit(unit)
		end
	end

	function Grid2:RosterHasUnknowns() -- Workaround for blizzard bug (see ticket #628)
		return roster_unknowns
	end

	-- functions to manage non-grouped and eventless units from custom headers (see GridGroupHeaders.lua)
	-- target, focus, targettarget, focustarget, bosssX, arenaX, ...
	Grid2InsecureGroupCustomHeader_RegisterUpdate(Grid2, "Grid_FakedUnitsUpdate", RefreshUnit, roster_faked)

	-- We delay roster updates to the next frame Update, to ensure all GROUP_ROSTER_UPDATE group headers events were already
	-- processed, in this way roster is up to date: non-existant units already removed from roster when UpdateRoster() is executed.
	-- As side effect we avoid a lot of unecessary roster updates, because blizzard fires a lot of GROUP_ROSTER_UPDATE events.
	do
		local frameThrottling = CreateFrame('Frame')
		frameThrottling:Hide()
		frameThrottling:SetScript('OnUpdate', function(self) self:Hide(); Grid2:UpdateRoster(); end)
		function Grid2:QueueUpdateRoster()
			frameThrottling:Show()
		end
	end
	-- GROUP_ROSTER_UPDATE => Grid2:GroupChanged() => Grid2:QueueUpdateRoster() => Grid2:UpdateRoster()
	-- Grid2Frame:OnUnitStateChanged() and Grid2Frame:OnAttributeChanged() process units roster joins&leaves
	-- so we only need to track changes on units names/guids here.
	function Grid2:UpdateRoster()
		roster_unknowns = false
		for unit in next, roster_guids do
			if UnitExists(unit) and UpdateUnit(unit) then
				self:UpdateFramesOfUnit(unit)
			end
		end
		self:SendMessage("Grid_RosterUpdate", roster_unknowns)
		if isVanilla then
			self:SendMessage("Grid_PlayerRolesAssigned")
		end
	end
end

-- Events to track raid type changes
do
	-- BGs instMapID>RaidSize lookup, fix for ticket #652 (Random BGs return an incorrect raidsize)
	local pvp_instances = {
		[2106] = 10, -- Warsong Gulch (patch 8.1.5)
		[726]  = 10, -- Twin Peaks
		[727]  = 10, -- Silvershard Mines
		[761]  = 10, -- The Battle for Gilneas
		[998]  = 10, -- Temple of Kotmogu
		[1803] = 10, -- Seething Shore
		[968]  = 10, -- Rated Eye of the Storm
		[2107] = 15, -- Arathi Basin (patch 8.1.5)
		[566]  = 15, -- Eye of the Storm
		[2245] = 15, -- Deepwind Gorge
		[1681] = 15, -- Arathi Blizzard
		[30]   = 40, -- Alterac Valley
		[628]  = 40, -- Isle of Conquest
		[1280] = 40, -- Tarren Mill vs Southshore
	}
	-- instance difficultiss only used when in party or solo
	local ins_difficulties = {
		[1]  = 'normal',
		[2]  = 'heroic',
		[8]  = 'mythic', -- mythic keystone
		[16] = 'mythic', -- mythic raid
		[23] = 'mythic', -- mythic dungeon
	}
	-- Local variables
	local updateCount = 0
	local groupsUsed = {}
	-- Calculate raid size (raid size is adjusted to be multiple of 5)
	local raidSizeFuncs = {
		[1] = function() -- max non-empty group in raid
			local m = 1
			for i = 1, 40 do
				local n, _, g = GetRaidRosterInfo(i)
				if n and g>m then m = g end
			end
			return m*5, m
		end,
		[2] = function() -- count non-empty groups in raid
			local r, m = 0, 1
			wipe(groupsUsed)
			for i = 1, 40 do
				local n, _, g = GetRaidRosterInfo(i)
				if n and groupsUsed[g]==nil then
					groupsUsed[g] = true
					if g>m then m = g end
					r = r + 1
				end
			end
			return r*5, m
		end,
		[3] = function() -- count players in raid
			local r, m = 0, 1
			for i = 1, 40 do
				local n, _, g = GetRaidRosterInfo(i)
				if n then
					if g>m then m = g end
					r = r + 1
				end
			end
			return math.ceil(r/5)*5, m
		end,
	}
	local function GetRaidMaxPlayers(maxPlayers, maxGroup)
		if IsInRaid() then
			local typ = Grid2.db.profile.raidSizeType
			if typ then
				local raidSize, raidGroup = raidSizeFuncs[typ]()
				if Grid2Layout.db.profile.displayAllGroups then
					return raidSize, raidGroup
				else
					return math.min(raidSize, maxPlayers), math.min(raidGroup, maxGroup)
				end
			end
		end
		return maxPlayers, maxGroup
	end
	-- Used by another modules
	function Grid2:GetGroupType()
		return self.groupType or "solo", self.instType or "other", self.instMaxPlayers or 1, self.instMaxGroup or 1
	end
	-- Workaround to fix maxPlayers in pvp when UI is reloaded (retry every .5 seconds for 2-3 seconds), see ticket #641
	function Grid2:FixGroupMaxPlayers(newInstType)
		if updateCount<=5 and (newInstType == 'pvp' or newInstType == 'arena') then
			updateCount = updateCount + 1001 -- +1000, trick to avoid launching the timer if already launched (updateCount<=5 will fail)
			C_Timer.After( .5, function()
				if self.instMaxPlayers==40 and (self.instType=='pvp' or self.instType=='arena') then
					updateCount = updateCount - 1000
					Grid2:GroupChanged('GRID2_TIMER')
				end
			end)
		end
	end
	-- needed to trigger an update when switching from one BG directly to another
	function Grid2:PLAYER_ENTERING_WORLD(_, isLogin, isReloadUI)
		if not (isLogin or isReloadUI) then
			self:PLAYER_SPECIALIZATION_CHANGED('PLAYER_ENTERING_WORLD', 'player') -- to detect blizzard silent spec change when entering in a LFG instance
		end
		self.groupType, updateCount = nil, 0
		self:GroupChanged('PLAYER_ENTERING_WORLD')
	end
	-- message registered by status filter code (GridStatusLoad.lua)
	function Grid2:ZONE_CHANGED_NEW_AREA(event)
		self:GroupChanged(event)
		self:SendMessage("Grid_ZoneChangedNewArea")
	end
	-- partyTypes = solo party arena raid / instTypes = none pvp lfr flex mythic other
	function Grid2:GroupChanged(event)
		local newGroupType
		local InInstance, newInstType = IsInInstance()
		local instName, _, difficultyID, _, maxPlayers, _, _, instMapID = GetInstanceInfo()
		if self.debugging then
			self:Debug("GetInstanceInfo %s %s %s/%s/%s %s@%s(%s)", tostring(event), tostring(instName), tostring(instMapID), tostring(difficultyID), tostring(maxPlayers), tostring(self.groupType), tostring(self.instType), tostring(self.instMaxPlayers))
		end
		if newInstType == "arena" then
			newGroupType = newInstType	-- arena@arena instances
		elseif IsInRaid() then
			newGroupType = "raid"
			if InInstance then
				if newInstType == "pvp" then      -- raid@pvp / PvP battleground instance
					maxPlayers = pvp_instances[instMapID] or maxPlayers
				elseif newInstType == "none" then -- raid@none / Not in Instance, in theory its not posible to reach this point
					maxPlayers = 40
				elseif difficultyID == 17 then    -- raid@lfr / Looking for Raid instances (but not LFR especial events instances)
					newInstType = "lfr"
				elseif difficultyID == 16 then    -- raid@mythic / Mythic instance
					newInstType = "mythic"
				elseif maxPlayers == 30 then      -- raid@flex / Flexible instances normal/heroic (but no LFR)
					newInstType = "flex"
				else                              -- raid@other / Other instances: 5man/unknow instances/classic instances
					newInstType = "other"
					if isClassic then
						if maxPlayers==5 then -- classic raid inside a dungeon
							maxPlayers = 10
						elseif maxPlayers==0 or maxPlayers==nil then -- classic bug sometimes GetInstanceInfo() returns 0/nil instead of instance maxPlayers
							maxPlayers = isVanilla and 40 or 25 -- vanilla:40 tbc:25 not a perfect workaround, entering a 40man vanilla instance (onyxia lair for example) from tbc client sets 25 instead of 40
						end
					end
				end
			else -- raid@none / In World Map or Garrison
				newInstType = "none"
				maxPlayers = 40
			end
		else
			newInstType = (not InInstance) and 'none' or ins_difficulties[difficultyID] or 'other'
			if GetNumGroupMembers()>0 then
				newGroupType, maxPlayers = "party", 5
			else
				newGroupType, maxPlayers = "solo", 1
			end
		end
		if maxPlayers == nil or maxPlayers == 0 then
			maxPlayers = 40
			self:FixGroupMaxPlayers(newInstType)
		elseif maxPlayers>40 then -- In Wrath Wintergrasp GetInstanceInfo() may return more than 40 players.
			maxPlayers = 40
		end
		local instMaxPlayers, instMaxGroup = GetRaidMaxPlayers( maxPlayers, math.ceil(maxPlayers/5) )
		if self.groupType ~= newGroupType or self.instType ~= newInstType or self.instMaxPlayers ~= instMaxPlayers or self.instMaxGroup ~= instMaxGroup then
			self:Debug("GroupChanged", event, instName, instMapID, self.groupType, self.instType, self.instMaxPlayers, self.instMaxGroup, "=>", newGroupType, newInstType, instMaxPlayers, instMaxGroup)
			self.groupType      = newGroupType
			self.instType       = newInstType
			self.instMaxPlayers = instMaxPlayers
			self.instMaxGroup   = instMaxGroup
			self:SendMessage("Grid_GroupTypeChanged", newGroupType, newInstType, instMaxPlayers, instMaxGroup)
		end
		self:QueueUpdateRoster()
	end
end

--{{ Public variables and methods used by some statuses
function Grid2:UnitIsDeadOrGhost(unit)
	return UnitIsDeadOrGhost(unit) and (UnitIsGhost(unit) and textGhost or textDeath) or false
end

function Grid2:GetUnitOfGUID(guid) -- only party/raid units
	return roster_units[guid]
end

function Grid2:IsGUIDInRaid(guid) -- only party/raid units
	return roster_units[guid]
end

function Grid2:GetPetOfUnit(unit) -- pet unit of a owner unit
	return pet_of_unit[unit]
end

function Grid2:GetOwnerOfUnit(unit) -- owner unit of a pet unit
	return owner_of_unit[unit]
end

function Grid2:IsUnitInRaid(unit) -- raid/party units
	return roster_guids[unit]
end

function Grid2:IsPlayerInRaid(unit) -- non-pet raid/party units
	return roster_players[unit]
end

function Grid2:UnitIsPet(unit) -- only valid for raid/party/arena units, not pets in target/focus.
	return owner_of_unit[unit]
end

function Grid2:IterateRosterGUIDs() -- guid=>unit, only guids/units in party/raid
	return next, roster_units
end

function Grid2:IterateRosterUnits() -- unit=>guid, all units: player/pet/partyN/raidN/arenaM/bossN/target/focus
	return next, roster_guids
end

function Grid2:IterateGroupedPlayers() -- grouped units: player/partyN/raidN
	return next, roster_players
end

function Grid2:IterateGroupedPets() -- grouped units's pets: pet/partypetN/raidpetN
	return next, roster_pets
end

Grid2.roster_guids    = roster_guids
Grid2.roster_units    = roster_units
Grid2.roster_players  = roster_players
Grid2.roster_pets     = roster_pets
Grid2.roster_names    = roster_names
Grid2.owner_of_unit   = owner_of_unit
Grid2.pet_of_unit     = pet_of_unit
Grid2.roster_my_units = roster_my_units
Grid2.roster_types    = roster_types
Grid2.grouped_units   = grouped_units
Grid2.grouped_players = grouped_players
Grid2.raid_indexes    = raid_indexes
Grid2.party_indexes   = party_indexes
Grid2.roster_deads    = roster_deads
Grid2.roster_faked    = roster_faked
--}}
