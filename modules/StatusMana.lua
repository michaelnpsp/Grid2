-- mana, lowmana, power, poweralt

local Mana = Grid2.statusPrototype:new("mana")
local LowMana = Grid2.statusPrototype:new("lowmana",false)
local ManaAlt = Grid2.statusPrototype:new("manaalt", false)
local Power = Grid2.statusPrototype:new("power",false)
local PowerAlt = Grid2.statusPrototype:new("poweralt",false)

local max = math.max
local fmt = string.format
local next = next
local tostring = tostring
local UnitMana = UnitPower
local UnitManaMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitGroupRolesAssigned = UnitGroupRolesAssigned or (function() return 'NONE' end)

local statuses = {}  -- Enabled statuses

-- Methods shared by all statuses
local status_OnEnable, status_OnDisable
do
	local frame
	local function Frame_OnEvent(self, event, unit, powerType)
		for status in next,statuses do
			status:UpdateUnitPower(unit, powerType, event)
		end
	end
	function status_OnEnable(status)
		if not next(statuses) then
			if not frame then frame = CreateFrame("Frame", nil, Grid2LayoutFrame) end
			frame:SetScript("OnEvent", Frame_OnEvent)
			frame:RegisterEvent("UNIT_POWER_UPDATE")
			frame:RegisterEvent("UNIT_MAXPOWER")
			frame:RegisterEvent("UNIT_DISPLAYPOWER")
		end
		statuses[status] = true
	end
	function status_OnDisable(status)
		statuses[status] = nil
		if (not next(statuses)) and frame then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_POWER_UPDATE")
			frame:UnregisterEvent("UNIT_MAXPOWER")
			frame:UnregisterEvent("UNIT_DISPLAYPOWER")
		end
	end
end

-- Mana status
Mana.GetColor = Grid2.statusLibrary.GetColor

function Mana:OnEnable()
	status_OnEnable(self)
	if self.dbx.showOnlyHealers then
		self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateAllUnits")
		self.rolesEvent = true
	end
end

function Mana:OnDisable()
	status_OnDisable(self)
	if self.rolesEvent then
		self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
		self.rolesEvent = nil
	end
end

function Mana:UpdateUnitPower(unit, powerType)
	self:UpdateIndicators(unit)
end

function Mana:IsActiveStandard(unit)
	return UnitPowerType(unit) == 0
end

function Mana:IsActiveHealer(unit)
	return UnitPowerType(unit) == 0 and (unit=="player" or UnitGroupRolesAssigned(unit) == "HEALER")
end

function Mana:GetPercent(unit)
	local m = UnitManaMax(unit)
	return m == 0 and 0 or UnitMana(unit) / m
end

function Mana:GetText(unit)
	return fmt("%.1fk", UnitMana(unit) / 1000)
end

function Mana:UpdateDB()
	Mana.IsActive = self.dbx.showOnlyHealers and Mana.IsActiveHealer or Mana.IsActiveStandard
end

Grid2.setupFunc["mana"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Mana, {"percent", "text", "color"}, baseKey, dbx)
	Mana:UpdateDB()
	return Mana
end

Grid2:DbSetStatusDefaultValue( "mana", {type = "mana", color1= {r=0,g=0,b=1,a=1}} )

-- Low Mana status
LowMana.GetColor  = Grid2.statusLibrary.GetColor
LowMana.OnEnable  = status_OnEnable
LowMana.OnDisable = status_OnDisable

function LowMana:UpdateUnitPower(unit, powerType)
	if powerType=="MANA" then
		self:UpdateIndicators(unit)
	end
end

function LowMana:IsActive(unit)
	return (UnitPowerType(unit) == 0) and (Mana:GetPercent(unit) < self.dbx.threshold)
end

Grid2.setupFunc["lowmana"] = function(baseKey, dbx)
	Grid2:RegisterStatus(LowMana, {"color"}, baseKey, dbx)
	return LowMana
end

Grid2:DbSetStatusDefaultValue( "lowmana", {type = "lowmana", threshold = 0.75, color1 = {r=0.5,g=0,b=1,a=1}})

-- Alternative power status
PowerAlt.GetColor = Grid2.statusLibrary.GetColor
PowerAlt.OnEnable = status_OnEnable
PowerAlt.OnDisable= status_OnDisable

function PowerAlt:UpdateUnitPower(unit, powerType)
	if powerType=="ALTERNATE" then
		self:UpdateIndicators(unit)
	end
end

function PowerAlt:IsActive(unit)
	return UnitPowerMax(unit,10)>0
end

function PowerAlt:GetPercent(unit)
	return max(UnitPower(unit,10),0) / UnitPowerMax(unit,10)
end

function PowerAlt:GetText(unit)
	local power= UnitPower(unit,10)
	if power>=1000 then
		return fmt("%.1fk", power / 1000)
	else
		return tostring( max(power,0) )
	end
end

Grid2.setupFunc["poweralt"] = function(baseKey, dbx)
	Grid2:RegisterStatus(PowerAlt, {"percent", "text", "color"}, baseKey, dbx)
	return PowerAlt
end

