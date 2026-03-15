-- Auras management
local Grid2 = Grid2
local type = type
local next = next
local GetTime = GetTime
local GetSpellInfo = Grid2.API.GetSpellInfo
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local GetAuraDuration = C_UnitAuras.GetAuraDuration
local canaccessvalue = Grid2.canaccessvalue
local myUnits = Grid2.roster_my_units
local myFrames = Grid2Frame.frames_of_unit

-- Local variables
local Statuses = {}
local Buffs = {}

-- UNIT_AURA event management
local UpdateAllAuras, UnitAuraEvent
do
	-- update status indicators
	local function UpdateStatusFrames(unit, status, frames)
		for indicator in next, status.indicators do
			for frame in next, frames do
				indicator:Update(frame, unit)
			end
		end
	end
	-- full aura scan
	local function ScanFull(u)
		for i=1,40 do
			local a = GetAuraDataByIndex(u, i, 'HELPFUL')
			if a==nil then break end
			local sid = a.spellId
			if canaccessvalue(sid) then
				local statuses = Buffs[a.name] or Buffs[sid]
				if statuses then
					for s in next, statuses do
						local mine = s.isMine
						if (mine==false or mine==myUnits[a.sourceUnit]) and (not s.seen) then
							s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.tkr[u] = true, a.auraInstanceID, a.icon, a.applications, a.duration, a.expirationTime, 1
						end
					end
				end
			end
		end
	end
	-- clear removed statuses on last aura full scan and update indicators linked to all statuses
	local function UpdateFull(u)
		local frames = myFrames[u]
		for s in next, Statuses do
			if s.seen then
				s.seen = nil
			else
				s.idx[u], s.exp[u] = nil, nil
			end
			UpdateStatusFrames(u,s,frames)
		end
	end
	-- clear removed statuses on last aura full scan without updating indicators
	local function ClearFull(u)
		for s in next, Statuses do
			if s.seen then
				s.seen = nil
			else
				s.idx[u], s.exp[u] = nil, nil
			end
		end
	end
	-- scan added auras
	local function ScanAdded(u, added)
		if added then
			for _,a in ipairs(added) do
				local sid = a.spellId
				if canaccessvalue(sid) then
					local statuses = Buffs[a.name] or Buffs[sid]
					if statuses then
						for s in next, statuses do
							local mine = s.isMine
							if (mine==false or mine==myUnits[a.sourceUnit]) and (not s.seen) then
								s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.tkr[u] = true, a.auraInstanceID, a.icon, a.applications, a.duration, a.expirationTime, 1
							end
						end
					end
				end
			end
		end
	end
	-- scan updated auras
	local function ScanUpdated(u, updated)
		if updated then
			for _,aid in ipairs(updated) do
				local a = GetAuraDataByAuraInstanceID(u,aid)
				if a then
					local sid = a.spellId
					if canaccessvalue(sid) then
						local statuses = Buffs[a.name] or Buffs[sid]
						if statuses then
							for s in next, statuses do
								if aid==s.idx[u] then
									s.seen, s.cnt[u], s.dur[u], s.exp[u], s.tkr[u] = true, a.applications, a.duration, a.expirationTime, 1
								end
							end
						end
					end
				end
			end
		end
	end
	-- scan removed auras
	local function ScanRemoved(u, removed)
		if removed then
			for _,aid in ipairs(removed) do
				removed[aid] = true
			end
		end
	end
	-- update indicators linked to statuses added/modified/removed on last aura non-full scan
	local function UpdatePartial(u, removed)
		local frames = myFrames[u]
		for s in next, Statuses do
			if s.seen then
				s.seen = nil
				UpdateStatusFrames(u,s,frames)
			elseif removed and removed[s.idx[u]] then
				s.idx[u], s.exp[u] = nil, nil
				UpdateStatusFrames(u,s,frames)
			end
		end
	end
	-- UNIT_AURA event
	UnitAuraEvent = function(_, event, u, info)
		if info and not info.isFullUpdate then
			ScanAdded(u, info.addedAuras)
			ScanUpdated(u, info.updatedAuraInstanceIDs)
			ScanRemoved(u, info.removedAuraInstanceIDs)
			UpdatePartial(u, info.removedAuraInstanceIDs)
		else
			ScanFull(u)
			UpdateFull(u)
		end
	end
	-- clear all statuses when a unit leave the roster
	Grid2.RegisterMessage( Statuses, "Grid_UnitLeft", function(_,u)
		for s in next, Statuses do
			s.idx[u], s.exp[u] = nil, nil
		end
	end )
	-- full scan when a roster unit joins or is changed, we don't update indicators here, because roster code will update all indicators after this message.
	Grid2.RegisterMessage( Statuses, "Grid_UnitUpdated", function(_,u)
		ScanFull(u)
		ClearFull(u)
	end )
	--  full scan when a status is enabled (profile load, status settings changed, or suspended status wake up), like in previous case indicators update is not needed.
	function UpdateAllAuras() -- TODO, very inefficient if several suspended buffs/debuffs are waked up, because it's executed for each status, and should be executed only once for all statuses.
		for u in Grid2:IterateRosterUnits() do
			ScanFull(u)
			ClearFull(u)
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
	if not next(Statuses) then
		Grid2.RegisterRosterUnitEvent(Statuses, "UNIT_AURA", UnitAuraEvent)
	end
	local handler = Buffs
	local statuses = handler[spell]
	if not statuses then
		statuses = {}
		handler[spell] = statuses
	end
	statuses[status] = true
	Statuses[status] = true
