--[[
Created by Grid2 original authors, modified by Michael
--]]

local Mana = Grid2.statusPrototype:new("mana",false)
local LowMana = Grid2.statusPrototype:new("lowmana",false)
local PowerAlt= Grid2.statusPrototype:new("poweralt",false)

local max = math.max
local fmt = string.format
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

local EnableManaFrame
do
	local frame
	local count = 0
	local function Frame_OnEvent(self, event, unit, powerType)
		if powerType == "MANA" then
			if Mana.enabled then 
				Mana:UpdateIndicators(unit) 
			end
			if LowMana.enabled then
				LowMana:UpdateIndicators(unit)
			end
		else
			if PowerAlt.enabled and powerType == "ALTERNATE" then
				PowerAlt:UpdateIndicators(unit)
			end	
		end
	end
	function EnableManaFrame(enable)
		local prev = (count == 0)
		if enable then
			count = count + 1
		else
			count = count - 1
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

function Mana:OnEnable()
	EnableManaFrame(true)
end

function Mana:OnDisable()
	EnableManaFrame(false)
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



function LowMana:OnEnable()
	EnableManaFrame(true)
end

function LowMana:OnDisable()
	EnableManaFrame(false)
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



function PowerAlt:OnEnable()
	EnableManaFrame(true)
end

function PowerAlt:OnDisable()
	EnableManaFrame(false)
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
