-- Roster management
local Grid2 = Grid2

-- Local variables to speed up things
local ipairs, pairs, next = ipairs, pairs, next
local UNKNOWNOBJECT = UNKNOWNOBJECT
local IsInRaid = IsInRaid
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local GetNumGroupMembers = GetNumGroupMembers
local isClassic = Grid2.isClassic
local isVanilla = Grid2.isVanilla
local isWrath   = Grid2.isWrath

-- helper tables to check units types/categories
local party_indexes   = {} -- player=>0, party1=>1, ..
local raid_indexes    = {} -- raid1=>1, raid2=>2, ..
local pet_of_unit     = {} -- party1=>partypet1, raid3=>raidpet3, arena1=>arenapet1, ..
local owner_of_unit   = {} -- partypet1=>party1, raidpet3=>raid3, arenapet1=>arena1, ..
local grouped_units   = {} -- party1=>1, raid1=>1 ; units in party or raid
local grouped_players = {} -- party1=>1, raid1=>1 ; only party/raid player/owner units
local grouped_pets    = {} -- partypet1=>1, raidpet2=>1 ; only party/raid pet units
local roster_types    = { target = 'target', focus = 'focus' }
local roster_my_units = { player = true, pet = true, vehicle = true }
-- roster tables / storing only existing units
local roster_names    = {} -- raid1=>name, ..
local roster_realms   = {} -- raid1=>realm,..
local roster_guids    = {} -- raid1=>guid,..
local roster_players  = {} -- raid1=>guid ;only non pet units in group/raid
local roster_pets     = {} -- raidpet1=>guid ;only pet units in group/raid
local roster_units    = {} -- guid=>raid1, ..

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
		Grid2:SendMessage("Grid_UnitLeft", unit)
	end

	function Grid2:UNIT_NAME_UPDATE(_, unit)
		if roster_guids[unit] then
			UpdateUnit(unit)
			self:UpdateFramesOfUnit(unit)
		end
	end

	function Grid2:UNIT_PET(_, owner)
		local unit = pet_of_unit[owner]
		if roster_guids[unit] then
			self:RosterRefreshUnit(unit)
			self:UpdateFramesOfUnit(unit)
		end
	end
	-- Called from Grid2Frame:OnUnitStateChanged() to maintain roster up to date, this callback is only fired by Special headers.
	function Grid2:RosterRefreshUnit(unit)
		if UnitExists(unit) then
			if roster_guids[unit] then
				UpdateUnit(unit)
			else
				AddUnit(unit)
			end
		elseif roster_guids[unit] then
			DelUnit(unit)
		end
	end
	-- Called from Grid2Frame:OnAttributeChanged() to maintain roster up to date.
	function Grid2:RosterRegisterUnit(unit)
		if UnitExists(unit) and not roster_guids[unit] then
			AddUnit(unit)
		end
	end
	-- Called from Grid2Frame:OnAttributeChanged() to maintain roster up to date.
	function Grid2:RosterUnregisterUnit(unit)
		if roster_guids[unit] then
			DelUnit(unit)
		end
	end
	-- Workaround for blizzard bug (see ticket #628)
	function Grid2:RosterHasUnknowns()
		return roster_unknowns
	end
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
	-- Used by another modules
	function Grid2:GetGroupType()
		return self.groupType or "solo", self.instType or "other", self.instMaxPlayers or 1
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
			self:ReloadProfile() -- to detect blizzard silent spec change when entering in a LFG instance
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
		if self.groupType ~= newGroupType or self.instType ~= newInstType or self.instMaxPlayers ~= maxPlayers then
			self:Debug("GroupChanged", event, instName, instMapID, self.groupType, self.instType, self.instMaxPlayers, "=>", newGroupType, newInstType, maxPlayers)
			self.groupType, self.instType, self.instMaxPlayers = newGroupType, newInstType, maxPlayers
			self:SendMessage("Grid_GroupTypeChanged", newGroupType, newInstType, maxPlayers)
		end
		self:QueueUpdateRoster()
	end
end

--{{ Public variables and methods used by some statuses
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
Grid2.raid_indexes    = raid_indexes
Grid2.party_indexes   = party_indexes
--}}
