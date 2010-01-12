local UnitExists = UnitExists
local UnitName = UnitName
local UnitGUID = UnitGUID

-- indexed by unit ID
local roster_names = {}
local roster_realms = {}
local roster_guids = {}
-- indexed by GUID
local roster_units = {}

local my_realm = GetRealmName()

-- unit tables
local party_units = {}
local raid_units = {}
local pet_of_unit = {}
local owner_of_unit = {}

do
	-- populate unit tables
	local function register_unit(tbl, unit, pet)
		table.insert(tbl, unit)
		pet_of_unit[unit] = pet
		owner_of_unit[pet] = unit
	end

	register_unit(party_units, "player", "pet")

	for i = 1, MAX_PARTY_MEMBERS do
		register_unit(party_units, ("party%d"):format(i),
					  ("partypet%d"):format(i))
	end

	for i = 1, MAX_RAID_MEMBERS do
		register_unit(raid_units, ("raid%d"):format(i),
					  ("raidpet%d"):format(i))
	end
end

--ToDo: Is this actually used
function Grid2:GetGUIDByName(name, realm)
	if realm == my_realm or realm == "" then realm = nil end
	for unit, unit_name in pairs(roster_names) do
		if name == unit_name and roster_realms[unit] == realm then
			return guid
		end
	end
end

--ToDo: Is this actually used
function Grid2:GetNameByGUID(guid)
	local unit = roster_units[guid]
	if unit then
		return roster_names[unit], roster_realms[unit]
	end
end

--ToDo: Is this actually used
function Grid2:GetGUIDByFullName(full_name)
	local name, realm = full_name:match("^([^%-]+)%-(.*)$")
	return self:GetGUIDByName(name or full_name, realm)
end

--ToDo: Is this actually used
function Grid2:GetFullNameByGUID(guid)
	local name, realm = self:GetNameByGUID(guid)

	if realm then
		return name .. "-" .. realm
	else
		return name
	end
end

function Grid2:GetUnitidByGUID(guid)
	return roster_units[guid]
end

function Grid2:GetOwnerUnitidByGUID(guid)
	local unitid = roster_units[guid]
	return owner_of_unit[unitid]
end

function Grid2:GetPetUnitidByUnitid(unitid)
	return pet_of_unit[unitid]
end

function Grid2:GetOwnerUnitidByUnitid(unitid)
	return owner_of_unit[unitid]
end

function Grid2:IsGUIDInRaid(guid)
	return roster_units[guid]
end

function Grid2:IterateRoster()
	return next, roster_units
end

function Grid2:UnitIsPet(unitid)
	return owner_of_unit[unitid]
end

function Grid2:UnitIsParty(unit)
	for _, v in next, party_units do
		if unit == v then return true end
	end
end

function Grid2:UnitIsRaid(unit)
	for _, v in next, raid_units do
		if unit == v then return true end
	end
end

-- roster updating
do
	local units_to_remove = {}
	local units_added = {}
	local units_updated = {}

	local function UpdateUnit(unit)
		local name, realm = UnitName(unit)
		local guid = UnitGUID(unit)

		if realm == "" then realm = nil end

		units_to_remove[unit] = nil

		local old_name = roster_names[unit]
		local old_realm = roster_realms[unit]

		if not old_name then
			units_added[unit] = guid
		elseif old_name ~= name or old_realm ~= realm then
			units_updated[unit] = guid
		end

		roster_names[unit] = name
		roster_realms[unit] = realm
		roster_guids[unit] = guid
		roster_units[guid] = unit
	end

	function Grid2:UNIT_NAME_UPDATE(_, unit)
		local name, realm = UnitName(unit)
		local guid = UnitGUID(unit)

		if realm == "" then realm = nil end

		local old_name = roster_names[unit]
		local old_realm = roster_realms[unit]

		roster_names[unit] = name
		roster_realms[unit] = realm

		if old_name ~= name or old_realm ~= realm then
			self:SendMessage("Grid_UnitChanged", unit, guid)
			self:SendMessage("Grid_RosterUpdated")
		end
	end

	function Grid2:UNIT_PET(_, owner)
		local unit = pet_of_unit[owner]
		if UnitExists(unit) then
			local name, realm = UnitName(unit)
			local guid = UnitGUID(unit)

			if realm == "" then realm = nil end

			local updated, exists = false, roster_guids[unit]

			if name ~= roster_names[unit] then
				roster_names[unit] = name
				updated = true
			end
			if realm ~= roster_realms[unit] then
				roster_realms[unit] = realm
				updated = true
			end
			local old_guid = roster_guids[unit]
			if guid ~= old_guid then
				if old_guid then
					-- Potentially, it could be problematic to have guid "moving around" between frames.
					-- assert (not roster_units[old_guid] or roster_units[old_guid] == unit)
					roster_units[old_guid] = nil
				end
				roster_units[guid] = unit
				updated = true
			end
			if updated then
				self:SendMessage(exists and "Grid_UnitChanged" or "Grid_UnitJoined", unit, guid)
				self:SendMessage("Grid_RosterUpdated")
			end
		else
			local old_guid = roster_guids[unit]
			if old_guid then
				roster_names[unit] = nil
				roster_realms[unit] = nil
				roster_guids[unit] = nil
				roster_units[old_guid] = nil

				self:SendMessage("Grid_UnitLeft", unit, old_guid)
				self:SendMessage("Grid_RosterUpdated")
			end
		end
	end

	function Grid2:UpdateRoster()
		for unit, guid in pairs(roster_guids) do
			units_to_remove[unit] = guid
		end

		local units = (GetNumRaidMembers() == 0) and party_units or raid_units

		for _, unit in ipairs(units) do
			if not UnitExists(unit) then break end
			UpdateUnit(unit)

			local unitpet = pet_of_unit[unit]
			if UnitExists(unitpet) then
				UpdateUnit(unitpet)
			end
		end

		local updated = false

		for unit, guid in pairs(units_to_remove) do
			updated = true

			roster_names[unit] = nil
			roster_realms[unit] = nil
			roster_guids[unit] = nil
			roster_units[guid] = nil

			self:SendMessage("Grid_UnitLeft", unit, guid)

			units_to_remove[guid] = nil
		end

		for unit, guid in pairs(units_added) do
			updated = true
			self:SendMessage("Grid_UnitJoined", unit, guid)
			units_added[unit] = nil
		end

		for unit, guid in pairs(units_updated) do
			updated = true
			self:SendMessage("Grid_UnitChanged", unit, guid)
			units_updated[unit] = nil
		end

		if updated then
			self:SendMessage("Grid_RosterUpdated")
		end
	end
end