end

local function UnregisterStatusAura(status, auraType, subType)
	local handler = Buffs
	for key,statuses in pairs(handler) do
		if statuses[status] then
			statuses[status] = nil
			if not next(statuses) then handler[key] = nil end
		end
	end
	Statuses[status] = nil
	if not next(Statuses) then
		Grid2.UnregisterRosterUnitEvent(Statuses, "UNIT_AURA")
	end
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
	local function GetDurationObject(self, unit)
		return GetAuraDuration(unit, self.idx[unit])
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
	local function GetAuraPointsValue(self, unit)
		local a = GetAuraDataByAuraInstanceID(unit, self.idx[unit])
		return a and a.points[self.vId] or 0
	end
	local function GetPercentHealth(self, unit)
		local m = UnitHealthMax(unit)
		return (canaccessvalue(m) and m>0) and GetAuraPointsValue(self, unit)/m or 0
	end
	local function GetPercentMax(self, unit)
		return GetAuraPointsValue(self, unit) / self.valMax
	end
	local function GetTextValue(self, unit)
		return fmt( "%.1fk", GetAuraPointsValue(self, unit) / 1000 )
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
		local value = GetAuraPointsValue(self, unit)
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
	local function GetBuffTooltip(self, unit, tip, slotID)
		local aid = slotID or self.idx[unit]
		if aid then
			tip:SetUnitAuraByAuraInstanceID(unit, aid)
		end
	end
	local function OnEnable(self)
		if self.spell then -- standalone buff
			RegisterStatusAura(self, self.handlerType, self.spell)
		elseif self.handlerType=='buff' then
			for spell in pairs(self.spells) do
				RegisterStatusAura( self, 'buff', spell )
			end
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
		wipe(self.idx);	wipe(self.exp)
		if self.OnDisableAura then self:OnDisableAura() end
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
			self.spellText = type(spell)=='number' and GetSpellInfo(spell) or tostring(spell)
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
		else
			self.stacks = dbx.enableStacks
			self.GetIcon = GetIcon
			self.GetCount = GetCount
			self.GetExpirationTime = GetExpirationTime
			self.GetDuration = dbx.maxDuration and GetDurationFixed or GetDuration
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
		self.GetBorder = GetBorderOptional
		self.GetTooltip = GetBuffTooltip
		self.GetDurationObject = GetDurationObject
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
		status.tkr = {}
		status.GetCountMax = GetCountMax
		status.UpdateDB    = UpdateDB
		status.OnEnable    = OnEnable
		status.OnDisable   = OnDisable
		Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)
		return status
	end
end

--===============================================================================
-- buff
--===============================================================================

do
	local statusTypesBD = { "color", "icon", "icons", "percent", "text", "tooltip" }

	Grid2.CreateStatusAura = CreateStatusAura

	local function CreateAura(baseKey, dbx)
		local status = Grid2.statusPrototype:new(baseKey, false)
		return CreateStatusAura( status, basekey, dbx, dbx.type, statusTypesBD )
	end

	Grid2.setupFunc["buff"] = CreateAura
end

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
--]]
