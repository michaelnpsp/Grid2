local update

local EnableAuraFrame
do
	local frame
	local count = 0
	local function Frame_OnEvent(self, event, unit)
		update(unit)
	end
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
				frame:SetScript("OnEvent", Frame_OnEvent)
				frame:RegisterEvent("UNIT_AURA")
				frame:RegisterEvent("UNIT_AURASTATE")
			end
		end
	end
end

local DebuffCache = {}
local function MakeDebuffTypeStatus(type, color)
	local name = "debuff-"..type

	local c = {}
	DebuffCache[type] = c

	local status = Grid2.statusPrototype:new(name)

	status.debuffType = type

	function status:OnEnable()
		EnableAuraFrame(true)
	end

	function status:OnDisable()
		EnableAuraFrame(false)
	end

	function status:IsActive(unit)
		return c[unit] ~= nil
	end

	status.defaultDB = {
		profile = {
			color = { r=color.r, g=color.g, b=color.b },
		}
	}

	function status:GetColor(unit)
		local color = self.db.profile.color
		return color.r, color.g, color.b, color.a
	end

	function status:GetIcon(unit)
		return c[unit]
	end

	Grid2:RegisterStatus(status, { "color", "icon" })
	return status
end

local DebuffTypeStatus = {}
for name, color in pairs(DebuffTypeColor) do
	if name ~= "none" then
		DebuffTypeStatus[name] = MakeDebuffTypeStatus(name, color)
	end
end

local StatusCount = 0
local BuffHandlers, DebuffHandlers = {}, {}
local function status_Reset(self, unit)
	self.prev_state = self:IsActive(unit)
	self.new_state = nil
	self.prev_count = self.counts[unit]
	self.states[unit] = nil
	self.expirations[unit] = nil
end

local function status_IsActive(self, unit)
	return self.states[unit]
end

local GetTime = GetTime
local function status_IsActiveBlink(self, unit)
	if not self.states[unit] then
		return
	elseif (self.expirations[unit] - GetTime()) < self.blinkThreshold then
		return "blink"
	else
		return true
	end
end

local function status_GetIcon(self, unit)
	return self.textures[unit]
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

local function status_UpdateState(self, unit, auraName, iconTexture, count, duration, expiration)
	if self.auraName == auraName then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.new_state = self:IsActive(unit)
		self.new_count = count
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
	end
end

local function status_HasStateChanged(self, unit)
	return (self.new_state ~= self.prev_state) or (self.new_count ~= self.prev_count)
end

local AddTimeTracker
do
	local timetracker
	AddTimeTracker = function (status, value)
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame)
		timetracker.tracked = {}
		timetracker:SetScript("OnUpdate", function (self, elapsed)
			local time = GetTime()
			for status, value in pairs(self.tracked) do
				local expirations = status.expirations
				for unit, expiration in pairs(expirations) do
					local timeLeft = expiration - time
					if (timeLeft < value) ~= (timeLeft + elapsed < value) then
						status:UpdateIndicators(unit)
					end
				end
			end
		end)
		AddTimeTracker = function (status, value)
			timetracker.tracked[status] = value
		end
		return AddTimeTracker(status, value)
	end
end

function Grid2:CreateBuffStatus(name, mine)
	if type(name) == "number" then name = GetSpellInfo(name) end
	assert(type(name) == "string")

	StatusCount = StatusCount + 1
	local status = Grid2.statusPrototype:new("buff-"..StatusCount)

	status.auraName = name
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}

	function status:OnEnable()
		EnableAuraFrame(true)
		BuffHandlers[self] = true
	end

	function status:OnDisable()
		EnableAuraFrame(false)
		BuffHandlers[self] = nil
	end

	status.Reset = status_Reset
	if type(mine) == "number" then
		status.blinkThreshold = mine
		status.IsActive = status_IsActiveBlink
		AddTimeTracker(status, mine)
	else
		status.IsActive = status_IsActive
	end
	status.GetIcon = status_GetIcon
	status.GetCount = status_GetCount
	status.GetDuration = status_GetDuration
	status.GetExpirationTime = status_GetExpirationTime
	status.UpdateState = mine and status_UpdateStateMine or status_UpdateState
	status.HasStateChanged = status_HasStateChanged

	return status -- status is not registered yet
end

function Grid2:CreateDebuffStatus(name, mine)
	if type(name) == "number" then name = GetSpellInfo(name) end
	assert(type(name) == "string")

	StatusCount = StatusCount + 1
	local status = Grid2.statusPrototype:new("debuff-"..StatusCount)

	status.auraName = name
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}

	function status:OnEnable()
		EnableAuraFrame(true)
		DebuffHandlers[self] = true
	end

	function status:OnDisable()
		EnableAuraFrame(false)
		DebuffHandlers[self] = nil
	end

	status.Reset = status_Reset
	if type(mine) == "number" then
		status.blinkThreshold = mine
		status.IsActive = status_IsActiveBlink
		AddTimeTracker(status, mine)
	else
		status.IsActive = status_IsActive
	end
	status.GetIcon = status_GetIcon
	status.GetCount = status_GetCount
	status.GetDuration = status_GetDuration
	status.GetExpirationTime = status_GetExpirationTime
	status.UpdateState = status_UpdateState
	status.HasStateChanged = status_HasStateChanged

	return status -- status is not registered yet
end

do
	local indicators = {}
	local types = {}
	function update(unit)
		local parent = Grid2:GetUnitFrame(unit)
		if not parent then return end

		for status in pairs(DebuffHandlers) do
			status:Reset(unit)
		end
		for status in pairs(BuffHandlers) do
			status:Reset(unit)
		end
		-- scan Debuffs and find the available debuff types
		local i = 1
		while true do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, isMine = UnitDebuff(unit, i)
			if not name then break end
			for status in pairs(DebuffHandlers) do
				status:UpdateState(unit, name, iconTexture, count, duration, expirationTime, isMine)
			end
			i = i + 1
			if debuffType and not types[debuffType] then
				types[debuffType] = iconTexture
			end
		end
		i = 1
		while true do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, isMine = UnitBuff(unit, i)
			if not name then break end
			for status in pairs(BuffHandlers) do
				status:UpdateState(unit, name, iconTexture, count, duration, expirationTime, isMine)
			end
			i = i + 1
		end
		-- update the debuff cache and mark indicators that needs updating
		for type, status in pairs(DebuffTypeStatus) do
			if status.enabled then
				local debuff = types[type]
				local cache = DebuffCache[type]
				if cache[unit] ~= debuff then
					cache[unit] = debuff
					for indicator in pairs(status.indicators) do
						indicators[indicator] = true
					end
				end
			end
			types[type] = nil
		end

		for status in pairs(DebuffHandlers) do
			if status:HasStateChanged(unit) then
				for indicator in pairs(status.indicators) do
					indicators[indicator] = true
				end
			end
		end
		for status in pairs(BuffHandlers) do
			if status:HasStateChanged(unit) then
				for indicator in pairs(status.indicators) do
					indicators[indicator] = true
				end
			end
		end
		-- Update indicators that needs updating only once.
		while true do
			local indicator = next(indicators)
			if not indicator then break end
			indicators[indicator] = nil
			indicator:Update(parent, unit)
		end
	end
end
