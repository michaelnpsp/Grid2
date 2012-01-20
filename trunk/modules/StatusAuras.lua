--[[
Created by Grid2 original authors, modified by Michael
--]]

local AuraFrame_OnEvent
local Grid2 = Grid2
local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local abs = math.abs

--{{ Local variables
local StatusList = {}
local DebuffHandlers = {}
local BuffHandlers = {}
local statusTypesBuffs = { "color", "icon", "percent", "text" }
local statusTypesDebuffs = { "color", "icon", "text" }
--}}

--{{ Timer to refresh auras remaining time 
local AddTimeTracker, RemoveTimeTracker
do
	local next = next
	local timetracker
	local elapsedTime= 0
	AddTimeTracker = function (status)
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame)
		timetracker.tracked = {}
		timetracker:SetScript("OnUpdate", function (self, elapsed)
			elapsedTime = elapsedTime + elapsed
			if elapsedTime>=0.10 then
				local time = GetTime()
				for status in next, self.tracked do
					local tracker    = status.tracker
					local thresholds = status.thresholds
					for unit, expiration in next, status.expirations do
						local timeLeft  = expiration - time
						local threshold = thresholds[ tracker[unit] ]
						if threshold and timeLeft <= threshold then
							tracker[unit] = tracker[unit] + 1
							status:UpdateIndicators(unit)
						end
					end
				end
				elapsedTime = 0
			end	
		end)
		AddTimeTracker = function (status)
			timetracker.tracked[status] = true
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
		AuraFrame_OnEvent(nil,nil,unit)  -- Not related to class filter, update auras of new units in raid
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
	
	function status:UpdateDB()
		self.debuffFilter = self.dbx.debuffFilter
	end
	
	status:UpdateDB()
	
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
	if self.tracker[unit]==1 then
		return true
	else
		return "blink"
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
	return GetTime() + 9999						 -- blinking work and to avoid a crash of IndicatorText status
end

local function status_GetPercent(self, unit)
	local t= GetTime()
	local expiration = (self.expirations[unit] or t) - t
	return expiration / (self.durations[unit] or 1)
end

local function status_GetThresholdColor(self, unit)    
	local colors = self.colors
	local index  = self.tracker[unit]
	local color  = colors[index] or colors[1]
	return color.r, color.g, color.b, color.a
end

-- This function includes a workaround to expiration variations of Druid WildGrowth HoT (little differences in expirations are ignored)
local function status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	local filtered = self.filtered
	if filtered and filtered[unit] then return end 
	local prevexp = self.expirations[unit]
	if count==0 then count = 1 end
	if self.states[unit]==nil or self.counts[unit] ~= count or prevexp==nil or abs(prevexp-expiration)>0.15 then 
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.tracker[unit] = 1
		self.seen= 1
	else
		self.seen= -1
	end
end

local function status_UpdateStateMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	end
end

local function status_UpdateStateNotMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if not IsMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	end
end

local function status_UpdateStateGroup(self, unit, iconTexture, count, duration, expiration)
	local filtered = self.filtered
	if filtered and filtered[unit] then return end
	if self.states[unit]==nil or self.expirations[unit] ~= expiration then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.counts[unit] = 1
		self.tracker[unit] = 1
		self.seen= 1
	else
		self.seen= -1
	end
end

local function status_UpdateStateGroupMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if isMine then
		status_UpdateStateGroup(self, unit,iconTexture, count,duration,expiration)
	end
end

local function status_UpdateStateGroupNotMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if not IsMine then
		status_UpdateStateGroup(self, unit,iconTexture, count, duration, expiration)
	end
end

local function RegisterStatusKey(self, spellName)
	local key = type(spellName)=="number" and (not self.dbx.useSpellId) and GetSpellInfo(spellName) or spellName
	self.keys[key] = true
	return key
end

local tempList = {}
local function GetSpellList(self)
	local auras = self.dbx.auras
	if not auras then
		tempList[1] = self.dbx.spellName
		return tempList
	end
	return auras
end

local function status_OnBuffEnable(self)
	EnableAuraFrame(true)
	if self.thresholds then AddTimeTracker(self) end
	local auras = GetSpellList(self)
	for _,spellName in next,auras do
		local key      = RegisterStatusKey(self,spellName)
		local statuses = BuffHandlers[key]
		if not statuses then 
			statuses = {};	BuffHandlers[key] = statuses
		end
		statuses[self] = true
	end
	StatusList[self]= true
end

local function status_OnBuffDisable(self)
	EnableAuraFrame(false)
	if RemoveTimeTracker then RemoveTimeTracker(self) end
	for key in next,self.keys do
		BuffHandlers[key][self] = nil
		if not next(BuffHandlers[key]) then	BuffHandlers[key] = nil	end
	end
	wipe(self.keys)
	StatusList[self]= nil
end

local function status_OnDebuffEnable(self)
	EnableAuraFrame(true)
	if self.thresholds then AddTimeTracker(self) end
	local auras = GetSpellList(self)
	for _,spellName in next,auras do
		DebuffHandlers[ RegisterStatusKey( self, spellName ) ] = self
	end
	StatusList[self]= true
end

local function status_OnDebuffDisable(self)
	EnableAuraFrame(false)
	if RemoveTimeTracker then RemoveTimeTracker(self) end
	for key in next,self.keys do
		DebuffHandlers[key][self] = nil
	end
	wipe(self.keys)
	StatusList[self]= nil
end

local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	MakeStatusFilter(self)
	local dbx = self.dbx
	if dbx.missing then
		local _, _, texture    = GetSpellInfo(auras and auras[1] or dbx.spellName )
		self.thresholds        = nil
		self.missingTexture    = texture or "Interface\\ICONS\\Achievement_General"
		self.GetIcon           = status_GetIconMissing
		self.GetExpirationTime = status_GetExpirationTimeMissing
		self.GetCount          = status_GetCountMissing
		self.IsActive          = dbx.blinkThreshold and status_IsInactiveBlink or status_IsInactive
		Grid2:MakeStatusColorHandler(self)		
	else
		self.GetIcon           = status_GetIcon
		self.GetExpirationTime = status_GetExpirationTime
		self.GetCount          = status_GetCount
		if dbx.blinkThreshold then
			self.thresholds = { dbx.blinkThreshold }
			self.IsActive   = status_IsActiveBlink
			Grid2:MakeStatusColorHandler(self)
		elseif dbx.colorThreshold then
			self.colors     = {}
			self.thresholds = dbx.colorThreshold
			self.GetColor   = status_GetThresholdColor
			self.IsActive   = status_IsActive
			for i=1,dbx.colorCount do
				self.colors[i] = dbx["color"..i]
			end
		else
			self.thresholds = nil
			self.IsActive   = status_IsActive
			Grid2:MakeStatusColorHandler(self)			
		end
	end
	if dbx.auras then  
		self.UpdateState =  (dbx.mine==2 and status_UpdateStateGroupNotMine) or
							(dbx.mine    and status_UpdateStateGroupMine) or
							 status_UpdateStateGroup
		
	else
		self.UpdateState =  (dbx.mine==2 and status_UpdateStateNotMine) or
							(dbx.mine    and status_UpdateStateMine) or
							 status_UpdateState
	end
	if self.enabled then self:OnEnable() end
end
--}}

