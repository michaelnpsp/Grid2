local Status = Grid2.statusPrototype:new("unit-index")

local Grid2 = Grid2

local tostring = tostring
local empty = {}
local valid_units

function Status:GetText(unit)
	return tostring( valid_units[unit] )
end

local function IsActive1(self, unit)
	return valid_units[unit]~=nil
end

local function IsActive2(self, unit)
	return unit~='player' and valid_units[unit]~=nil
end

function Status:Grid_GroupTypeChanged()
	self:UpdateDB()
end

function Status:OnEnable()
	self:RegisterMessage("Grid_GroupTypeChanged")
end

function Status:OnDisable()
	self:UnregisterMessage("Grid_GroupTypeChanged")
end

function Status:UpdateDB()
	self.IsActive =	self.dbx.playerUnit and IsActive1 or IsActive2
	valid_units = (Grid2:GetGroupType()=='solo' and empty) or (self.dbx.partyUnits and Grid2.party_indexes) or Grid2.grouped_units
end

Grid2.setupFunc["unit-index"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Status, {"text"}, baseKey, dbx)
	return Status
end

Grid2:DbSetStatusDefaultValue( "unit-index", {type = "unit-index"})
