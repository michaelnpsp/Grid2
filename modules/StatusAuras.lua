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
			color1 = { r=color.r, g=color.g, b=color.b },
		}
	}

	function status:GetColor(unit)
		local color = self.db.profile.color1
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
	self.prev_expiration = self.expirations[unit]
	self.states[unit] = nil
	self.expirations[unit] = nil
end

local function status_IsActive(self, unit)
	local profile = self.db.profile
	if (profile.classFilter and profile.classFilter[select(2, UnitClass(unit))]) then
		return nil
	end
	if (profile.missing) then
		return not self.states[unit]
	else
		return self.states[unit]
	end
end

local GetTime = GetTime
local function status_IsActiveBlink(self, unit)
	local profile = self.db.profile
	if (profile.classFilter and profile.classFilter[select(2, UnitClass(unit))]) then
		return nil
	end
	if not self.states[unit] then
		return profile.missing
	elseif (self.expirations[unit] - GetTime()) < self.blinkThreshold then
		return "blink"
	else
		return not profile.missing
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

local function status_GetPercent(self, unit)
	local color = self.db.profile.color1
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

local function status_HasStateChanged(self, unit)
	return (self.new_state ~= self.prev_state) or (self.new_count ~= self.prev_count) or (self.new_expiration ~= self.prev_expiration)
end

local AddTimeTracker
local RemoveTimeTracker
do
	local next = next
	local timetracker
	AddTimeTracker = function (status, value)
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame)
		timetracker.tracked = {}
		timetracker:SetScript("OnUpdate", function (self, elapsed)
			local time = GetTime()
			for status, value in next, self.tracked do
				local expirations = status.expirations
				for unit, expiration in next, expirations do
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

local function status_UpdateBlinkThreshold(self)
	local blinkThreshold = self.db.profile.blinkThreshold
	if blinkThreshold then
		self.blinkThreshold = blinkThreshold
		self.IsActive = status_IsActiveBlink
		AddTimeTracker(self, blinkThreshold)
	else
		self.blinkThreshold = nil
		self.IsActive = status_IsActive
		if RemoveTimeTracker then
			RemoveTimeTracker(status)
		end
	end
end

local function CreateAuraStatusCommon(status, spellName, mine, ...)
	if (type(spellName) == "number") then
		spellName = GetSpellInfo(spellName)
	end
	assert(type(spellName) == "string")

	status.auraName = spellName
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}

	status.defaultDB = {
		profile = {
		}
	}
 	local colorCount = select('#', ...) / 4
	assert(colorCount * 4 == select('#', ...), "Color parameters need to be multiples of r,g,b,a")
 	status.defaultDB.profile.colorCount = colorCount
 	for i = 1, colorCount, 1 do
 		local componentIndex = i * 4
 		local color = { r = (select((componentIndex - 3), ...)), g = (select((componentIndex - 2), ...)), b = (select((componentIndex - 1), ...)), a = (select((componentIndex), ...)) }
 		status.defaultDB.profile[("color" .. i)] = color
 	end

	status.Reset = status_Reset
	status.GetIcon = status_GetIcon
	status.GetCount = status_GetCount
	status.GetDuration = status_GetDuration
	status.GetExpirationTime = status_GetExpirationTime
	status.GetPercent = status_GetPercent
	status.HasStateChanged = status_HasStateChanged
	status.UpdateBlinkThreshold = status_UpdateBlinkThreshold
end

-- spellName: spellId or localized spellName
function Grid2:CreateBuffStatus(spellName, mine, missing, ...)
	StatusCount = StatusCount + 1
	local status = Grid2.statusPrototype:new("buff-" .. StatusCount)
	CreateAuraStatusCommon(status, spellName, mine, ...)

	function status:OnEnable()
		EnableAuraFrame(true)
		BuffHandlers[self] = true
	end

	function status:OnDisable()
		EnableAuraFrame(false)
		BuffHandlers[self] = nil
	end

	local profile = status.defaultDB.profile
	if (type(mine) == "number") then
		profile.blinkThreshold = mine
	end
	profile.missing = missing

	status.UpdateState = mine and status_UpdateStateMine or status_UpdateState

	return status -- status is not registered yet
end

function Grid2:CreateDebuffStatus(spellName, mine, ...)
	StatusCount = StatusCount + 1
	local status = Grid2.statusPrototype:new("debuff-" .. StatusCount)
	CreateAuraStatusCommon(status, spellName, mine, ...)

	function status:OnEnable()
		EnableAuraFrame(true)
		DebuffHandlers[self] = true
	end

	function status:OnDisable()
		EnableAuraFrame(false)
		DebuffHandlers[self] = nil
	end

	if (type(mine) == "number") then
		status.blinkThreshold = mine
		status.IsActive = status_IsActiveBlink
		AddTimeTracker(status, mine)
	else
		status.IsActive = status_IsActive
	end

	status.UpdateState = status_UpdateState

	return status -- status is not registered yet
end

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
		local parent = Grid2:GetUnitFrame(unit)
		if not parent then return end

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
			indicator:Update(parent, unit)
		end
	end
end
