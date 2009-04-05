local Mana = Grid2.statusPrototype:new("mana")
local LowMana = Grid2.statusPrototype:new("lowmana")

local EnableManaFrame
do
	local frame
	local count = 0
	local function Frame_OnEvent(self, event, unit)
		if (event ~= "UNIT_MANA" or UnitPowerType(unit) == 0) then
			if Mana.enabled then Mana:UpdateIndicators(unit) end
			if (LowMana.enabled) then
				LowMana:UpdateIndicators(unit)
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
				frame:UnregisterEvent("UNIT_MANA")
				frame:UnregisterEvent("UNIT_MAXMANA")
				frame:UnregisterEvent("UNIT_DISPLAYPOWER")
			else
				frame:SetScript("OnEvent", Frame_OnEvent)
				frame:RegisterEvent("UNIT_MANA")
				frame:RegisterEvent("UNIT_MAXMANA")
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

function Mana:GetText(unit)
	return Grid2:GetShortNumber(UnitMana(unit))
end

Grid2:RegisterStatus(Mana, { "percent" })


LowMana.defaultDB = {
	profile = {
		threshold = 0.25,
		color1 = { r = 0, g = 0, b = 1, a = 1 },
	}
}

function LowMana:OnEnable()
	EnableManaFrame(true)
end

function LowMana:OnDisable()
	EnableManaFrame(false)
end

function LowMana:IsActive(unit)
	return UnitPowerType(unit) == 0 and Mana:GetPercent(unit) < self.db.profile.threshold
end

function LowMana:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(LowMana, { "color" })
