local AuraFrame_OnEvent

local EnableAuraFrame
do
	local frame
	local count = 0
	function EnableAuraFrame(enable)
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
				frame:UnregisterEvent("UNIT_AURA")
				frame:UnregisterEvent("UNIT_AURASTATE")
			else
				frame:SetScript("OnEvent", AuraFrame_OnEvent)
				frame:RegisterEvent("UNIT_AURA")
				frame:RegisterEvent("UNIT_AURASTATE")
			end
		end
	end
	Grid2.EnableAuraFrame = EnableAuraFrame
end

local DebuffCache = {}
local DebuffTypeStatus = {}

function CreateDebuffType(baseKey, dbx)
	local type = dbx.subType

	local c = {}
	DebuffCache[type] = c

	local status = Grid2.statusPrototype:new(baseKey)
	DebuffTypeStatus[type] = status

	status.debuffType = type
	status.dbx = dbx

	function status:OnEnable()
		EnableAuraFrame(true)
	end

	function status:OnDisable()
		EnableAuraFrame(false)
	end

	function status:IsActive(unit)
		return c[unit] ~= nil
	end

	function status:GetBorder(unit)
		return 1
	end

	function status:GetColor(unit)
		local color = self.dbx.color1
		return color.r, color.g, color.b, color.a
	end

	function status:GetIcon(unit)
		return c[unit]
	end

	Grid2:RegisterStatus(status, { "color", "icon" }, baseKey, dbx)
	return status
end

local StatusCount = 0
local BuffHandlers, DebuffHandlers = {}, {}

local MakeStatusFilter
do
	local filter_mt = {
		__index = function (self, unit)
			local _, class = UnitClass(unit)
			local result = self.source[class]
			self[unit] = result
		end,
	}
	local filters = {}
	MakeStatusFilter = function(status)
		local dbx = status.dbx
		local source, dest = dbx.classFilter, status.filtered
		if not source then
			if dest then
				filters[dest] = nil
				status.filtered = nil
				dest = nil
			end
		elseif dest then
			wipe(dest)
			dest.source = source
		else
			dest = setmetatable({source = dbx.classFilter}, filter_mt)
			status.filtered = dest
			filters[dest] = true
		end
		return dest
	end

	local next = next
	local Grid2_UnitIsPet = Grid2.UnitIsPet
	local function status_ClearFilterUnit(_, unit)
		if Grid2_UnitIsPet(nil, unit) then return end -- hackish
		for filter in next, filters do
			filter[unit] = nil
		end
	end

	Grid2.RegisterMessage(filter_mt, "Grid_UnitJoined", status_ClearFilterUnit)
	Grid2.RegisterMessage(filter_mt, "Grid_UnitChanged", status_ClearFilterUnit)
end

local function status_Reset(self, unit)
	self.prev_state = self:IsActive(unit)
	self.new_state = nil
	self.prev_count = self.counts[unit]
	self.prev_expiration = self.expirations[unit]
	self.states[unit] = nil
	self.expirations[unit] = nil
end

local function status_IsInactive(self, unit) -- used for "missing" status
	local filtered = self.filtered
	if filtered and filtered[unit] then return nil end
	return not self.states[unit]
end

local function status_IsActive(self, unit)
	local filtered = self.filtered
	if filtered and filtered[unit] then return nil end
	return self.states[unit]
end

local status_IsActiveBlink, status_IsInactiveBlink
do
	local GetTime = GetTime
	status_IsActiveBlink = function (self, unit)
		local filtered = self.filtered
		if (filtered and filtered[unit]) or not self.states[unit] then return nil end
		if self.expirations[unit] - GetTime() < self.blinkThreshold then
			return "blink"
		else
			return true
		end
	end
	status_IsInactiveBlink = function (self, unit)
		-- does this really make sense ?
		local filtered = self.filtered
		if filtered and filtered[unit] then return nil end
		if not self.states[unit] then return true end
		if self.expirations[unit] - GetTime() < self.blinkThreshold then
			return "blink"
		else
			return false
		end
	end
