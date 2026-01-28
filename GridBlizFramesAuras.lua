-- BlizFramesAuras management API
if not Grid2.isMidnight then return end

local lib = {}

local next = next
local strfind = strfind
local min = math.min
local GetUnitAuras = C_UnitAuras.GetUnitAuras
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetUnitAuraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID

local rosterUnits = Grid2.roster_guids

local enabled
local callbacks = {}
local unit2frame = {}
local resultTable = {}

local FILTER2BLIZKEY = {
	["HELPFUL"] = "buffFrames",
	["HELPFUL|PLAYER"] = "buffFrames",
	["HELPFUL|RAID"] = "buffFrames",
	["HELPFUL|RAID_IN_COMBAT"] = "buffFrames",
	["HELPFUL|PLAYER|RAID_IN_COMBAT"] = "buffFrames",
	["HELPFUL|RAID_IN_COMBAT|PLAYER"] = "buffFrames",
	["HELPFUL|EXTERNAL_DEFENSIVE"] = "CenterDefensiveBuff",
	["HARMFUL"] = "debuffFrames",
	["HARMFUL|RAID"] = "dispelDebuffFrames",
	['HARMFUL|RAID_PLAYER_DISPELLABLE'] = "dispelDebuffFrames",
}

--------------------------------------------------------------------------
-- Init & Update
--------------------------------------------------------------------------

function lib.UpdateUnit(frame)
	if enabled then
		local unit = frame.unit
		if unit and not strfind(unit, "^nameplate") then -- skip nameplates
			unit2frame[unit] = frame
			if rosterUnits[unit] then
				for _, func in next, callbacks do
					func(unit)
				end
			end
		end
	end
end

function lib.InitCache()
	local function save(frameName)
		local frame = _G[frameName]
		if frame and frame.unit and frame:IsShown()  then
			unit2frame[frame.unit] = frame
		end
	end
	for i = 1, 4 do
		save("CompactPartyFrameMember"..i)
	end
	for i = 1, 40 do
		save("CompactRaidFrame"..i)
	end
	lib.Initialize = lib.InitCache
	enabled = true
end

function lib.Initialize()
	hooksecurefunc("CompactUnitFrame_UpdateAuras", lib.UpdateUnit)
	lib.InitCache()
end

function lib.Deinitialize()
	wipe(unit2frame)
	enabled = nil
end

--------------------------------------------------------------------------
-- Callbacks registration
--------------------------------------------------------------------------

function lib.RegisterCallback(obj, func)
	if not next(callbacks) then
		lib.Initialize()
	end
	if type(obj)=='table' then
		if type(func)=='string' then
			callbacks[obj] = function(unit) obj[func](obj, "LBA_UNIT_AURA", unit) end
		else
			callbacks[obj] = function(unit) func(obj, "LBA_UNIT_AURA", unit) end
		end
	else
		callbacks[obj] = function(unit) func("LBA_UNIT_AURA", unit) end
	end
end

function lib.UnregisterCallback(obj)
	callbacks[obj] = nil
	if not next(callbacks) then
		lib.Deinitialize()
	end
end

--------------------------------------------------------------------------
-- Functions to check Blizzard unit frames Auras
--------------------------------------------------------------------------

local function HasAuras(unit, key, filter)
	local frame = unit2frame[unit]
	if frame then
		local aurasFrame = frame[key]
		if aurasFrame then
			local auraInstanceID = aurasFrame.auraInstanceID
			if #aurasFrame>0 then -- buffs & debuffs otherwise DefensiveBuff
				aurasFrame = aurasFrame[1]
			end
			return aurasFrame:IsShown() and aurasFrame.auraInstanceID
		end
	end
	if filter then -- fallback to standard filter
		local aura = GetAuraDataByIndex(unit, 1, filter)
		return aura and aura.auraInstanceID
	end
	return nil
end

function lib.UnitHasBuffs(unit, filter)
	return HasAuras(unit, "buffFrames", filter)
end

function lib.UnitHasBuffsDefensive(unit, filter)
	return HasAuras(unit, "CenterDefensiveBuff", filter)
end

function lib.UnitHasDebuffs(unit, filter)
	return HasAuras(unit, "debuffFrames", filter)
end

function lib.UnitHasDebuffsDispellable(unit, filter)
	return HasAuras(unit, "dispelDebuffFrames", filter)
end

function lib.UnitHasAuras(unit, filter)
	return HasAuras(unit, FILTER2BLIZKEY[filter] or "buffFrames", filter)
end

--------------------------------------------------------------------------
-- Functions to get Blizzard unit frames Auras
--------------------------------------------------------------------------

local function GetAuras(unit, key, filter, max, sortRule, sortDir, onlyIDs, result)
	result = result or resultTable
	wipe(result)
	local frame = unit2frame[unit]
	if frame then
		local aurasFrame = frame[key]
		if aurasFrame then
			local count = min(#aurasFrame, max or 8)
			if count>0 then
				for i=1, count do
					local auraFrame = aurasFrame[i]
					if not auraFrame:IsShown() then break end
					local auraInstanceID = auraFrame.auraInstanceID
					if auraInstanceID then
						result[#result+1] = onlyIDs and auraInstanceID or GetAuraDataByAuraInstanceID(unit, auraInstanceID)
					end
				end
			else
				local auraInstanceID = aurasFrame.auraInstanceID
				if auraInstanceID then
					result[1] = onlyIDs and auraInstanceID or GetAuraDataByAuraInstanceID(unit, auraInstanceID)
				end
			end
			return result
		end
	end
	if filter then -- fallback to standard filter
		if onlyIDs then
			return GetUnitAuraInstanceIDs(unit, filter, max or 8, sortRule, sortDir)
		else
			return GetUnitAuras(unit, filter, max or 8, sortRule, sortDir)
		end
	end
	return result
end

function lib.GetUnitBuffs(unit, filter, max, sortRule, sortDir, onlyIDs, result)
	return GetAuras(unit, "buffFrames", filter, max, sortRule, sortDir, onlyIDs, result)
end

function lib.GetUnitBuffsDefensive(unit, filter, max, sortRule, sortDir, onlyIDs, result)
	return GetAuras(unit, "CenterDefensiveBuff", filter, max, sortRule, sortDir, onlyIDs, result)
end

function lib.GetUnitDebuffs(unit, filter, max, sortRule, sortDir, onlyIDs, result)
	return GetAuras(unit, "debuffFrames", filter, max, sortRule, sortDir, onlyIDs, result)
end

function lib.GetUnitDebuffsDispellable(unit, filter, max, sortRule, sortDir, onlyIDs, result)
	return GetAuras(unit, "dispelDebuffFrames", filter, max, sortRule, sortDir, onlyIDs, result)
end

function lib.GetUnitAuras(unit, filter, max, sortRule, sortDir, onlyIDs, result)
	return GetAuras(unit, FILTER2BLIZKEY[filter] or "buffFrames", filter, max, sortRule, sortDir, onlyIDs, result)
end

-- Publish our internal library
Grid2.BlizFramesAuras = lib
