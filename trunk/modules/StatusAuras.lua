--[[
Created by Grid2 original authors, modified by Michael
--]]

local AuraFrame_OnEvent
local Grid2 = Grid2
local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local abs = math.abs
local strlen = strlen
local type = type
local fmt = string.format
local UnitHealthMax = UnitHealthMax

--{{ Local variables
local StatusList = {}
local DebuffHandlers = {}
local BuffHandlers = {}
local DebuffTypeHandlers = {}
local Handlers = { buff = BuffHandlers, debuff = DebuffHandlers }
local statusTypes = { "color", "icon", "percent", "text" }
local statusTypesDebuffType = { "color", "icon", "text" }
--}}

--{{  Misc functions
local handlerArray = {}
local function MakeStatusColorHandler(status)
	local dbx = status.dbx
	local colorCount = dbx.colorCount or 1
	handlerArray[1] = "return function (self, unit)"
	if colorCount > 1 then
		handlerArray[#handlerArray+1] = " local count = self:GetCount(unit)"
		for i = 1, colorCount - 1 do
			local color = dbx["color" .. i]
			handlerArray[#handlerArray+1] = (" if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
		end
	end
	color = dbx["color" .. colorCount]
	handlerArray[#handlerArray+1] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)
	status.GetColor = assert(loadstring(table.concat(handlerArray)))()
	wipe(handlerArray)
end

local function GetStatusKey(self, spellName)
	return type(spellName)=="number" and (not self.dbx.useSpellId) and GetSpellInfo(spellName) or spellName
end

local function IterateStatusSpells(status)
	local auras = status.dbx.auras
	if auras then
		local i = 0
		return function() i=i+1; return auras[i] end
	else
		local spell, value = status.dbx.spellName
		return function() value, spell = spell, nil; return value end
	end
end
--}}

--{{ Timer to refresh auras remaining time 
local AddTimeTracker, RemoveTimeTracker
do
	local next = next
	local timetracker
	local tracked 
	AddTimeTracker = function (status)
		tracked = {}
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame):CreateAnimationGroup()
		timetracker:SetScript("OnFinished", function (self)
			local time = GetTime()
			for status in next, tracked do
				local tracker    = status.tracker
				local thresholds = status.thresholds
				if status.trackElapsed then
					local durations = status.durations
					for unit, expiration in next, status.expirations do
						local timeElapsed = time - (expiration - durations[unit])
						local threshold = thresholds[ tracker[unit] ]
						if threshold and timeElapsed >= threshold then
							tracker[unit] = tracker[unit] + 1
							status:UpdateIndicators(unit)
						end
					end
				else
					for unit, expiration in next, status.expirations do
						local timeLeft  = expiration - time
						local threshold = thresholds[ tracker[unit] ]
						if threshold and timeLeft <= threshold then
							tracker[unit] = tracker[unit] + 1
							status:UpdateIndicators(unit)
						end
					end
				end	
			end
			self:Play()
		end)
		local timer = timetracker:CreateAnimation()
		timer:SetOrder(1); timer:SetDuration(0.10) 
		AddTimeTracker = function (status)
			if not next(tracked) then timetracker:Play() end
			tracked[status] = true
		end
		RemoveTimeTracker = function (status)
			tracked[status] = nil
			if not next(tracked) then timetracker:Stop() end
		end
		return AddTimeTracker(status)
	end
end
--}}

--{{ Auras Event 
local EnableAuraFrame, DisableAuraFrame
do
	local frame
	local count = 0
	function EnableAuraFrame()
		if count == 0 then
			if not frame then 
				frame = CreateFrame("Frame", nil, Grid2LayoutFrame) 
			end
			frame:SetScript("OnEvent", AuraFrame_OnEvent)
			frame:RegisterEvent("UNIT_AURA")
		end
		count = count + 1
	end	
	function DisableAuraFrame()
		count = count - 1
		if count == 0 then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_AURA")
		end
	end
end
--}}

--{{
local function RegisterStatusAura(status, aura)
	local handler = Handlers[status.dbx.type]
	local statuses = handler[aura]
	if not statuses then
		statuses = {}
		handler[aura] = statuses 
	end
	statuses[status] = true
	StatusList[status] = true
end

local function UnregisterStatusAura(status)
	local handler = Handlers[status.dbx.type]
	for key,statuses in pairs(handler) do
		if statuses[self] then
			statuses[self] = nil
			if not next(statuses) then handler[key] = nil end
		end
	end
	StatusList[status] = nil
end
--}}

--{{ Methods shared by different status types
local function status_Reset(self, unit)
	self.states[unit] = nil
	self.counts[unit] = nil
	self.expirations[unit] = nil
	self.values[unit] = nil
	return true
end

local function status_IsInactive(self, unit) -- used for "missing" status
	return not ( self.states[unit] or Grid2:UnitIsPet(unit) )
end

local function status_IsActive(self, unit)
	return self.states[unit]
end

local function status_IsActiveBlink(self, unit)
	if not self.states[unit] then return end
	if self.tracker[unit]==1 then
		return true
	else
		return "blink"
	end
end

local function status_IsInactiveBlink(self, unit) -- A missing active status has no expiration, always returns blink
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

local function status_GetThresholdColor(self, unit)    
	local colors = self.colors
	local index  = self.tracker[unit]
	local color  = colors[index] or colors[1]
	return color.r, color.g, color.b, color.a
end

local function status_GetThresholdColorValue(self, unit)
	local i = 1
	local value = self.values[unit] or 0
	local thresholds = self.thresholds
	while i<=#thresholds and value<thresholds[i] do
		i = i + 1
	end
	local c = self.colors[i]
	return c.r, c.g, c.b, c.a
end

local function status_GetPercentHealth(self, unit)
	return (self.values[unit] or 0) / UnitHealthMax(unit)
end

local function status_GetPercentMax(self, unit)
	return (self.values[unit] or 0) / self.valueMax
end

local function status_GetText(self, unit)
	return fmt( "%.1fk", (self.values[unit] or 0) / 1000 )
end

local function status_UpdateState(self, unit, iconTexture, count, duration, expiration, value)
	if count==0 then count = 1 end
	if self.states[unit]==nil or self.counts[unit] ~= count or expiration~=self.expirations[unit] or value~=self.values[unit] then 
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.values[unit] = value
		self.tracker[unit] = 1
		self.seen = 1
	else
		self.seen = -1
	end
end

local function status_UpdateStateMine(self, unit, iconTexture, count, duration, expiration, value, isMine)
	if isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration, value)
	end
end

local function status_UpdateStateNotMine(self, unit, iconTexture, count, duration, expiration, value, isMine)
	if not isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration, value)
	end
end

local function status_UpdateStateGroup(self, unit, iconTexture, count, duration, expiration)
	if self.states[unit]==nil or self.expirations[unit] ~= expiration then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.counts[unit] = 1
		self.tracker[unit] = 1
		self.seen = 1
	else
		self.seen = -1
	end
end

local function status_UpdateStateGroupMine(self, unit, iconTexture, count, duration, expiration, _, isMine)
	if isMine then
		status_UpdateStateGroup(self, unit,iconTexture, count, duration, expiration)
	end
end

local function status_UpdateStateGroupNotMine(self, unit, iconTexture, count, duration, expiration, _, isMine)
	if not IsMine then
		status_UpdateStateGroup(self, unit,iconTexture, count, duration, expiration)
	end
end

local function status_OnEnable(self)
	EnableAuraFrame()
	if self.thresholds and (not self.trackValue) then AddTimeTracker(self) end
	for spellName in IterateStatusSpells(self) do
		RegisterStatusAura(self, GetStatusKey(self, spellName) )
	end
end

local function status_OnDisable(self)
	DisableAuraFrame()
	if RemoveTimeTracker then RemoveTimeTracker(self) end
	UnregisterStatusAura(self)
end

local AuraFunc = { buff = UnitBuff,	debuff = UnitDebuff }
local function status_IterateAuras(self, unit)
	local i, spells, UnitAura = 0, self.auraNames, AuraFunc[self.dbx.type]
	return function() 
		while true do
			i = i + 1
			local name, _, texture, count, _, duration, expiration = UnitAura(unit, i)
			if name then
				if spells[name] then return name, texture, count, expiration, duration end	
			else
				return
			end
		end
	end
end

local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	local dbx = self.dbx
	local auras = dbx.auras
	self.valueIndex = self.dbx.valueIndex or 0
	self.valueMax   = self.dbx.valueMax
	self.GetPercent = self.valueMax and status_GetPercentMax or status_GetPercentHealth
	if dbx.missing then
		local _, _, texture    = GetSpellInfo(auras and auras[1] or dbx.spellName )
		self.thresholds        = nil
		self.missingTexture    = texture or "Interface\\ICONS\\Achievement_General"
		self.GetIcon           = status_GetIconMissing
		self.GetExpirationTime = status_GetExpirationTimeMissing
		self.GetCount          = status_GetCountMissing
		self.IsActive          = dbx.blinkThreshold and status_IsInactiveBlink or status_IsInactive
		MakeStatusColorHandler(self)
	else
		self.GetIcon           = status_GetIcon
		self.GetExpirationTime = status_GetExpirationTime
		self.GetCount          = status_GetCount
		if dbx.blinkThreshold then
			self.thresholds = { dbx.blinkThreshold }
			self.IsActive   = status_IsActiveBlink
			MakeStatusColorHandler(self)
		elseif dbx.colorThreshold then
			self.colors       = {}
			self.thresholds   = dbx.colorThreshold
			self.trackElapsed = dbx.colorThresholdElapsed
			self.trackValue   = dbx.colorThresholdValue
			self.GetColor     = self.trackValue and status_GetThresholdColorValue or status_GetThresholdColor
			self.IsActive     = status_IsActive
			for i=1,dbx.colorCount do
				self.colors[i] = dbx["color"..i]
			end
		else
			self.thresholds = nil
			self.IsActive   = status_IsActive
			MakeStatusColorHandler(self)
		end
	end
	if auras then
		self.auraNames = self.auraNames or {}
		wipe(self.auraNames)
		for _,name in ipairs(auras) do 
			self.auraNames[name] = true
		end
		self.IterateAuras = status_IterateAuras		
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

local function CreateAura(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.states      = {}
	status.textures    = {}
	status.counts      = {}
	status.expirations = {}
	status.durations   = {}
	status.tracker     = {}	
	status.values      = {}
	status.Reset       = status_Reset
	status.GetCountMax = status_GetCountMax
	status.GetDuration = status_GetDuration
	status.GetText     = status_GetText	
	status.OnEnable    = status_OnEnable
	status.OnDisable   = status_OnDisable
	status.UpdateDB    = status_UpdateDB
	Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)
	status:UpdateDB()
	return status
end
--}}

