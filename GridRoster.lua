local validRaidUnits, validPartyUnits, unitPets = {}, {}, { player = "pet" }

for i = 1, 40 do
	validRaidUnits["raid"..i] = true
	unitPets["raid"..i] = "raidpet"..i
end
for i = 1, 4 do
	validPartyUnits["party"..i] = true
	unitPets["party"..i] = "partypet"..i
end

local roster = {
	player = true,
}

function Grid2:UnitIsPet(unit)
	return roster[unit] == false
end

function Grid2:UpdateRoster()
	if GetNumRaidMembers() > 0 then
		for unit in pairs(validRaidUnits) do
			local exists = UnitExists(unit)
			roster[unit] = exists
			if exists then
				local pet = unitPets[unit]
				roster[pet] = UnitExists(pet) and false
			end
		end
	end
	if GetNumPartyMembers() > 0 then
		for unit in pairs(validPartyUnits) do
			local exists = UnitExists(unit)
			roster[unit] = exists
			if exists then
				local pet = unitPets[unit]
				roster[pet] = UnitExists(pet) and false
			end
		end
	end
	roster.pet = UnitExists("pet") and false
	self:SendMessage("Grid_RosterUpdated")
end

local function nextNotFalse(table, key)
	while true do
		local r, v = next(table, key)
		if v or not r then
			return r, v
		else
			key = r
		end
	end
end

function Grid2:IterateRoster(includePet)
	if includePet then
		return next, roster
	else
		return nextNotFalse, roster
	end
end

function Grid2:UNIT_PET(_, unit)
	local pet = unitPets[unit]
	if not pet then return end
	local exists = UnitExists(pet) 
	roster[pet] = exists and false
	self:SendMessage("Grid_PetChanged", pet, unit, exists)
end