end

local function status_GetIcon(self, unit)
	return self.textures[unit]
end

local function status_GetIconMissing(self, unit)
	return self.missingTexture
end

local function status_GetCount(self, unit)
	return self.counts[unit]
end

local function status_GetDuration(self, unit)
	return self.durations[unit]
end

local function status_GetExpirationTime(self, unit)
	return self.expirations[unit]
end

local function status_GetPercent(self, unit)
	local color = self.dbx.color1
	return color.a
end

local function status_UpdateState(self, unit, auraName, iconTexture, count, duration, expiration)
	if self.auraName == auraName then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.new_state = self:IsActive(unit)
		self.new_count = count
		self.new_expiration = expiration
	end
end

local function status_UpdateStateMine(self, unit, auraName, iconTexture, count, duration, expiration, isMine)
	if self.auraName == auraName and isMine then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.new_state = self:IsActive(unit)
		self.new_count = count
		self.new_expiration = expiration
	end
end

local function status_UpdateStateNotMine(self, unit, auraName, iconTexture, count, duration, expiration, isMine)
	if self.auraName == auraName and not isMine then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.new_state = self:IsActive(unit)
		self.new_count = count
		self.new_expiration = expiration
	end
end

local function status_HasStateChanged(self, unit)
	return (self.new_state ~= self.prev_state) or (self.new_count ~= self.prev_count) or (self.new_expiration ~= self.prev_expiration)
end

local AddTimeTracker, RemoveTimeTracker
do
	local next = next
	local timetracker
	AddTimeTracker = function (status, value)
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame)
		timetracker.tracked = {}
		timetracker:SetScript("OnUpdate", function (self, elapsed)
			local time = GetTime()
			for status, value in next, self.tracked do
				for unit, expiration in next, status.expirations do
					local timeLeft = expiration - time
					if (timeLeft < value) ~= (timeLeft + elapsed < value) then
						status:UpdateIndicators(unit)
					end
				end
			end
		end)
		AddTimeTracker = function (status, value)
			timetracker.tracked[status] = value
			timetracker:Show()
		end
		RemoveTimeTracker = function (status)
			timetracker.tracked[status] = nil
			if not next(timetracker.tracked) then
				timetracker:Hide()
			end
		end
		return AddTimeTracker(status, value)
	end
end

local function status_UpdateDB(self)
	local dbx = self.dbx
	MakeStatusFilter(self)
	local blinkThreshold, missing = dbx.blinkThreshold, dbx.missing
	if blinkThreshold then
		self.blinkThreshold = blinkThreshold
		self.IsActive = missing and status_IsInactiveBlink or status_IsActiveBlink
		AddTimeTracker(self, blinkThreshold)
	else
		self.blinkThreshold = nil
		self.IsActive = missing and status_IsInactive or status_IsActive
		if RemoveTimeTracker then
			RemoveTimeTracker(self)
		end
	end
	self.GetIcon = dbx.missing and status_GetIconMissing or status_GetIcon
end


function Grid2.CreateAuraCommon(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey)

	local spellName = dbx.spellName
	if (type(spellName) == "number") then
		spellName = GetSpellInfo(spellName)
	end
	assert(type(spellName) == "string", "Bad spellName: " .. tostring(dbx.spellName) .. " for " .. tostring(baseKey))

	status.auraName = spellName
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}

	status.Reset = status_Reset
	status.GetIcon = dbx.missing and status_GetIconMissing or status_GetIcon
	status.GetCount = status_GetCount
	status.GetDuration = status_GetDuration
	status.GetExpirationTime = status_GetExpirationTime
	status.GetPercent = status_GetPercent
	status.HasStateChanged = status_HasStateChanged
	status.UpdateDB = status_UpdateDB

	return status
end

