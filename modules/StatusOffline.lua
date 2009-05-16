local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Offline = Grid2.statusPrototype:new("offline")

Offline.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = 1, a = 1 },
	}
}

local function Frame_RAID_ROSTER_UPDATE(self, _, unit)
	if (Offline.enabled) then
		Offline:UpdateIndicators(unit)
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
			else
				frame:SetScript("OnEvent", Frame_RAID_ROSTER_UPDATE)
				frame:RegisterEvent("RAID_ROSTER_UPDATE")
			end
		end
	end
end


function Offline:OnEnable()
	EnableRosterFrame(true)
end

function Offline:OnDisable()
	EnableRosterFrame(false)
end

function Offline:IsActive(unit)
	return not UnitIsConnected(unit)
end

function Offline:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function Offline:GetText(unit)
	if (UnitIsConnected(unit)) then
		return nil
	else
		return L["Offline"]
	end
end

function Offline:GetPercent(unit)
	return UnitIsConnected(unit) and 1 or self.db.profile.color1.a
end

Grid2:RegisterStatus(Offline, { "color", "text", "percent" })
