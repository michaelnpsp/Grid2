-- Auras management
local Grid2 = Grid2
local type = type
local next = next
local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

-- Local variables
local Statuses = {}
local Buffs = {}
local Debuffs = {}
local DebuffTypes = {}
local DebuffGroups = {}
local debuffTypeColors = {}
local debuffDispelTypes = { Magic = true, Curse = true, Disease = true, Poison = true }

-- UNIT_AURA event management
local AuraFrame_OnEvent
do
	local indicators = {}
	local val = {0, 0, 0}
	local myUnits = Grid2.roster_my_units
	AuraFrame_OnEvent = function(_, _, u)
		local frames = Grid2:GetUnitFrames(u)
		if not next(frames) then return end
		-- Scan Debuffs, Debuff Types, Debuff Groups
		local i = 1
		while true do
			local nam, tex, cnt, typ, dur, exp, cas, sid, bos, _
			nam, tex, cnt, typ, dur, exp, cas, _, _, sid, _, bos, _, val[1], val[2], val[3] = UnitDebuff(u, i)
			if not nam then break end
			if cnt==0 then cnt=1 end
			local statuses = Debuffs[nam] or Debuffs[sid]
			if statuses then
				for s in next, statuses do
					local mine = s.isMine
					if mine==false or mine==myUnits[cas] then
						if exp~=s.exp[u] or cnt~=s.cnt[u] or val[s.vId]~=s.val[u] then 
							s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.typ[u], s.val[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, typ, val[s.vId], 1
						else
							s.seen, s.idx[u] = -1, i
						end
					end	
				end
			end
			if typ then
				local s = DebuffTypes[typ]
				if s and not s.seen and not (s.debuffFilter and s.debuffFilter[nam]) then
					if exp~=s.exp[u] or cnt~=s.cnt[u] then
						s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u] = 1, i, tex, cnt, dur, exp
					else
						s.seen, s.idx[u] = -1, i
					end
				end
			end
			for s in next, DebuffGroups do
				if (not s.seen) and s:UpdateState(u, nam, dur, cas, bos) then
					s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.typ[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, typ, 1
				end	
			end
			i = i + 1
		end
		-- Scan Buffs
		i = 1
		while true do
			local nam, tex, cnt, dur, exp, cas, sid, _
			nam, tex, cnt, _, dur, exp, cas, _, _, sid, _, _, _, val[1], val[2], val[3] = UnitBuff(u, i)
			if not nam then break end
			local statuses = Buffs[nam] or Buffs[sid]
			if statuses then
				if cnt==0 then cnt = 1 end
				for s in next, statuses do
					local mine = s.isMine
					if mine==false or mine==myUnits[cas] then
						if exp~=s.exp[u] or s.cnt[u]~=cnt or val[s.vId]~=s.val[u] or s.spells then 
							s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.val[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, val[s.vId], 1
						else
							s.seen, s.idx[u] = -1, i 
						end
					end
				end
			end
			i = i + 1
		end
		-- Mark indicators that need updating
		for s in next, Statuses do
			local seen = s.seen
			if (seen==1) or ((not seen) and s.idx[u] and s:Reset(u)) then
				for indicator in next, s.indicators do
					indicators[indicator] = true
				end
			end	
			s.seen = false
		end
		-- Update indicators that needs updating only once.
		for indicator in next, indicators do
			for frame in next, frames do
				indicator:Update(frame, u)
			end
		end
		wipe(indicators)
	end
end

-- Passing Statuses instead of nil, because i dont know if nil is valid for RegisterMessage
Grid2.RegisterMessage( Statuses, "Grid_UnitUpdated", function(_, u) 
	AuraFrame_OnEvent(nil,nil,u)
end)

-- EnableAuraEvents() DisableAuraEvents()
local EnableAuraEvents, DisableAuraEvents
do
	local frame
	EnableAuraEvents = function()
		if not next(Statuses) then
			if not frame then frame = CreateFrame("Frame", nil, Grid2LayoutFrame) end
			frame:SetScript("OnEvent", AuraFrame_OnEvent)
			frame:RegisterEvent("UNIT_AURA")
		end
	end	
	DisableAuraEvents = function()
		if not next(Statuses) then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_AURA")
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

local function RegisterStatusAura(status, auraType, spell)
	EnableAuraEvents()
	if auraType=="debuffType" then
			DebuffTypes[spell] = status
	elseif not spell then
		DebuffGroups[status] = true
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
			if statuses[self] then
				statuses[self] = nil
				if not next(statuses) then handler[key] = nil end
			end
		end
		DebuffGroups[status] = nil
	else	
		DebuffTypes[subType] = nil
	end	
	Statuses[status] = nil
	DisableAuraEvents()
end

local function RefreshAuras() 
	for unit in Grid2:IterateRosterUnits() do
		AuraFrame_OnEvent(nil,nil,unit) 
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
	local function Reset(self, unit) 
		-- multibar indicator needs val[unit]=nil because due to a speed optimization it does not check if status is active before calling GetPercent()
		self.idx[unit], self.exp[unit], self.val[unit] = nil, nil, nil
		return true
	end
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
	local function IsInactive(self, unit)
		return not (self.idx[unit] or Grid2:UnitIsPet(unit)) 
	end
	local function IsInactiveBlink(self, unit) 
		return not self.idx[unit] and "blink" 
	end
	local function GetIcon(self, unit) return 
		self.tex[unit] 
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
	local function GetPercentHealth(self, unit)
		return (self.val[unit] or 0) / UnitHealthMax(unit)
	end
	local function GetPercentMax(self, unit)
		return (self.val[unit] or 0) / self.valMax
	end
	local function GetText(self, unit)
		return fmt( "%.1fk", (self.val[unit] or 0) / 1000 )
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
	local function GetDebuffTypeColor(self, unit)
		local color = debuffTypeColors[ self.typ[unit] ]
		if color then
			return color.r, color.g, color.b, color.a
		else
			return 0,0,0,1
		end
	end
	local function GetDebuffTooltip(self, unit, tip)
		local index = self.idx[unit]
		if index then
			tip:SetUnitDebuff(unit, index)
		end
	end	
	local function OnEnable(self)
		if self.spell then -- standalone buff or debuff
			RegisterStatusAura(self, self.handlerType, self.spell)
		elseif self.handlerType=="buff" or self.dbx.useWhiteList then  
			for spell in pairs(self.spells) do
				RegisterStatusAura( self, self.handlerType, spell )
			end	
		else -- debuffType or group of filtered debuffs 
			RegisterStatusAura(self, self.handlerType, self.dbx.subType)
		end
		if self.thresholds and (not self.dbx.colorThresholdValue) then
			RegisterTimeTrackerStatus(self, self.dbx.colorThresholdElapsed)
		end
	end
	local function OnDisable(self)
		UnregisterStatusAura(self, self.handlerType, self.dbx.subType)
		UnregisterTimeTrackerStatus(self)
	end
	local function UpdateDB(self,dbx)
		if self.enabled then self:OnDisable() end
		local dbx = dbx or self.dbx
		self.vId = dbx.valueIndex or 0
		self.valMax = dbx.valueMax
		self.GetPercent = dbx.valueMax and GetPercentMax or GetPercentHealth
		if dbx.auras then -- multiple spells
			self.spells = self.spells or {}
			wipe(self.spells)
			for _,spell in ipairs(dbx.auras) do
				self.spells[spell] = true
			end
		elseif dbx.spellName then -- single spell
			self.spell = type(dbx.spellName)=="number" and not self.dbx.useSpellId and GetSpellInfo(dbx.spellName) or dbx.spellName or "UNDEFINED"
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
			self.GetExpirationTime = GetExpirationTimeMissing
			self.IsActive = dbx.blinkThreshold and IsInactiveBlink or IsInactive
			self.thresholds = nil
		else
			self.stacks = dbx.enableStacks
			self.GetIcon  = GetIcon
			self.GetCount = GetCount
			self.GetExpirationTime = GetExpirationTime
			if dbx.blinkThreshold then
				self.thresholds = { dbx.blinkThreshold }
				self.IsActive = self.stacks and IsActiveStacksBlink or IsActiveBlink
			else
				self.thresholds = dbx.colorThreshold
				self.IsActive = self.stacks and IsActiveStacks or IsActive
			end
		end
		local colorCount = dbx.colorCount or 1
		if self.thresholds and colorCount>1 then
			self.colors = self.colors or {}
			for i=1,colorCount do
				self.colors[i] = dbx["color"..i]
			end
			self.GetColor = dbx.colorThresholdValue and GetValueColor or GetTimeColor
		elseif dbx.debuffTypeColorize then
			self.GetColor = GetDebuffTypeColor
		else
			MakeStatusColorHandler(self)
		end
		if dbx.type == "debuffType" then
			self.debuffFilter = dbx.debuffFilter
			self.GetBorder = GetBorderMandatory
			debuffTypeColors[dbx.subType] = dbx.color1
		else
			self.GetBorder = GetBorderOptional
		end
		if self.handlerType ~= "buff" then
			self.GetTooltip = GetDebuffTooltip
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
		status.GetText     = GetText
		status.GetDuration = GetDuration
		status.GetCountMax = GetCountMax
		status.UpdateDB    = UpdateDB
		status.OnEnable    = OnEnable
		status.OnDisable   = OnDisable
		Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)
		status:UpdateDB()
		return status
	end
end

--===============================================================================
-- buff, debuff, debuffType statuses
--===============================================================================

local statusTypesBD = { "color", "icon", "icons", "percent", "text" }
local statusTypesDT = { "color", "icon", "icons", "text", "tooltip" }

local function CreateAura(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	return CreateStatusAura( status, basekey, dbx, dbx.type, dbx.type=='debuffType' and statusTypesDT or statusTypesBD )
end

Grid2.setupFunc["buff"]       = CreateAura
Grid2.setupFunc["debuff"]     = CreateAura
Grid2.setupFunc["debuffType"] = CreateAura

Grid2:DbSetStatusDefaultValue( "debuff-Magic",   {type = "debuffType", subType = "Magic",   color1 = {r=.2,g=.6,b=1,a=1}} )
Grid2:DbSetStatusDefaultValue( "debuff-Poison",  {type = "debuffType", subType = "Poison",  color1 = {r=0,g=.6,b=0,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Curse",   {type = "debuffType", subType = "Curse",   color1 = {r=.6,g=0,b=1,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Disease", {type = "debuffType", subType = "Disease", color1 = {r=.6,g=.4,b=0,a=1}} )

--===============================================================================
-- Publish some functions & tables
--===============================================================================

Grid2.RefreshAuras      = RefreshAuras
Grid2.CreateStatusAura  = CreateStatusAura
Grid2.debuffTypeColors  = debuffTypeColors
Grid2.debuffDispelTypes = debuffDispelTypes

--[[ statuses database configurations 
	type = "buff" 
	enableStacks = integer              -- minimum stacks to activate the status
	spellName = string|integer
	useSpellID = true|nil			    -- track by spellID instead of aura name
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
	useSpellID = true|nil
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
