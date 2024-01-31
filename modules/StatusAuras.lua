-- Auras management
local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local type = type
local next = next
local rawget = rawget
local max = math.max
local GetTime = GetTime
local isClassic = Grid2.isClassic
local UnitAura = Grid2.UnitAuraLite

-- Local variables
local Statuses = {}

local Buffs = {}
local Debuffs = {}
local DebuffTypes = {}
local DebuffGroups = {}
local debuffTypeColors = {}
local debuffTypesKeys = { 'Magic', 'Curse', 'Disease', 'Poison', 'Typeless', 'Boss' }
local debuffDispelTypes = { Magic = true, Curse = true, Disease = true, Poison = true }

-- UNIT_AURA event management
-- s.seen = nil aura was removed, linked indicators must be updated
-- s.seen = 1   aura was changed, linked indicators must be updated
-- s.seen = -1  aura was not changed, do nothing
local AuraFrame_OnEvent
do
	local GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
	local myUnits  = Grid2.roster_my_units
	local roUnits  = Grid2.roster_guids
	local myFrames = Grid2Frame.frames_of_unit
	local indicators = {}
	local val = {0,0,0}
	local fill = (GetAuraDataByIndex~=nil)
	local a, nam, tex, cnt, typ, dur, exp, cas, sid, bos, _
	local GetAura = GetAuraDataByIndex and function(unit, index, filter) -- for retail
		a = GetAuraDataByIndex(unit, index, filter)
		if a then fill, nam, typ, cas, sid, bos = true, a.name, a.dispelName, a.sourceUnit, a.spellId, a.isBossAura; return true; end
	end or function(unit, index, filter) -- for classic
		nam, tex, cnt, typ, dur, exp, cas, _, _, sid, _, bos, _, _, _, val[1], val[2], val[3] = UnitAura(unit, index, filter)
		if nam then if cnt==0 then cnt=1 end; return true end
	end
	AuraFrame_OnEvent = function(_, event, u)
		if not roUnits[u] then return end
		-- Scan Debuffs, Debuff Types, Debuff Groups
		local i = 1
		while GetAura(u, i, 'HARMFUL') do
			local statuses = Debuffs[nam] or Debuffs[sid]
			if statuses then
				for s in next, statuses do
					local mine = s.isMine
					if mine==false or mine==myUnits[cas] then
						if fill then fill, tex, cnt, dur, exp, val[s.vId] = false, a.icon, max(a.applications,1), a.duration, a.expirationTime, a.points[s.vId] end
						if s.UpdateState then
							s:UpdateState(u, i, sid, nam, tex, cnt, dur, exp, typ)
						elseif exp~=s.exp[u] or cnt~=s.cnt[u] or val[s.vId]~=s.val[u] then
							s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.typ[u], s.val[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, typ, val[s.vId], 1
						else
							s.seen, s.idx[u] = -1, i
						end
					end
				end
			end
			local s = DebuffTypes[typ or 'Typeless']
			if s and not s.seen and not (s.debuffFilter and s.debuffFilter[nam]) then
				if fill then fill, tex, cnt, dur, exp = false, a.icon, max(a.applications,1), a.duration, a.expirationTime end
				if exp~=s.exp[u] or cnt~=s.cnt[u] then
					s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u] = 1, i, tex, cnt, dur, exp
				else
					s.seen, s.idx[u] = -1, i
				end
			end
			if bos then
				local s = DebuffTypes.Boss
				if s and not s.seen and not (s.debuffFilter and s.debuffFilter[nam]) then
					if fill then fill, tex, cnt, dur, exp = false, a.icon, max(a.applications,1), a.duration, a.expirationTime end
					if exp~=s.exp[u] or cnt~=s.cnt[u] then
						s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u] = 1, i, tex, cnt, dur, exp
					else
						s.seen, s.idx[u] = -1, i
					end
				end
			end
			for s, update in next, DebuffGroups do
				if fill then fill, tex, cnt, dur, exp = false, a.icon, max(a.applications,1), a.duration, a.expirationTime end
				if (update or not s.seen) and s:UpdateState(u, sid, nam, cnt, dur, cas, bos, typ) then
					s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.typ[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, typ, 1
				end
			end
			i = i + 1
		end
		-- Scan Buffs
		i = 1
		while GetAura(u,i,'HELPFUL') do
			local statuses = Buffs[nam] or Buffs[sid]
			if statuses then
				for s in next, statuses do
					local mine = s.isMine
					if (mine==false or mine==myUnits[cas]) and s.seen~=1 then
						if fill then fill, tex, cnt, dur, exp, val[s.vId] = false, a.icon, max(a.applications,1), a.duration, a.expirationTime, a.points[s.vId] end
						if s.UpdateState then
							 s:UpdateState(u, i, sid, nam, tex, cnt, dur, exp)
						elseif exp~=s.exp[u] or s.cnt[u]~=cnt or val[s.vId]~=s.val[u] or s.spells then
							s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.val[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, val[s.vId], 1
						else
							s.seen, s.idx[u] = -1, i
						end
					end
				end
			end
			i = i + 1
		end
		if event then
			-- Mark indicators that need updating
			for s in next, Statuses do
				local seen = s.seen
				if (seen==1) or ((not seen) and s.idx[u] and s:Reset(u)) then
					for indicator in next, s.indicators do
						indicators[indicator] = true
					end
				end
				if s.ResetState then s:ResetState(u) end
				s.seen = false
			end
			-- Update indicators that needs updating only once.
			local frames = myFrames[u]
			for indicator in next, indicators do
				for frame in next, frames do
					indicator:Update(frame, u)
				end
			end
			wipe(indicators)
		else
			for s in next, Statuses do
				if not s.seen and s.idx[u] then
					s.idx[u], s.exp[u], s.val[u] = nil, nil, nil
				end
				if s.ResetState then s:ResetState(u) end
				s.seen = false
			end
		end
	end
end

-- Clear/update auras when unit changes or leaves the roster.
local UpdateAllAuras
do
	local function UpdateFakedUnitsAuras(_,units)
		for unit in next, units do
			AuraFrame_OnEvent(nil, true, unit)
		end
	end
	local function ClearAurasOfUnit(_, unit)
		for status in next, Statuses do
			status.idx[unit], status.exp[unit], status.val[unit] = nil, nil, nil
		end
	end
	local function UpdateAurasOfUnit(_, unit)
		AuraFrame_OnEvent(nil, nil, unit)
	end
	function UpdateAllAuras() -- TODO, very inefficient if several suspended buffs/debuffs are waked up, because it's executed for each status, and should be executed only once for all statuses.
		for unit in Grid2:IterateRosterUnits() do
			AuraFrame_OnEvent(nil,nil,unit)
		end
	end
	Grid2.RegisterMessage( Statuses, "Grid_UnitLeft", ClearAurasOfUnit )
	Grid2.RegisterMessage( Statuses, "Grid_UnitUpdated", UpdateAurasOfUnit )
	Grid2.RegisterMessage( Statuses, "Grid_FakedUnitsUpdate", UpdateFakedUnitsAuras)
end

-- Load colors cache for debuff types
local function LoadDebuffTypeColors()
	local statuses = Grid2.db.profile.statuses
	for _,typ in ipairs(debuffTypesKeys) do
		local status = statuses['debuff-'..typ]
		debuffTypeColors[typ] = status and status.color1
	end
end

-- EnableAuraEvents() DisableAuraEvents()
local EnableAuraEvents, DisableAuraEvents
do
	local frame
	EnableAuraEvents = function(status)
		if not next(Statuses) then
			if not frame then frame = CreateFrame("Frame", nil, Grid2LayoutFrame) end
			frame:SetScript("OnEvent", AuraFrame_OnEvent)
			frame:RegisterEvent("UNIT_AURA")
			if Grid2.classicDurations then
				LibStub("LibClassicDurations"):Register(Grid2)
				UnitAura = LibStub("LibClassicDurations").UnitAuraDirect
			end
			LoadDebuffTypeColors()
		end
	end
	DisableAuraEvents = function(status)
		if not next(Statuses) then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_AURA")
			if Grid2.classicDurations then
				LibStub("LibClassicDurations"):Unregister(Grid2)
			end
		end
	end
end

-- RegisterTimeTrackerStatus() UnregisterTimeTrackerStatus()
local RegisterTimeTrackerStatus, UnregisterTimeTrackerStatus
do
	local timetracker
	local tracked = {}
	RegisterTimeTrackerStatus = function(status, elapsed)
		timetracker = Grid2:CreateTimer( function(self)
			local time = GetTime()
			for status,elapsed in next, tracked do
				local tracker    = status.tkr
				local thresholds = status.thresholds
				for unit, expiration in next, status.exp do
					local threshold = thresholds[tracker[unit]]
					if threshold and time >= expiration - (elapsed and status.dur[unit]-threshold or threshold) then
						tracker[unit] = tracker[unit] + 1
						status:UpdateIndicators(unit)
					end
				end
			end
		end, 0.1, false )
		RegisterTimeTrackerStatus = function(status, elapsed)
			if not next(tracked) then timetracker:Play() end
			tracked[status] = elapsed or false
		end
		RegisterTimeTrackerStatus(status, elapsed)
	end
	UnregisterTimeTrackerStatus = function(status)
		tracked[status] = nil
		if (not next(tracked)) and timetracker then timetracker:Stop() end
	end
end

local function RegisterStatusAura(status, auraType, spell, update)
	EnableAuraEvents(status)
	if auraType=="debuffType" then
		DebuffTypes[spell] = status
	elseif not spell then
		DebuffGroups[status] = not not update
	else
		local handler = auraType=="buff" and Buffs or Debuffs
		local statuses = handler[spell]
		if not statuses then
			statuses = {}
			handler[spell] = statuses
		end
		statuses[status] = true
	end
	Statuses[status] = true
end

local function UnregisterStatusAura(status, auraType, subType)
	local handler = (auraType=="buff" and Buffs) or (auraType=="debuff" and Debuffs)
	if handler then
		for key,statuses in pairs(handler) do
			if statuses[status] then
				statuses[status] = nil
				if not next(statuses) then handler[key] = nil end
			end
		end
		DebuffGroups[status] = nil
	else
		DebuffTypes[subType] = nil
	end
	Statuses[status] = nil
	DisableAuraEvents(status)
end

-- MakeStatusColorHandler()
local MakeStatusColorHandler
do
	local handlerArray = {}
	MakeStatusColorHandler = function(status)
		local dbx = status.dbx
		if dbx.color1 then
			local colorCount = dbx.colorCount or 1
			handlerArray[1] = "return function (self, unit)"
			if colorCount > 1 then
				handlerArray[#handlerArray+1] = " local count = self:GetCount(unit)"
				for i = 1, colorCount - 1 do
					local color = dbx["color" .. i]
					handlerArray[#handlerArray+1] = (" if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
				end
			end
			local color = dbx["color" .. colorCount]
			handlerArray[#handlerArray+1] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)
			status.GetColor = assert(loadstring(table.concat(handlerArray)))()
			wipe(handlerArray)
		end
	end
end

-- Grid2.CreateStatusAura()
local CreateStatusAura
do
	local fmt = string.format
	local UnitHealthMax = UnitHealthMax
	local unit_is_pet   = Grid2.owner_of_unit
	local function Reset(self, unit) -- multibar indicator needs val[unit]=nil because due to a speed optimization it does not check if status is active before calling GetPercent()
		self.idx[unit], self.exp[unit], self.val[unit] = nil, nil, nil
		return true
	end
	-- with unit class/reaction/role filters
	local function IsActiveFilter(self, unit)
		return not self.filtered[unit] and self.idx[unit]~=nil
	end
	local function IsActiveStacksFilter(self, unit)
		return not self.filtered[unit] and self.idx[unit] and self.cnt[unit]>=self.stacks
	end
	local function IsActiveBlinkFilter(self, unit)
		if self.filtered[unit] or not self.idx[unit] then return end
		return self.tkr[unit]==1 or "blink"
	end
	local function IsActiveStacksBlinkFilter(self, unit)
		if self.filtered[unit] or not (self.idx[unit] and self.cnt[unit]>=self.stacks) then return end
		return self.tkr[unit]==1 or "blink"
	end
	local function IsActiveBlinkAFilter(self, unit)
		if self.filtered[unit] or not self.idx[unit] then return end
		return "blink"
	end
	local function IsActiveStacksBlinkAFilter(self, unit)
		if self.filtered[unit] or not (self.idx[unit] and self.cnt[unit]>=self.stacks) then return end
		return "blink"
	end
	local function IsInactiveFilter(self, unit)
		return not self.filtered[unit] and not (self.idx[unit] or unit_is_pet[unit])
	end
	local function IsInactiveBlinkFilter(self, unit)
		return not self.filtered[unit] and not (self.idx[unit] or unit_is_pet[unit]) and "blink"
	end
	local function IsInactiveFilterPets(self, unit)
		return not self.filtered[unit] and not self.idx[unit]
	end
	local function IsInactiveBlinkFilterPets(self, unit)
		return not self.filtered[unit] and not self.idx[unit] and "blink"
	end
	-- no unit class/reaction/role filters
	local function IsActive(self, unit)
		if self.idx[unit] then return true end
	end
	local function IsActiveStacks(self, unit)
		if self.idx[unit] and self.cnt[unit]>=self.stacks then return true end
	end
	local function IsActiveBlink(self, unit)
		if not self.idx[unit] then return end
		return self.tkr[unit]==1 or "blink"
	end
	local function IsActiveStacksBlink(self, unit)
		if not (self.idx[unit] and self.cnt[unit]>=self.stacks) then return end
		return self.tkr[unit]==1 or "blink"
	end
	local function IsActiveBlinkA(self, unit)
		if not self.idx[unit] then return end
		return "blink"
	end
	local function IsActiveStacksBlinkA(self, unit)
		if not (self.idx[unit] and self.cnt[unit]>=self.stacks) then return end
		return "blink"
	end
	local function IsInactive(self, unit)
		return not (self.idx[unit] or unit_is_pet[unit])
	end
	local function IsInactiveBlink(self, unit)
		return not (self.idx[unit] or unit_is_pet[unit]) and "blink"
	end
	local function IsInactivePets(self, unit)
		return not self.idx[unit]
	end
	local function IsInactiveBlinkPets(self, unit)
		return not self.idx[unit] and "blink"
	end
	--
	local function GetIcon(self, unit)
		return self.tex[unit]
	end
	local function GetIconMissing(self)
		return self.missingTexture
	end
	local function GetCount(self, unit)
		return self.cnt[unit]
	end
	local function GetCountMissing()
		return 1
	end
	local function GetExpirationTime(self, unit)
		return self.exp[unit]
	end
	local function GetExpirationTimeMissing()
		return GetTime() + 9999
	end
	local function GetCountMax(self)
		return self.dbx.colorCount or 1
	end
	local function GetDuration(self, unit)
		return self.dur[unit]
	end
	local function GetDurationFixed(self)
		return self.dbx.maxDuration
	end
	local function GetDurationMissing()
		return
	end
	local function GetPercentHealth(self, unit)
		local m = UnitHealthMax(unit)
		return m>0 and (self.val[unit] or 0) / m or 0
	end
	local function GetPercentMax(self, unit)
		return (self.val[unit] or 0) / self.valMax
	end
	local function GetTextValue(self, unit)
		return fmt( "%.1fk", (self.val[unit] or 0) / 1000 )
	end
	local function GetTextSpell(self, unit)
		return self.spellText
	end
	local function GetTextCustom(self, unit)
		return self.customText
	end
	local function GetTimeColor(self, unit) -- Color by time remaining or time elapsed
		local colors = self.colors
		local i = self.tkr[unit]
		local c = colors[i] or colors[1]
		return c.r, c.g, c.b, c.a
	end
	local function GetValueColor(self, unit) -- Color by value
		local i = 1
		local value = self.val[unit] or 0
		local thresholds = self.thresholds
		while i<=#thresholds and value<thresholds[i] do
			i = i + 1
		end
		local c = self.colors[i]
		return c.r, c.g, c.b, c.a
	end
	local function GetBorderMandatory()
		return 1
	end
	local function GetBorderOptional()
		return 0
	end
	local function GetDebuffTooltip(self, unit, tip, slotID)
		local index = slotID or self.idx[unit]
		if index then
			tip:SetUnitDebuff(unit, index)
		end
	end
	local function GetBuffTooltip(self, unit, tip, slotID)
		local index = slotID or self.idx[unit]
		if index then
			tip:SetUnitBuff(unit, index)
		end
	end
	local function OnEnable(self)
		if self.spell then -- standalone buff or debuff
			RegisterStatusAura(self, self.handlerType, self.spell)
		elseif self.handlerType=='buff' then
			for spell in pairs(self.spells) do
				RegisterStatusAura( self, 'buff', spell )
			end
		else -- debuffType or group of filtered debuffs
			RegisterStatusAura(self, self.handlerType, self.dbx.subType, self.fullUpdate)
		end
		if self.thresholds and (not self.dbx.colorThresholdValue) then
			RegisterTimeTrackerStatus(self, self.dbx.colorThresholdElapsed)
		end
		UpdateAllAuras()
		if self.OnEnableAura then self:OnEnableAura() end
	end
	local function OnDisable(self)
		UnregisterStatusAura(self, self.handlerType, self.dbx.subType)
		UnregisterTimeTrackerStatus(self)
		wipe(self.idx);	wipe(self.exp); wipe(self.val)
		if self.OnDisableAura then self:OnDisableAura() end
	end
	local function UpdateStateCombineStacks(s, u, i, sid, nam, tex, cnt, dur, exp, typ)
		if s.seen then -- adding extra debuffs stacks
			s.cnt[u] = s.cnt[u] + cnt
		else -- debuff must be always marked to be updated (seen=1) and cnt must be initialized even if first debuff is not new and didn't change
			s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.typ[u], s.tkr[u], s.val[u]  = 1, i, tex, cnt, dur, exp, typ, 1, nil
		end
	end
	local function UpdateDB(self,dbx)
		if self.enabled then self:OnDisable() end
		local dbx = dbx or self.dbx
		local blinkThreshold = dbx.blinkThreshold or nil
		self.vId = dbx.valueIndex or 0
		self.valMax = dbx.valueMax
		self.GetPercent = dbx.valueIndex and (dbx.valueMax and GetPercentMax or GetPercentHealth) or Grid2.statusLibrary.GetPercent
		if self.spells then wipe(self.spells) end
		if dbx.auras then -- multiple spells
			local useSpellId = dbx.useSpellId
			self.spells = self.spells or {}
			if dbx.useSpellId then
				for _,spell in ipairs(dbx.auras) do
					self.spells[spell] = true
				end
			else
				for _,spell in ipairs(dbx.auras) do
					self.spells[ type(spell)=='number' and GetSpellInfo(spell) or spell ] = true
				end
			end
		elseif dbx.spellName then -- single spell
			local spell = dbx.spellName
			self.spellText = type(spell)=='number' and GetSpellInfo(spell) or spell
			self.spell = dbx.useSpellId and spell or self.spellText
		end
		if dbx.mine==2 then  -- 2>nil = not mine;  1|true>true = mine;  false|nil>false = mine&not-mine
			self.isMine = nil
		else
			self.isMine = not not dbx.mine
		end
		if dbx.missing then
			local spell = dbx.auras and dbx.auras[1] or dbx.spellName
			self.missingTexture = spell and select(3,GetSpellInfo(spell)) or "Interface\\ICONS\\Achievement_General"
			self.GetIcon  = GetIconMissing
			self.GetCount = GetCountMissing
			self.GetDuration = GetDurationMissing
			self.GetExpirationTime = GetExpirationTimeMissing
			if dbx.missingPets then
				if self.filtered then
					self.IsActive = blinkThreshold and IsInactiveBlinkFilterPets or IsInactiveFilterPets
				else
					self.IsActive = blinkThreshold and IsInactiveBlinkPets or IsInactivePets
				end
			else
				if self.filtered then
					self.IsActive = blinkThreshold and IsInactiveBlinkFilter or IsInactiveFilter
				else
					self.IsActive = blinkThreshold and IsInactiveBlink or IsInactive
				end
			end
			self.thresholds = nil
			self.UpdateState = nil
		else
			self.stacks = dbx.enableStacks
			self.GetIcon = GetIcon
			self.GetCount = GetCount
			self.GetExpirationTime = GetExpirationTime
			self.GetDuration = dbx.maxDuration and GetDurationFixed or GetDuration
			self.UpdateState = dbx.combineStacks and UpdateStateCombineStacks or nil
			if blinkThreshold then
				if blinkThreshold>0 then -- blink/glow active after some time threshold
					self.thresholds = { blinkThreshold }
					if self.filtered then
						self.IsActive = self.stacks and IsActiveStacksBlinkFilter or IsActiveBlinkFilter
					else
						self.IsActive = self.stacks and IsActiveStacksBlink or IsActiveBlink
					end
				else -- blink/glow always active, no timetracker is needed
					self.thresholds = nil
					if self.filtered then
						self.IsActive = self.stacks and IsActiveStacksBlinkAFilter or IsActiveBlinkAFilter
					else
						self.IsActive = self.stacks and IsActiveStacksBlinkA or IsActiveBlinkA
					end
				end
			else -- blinkThreshold==0 => always active
				self.thresholds = dbx.colorThreshold
				if self.filtered then
					self.IsActive = self.stacks and IsActiveStacksFilter or IsActiveFilter
				else
					self.IsActive = self.stacks and IsActiveStacks or IsActive
				end
			end
		end
		local colorCount = dbx.colorCount or 1
		if dbx.colorThreshold and colorCount>1 then -- color by time or value
			self.colors = self.colors or {}
			for i=1,colorCount do self.colors[i] = dbx["color"..i] end
			self.GetColor = dbx.colorThresholdValue and GetValueColor or GetTimeColor
		else -- single color or color by number of stacks
			MakeStatusColorHandler(self)
		end
		if dbx.type == "debuffType" then
			self.debuffFilter = dbx.debuffFilter
			self.GetBorder = GetBorderMandatory
		else
			self.GetBorder = GetBorderOptional
		end
		self.GetTooltip = (self.handlerType~="buff") and GetDebuffTooltip or GetBuffTooltip
		self.customText = dbx.text
		if dbx.text==1 then -- tracked value
			self.GetText = GetTextValue
		elseif dbx.text then -- custom text
			self.GetText = GetTextCustom
		else -- aura name
			self.GetText = GetTextSpell
		end
		if self.OnUpdate then self:OnUpdate(dbx) end
		if self.enabled then self:OnEnable() end
	end
	CreateStatusAura = function(status, baseKey, dbx, handlerType, statusTypes)
		status.handlerType = handlerType
		status.idx = {}
		status.tex = {}
		status.cnt = {}
		status.exp = {}
		status.dur = {}
		status.typ = {}
		status.val = {}
		status.tkr = {}
		status.Reset       = Reset
		status.GetCountMax = GetCountMax
		status.UpdateDB    = UpdateDB
		status.OnEnable    = OnEnable
		status.OnDisable   = OnDisable
		Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)
		return status
	end
end

--===============================================================================
-- buff, debuff, debuffType statuses
--===============================================================================

local statusTypesBD = { "color", "icon", "icons", "percent", "text", "tooltip" }
local statusTypesDT = { "color", "icon", "icons", "text", "tooltip" }

local function CreateAura(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	return CreateStatusAura( status, basekey, dbx, dbx.type, dbx.type=='debuffType' and statusTypesDT or statusTypesBD )
end

Grid2.setupFunc["buff"]       = CreateAura
Grid2.setupFunc["debuff"]     = CreateAura
Grid2.setupFunc["debuffType"] = CreateAura

Grid2:DbSetStatusDefaultValue( "debuff-Boss",     {type = "debuffType", subType = "Boss",     color1 = {r=1, g=0, b=0,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Magic",    {type = "debuffType", subType = "Magic",    color1 = {r=.2,g=.6,b=1,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Poison",   {type = "debuffType", subType = "Poison",   color1 = {r=0, g=.6,b=0,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Curse",    {type = "debuffType", subType = "Curse",    color1 = {r=.6,g=0, b=1,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Disease",  {type = "debuffType", subType = "Disease",  color1 = {r=.6,g=.4,b=0,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Typeless", {type = "debuffType", subType = "Typeless", color1 = {r=0, g=0, b=0,a=1 }} )

--===============================================================================
-- Publish some functions & tables
--===============================================================================

Grid2.CreateStatusAura = CreateStatusAura
Grid2.debuffTypeColors = debuffTypeColors
Grid2.debuffDispelTypes = debuffDispelTypes

--[[ statuses database configurations
	type = "buff"
	enableStacks = integer              -- minimum stacks to activate the status
	spellName = string|integer
	useSpellId = true|nil			    -- track by spellID instead of aura name
	mine = 2 | 1 | true | false | nil   -- 2=not mine; 1|true=mine; false|nil=all spells
	missing = true | nil
	blinkThreshold = number	            -- seconds remaining to enable indicator blinking
	colorThresholdValue = true | nil 	-- true = color by value; nil = color by time
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--
	type = "debuff"
	enableStacks = integer              -- minimum stacks to activate the status
	spellName = string|integer
	useSpellId = true|nil
	blinkThreshold = number	            -- seconds remaining to enable indicator blinking
	colorThresholdValue = true | nil 	-- true = color by value; nil = color by time
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--
	type = "debuffType"
	subType = "Magic"|"Curse"|"Poison"|"Disease"
	debuffFilter = { "Chill" = true, "Fear" = true }
	color1 = { r=1,g=1,b=1,a=1 }
--]]
