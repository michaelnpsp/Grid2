local validRaidUnits, validPartyUnits, unitPets = {}, {}, { player = "pet" }

local UnitExists = UnitExists
local UnitName = UnitName
local UnitGUID = UnitGUID

--[[
function Grid2:UnitIsPet(unit)
	return roster[unit] == false
end

function Grid2:UpdateRoster()
	for guid, unit in pairs(roster.unitid) do
		units_to_remove[guid] = true
	end

	local units
	if (GetNumRaidMembers() > 0) then
		units = validRaidUnits
	else
		units = validPartyUnits
	end

	for unit in pairs(units) do
		local exists = UnitExists(unit)
		roster[unit] = exists
		if exists then
			local pet = unitPets[unit]
			roster[pet] = UnitExists(pet) and false
		end
	end

	roster.pet = UnitExists("pet") and false
	self:SendMessage("Grid_RosterUpdated")
end

function Grid2:UNIT_PET(_, unit)
	local pet = unitPets[unit]
	if not pet then return end
	local exists = UnitExists(pet)
	roster[pet] = exists and false
	self:SendMessage("Grid_PetChanged", pet, unit, exists)
end
--]]











-- roster[attribute_name][guid] = value
local roster = {
	name = {},
	realm = {},
	unitid = {},
	guid = {},
}

-- for debugging
Grid2.roster = roster

--
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

--[[
function GridRoster:OnInitialize()
	-- empty roster
	for attr, attr_tbl in pairs(roster) do
		for k in pairs(attr_tbl) do
			attr_tbl[k] = nil
		end
	end
end

function GridRoster:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_PET", "UpdateRoster")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateRoster")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateRoster")

	self:RegisterEvent("UNIT_NAME_UPDATE", "UpdateRoster")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateRoster")

	self:UpdateRoster()
end
--]]

--ToDo: Is this actually used
function Grid2:GetGUIDByName(name, realm)
	if realm == my_realm or realm == "" then realm = nil end
	for guid, unit_name in pairs(roster.name) do
		if name == unit_name and roster.realm[guid] == realm then
			return guid
		end
	end
end

--ToDo: Is this actually used
function Grid2:GetNameByGUID(guid)
	return roster.name[guid], roster.realm[guid]
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
	return roster.unitid[guid]
end

function Grid2:GetOwnerUnitidByGUID(guid)
	local unitid = roster.unitid[guid]
	return owner_of_unit[unitid]
end

function Grid2:GetPetUnitidByUnitid(unitid)
	return pet_of_unit[unitid]
end

function Grid2:GetOwnerUnitidByUnitid(unitid)
	return owner_of_unit[unitid]
end

function Grid2:IsGUIDInRaid(guid)
	return roster.guid[guid] ~= nil
end

function Grid2:IterateRoster()
	return pairs(roster.unitid)
end

function Grid2:UnitIsPet(unitid)
--[[
	if (unitid) then
		return bit.band(UnitGUID(unitid):sub(1, 5), 0x00f) == 0x004
	end
--]]
	local owner = owner_of_unit[unitid]
	if (owner and pet_of_unit[owner] == unitid) then
		return true
	else
		return false
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

		if guid then
			if (realm == "") then
				realm = nil
			end

			if (units_to_remove[guid]) then
				units_to_remove[guid] = nil

				local old_name = roster.name[guid]
				local old_realm = roster.realm[guid]
				local old_unitid = roster.unitid[guid]

				if old_name ~= name or old_realm ~= realm or
					old_unitid ~= unit then
					units_updated[guid] = true
				end
			else
				units_added[guid] = true
			end

			roster.name[guid] = name
			roster.realm[guid] = realm
			roster.unitid[guid] = unit
			roster.guid[guid] = guid
		end
	end

	function Grid2:UpdateRoster()
		for guid, unit in pairs(roster.unitid) do
			units_to_remove[guid] = true
		end

		local units
		if (GetNumRaidMembers() == 0) then
			units = party_units
		else
			units = raid_units
		end

		for _, unit in ipairs(units) do
			if unit and UnitExists(unit) then
				UpdateUnit(unit)

				local unitpet = pet_of_unit[unit]
				if unitpet and UnitExists(unitpet) then
					UpdateUnit(unitpet)
				end
			end
		end

		local updated = false

		for guid in pairs(units_to_remove) do
			updated = true
			self:SendMessage("Grid_UnitLeft", guid)

			for attr, attr_tbl in pairs(roster) do
				attr_tbl[guid] = nil
			end

			units_to_remove[guid] = nil
		end

		for guid in pairs(units_added) do
			updated = true
			self:SendMessage("Grid_UnitJoined", guid, roster.unitid[guid])

			units_added[guid] = nil
		end

		for guid in pairs(units_updated) do
			updated = true
			self:SendMessage("Grid_UnitChanged", guid, roster.unitid[guid])

			units_updated[guid] = nil
		end

		if (updated) then
			self:SendMessage("Grid_RosterUpdated")
		end
	end
end
