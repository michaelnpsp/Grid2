-- Roster management
local Grid2 = Grid2

-- Local variables to speed up things
local ipairs, pairs, next = ipairs, pairs, next
local UNKNOWNOBJECT = UNKNOWNOBJECT
local IsInRaid = IsInRaid
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitExists = UnitExists
local GetNumGroupMembers = GetNumGroupMembers
local isClassic = Grid2.isClassic

-- roster tables
local roster_my_units = { player = true, pet = true, vehicle = true }
local roster_names    = {} -- raid1     => name, ...
local roster_realms   = {} -- raid1     => realm, ...
local roster_guids    = {} -- raid1     => guid, ...
local roster_players  = {} -- raid1     => guid ; only non pet units
local roster_pets     = {} -- raidpet1  => guid ; only pet units
local pet_of_unit     = {} -- party1    => partypet1, raid3    => raidpet3,...
local owner_of_unit   = {} -- partypet1 => party1,    raidpet3 => raid3,...
local party_indexes   = {} -- player    => 0, party1 => 1,...
local raid_indexes    = {} -- raid1     => 1, raid2  => 2,...
local arena_indexes   = {} -- arena1    => 1, arena2 => 2,...
local roster_units    = {} -- guid      => raid1, ...

-- populate unit tables
do
	local function register_unit(unit, pet, index, indexes)
		pet_of_unit[unit] = pet
		owner_of_unit[pet] = unit
		indexes[unit] = index
	end
	for i = 1, MAX_PARTY_MEMBERS do
		register_unit( ("party%d"):format(i), ("partypet%d"):format(i), i, party_indexes )
	end
	for i = 1, MAX_RAID_MEMBERS do
		register_unit( ("raid%d"):format(i), ("raidpet%d"):format(i), i, raid_indexes )
	end
	for i= 1, 5 do
		register_unit( ("arena%d"):format(i), ("arenapet%d"):format(i), i, arena_indexes )
	end
	register_unit( "player", "pet", 0, party_indexes )
end

