--[[
Created by Grid2 original authors, modified by Michael
--]]

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

function Mana:GetTextDefault(unit)
	return fmt("%.1fk", UnitMana(unit) / 1000)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Mana, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(Mana)

	return Mana
end

Mana.GetColor = status_GetColor
Mana.OnEnable = status_OnEnable
Mana.OnDisable= status_OnDisable

Grid2.setupFunc["mana"] = Create

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

function PowerAlt:GetTextDefault(unit)
	local power= UnitPower(unit,10)
	if power>=1000 then
		return fmt("%.1fk", power / 1000)
	else
		return tostring( max(power,0) )	
	end
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(PowerAlt, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(PowerAlt)

	return PowerAlt
end

PowerAlt.GetColor = status_GetColor
PowerAlt.OnEnable = status_OnEnable
PowerAlt.OnDisable= status_OnDisable

Grid2.setupFunc["poweralt"] = Create

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

function Power:GetTextDefault(unit)
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
	Grid2:MakeTextHandler(Power)
	Power:UpdateDB()
	return Power
end

Power.OnEnable = status_OnEnable
Power.OnDisable= status_OnDisable

Grid2.setupFunc["power"] = Create
