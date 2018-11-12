local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2

-- shared methods

local function GetTexCoordEmpty()
	return 0,0.05,0,0.05
end

local function GetTexCoordIcon()
	return 0.55, 0.93, 0.07, 0.42
end

local text = L["combat"]
local function GetText(self,unit)
	return text
end

local function GetPercent(self, unit)
	return self.dbx.color1.a, text
end

local function GetIcon()
	return [[Interface\CharacterFrame\UI-StateIcon]]
end

-- combat status

local Combat = Grid2.statusPrototype:new("combat")

local UnitAffectingCombat = UnitAffectingCombat
local timer
local cache = {}

Combat.GetColor = Grid2.statusLibrary.GetColor
Combat.GetPercent = GetPercent
Combat.GetText = GetText
Combat.GetIcon = GetIcon

local function UpdateUnits()
	for unit in Grid2:IterateRosterUnits() do
		local value = UnitAffectingCombat(unit)
		if value ~= cache[unit] then
			cache[unit] = value
			Combat:UpdateIndicators(unit)
		end
	end
end

function Combat:OnEnable()	
	self:UpdateDB()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	timer:Play() 
end

function Combat:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	timer:Stop()
	wipe(cache)
end

function Combat:Grid_UnitUpdated(_, unit)
	cache[unit] = UnitAffectingCombat(unit)
end

function Combat:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

function Combat:IsActive(unit)
	return cache[unit]
end

function Combat:UpdateDB()
	self.GetTexCoord = self.dbx.useEmptyIcon and GetTexCoordEmpty or GetTexCoordIcon
	timer = timer or Grid2:CreateTimer( UpdateUnits, 1, false)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Combat, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return Combat
end

Grid2.setupFunc["combat"] = Create

Grid2:DbSetStatusDefaultValue( "combat", {type = "combat", color1 = {r=1,g=0,b=0,a=1}} )

-- combat-mine status

local MyCombat = Grid2.statusPrototype:new("combat-mine")

local inCombat

MyCombat.GetColor = Grid2.statusLibrary.GetColor
MyCombat.GetPercent = GetPercent
MyCombat.GetText = GetText
MyCombat.GetIcon = GetIcon

function MyCombat:IsActive()
	return inCombat
end

function MyCombat:OnEnable()
	self:UpdateDB()
	self:RegisterEvent("PLAYER_REGEN_ENABLED",  "CombatChanged" )
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatChanged" )
	inCombat = InCombatLockdown()
end

function MyCombat:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function MyCombat:CombatChanged(event)
	inCombat = (event=='PLAYER_REGEN_DISABLED')
	self:UpdateAllUnits()
end

function MyCombat:UpdateDB()
	self.GetTexCoord = self.dbx.useEmptyIcon and GetTexCoordEmpty or GetTexCoordIcon
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(MyCombat, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return MyCombat
end

Grid2.setupFunc["combat-mine"] = Create

Grid2:DbSetStatusDefaultValue( "combat-mine", {type = "combat-mine", color1 = {r=1,g=0,b=0,a=1}} )
