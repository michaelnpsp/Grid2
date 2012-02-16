-- mana, lowmana, power, poweralt

local Mana = Grid2.statusPrototype:new("mana",false)
local LowMana = Grid2.statusPrototype:new("lowmana",false)
local Power = Grid2.statusPrototype:new("power",false)
local PowerAlt= Grid2.statusPrototype:new("poweralt",false)

local max = math.max
local fmt = string.format
local next = next
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitIsPlayer = UnitIsPlayer

local statuses= {}  -- Enabled statuses

-- Methods shared by all statuses
local status_OnEnable, status_OnDisable
do
	local frame
	local function Frame_OnEvent(self, event, unit, powerType)
		for status in next,statuses do
			status:UpdateUnitPower(unit, powerType)
		end
	end
	function status_OnEnable(status)
		if not next(statuses) then
			if not frame then frame = CreateFrame("Frame", nil, Grid2LayoutFrame) end
			frame:SetScript("OnEvent", Frame_OnEvent)
			frame:RegisterEvent("UNIT_POWER")
			frame:RegisterEvent("UNIT_MAXPOWER")
			frame:RegisterEvent("UNIT_DISPLAYPOWER")
		end
		statuses[status] = true
	end
	function status_OnDisable(status)
		statuses[status] = nil
		if (not next(statuses)) and frame then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_POWER")
			frame:UnregisterEvent("UNIT_MAXPOWER")
			frame:UnregisterEvent("UNIT_DISPLAYPOWER")
		end
	end
end

local function status_GetColor(self)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

-- Mana status
function Mana:UpdateUnitPower(unit, powerType)
	if powerType=="MANA" then
		self:UpdateIndicators(unit)
	end
end

function Mana:IsActive(unit)
	return UnitPowerType(unit) == 0
end

function Mana:GetPercent(unit)
	return UnitMana(unit) / UnitManaMax(unit)
end

function Mana:GetText(unit)
	return fmt("%.1fk", UnitMana(unit) / 1000)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Mana, {"percent", "text", "color"}, baseKey, dbx)

	return Mana
end

Mana.GetColor = status_GetColor
Mana.OnEnable = status_OnEnable
Mana.OnDisable= status_OnDisable

Grid2.setupFunc["mana"] = Create

Grid2:DbSetStatusDefaultValue( "mana", {type = "mana", color1= {r=0,g=0,b=1,a=1}} )

-- Low Mana status
function LowMana:UpdateUnitPower(unit, powerType)
	if powerType=="MANA" then
		self:UpdateIndicators(unit)
	end
end

function LowMana:IsActive(unit)
	return (UnitPowerType(unit) == 0) and (Mana:GetPercent(unit) < self.dbx.threshold)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(LowMana, {"color"}, baseKey, dbx)
	return LowMana
end

LowMana.GetColor  = status_GetColor
LowMana.OnEnable  = status_OnEnable
LowMana.OnDisable = status_OnDisable

Grid2.setupFunc["lowmana"] = Create

Grid2:DbSetStatusDefaultValue( "lowmana", {type = "lowmana", threshold = 0.75, color1 = {r=0.5,g=0,b=1,a=1}})

-- Alternative power status
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

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(PowerAlt, {"percent", "text", "color"}, baseKey, dbx)

	return PowerAlt
end

PowerAlt.GetColor = status_GetColor
PowerAlt.OnEnable = status_OnEnable
PowerAlt.OnDisable= status_OnDisable

Grid2.setupFunc["poweralt"] = Create

Grid2:DbSetStatusDefaultValue( "poweralt", {type = "poweralt", color1= {r=1,g=0,b=0.5,a=1}} )

-- Power status
local powerColors= {}

function Power:UpdateUnitPower(unit, powerType)
   if UnitIsPlayer(unit) and powerColors[ powerType ] then
		self:UpdateIndicators(unit)
	end
end

function Power:IsActive(unit)
  return UnitIsPlayer(unit)
end

function Power:GetPercent(unit)
	return UnitPower(unit) / UnitPowerMax(unit)
end

function Power:GetText(unit)
	local power= UnitPower(unit)
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
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Power, {"percent", "text", "color"}, baseKey, dbx)
	Power:UpdateDB()
	return Power
end

Power.OnEnable = status_OnEnable
Power.OnDisable = status_OnDisable

Grid2.setupFunc["power"] = Create

Grid2:DbSetStatusDefaultValue( "power", {type = "power", colorCount = 5, 
	color1 = {r=0,g=0.5,b=1  ,a=1},   -- mana
	color2 = {r=1,g=0  ,b=0  ,a=1},   -- rage
	color3 = {r=1,g=0.5,b=0  ,a=1},   -- focus
	color4 = {r=1,g=1  ,b=0  ,a=1},   -- energy
	color5 = {r=0,g=0.8,b=0.8,a=1},   -- runic power
})  