local statusTypes = { "color", "icon" }
function Grid2.CreateBuff(baseKey, dbx, statusTypesOverride)
	local status = Grid2.CreateAuraCommon(baseKey, dbx)

	function status:OnEnable()
		self:UpdateDB()
		EnableAuraFrame(true)
		BuffHandlers[self] = true
	end

	function status:OnDisable()
		EnableAuraFrame(false)
		BuffHandlers[self] = nil
	end

	if dbx.missing then
		-- Initialize the texture for "missing" status
		-- Note that this means missing statuses only ever display this one texture
		local _, _, texture = GetSpellInfo(dbx.spellName)
		status.missingTexture = texture
	end

	if dbx.mine == 2 then
		status.UpdateState = status_UpdateStateNotMine
	elseif dbx.mine then
		status.UpdateState = status_UpdateStateMine
	else
		status.UpdateState = status_UpdateState
	end

	Grid2:RegisterStatus(status, statusTypesOverride or statusTypes, baseKey, dbx)
	Grid2:MakeBuffColorHandler(status)
	status:UpdateDB()

	return status
end

function Grid2.CreateDebuff(baseKey, dbx, statusTypesOverride)
	local status = Grid2.CreateAuraCommon(baseKey, dbx)

	function status:OnEnable()
		self:UpdateDB()
		EnableAuraFrame(true)
		DebuffHandlers[self] = true
	end

	function status:OnDisable()
		EnableAuraFrame(false)
		DebuffHandlers[self] = nil
	end

	status.UpdateState = status_UpdateState

	Grid2:RegisterStatus(status, statusTypesOverride or statusTypes, baseKey, dbx)
	Grid2:MakeDebuffColorHandler(status)

	return status
end

Grid2.setupFunc["buff"] = Grid2.CreateBuff
Grid2.setupFunc["debuff"] = Grid2.CreateDebuff
Grid2.setupFunc["debuffType"] = CreateDebuffType


do
	local indicators = {}
	local types = {}
	local next = next
	local myUnits = {
		player = true,
		pet = true,
		vehicle = true,
	}
	function AuraFrame_OnEvent(_, _, unit)
		local frames = Grid2:GetUnitFrames(unit)
		if not next(frames) then return end

		for status in next, DebuffHandlers do
			status:Reset(unit)
		end
		for status in next, BuffHandlers do
			status:Reset(unit)
		end
		-- scan Debuffs and find the available debuff types
		local i = 1
		while true do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, caster = UnitDebuff(unit, i)
			if not name then break end

			local isMine = myUnits[caster]
			for status in next, DebuffHandlers do
				status:UpdateState(unit, name, iconTexture, count, duration, expirationTime, isMine)
			end
			i = i + 1
			if debuffType and not types[debuffType] then
				types[debuffType] = iconTexture
			end
		end
		i = 1
		while true do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, caster = UnitBuff(unit, i)
			if not name then break end

			local isMine = myUnits[caster]
			for status in next, BuffHandlers do
				status:UpdateState(unit, name, iconTexture, count, duration, expirationTime, isMine)
			end
			i = i + 1
		end
		-- update the debuff cache and mark indicators that need updating
		for type, status in next, DebuffTypeStatus do
			if status.enabled then
				local debuff = types[type]
				local cache = DebuffCache[type]
				if cache[unit] ~= debuff then
					cache[unit] = debuff
					for indicator in next, status.indicators do
						indicators[indicator] = true
					end
				end
			end
			types[type] = nil
		end

		for status in next, DebuffHandlers do
			if status:HasStateChanged(unit) then
				for indicator in next, status.indicators do
					indicators[indicator] = true
				end
			end
		end
		for status in next, BuffHandlers do
			if status:HasStateChanged(unit) then
				for indicator in next, status.indicators do
					indicators[indicator] = true
				end
			end
		end
		-- Update indicators that needs updating only once.
		for indicator in next, indicators do
			indicators[indicator] = nil
			for frame in next, frames do
				indicator:Update(frame, unit)
			end
		end
	end
end
