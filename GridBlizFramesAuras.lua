-- BlizFramesAuras management API
if not Grid2.isMidnight then return end

local lib = {}

local next = next
local strfind = strfind
local min = math.min
local GetUnitAuras = C_UnitAuras.GetUnitAuras
local GetUnitAuraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID

local enabled
local callbacks = {}
local unit2frame = {}
local resultTable = {}

--------------------------------------------------------------------------
-- Init & Update
--------------------------------------------------------------------------

function lib.UpdateUnit(frame)
	if enabled then
		local unit = frame.unit
		if unit and not strfind(unit, "^nameplate") then -- skip nameplates
			unit2frame[unit] = frame
			for _, func in next, callbacks do
				func(unit)
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
			callbacks[obj] = function(unit) obj[func](obj, "LBF_UNIT_AURA", unit) end
		else
			callbacks[obj] = function(unit) func(obj, "LBF_UNIT_AURA", unit) end
		end
	else
		callbacks[obj] = function(unit) func("LBF_UNIT_AURA", unit) end
	end
end

function lib.UnregisterCallback(obj)
	callbacks[obj] = nil
	if not next(callbacks) then
		lib.Deinitialize()
	end
end

--------------------------------------------------------------------------
-- Functions to access Blizzard unit frames Get Auras
--------------------------------------------------------------------------

local function GetAuras(unit, key, filter, max, sortRule, sortDir, onlyIDs, result)
	result = result or resultTable
	wipe(result)
	local frame = unit2frame[unit]
	if frame then
		local aurasFrame = frame[key]
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
	elseif filter then -- fallback to standard filter
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

local FILTER2FUNC = {
	["HELPFUL"] = lib.GetUnitBuffs,
	["HELPFUL|PLAYER"] = lib.GetUnitBuffs,
	["HELPFUL|RAID"] = lib.GetUnitBuffs,
	["HELPFUL|EXTERNAL_DEFENSIVE"] = lib.GetUnitBuffsDefensive,
	["HARMFUL"] = lib.GetUnitDebuffs,
	["HARMFUL|RAID"] = lib.GetUnitDebuffsDispellable,
}

function lib.GetUnitAuras(unit, filter, max, sortRule, sortDir, onlyIDs, result)
	local func = FILTER2FUNC[filter] or lib.GetUnitBuffs
	return func(unit, filter, max, sortRule, sortDir, onlyIDs, result)
end

-- Publish our internal library
Grid2.BlizFramesAuras = lib