-- {{ DebuffType
local function status_OnDebuffTypeEnable(self)
	EnableAuraFrame()
	DebuffTypeHandlers[ self.subType ] = self
	StatusList[self] = true
end

local function status_OnDebuffTypeDisable(self)
	DisableAuraFrame()
	DebuffTypeHandlers[ self.subType ] = nil
	StatusList[self] = nil
end

local function status_UpdateStateDebuffType(self, unit, iconTexture, count, duration, expiration, name)
	if self.debuffFilter and self.debuffFilter[name] then return end
	self.states[unit] = true
	self.textures[unit] = iconTexture
	self.durations[unit] = duration
	self.expirations[unit] = expiration
	self.counts[unit] = count~=0 and count or 1
	self.seen = 1
end

local function status_UpdateDebuffTypeDB(self)
	if self.enabled then self:OnDisable() end
	self.subType           = self.dbx.subType
	self.debuffFilter      = self.dbx.debuffFilter
	self.GetBorder         = Grid2.statusLibrary.GetBorder
	self.UpdateState       = status_UpdateStateDebuffType
	self.GetIcon           = status_GetIcon
	self.GetExpirationTime = status_GetExpirationTime
	self.GetCount          = status_GetCount
	self.IsActive          = status_IsActive
	MakeStatusColorHandler(self)
	if self.enabled then self:OnEnable() end	
end

local function CreateDebuffType(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}
	status.values      = {}
	status.Reset       = status_Reset
	status.GetCountMax = status_GetCountMax
	status.GetDuration = status_GetDuration
	status.UpdateDB    = status_UpdateDebuffTypeDB	
	status.OnEnable    = status_OnDebuffTypeEnable
	status.OnDisable   = status_OnDebuffTypeDisable
	Grid2:RegisterStatus(status, statusTypesDebuffType, baseKey, dbx)
	status:UpdateDB()
	return status
end
-- }}