-- roster management
do
	-- flag to track if roster contains unknown units, workaround to blizzard bug (see ticket #628)
	local roster_unknowns

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
			print("***UNKNOWN Unit:", unit, name)
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
		if pet_of_unit[unit] then
			roster_units[guid] = unit
			roster_players[unit] = guid
		elseif owner_of_unit[unit] then
			roster_units[guid] = unit
			roster_pets[unit] = guid
		end
		Grid2:SendMessage("Grid_UnitUpdated", unit)
	end

	local function DelUnit(unit)
		roster_names[unit]  = nil
		roster_realms[unit] = nil
		roster_guids[unit]  = nil
		if owner_of_unit[unit] then
			roster_pets[unit] = nil
		else
			roster_players[unit] = nil
		end
		local guid = roster_guids[unit]
		if unit == roster_units[guid] then
			roster_units[guid] = nil
		end
		Grid2:SendMessage("Grid_UnitLeft", unit)
	end

	function Grid2:UNIT_NAME_UPDATE(_, unit)
		print("*UNIT_NAME_UPDATE", unit, (UnitName(unit)), roster_names[unit] )
		self:RosterRefreshUnit(unit)
		self:UpdateFramesOfUnit(unit)
	end

	function Grid2:UNIT_PET(_, owner)
		local unit = pet_of_unit[owner]
		if UnitExists(unit) then
			self:RosterRefreshUnit(unit)
			self:UpdateFramesOfUnit(unit)
		end
	end
	-- Grid2Frame:OnUnitStateChanged() and Grid2Frame:OnAttributeChanged() manage units roster joins/leaves
	-- so we only need to take care of changes on units names/guids here.
	function Grid2:UpdateRoster()
		roster_unknowns = false
		for unit in next, roster_guids do
			if UnitExists(unit) and UpdateUnit(unit) then
				print("Updating unit:", unit, UnitName(unit) )
				self:UpdateFramesOfUnit(unit)
			end
		end
		self:SendMessage("Grid_RosterUpdate", roster_unknowns)
		if roster_unknowns then
			print(">>>>>>>>>>>> Roster has Unknowns !!!!!!")
		end
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
	-- Called from Grid2Frame:OnUnitStateChanged() to maintain roster up to date, only Special headers trigger this callback.
	function Grid2:RosterRefreshUnit(unit)
		if UnitExists(unit) then
			if roster_names[unit] then
				UpdateUnit(unit)
			else
				AddUnit(unit)
			end
		elseif roster_names[unit] then
			DelUnit(unit)
		end
	end
	-- Called from Grid2Frame:OnAttributeChanged() to maintain roster up to date.
	function Grid2:RosterRegisterUnit(unit)
		if UnitExists(unit) and not roster_names[unit] then
			AddUnit(unit)
		end
	end
	-- Called from Grid2Frame:OnAttributeChanged() to maintain roster up to date.
	function Grid2:RosterUnregisterUnit(unit)
		if roster_names[unit] then
			DelUnit(unit)
		end
	end
	-- Workaround for blizzard bug (see ticket #628)
	function Grid2:RosterHasUnknowns()
		return roster_unknowns
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
	-- Local variables
	local updateCount, groupType, instType, instMaxPlayers = 0
	-- Used by another modules
	function Grid2:GetGroupType()
		return groupType or "solo", instType or "other", instMaxPlayers or 1
	end
	-- Workaround to fix maxPlayers in pvp when UI is reloaded (retry every .5 seconds for 2-3 seconds), see ticket #641
	function Grid2:FixGroupMaxPlayers(newInstType)
		if updateCount<=5 and (newInstType == 'pvp' or newInstType == 'arena') then
			updateCount = updateCount + 1001 -- +1000, trick to avoid launching the timer if already launched (updateCount<=5 will fail)
			C_Timer.After( .5, function()
				if instMaxPlayers==40 and (instType=='pvp' or instType=='arena') then
					updateCount = updateCount - 1000
					Grid2:GroupChanged('GRID2_TIMER')
				end
			end)
		end
	end
	-- needed to trigger an update when switching from one BG directly to another
	function Grid2:PLAYER_ENTERING_WORLD(_, isLogin, isReloadUI)
		groupType, updateCount = nil, 0
		if not (isLogin or isReloadUI) then
			self:ReloadProfile() -- to detect blizzard silent spec change when entering in a LFG instance
		end
		self:GroupChanged('PLAYER_ENTERING_WORLD')
	end
	-- partyTypes = solo party arena raid / instTypes = none pvp lfr flex mythic other
	function Grid2:GroupChanged(event)
		local newGroupType
		local InInstance, newInstType = IsInInstance()
		local instName, _, difficultyID, _, maxPlayers, _, _, instMapID = GetInstanceInfo()
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
				else                              -- raid@other / Other instances: 5man/garrison/unknow instances
					newInstType = "other"
					if isClassic and (maxPlayers or 0)<=5 then
						maxPlayers = 10 -- classic, raid inside dungeons
					end
				end
			else -- raid@none / In World Map or Garrison
				newInstType = "none"
				maxPlayers = 40
			end
		elseif GetNumGroupMembers()>0 then
			newGroupType, newInstType, maxPlayers = "party", "other", 5
		else
			newGroupType, newInstType, maxPlayers = "solo", "other", 1
		end
		if maxPlayers == nil or maxPlayers == 0 then
			maxPlayers = 40
			self:FixGroupMaxPlayers(newInstType)
		end
		if groupType ~= newGroupType or instType ~= newInstType or instMaxPlayers ~= maxPlayers then
			self:Debug("GroupChanged", event, instName, instMapID, groupType, instType, instMaxPlayers, "=>", newGroupType, newInstType, maxPlayers)
			groupType, instType, instMaxPlayers = newGroupType, newInstType, maxPlayers
			self:SendMessage("Grid_GroupTypeChanged", groupType, instType, maxPlayers)
		end
		self:QueueUpdateRoster()
	end
end

--{{ Public variables and methods to be used by statuses
function Grid2:GetUnitByGUID(guid)
	return roster_units[guid]
end

function Grid2:IsGUIDInRaid(guid)
	return roster_units[guid]
end

function Grid2:GetPetUnitByUnit(unit)
	return pet_of_unit[unit]
end

function Grid2:GetOwnerUnitByUnit(unit)
	return owner_of_unit[unit]
end

function Grid2:IsUnitInRaid(unit)
	return roster_guids[unit]
end

function Grid2:IsUnitNoPetInRaid(unit)
	return roster_guids[unit] and pet_of_unit[unit]
end

function Grid2:UnitIsPet(unit)
	return owner_of_unit[unit]
end

function Grid2:IterateRoster()
	return next, roster_units
end

function Grid2:IterateRosterUnits()
	return next, roster_guids
end

function Grid2:IteratePlayerUnits()
	return next, roster_players
end

function Grid2:IteratePetUnits()
	return next, roster_pets
end

Grid2.roster_guids    = roster_guids
Grid2.roster_players  = roster_players
Grid2.roster_pets     = roster_pets
Grid2.roster_units    = roster_units
Grid2.owner_of_unit   = owner_of_unit
Grid2.roster_my_units = roster_my_units
Grid2.raid_indexes    = raid_indexes
Grid2.party_indexes   = party_indexes
Grid2.arena_indexes   = arena_indexes
--}}