Grid2:DbSetStatusDefaultValue( "poweralt", {type = "poweralt", color1= {r=1,g=0,b=0.5,a=1}} )

-- Power status
local powerColors= {}

Power.OnEnable = status_OnEnable
Power.OnDisable = status_OnDisable

function Power:UpdateUnitPower(unit, powerType)
   if UnitIsPlayer(unit) and powerColors[ powerType ] then
		self:UpdateIndicators(unit)
	end
end

function Power:IsActive(unit)
  return UnitIsPlayer(unit)
end

function Power:GetPercent(unit)
	local m = UnitPowerMax(unit)
	return m == 0 and 0 or UnitPower(unit) / m
end

function Power:GetText(unit)
	local power = UnitPower(unit)
	if power>=1000 then
		return fmt("%.1fk", power / 1000)
	else
		return tostring(power)
	end
end

function Power:GetColor(unit)
	local _,type= UnitPowerType(unit)
	local c= powerColors[type] or powerColors["MANA"]
	return c.r, c.g, c.b, c.a
end

function Power:UpdateDB()
	powerColors["MANA"] = self.dbx.color1
	powerColors["RAGE"] = self.dbx.color2
	powerColors["FOCUS"] = self.dbx.color3
	powerColors["ENERGY"] = self.dbx.color4
	powerColors["RUNIC_POWER"] = self.dbx.color5
	powerColors["INSANITY"] = self.dbx.color6
	powerColors["MAELSTROM"] = self.dbx.color7
	powerColors["LUNAR_POWER"] = self.dbx.color8
	powerColors["FURY"] = self.dbx.color9
	powerColors["PAIN"] = self.dbx.color10
end

Grid2.setupFunc["power"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Power, {"percent", "text", "color"}, baseKey, dbx)
	Power:UpdateDB()
	return Power
end

Grid2:DbSetStatusDefaultValue( "power", {type = "power", colorCount = 10,
	color1 = {r=0,g=0.5,b=1  ,a=1},   -- mana
	color2 = {r=1,g=0  ,b=0  ,a=1},   -- rage
	color3 = {r=1,g=0.5,b=0  ,a=1},   -- focus
	color4 = {r=1,g=1  ,b=0  ,a=1},   -- energy
	color5 = {r=0,g=0.8,b=0.8,a=1},   -- runic power
	color6 = {r=0.40, g=0.00, b=0.80, a=1}, -- insanity
	color7 = {r=0.00, g=0.50, b=1.00, a=1}, -- maelstrom
	color8 = {r=0.30, g=0.52, b=0.90, a=1}, -- astral power
	color9 = {r=0.788, g=0.259, b=0.992, a=1}, -- fury
	color10 = {r=1.00, g=0.61, b=0.00, a=1} -- pain
})


-- Mana Alt status
ManaAlt.GetColor = Grid2.statusLibrary.GetColor

local validClasses
local validUnits = {}

local function ManaAlt_UnitUpdated(_, unit)
	local _, class = UnitClass(unit)
	validUnits[unit] = validClasses[class]
end

function ManaAlt:RefreshAllUnits()
	self:UpdateDB()
	wipe(validUnits)
	for unit in Grid2:IterateRosterUnits() do
		ManaAlt_UnitUpdated(nil, unit)
		self:UpdateIndicators(unit)
	end
end

function ManaAlt:OnEnable()
	status_OnEnable(self)
	Grid2.RegisterMessage( validUnits, "Grid_UnitUpdated", ManaAlt_UnitUpdated )
end

function ManaAlt:OnDisable()
	status_OnDisable(self)
	Grid2.UnregisterMessage( validUnits, "Grid_UnitUpdated", ManaAlt_UnitUpdated )
	wipe(validUnits)
	validClasses = nil	
end

function ManaAlt:UpdateUnitPower(unit, powerType, event)
	if event=='UNIT_DISPLAYPOWER' or (powerType=='MANA' and validUnits[unit]) then
		self:UpdateIndicators(unit)
	end	
end

function ManaAlt:IsActiveStandard(unit)
	return validUnits[unit] and UnitPowerType(unit) ~= 0
end

function ManaAlt:IsActiveAlways(unit)
	return validUnits[unit]
end

function ManaAlt:GetPercent(unit)
	local m = UnitPowerMax(unit,0)
	return m == 0 and 0 or UnitPower(unit,0) / m
end

function ManaAlt:GetText(unit)
	return fmt("%.1fk", UnitPower(unit,0) / 1000)
end

function ManaAlt:UpdateDB()
	validClasses = self.dbx.classes
	self.IsActive = self.dbx.showDefault and self.IsActiveAlways or self.IsActiveStandard	
end

Grid2.setupFunc["manaalt"] = function(baseKey, dbx)
	Grid2:RegisterStatus(ManaAlt, {"percent", "text", "color"}, baseKey, dbx)
	ManaAlt:UpdateDB()
	return ManaAlt
end

Grid2:DbSetStatusDefaultValue( "manaalt", {type = "manaalt", classes = {PRIEST=true}, color1={r=0,g=0,b=1,a=1}} )
