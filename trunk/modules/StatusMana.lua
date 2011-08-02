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

local statuses= {}  -- Enabled powertype statuses

local EnableManaFrame
do
	local frame
	local count = 0
	local function Frame_OnEvent(self, event, unit, powerType)
		for status in next,statuses do
			status:UpdateUnitPower(unit, powerType)
		end
	end
	function EnableManaFrame(enable, status)
		local prev = (count == 0)
		if enable then
			count = count + 1
			statuses[status]= true
		else
			count = count - 1
			statuses[status]= nil
		end
		assert(count >= 0)
		local curr = (count == 0)
		if prev ~= curr then
			if not frame then
				frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			end
			if curr then
				frame:SetScript("OnEvent", nil)
				frame:UnregisterEvent("UNIT_POWER")
				frame:UnregisterEvent("UNIT_MAXPOWER")
				frame:UnregisterEvent("UNIT_DISPLAYPOWER")
			else
				frame:SetScript("OnEvent", Frame_OnEvent)
				frame:RegisterEvent("UNIT_POWER")
				frame:RegisterEvent("UNIT_MAXPOWER")
				frame:RegisterEvent("UNIT_DISPLAYPOWER")
			end
		end
	end
end

-- Mana status

function Mana:UpdateUnitPower(unit, powerType)
	if powerType=="MANA" then
		self:UpdateIndicators(unit)
	end
end

function Mana:OnEnable()
	EnableManaFrame(true, self)
end

function Mana:OnDisable()
	EnableManaFrame(false, self)
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

function Mana:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Mana, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(Mana)

	return Mana
end

Grid2.setupFunc["mana"] = Create


-- Low Mana status

function LowMana:UpdateUnitPower(unit, powerType)
	if powerType=="MANA" then
		self:UpdateIndicators(unit)
	end
end

function LowMana:OnEnable()
	EnableManaFrame(true, self)
end

function LowMana:OnDisable()
	EnableManaFrame(false, self)
end

function LowMana:IsActive(unit)
	return (UnitPowerType(unit) == 0) and (Mana:GetPercent(unit) < self.dbx.threshold)
end

function LowMana:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(LowMana, {"color"}, baseKey, dbx)

	return LowMana
end

Grid2.setupFunc["lowmana"] = Create


-- Alternative power status

function PowerAlt:UpdateUnitPower(unit, powerType)
	if powerType=="ALTERNATE" then
		self:UpdateIndicators(unit)
	end
end

function PowerAlt:OnEnable()
	EnableManaFrame(true, self)
end

function PowerAlt:OnDisable()
	EnableManaFrame(false, self)
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

function PowerAlt:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(PowerAlt, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(PowerAlt)

	return PowerAlt
end

Grid2.setupFunc["poweralt"] = Create


-- Power status

local powerColors= {}

function Power:UpdateUnitPower(unit, powerType)
   if UnitIsPlayer(unit) and powerColors[ powerType ] then
		self:UpdateIndicators(unit)
	end
end

function Power:OnEnable()
	EnableManaFrame(true, self)
end

function Power:OnDisable()
	EnableManaFrame(false, self)
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
	powerColors["MANA"]= self.dbx.color1 
	powerColors["RAGE"]= self.dbx.color2 
	powerColors["FOCUS"]= self.dbx.color3
	powerColors["ENERGY"]= self.dbx.color4
	powerColors["RUNICPOWER"]= self.dbx.color5
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Power, {"percent", "text", "color"}, baseKey, dbx)
	Grid2:MakeTextHandler(Power)
	Power:UpdateDB()
	return Power
end

Grid2.setupFunc["power"] = Create
