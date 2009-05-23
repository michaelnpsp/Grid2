
local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
local spellDB = {
	[BZ["Karazhan"]] = { 37066, 29522, 29511, 30753, 30115, 30843 },
	[BZ["Zul'Aman"]] = { 42389, 43657, 43622, 43299, 43303, 43613, 43501, 43093, 43095, 43150 },
	[BZ["Serpentshrine Cavern"]] = { 39042, 39044, 38235, 38246, 37850, 38023, 38024, 38025, 37676, 37641, 37749, 38280, },
	[BZ["Tempest Keep"]] = { 37123, 37120, 37118, 42783, 37027, 36798, },
	[BZ["Hyjal Summit"]] = { 31249, 31306, 31347, 31341, 31344, 31944, 31972, },
	[BZ["Black Temple"]] = { 34654, 39674, 41150, 41168, 39837, 40239, 40251, 40604, 40481, 40508, 42005, 41303, 41410, 41376, 40860, 41001, 41485, 41472, 41914, 41917, 40585, 40932, },
	[BZ["Sunwell Plateau"]] = { 46561, 46562, 46266, 46557, 46560, 46543, 46427, 45032, 45034, 45018, 46384, 45150, 45855, 45662, 45402, 45717, 45256, 45333, 46771, 45270, 45347, 45348, 45996, 45442, 45641, 45885, 45737, 45740, 45741, },
--	[BZ["Ulduar"]] = { 62928, 62589, 63571, 62532, 62589, 61969, 61990, 62469, 62470, 62548, 62997, 63476, 62680, 63472, 62717, 63477, 64290, 64292, 62042, 62130, 63024, 64234, 63018, 63473, 65121, 63666, 64529, 64668, 65026 },
	[BZ["Ulduar"]] = { 62928, 63612, 63673, 63615, 64705, 64706, 62589, 63571, 62532, 62861, 62930, 62469, 61969, 61990, 62188, 62548, 63476, 62680, 63472, 62717, 63477, 64290, 64292, 63355, 64002, 62055, 62042, 62130, 62526, 62470, 62331, 62418, 63024, 64234, 63018, 65121, 61888, 64637, 62269, 63490, 61903, 63493, 63666, 65026, 62997, 64529, 64668, 63276, 63322, 63830, 63802, 63042, 64156, 64153, 64157, 64152, 64125, 64126, 63050 },
}


local GSRD = Grid2:NewModule("StatusRaidDebuffs")
local status = Grid2.statusPrototype:new("raid-debuffs")
local frame = CreateFrame("Frame")
local spells = {}

function GSRD:UpdateZoneSpells(zone)
	wipe(spells)
	local zone = zone or GetRealZoneText()
	local db = spellDB[zone]
	if db then
		for _, spellId in ipairs(db) do
			local name = GetSpellInfo(spellId)
			if name then
				local found
				for _, s in ipairs(spells) do
					if s == name then
						found = true
						break
					end
				end
				if not found then
					spells[#spells + 1] = name
				end
			end
		end
	end
	if #spells == 0 then
		frame:UnregisterEvent("UNIT_AURA")
	else
		frame:RegisterEvent("UNIT_AURA")
	end
end

function status:OnEnable()
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	GSRD:UpdateZoneSpells()
end

function status:OnDisable()
	frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

local states = {}
local textures = {}
local counts = {}
local types = {}
local durations = {}
local expirations = {}

function status:IsActive(unit)
	return states[unit]
end

function status:GetIcon(unit)
	return textures[unit]
end

function status:GetColor(unit)
	return 1, 0, 0
end

function status:GetCount(unit)
	return counts[unit]
end

function status:GetDuration(unit)
	return durations[unit]
end

function status:GetExpirationTime(unit)
	return expirations[unit]
end

local UnitDebuff = UnitDebuff
local ipairs = ipairs
frame:SetScript("OnEvent", function (self, event, ...)
	if event == "UNIT_AURA" then
		local unit = ...
		local spellIndex
		local auraIndex
		local index = 1
		while true do
			local name = UnitDebuff(unit, index)
			if not name then break end
			for i, n in ipairs(spells) do
				if name == n then
					if not spellIndex or i < spellIndex then
						auraIndex = index
						spellIndex = i
					end
					break
				end
			end
			index = index + 1
		end
		if spellIndex then
			local p_state = states[unit]
			local p_texture = textures[unit]
			local p_count = counts[unit]
			local p_type = types[unit]
			local p_duration = durations[unit]
			local p_expiration = expirations[unit]

			local n_state, n_texture, n_count, n_expiration, n_duration, _
			n_state = true
			_, _, n_texture, n_count, n_type, n_duration, n_expiration = UnitDebuff(unit, auraIndex)

			if
				p_state ~= n_state or
				p_texture ~= n_texture or
				p_count ~= n_count or
				p_type ~= n_type or
				p_duration ~= n_duration or
				p_expiration ~= n_expiration
			then
				states[unit] = n_state
				textures[unit] = n_texture
				counts[unit] = n_count
				types[unit] = n_type
				durations[unit] = n_duration
				expirations[unit] = n_expiration
				status:UpdateIndicators(unit)
			end
		elseif states[unit] then
			states[unit] = nil
			status:UpdateIndicators(unit)
		end
	else
		GSRD:UpdateZoneSpells()
	end
end)

Grid2:RegisterStatus(status, { "icon" })

local prev_MakeDefaultSetup = Grid2.MakeDefaultSetup
function Grid2:MakeDefaultSetup(...)
	local setup, class = prev_MakeDefaultSetup(self, ...)

	local setupIndicator = setup.status
	self:SetupIndicatorStatus(setupIndicator, "icon-center", "raid-debuffs", 1000)

	return setup, class
end
--[[
/dump Grid2.db.profile.setup.status["icon-center"]
/dump Grid2.db.profile.setup.status["corner-bottomright"]
/dump Grid2.statuses["raid-debuffs"]
--]]