--{{ Aura Refresh 
-- Passing StatusList instead of nil, because i dont know if nil is valid for RegisterMessage
Grid2.RegisterMessage( StatusList, "Grid_UnitUpdated", function(_, unit) 
	AuraFrame_OnEvent(nil,nil,unit)
end)
-- Called by Grid2Options when an aura status is enabled
function Grid2:RefreshAuras() 
	for unit in Grid2:IterateRosterUnits() do
		AuraFrame_OnEvent(nil,nil,unit) 
	end
end	
-- }}

--{{ Aura events management
do
	local next = next
	local indicators = {}
	local myUnits = { player = true, pet = true, vehicle = true }
	local values = { 0, 0, 0 }
	function AuraFrame_OnEvent(_, _, unit)
		local frames = Grid2:GetUnitFrames(unit)
		if not next(frames) then return end
		-- scan Debuffs and Debuff Types
		local i = 1
		while true do
			local name, iconTexture, count, debuffType, duration, expirationTime, caster, spellId, _
			name, _, iconTexture, count, debuffType, duration, expirationTime, caster, _, _, spellId, _, _, _, values[1], values[2], values[3] = UnitDebuff(unit, i)
			if not name then break end
			local statuses = DebuffHandlers[name] or DebuffHandlers[spellId]
			if statuses then
				local isMine = myUnits[caster]
				for status in next, statuses do
					status:UpdateState(unit, iconTexture, count, duration, expirationTime, values[status.valueIndex], isMine )
				end
			end
			if debuffType then
				status = DebuffTypeHandlers[debuffType]
				if status and (not status.seen) then
					status:UpdateState(unit, iconTexture, count, duration, expirationTime, name)
				end
			end
			i = i + 1
		end
		-- scan Buffs
		i = 1
		while true do
			local name, iconTexture, count, duration, expirationTime, caster, spellId, _
			name, _, iconTexture, count, _, duration, expirationTime, caster, _, _, spellId, _, _, _, values[1], values[2], values[3] = UnitBuff(unit, i)
			if not name then break end
			local statuses = BuffHandlers[name] or BuffHandlers[spellId]
			if statuses then
				local isMine = myUnits[caster]
				for status in next, statuses do
					status:UpdateState(unit, iconTexture, count, duration, expirationTime, values[status.valueIndex], isMine)
				end
			end
			i = i + 1
		end
		-- Mark indicators that need updating
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
end
--}}

--{{
Grid2.setupFunc["buff"]       = CreateAura
Grid2.setupFunc["debuff"]     = CreateAura
Grid2.setupFunc["debuffType"] = CreateDebuffType
--}}

--{{ 
Grid2:DbSetStatusDefaultValue( "debuff-Magic", {type = "debuffType", subType = "Magic", color1 = {r=.2,g=.6,b=1,a=1}})
Grid2:DbSetStatusDefaultValue( "debuff-Poison", {type = "debuffType", subType = "Poison", color1 = {r=0,g=.6,b=0,a=1}})
Grid2:DbSetStatusDefaultValue( "debuff-Curse", {type = "debuffType", subType = "Curse", color1 = {r=.6,g=0,b=1,a=1}})
Grid2:DbSetStatusDefaultValue( "debuff-Disease", {type = "debuffType", subType = "Disease", color1 = {r=.6,g=.4,b=0,a=1}})
--}}
