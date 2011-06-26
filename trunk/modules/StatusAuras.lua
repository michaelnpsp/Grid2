--[[
Created by Grid2 original authors, modified by Michael
--]]

local AuraFrame_OnEvent
local Grid2 = Grid2
local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

--{{ Local variables
local StatusList, BuffHandlers, DebuffHandlers = {}, {}, {}
local statusTypesBuffs = { "color", "icon", "percent", "text" }
local statusTypesDebuffs = { "color", "icon", "text" }
--}}

--{{ Timer to refresh auras remaining time 
local AddTimeTracker, RemoveTimeTracker
do
	local next = next
	local timetracker
	local elapsedTime= 0
	AddTimeTracker = function (status, value)
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame)
		timetracker.tracked = {}
		timetracker:SetScript("OnUpdate", function (self, elapsed)
			elapsedTime= elapsedTime + elapsed
			if elapsedTime>=0.10 then
				local time = GetTime()
				for status, value in next, self.tracked do
					for unit, expiration in next, status.expirations do
						local timeLeft = expiration - time
						if (timeLeft < value) ~= (timeLeft + elapsedTime < value) then
							status:UpdateIndicators(unit)
						end
					end
				end
				elapsedTime= 0
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
--}}

--{{ Auras filter
local MakeStatusFilter
do
	local filter_mt = {
		__index = function (self, unit)
			local _, class = UnitClass(unit)
			local result= self.source[class]
			self[unit]= result
			return result
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
--}}

--{{ Auras Event 
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
			else
				frame:SetScript("OnEvent", AuraFrame_OnEvent)
				frame:RegisterEvent("UNIT_AURA")
			end
		end
	end
	Grid2.EnableAuraFrame = EnableAuraFrame
end
--}}

--{{ Debuffs types 
local DebuffCache = {}
local DebuffTypeStatus = {}

function CreateDebuffType(baseKey, dbx)
	local type = dbx.subType

	local c = {}
	DebuffCache[type] = c

	local status = Grid2.statusPrototype:new(baseKey, false)
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
--}}

--{{ Auras methods
local function status_Reset(self, unit)
	self.states[unit] = nil
	self.counts[unit] = nil
	self.expirations[unit] = nil
	return true
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

local function status_IsActiveBlink(self, unit)
	local filtered = self.filtered
	if (filtered and filtered[unit]) or not self.states[unit] then return nil end
	if self.expirations[unit] - GetTime() < self.blinkThreshold then
		return "blink"
	else
		return true
	end
end

local function status_IsInactiveBlink(self, unit) -- A missing active status has no expiration time, always returns blink when is active
	local filtered = self.filtered
	if filtered and filtered[unit] then return nil end
	return not self.states[unit] and "blink"
end

local function status_GetIcon(self, unit)
	return self.textures[unit]
end

local function status_GetIconMissing(self)
	return self.missingTexture
end

local function status_GetCount(self, unit)
	return self.counts[unit]
end

local function status_GetCountMissing()
	return 1
end

local function status_GetCountMax(self)
	return self.dbx.colorCount or 1
end	

local function status_GetDuration(self, unit)
	return self.durations[unit]
end

local function status_GetExpirationTime(self, unit)
	return self.expirations[unit]
end

local function status_GetExpirationTimeMissing() -- Expiration time is unknow, return some hours in future to allow 
	return GetTime() + 9999						 -- blinking work and to prevent failing of IndicatorText status
end

local function status_GetPercent(self, unit)
	local t= GetTime()
	local expiration = (self.expirations[unit] or t) - t
	return expiration / (self.durations[unit] or 1)
end

local function status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	local filtered = self.filtered
	if filtered and filtered[unit] then return end 
	if (self.states[unit]==nil) or 
	   (self.counts[unit] ~= count) or 
	   (self.expirations[unit] ~= expiration)
	then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count and count>0 and count or 1
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.seen= 1
	else
		self.seen= -1
	end
end

local function status_UpdateStateGroup(self, unit, iconTexture, count, duration, expiration)
	local filtered = self.filtered
	if filtered and filtered[unit] then return end 
	if self.states[unit]==nil then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.counts[unit] = 1
		self.seen= 1
	else
		self.seen= -1
	end
end

local function status_OnEnable(self)
	EnableAuraFrame(true)
	if self.auraKeys then
		local handlers= self.handlers
		for _,auraKey in next,self.auraKeys do
			handlers[auraKey] = self
		end
	else
		self.handlers[self.auraKey] = self
	end
	StatusList[self]= true
end

local function status_OnDisable(self)
	EnableAuraFrame(false)
	if self.auraKeys then
		local handlers= self.handlers
		for _,auraKey in next,self.auraKeys do
			handlers[auraKey] = nil
		end
	else
		self.handlers[self.auraKey] = nil
	end	
	StatusList[self]= nil
end

local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	local dbx = self.dbx
	MakeStatusFilter(self)
	local blinkThreshold, missing, auras, mine = dbx.blinkThreshold, dbx.missing, dbx.auras, dbx.mine
	if blinkThreshold then
		self.blinkThreshold = blinkThreshold
		self.IsActive = missing and status_IsInactiveBlink or status_IsActiveBlink
		if not missing then  -- blinking missing statuses dont need timetracker, because are always blinking
			AddTimeTracker(self, blinkThreshold)
		end	
	else
		self.blinkThreshold = nil
		self.IsActive = missing and status_IsInactive or status_IsActive
		if RemoveTimeTracker then
			RemoveTimeTracker(self)
		end
	end
	if missing then
		local _, _, texture = GetSpellInfo(auras and auras[1] or dbx.spellName )
		self.missingTexture = texture or "Interface\\ICONS\\Achievement_General"
	end
	local suffix= (mine==2 and "-") or (mine and "+") or ""
	if auras then  
		local auraKeys= {}
		for index, spellName in next,auras do
			auraKeys[index]= (type(spellName)=="number" and GetSpellInfo(spellName) or spellName) .. suffix
		end
		self.auraKeys= auraKeys
		self.UpdateState = status_UpdateStateGroup
	else
		local spellName= dbx.spellName
		self.auraKey= (type(spellName)=="number" and GetSpellInfo(spellName) or spellName) .. suffix
		self.UpdateState = status_UpdateState
	end
	self.GetIcon = missing and status_GetIconMissing or status_GetIcon
	self.GetExpirationTime = missing and status_GetExpirationTimeMissing or status_GetExpirationTime
	self.GetCount = missing and status_GetCountMissing or status_GetCount
	if self.enabled then self:OnEnable() end
end
--}}

--{{ Aura creation functions
local function CreateAuraCommon(baseKey, dbx, handlers, types)
	local status = Grid2.statusPrototype:new(baseKey, false)

	status.handlers = handlers
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}

	status.Reset = status_Reset
	status.GetCountMax = status_GetCountMax
	status.GetDuration = status_GetDuration
	status.GetPercent = status_GetPercent
	status.OnEnable= status_OnEnable
	status.OnDisable= status_OnDisable
	status.UpdateDB = status_UpdateDB

	Grid2:RegisterStatus(status, types, baseKey, dbx)
	Grid2:MakeStatusColorHandler(status)

	status:UpdateDB()
	
	return status
end

function Grid2.CreateBuff(baseKey, dbx, statusTypesOverride)
	return CreateAuraCommon(baseKey, dbx, BuffHandlers, statusTypesOverride or statusTypesBuffs)
end

function Grid2.CreateDebuff(baseKey, dbx, statusTypesOverride)
	return CreateAuraCommon( baseKey, dbx, DebuffHandlers, statusTypesOverride or statusTypesDebuffs)
end
--}}

