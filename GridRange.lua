-- GridRange.lua
--
-- A TBC range library

--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

--}}}

GridRange = Grid2:NewModule("GridRange")

local ranges, checks
local select = select
local IsSpellInRange = IsSpellInRange
local CheckInteractDistance = CheckInteractDistance
local UnitIsVisible = UnitIsVisible
local BOOKTYPE_SPELL = BOOKTYPE_SPELL

local invalidSpells = {
	[GetSpellInfo(136)] = true,
	[GetSpellInfo(755)] = true,
}

local rezSpell, rezCheck
do
	local class = select(2, UnitClass("player"))
	if class == "DRUID" then
		rezSpell = GetSpellInfo(20484)
	elseif class == "PRIEST" then
		rezSpell = GetSpellInfo(2006)
	elseif class == "PALADIN" then
		rezSpell = GetSpellInfo(7328)
	elseif class == "SHAMAN" then
		rezSpell = GetSpellInfo(2008)
	end
end

local function addRange(range, check)
	-- 100 yards is the farthest possible range
	if range > 100 then return end

	if not checks[range] then
		ranges[#ranges + 1] = range
		table.sort(ranges)
		checks[range] = check
	end
end

local function checkRange10(unit)
	return CheckInteractDistance(unit, 3)
end

local function checkRange28(unit)
	return CheckInteractDistance(unit, 4)
end

local checkRange38 = UnitInRange
local checkRange100 = UnitIsVisible

local function initRanges()
	ranges, checks = {}, {}
	addRange(10, checkRange10)
	addRange(28, checkRange28)
	addRange(38, checkRange38)
	addRange(100, checkRange100)
end

function GridRange:ScanSpellbook()
	initRanges()

	-- using IsSpellInRange doesn't work for dead players.
	-- reschedule the spell scanning for when the player is alive
	if UnitIsDeadOrGhost("player") then
		self:RegisterEvent("PLAYER_UNGHOST", "ScanSpellbook")
		self:RegisterEvent("PLAYER_ALIVE", "ScanSpellbook")
	else
		self:UnregisterEvent("PLAYER_UNGHOST")
		self:UnregisterEvent("PLAYER_ALIVE")
	end

	local i = 1
	while true do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
		if not name then break end
		-- beneficial spell with a range
		if name == rezSpell then
			local index = i
			rezCheck = function (unit) return UnitIsDead(unit) and IsSpellInRange(index, BOOKTYPE_SPELL, unit) == 1 end
		end
		if not invalidSpells[name] and IsSpellInRange(i, BOOKTYPE_SPELL, "player") then
			local _, _, _, _, _, _, _, _, range = GetSpellInfo(name)
			if range then
				range = math.floor(range + 0.5)
				if range > 0 then
					local index = i -- we have to create an upvalue
					addRange(tonumber(range), function (unit) return IsSpellInRange(index, BOOKTYPE_SPELL, unit) == 1 end)
					self:Debug("%d %s (%s) has range %s", i, name, rank, range)
				end
			end
		end
		i = i + 1
	end

	self:SendMessage("Grid_RangesUpdated")
end

function GridRange:OnEnable()
	self.core.defaultModulePrototype.OnEnable(self)

	self:ScanSpellbook()
	self:RegisterEvent("LEARNED_SPELL_IN_TAB", "ScanSpellbook")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "ScanSpellbook")
end

function GridRange:GetUnitRange(unit)
	if not ranges then return end
	for _, range in ipairs(ranges) do
		if checks[range](unit) then
			return range
		end
	end
end

function GridRange:GetRezCheck()
	return rezCheck
end

function GridRange:GetRangeCheck(range)
	if not checks then return end
	local check = checks[range]
	if not check then
		local closest_range
		for _, r in ipairs(ranges) do
			if r < range then
				closest_range = r
			else
				break
			end
		end
		if closest_range then
			range = closest_range
			check = checks[range]
		end
	end
	return check, range
end

function GridRange:AvailableRangeIterator()
	local i = 0
	return function ()
		i = i + 1
		return ranges[i]
	end
end
