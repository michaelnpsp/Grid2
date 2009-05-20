local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local PvP = Grid2.statusPrototype:new("pvp")

PvP.defaultDB = {
	profile = {
		color1 = { r = 0, g = 1, b = 1, a = .75 },
	}
}

local function Frame_OnEvent(self, event, unitid)
	if (PvP.enabled) then
		if (event == "RAID_ROSTER_UPDATE") then
			PvP:UpdateIndicators(unitid)
		elseif (event == "UNIT_FACTION") then
			PvP:UpdateIndicators(unitid)
		elseif (event == "Grid_UnitJoined") then
			PvP:UpdateIndicators(unitid)
		else -- ZONE_CHANGED_NEW_AREA
			for guid, unitid in Grid2:IterateRoster() do
				PvP:UpdateIndicators(unitid)
			end
		end
	end
end

local EnableRosterFrame
do
	local frame
	local count = 0
	function EnableRosterFrame(enable)
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
				frame:UnregisterEvent("RAID_ROSTER_UPDATE")
				frame:UnregisterEvent("UNIT_FACTION")
				frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
				frame:UnregisterEvent("Grid_UnitJoined")
			else
				frame:SetScript("OnEvent", Frame_OnEvent)
				frame:RegisterEvent("RAID_ROSTER_UPDATE")
				frame:RegisterEvent("UNIT_FACTION")
				frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
				frame:RegisterEvent("Grid_UnitJoined")
			end
		end
	end
end


function PvP:OnEnable()
	EnableRosterFrame(true)
end

function PvP:OnDisable()
	EnableRosterFrame(false)
end

function PvP:IsActive(unitid)
	local _, instanceType = IsInInstance()
	if (instanceType == "pvp" or instanceType == "arena") then
		return nil
	else
		return UnitIsPVP(unitid) or UnitIsPVPFreeForAll(unitid)
	end
end

function PvP:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

local factionTexture, ffaTexture
local factionTexCoord, ffaTexCoord
local factionText, ffaText
do
	local faction = UnitFactionGroup("player")
	if (faction == "Horde") then
		factionTexture = [[Interface\PVPFrame\PVP-Currency-Horde]]
--		factionTexture = [[Interface\TargetingFrame\UI-PVP-Horde]]
		factionTexCoord = {0.08, 0.58, 0.045, 0.545}
	else
		factionTexture = [[Interface\PVPFrame\PVP-Currency-Alliance]]
--		factionTexture = [[Interface\TargetingFrame\UI-PVP-Alliance]]
		factionTexCoord = {0.07, 0.58, 0.06, 0.57}
	end
	factionText = L["PvP"]

	ffaTexture = [[Interface\TargetingFrame\UI-PVP-FFA]]
	--ToDo: add a TexCoord callback
	ffaTexCoord = {0.05, 0.605, 0.015, 0.57}
	ffaText = L["FFA"]
end

function PvP:GetIcon(unitid)
	if (UnitIsPVP(unitid)) then
		return factionTexture
	elseif (UnitIsPVPFreeForAll(unitid)) then
		return ffaTexture
	else
		return nil
	end
end

function PvP:GetPercent(unitid)
	return (UnitIsPVP(unitid) or UnitIsPVPFreeForAll(unitid)) and self.db.profile.color1.a
end

function PvP:GetText(unitid)
	if (UnitIsPVP(unitid)) then
		return factionText
	elseif (UnitIsPVPFreeForAll(unitid)) then
		return ffaText
	else
		return nil
	end
end

Grid2:RegisterStatus(PvP, { "color", "icon", "percent", "text" })