--{{ Aura creation functions
local function CreateAuraCommon(baseKey, dbx, types)
	local status = Grid2.statusPrototype:new(baseKey, false)

	status.keys = {}
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}
	status.tracker = {}
	
	status.UpdateDB    = status_UpdateDB
	status.Reset       = status_Reset
	status.GetCountMax = status_GetCountMax
	status.GetDuration = status_GetDuration
	status.GetPercent  = status_GetPercent
	status.OnEnable    = dbx.type=="buff" and status_OnBuffEnable  or status_OnDebuffEnable
	status.OnDisable   = dbx.type=="buff" and status_OnBuffDisable or status_OnDebuffDisable

	Grid2:RegisterStatus(status, types, baseKey, dbx)
	
	status:UpdateDB()
	
	return status
end

function Grid2.CreateBuff(baseKey, dbx, statusTypesOverride)
	return CreateAuraCommon(baseKey, dbx, statusTypesOverride or statusTypesBuffs)
end

function Grid2.CreateDebuff(baseKey, dbx, statusTypesOverride)
	return CreateAuraCommon( baseKey, dbx, statusTypesOverride or statusTypesDebuffs)
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
			local name, _, iconTexture, count, debuffType, duration, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i)
			if not name then break end
			local status = DebuffHandlers[name] or DebuffHandlers[spellId]
			if status then
				status:UpdateState(unit, iconTexture, count, duration, expirationTime, myUnits[caster])
			end
			i = i + 1
			if debuffType and (not types[debuffType]) then
				status = DebuffTypeStatus[debuffType]
				if not (status and status.debuffFilter and status.debuffFilter[name]) then
					types[debuffType] = iconTexture
				end
			end
		end
		-- scan Buffs
		i = 1
		while true do
			local name, _, iconTexture, count, _, duration, expirationTime, caster, _, _, spellId = UnitBuff(unit, i)
			if not name then break end
			local statuses = BuffHandlers[name] or BuffHandlers[spellId]
			if statuses then
				local isMine = myUnits[caster]
				for status in next, statuses do
					status:UpdateState(unit, iconTexture, count, duration, expirationTime, isMine)
				end
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
			local seen = status.seen
			if (seen==1) or ((not seen) and status.states[unit] and status:Reset(unit)) then
				for indicator in next, status.indicators do
					indicators[indicator] = true
				end
			end	
			status.seen = false
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
Grid2.setupFunc["buff"]       = Grid2.CreateBuff
Grid2.setupFunc["debuff"]     = Grid2.CreateDebuff
--}}