--{{ Aura events management
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
		-- scan Debuffs and find the available debuff types
		local i = 1
		while true do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, caster = UnitDebuff(unit, i)
			if not name then break end
			local status= DebuffHandlers[name]
			if status then
				status:UpdateState(unit, iconTexture, count, duration, expirationTime, myUnits[caster])
			end
			i = i + 1
			if debuffType and not types[debuffType] then
				types[debuffType] = iconTexture
			end
		end
		-- scan Buffs
		i = 1
		while true do
			local name, _, iconTexture, count, _, duration, expirationTime, caster = UnitBuff(unit, i)
			if not name then break end
			local isMine = myUnits[caster]
			-- Search standard buff 
			local status= BuffHandlers[name]
			if status then
				status:UpdateState(unit, iconTexture, count, duration, expirationTime, isMine)
			end
			-- Search mine/notmine buff
			status= BuffHandlers[name..(isMine and "+" or "-")]
			if status then
				status:UpdateState(unit, iconTexture, count, duration, expirationTime, isMine)
			end
			i = i + 1
		end
		-- Update the debuff cache and mark indicators that need updating
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
		for status in next, StatusList do
			local seen= status.seen
			if (seen==1) or ((not seen) and status.states[unit] and status:Reset(unit)) then
				for indicator in next, status.indicators do
					indicators[indicator] = true
				end
			end	
			status.seen= false
		end
		-- Update indicators that needs updating only once.
		for indicator in next, indicators do
			for frame in next, frames do
				indicator:Update(frame, unit)
			end
		end
		wipe(indicators)
	end
	-- Needed in Grid2Options to refresh auras when an aura status is enabled
	function Grid2:RefreshAuras()
		for unit, _ in Grid2:IterateRosterUnits() do
			AuraFrame_OnEvent(nil,nil,unit) 
		end
	end	
end
--}}

--{{ Registering statuses constructors
Grid2.setupFunc["debuffType"] = CreateDebuffType
Grid2.setupFunc["buff"] = Grid2.CreateBuff
Grid2.setupFunc["debuff"] = Grid2.CreateDebuff
--}}