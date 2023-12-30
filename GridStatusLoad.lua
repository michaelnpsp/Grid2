-- Statuses Load filter management, by MiCHaEL
local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local next = next
local pairs = pairs
local rawget = rawget
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local GetSpellCooldown = GetSpellCooldown
local UnitGroupRolesAssigned = Grid2.UnitGroupRolesAssigned
local roster_types = Grid2.roster_types
local roster_deads = Grid2.roster_deads
local empty = {}

-------------------------------------------------------------------------
-- Register/Unregister filtered statuses
-------------------------------------------------------------------------

local statuses = { combat = {}, playerClassSpec = {}, groupInstType = {}, instNameID = {}, unitFilter = {}, unitRole = {}, unitAlive = {}, cooldown = {} }

local function RegisterMsgFilter(status, filterType, message, func, enabled)
	local registered = statuses[filterType]
	if not enabled ~= not registered[status] then
		if enabled then
			if not next(registered) then Grid2.RegisterMessage(statuses, message, func) end
			registered[status] = enabled
		else
			registered[status] = nil
			if not next(registered) then Grid2.UnregisterMessage(statuses, message) end
		end
	end
end

local function RegisterEventFilter(status, filterType, event, func, enabled)
	local registered = statuses[filterType]
	if not enabled ~= not registered[status] then
		if enabled then
			if not next(registered) then Grid2:RegisterEvent(event, func) end
			registered[status] = enabled
		else
			registered[status] = nil
			if not next(registered) then Grid2:UnregisterEvent(event) end
		end
	end
end

-------------------------------------------------------------------------
-- General filters: class/spec/zone/group type
-- statuses are suspended&unregistered from indicators
-------------------------------------------------------------------------

local FilterG_Register, FilterG_Unregister, FilterG_Refresh
do
	local indicators = {} -- indicators marked for update

	local function RegisterIndicators(self)
		local method = self.suspended and "UnregisterStatus" or "RegisterStatus"
		for indicator, priority in pairs(self.priorities) do -- wakeup/suspend status from linked indicators
			indicator[method](indicator, self, priority)
			indicators[indicator] = true
		end
	end

	local function UpdateMarkedIndicators()
		for frame, unit in next, Grid2Frame.activatedFrames do
			for indicator in next, indicators do
				indicator:Update(frame, unit)
			end
		end
		wipe(indicators)
	end

	local function CheckZoneFilter(filter)
		local instanceName,_,_,_,_,_,_,instanceID = GetInstanceInfo()
		return filter[instanceName] or filter[instanceID]
	end

	local function SuspendStatus(self, load)
		local prev = self.suspended
		if load then
			self.suspended =
				( load.disabled ) or
				( load.playerClass     and not load.playerClass[ Grid2.playerClass ]         ) or
				( load.playerClassSpec and not load.playerClassSpec[ Grid2.playerClassSpec ] ) or
				( load.groupType       and not load.groupType[ Grid2.groupType ]             ) or
				( load.instType        and not load.instType[ Grid2.instType ]               ) or
				( load.instNameID      and not CheckZoneFilter(load.instNameID)              ) or nil
			return self.suspended ~= prev
		else
			self.suspended = nil
			return prev
		end
	end

	local function RefreshStatuses(filterType)
		local notify
		for status, load in pairs(statuses[filterType]) do
			if SuspendStatus(status, load) then
				RegisterIndicators(status)
				notify = true
			end
		end
		UpdateMarkedIndicators()
		if notify then
			Grid2:SendMessage("Grid_StatusLoadChanged")
		end
	end

	-- message events
	local function GroupTypeEvent()
		RefreshStatuses('groupInstType')
	end

	local function PlayerSpecEvent()
		RefreshStatuses('playerClassSpec')
	end

	local function ZoneChangedEvent()
		RefreshStatuses('instNameID')
	end

	-- public
	function FilterG_Register(self, load)
		RegisterMsgFilter( self, "instNameID",      "Grid_ZoneChangedNewArea", ZoneChangedEvent, load and load.instNameID and load )
		RegisterMsgFilter( self, "playerClassSpec", "Grid_PlayerSpecChanged",  PlayerSpecEvent,  load and load.playerClassSpec and load )
		RegisterMsgFilter( self, "groupInstType",   "Grid_GroupTypeChanged",   GroupTypeEvent,   load and (load.groupType or load.instType) and load )
		return SuspendStatus(self, load)
	end

	function FilterG_Unregister(self)
		RegisterMsgFilter( self, "instNameID",      "Grid_ZoneChangedNewArea" )
		RegisterMsgFilter( self, "playerClassSpec", "Grid_PlayerSpecChanged" )
		RegisterMsgFilter( self, "groupInstType",   "Grid_GroupTypeChanged" )
	end

	function FilterG_Refresh(self, load)
		if FilterG_Register(self, load or empty) then
			RegisterIndicators(self)
			UpdateMarkedIndicators()
		end
	end

end

-------------------------------------------------------------------------
-- Unit filters: type/class/role/reaction
-- self.filtered[unit] check inside status:IsActive() method is necessary
-------------------------------------------------------------------------

local FilterU_Register, FilterU_Unregister, FilterU_Enable, FilterU_Disable, FilterU_Refresh
do
	local function IsSpellInCooldown(spellID)
		local start, duration = GetSpellCooldown(spellID)
		if start~=0 then
			local gcdStart, gcdDuration = GetSpellCooldown(61304)
			return start ~= gcdStart or duration ~= gcdDuration
		end
		return false
	end

	local cooldowns_mt = { __index = function(t,spellID)
		local r = IsSpellInCooldown(spellID)
		t[spellID] = r
		return r
	end }
	setmetatable(cooldowns_mt, cooldowns_mt)

	local filter_mt = {	__index = function(t,u)
		if UnitExists(u) then
			local load, r = t.source
			if load.unitType then
				r = not load.unitType[ roster_types[u] ]
			end
			if not r then
				if load.unitRole then
					r = not load.unitRole[ UnitGroupRolesAssigned(u) ]
				end
				if not r then
					if load.unitClass then
						local _,class = UnitClass(u)
						r = not load.unitClass[class]
					end
					if not r then
						if load.unitReaction then
							r = not UnitIsFriend('player',u)
							if load.unitReaction.hostile then r = not r end
						end
						if not r then
							if load.unitAlive~=nil then
								r = not roster_deads[u] == not load.unitAlive
							end
							if not r then
								if load.cooldown then
									r = cooldowns_mt[load.cooldown]
								end
							end
						end
					end
				end
			end
			t[u] = r
			return r
		end
		t[u] = true
		return true
	end }

	local function ClearUnitFilters(_, unit)
		for status, filtered in next, statuses.unitFilter do
			filtered[unit] = nil
		end
	end

	local function RefreshAliveFilter(_, unit)
		for status, filtered in next, statuses.unitAlive do
			filtered[unit] = nil
			status:UpdateIndicators(unit)
		end
	end

	local function RefreshRoleFilter()
		for status, filtered in next, statuses.unitRole do
			wipe(filtered).source = status.dbx.load
			status:UpdateAllUnits()
		end
	end

	local function RefreshCooldownFilter()
		for status, filtered in next, statuses.cooldown do
			local load = status.dbx.load
			local spellID = load.cooldown
			local cool = IsSpellInCooldown(spellID)
			if cool ~= rawget( cooldowns_mt, spellID ) then
				cooldowns_mt[spellID] = cool
				wipe(filtered).source = load
				for unit in next, status.idx do
					status:UpdateIndicators(unit)
				end
			end
		end
	end

	-- public
	function FilterU_Register(self, load)
		if load.unitType or load.unitReaction or load.unitClass or load.unitRole or load.cooldown or load.unitAlive~=nil then
			self.filtered = setmetatable({source = load}, filter_mt)
		else
			self.filtered = nil
		end
	end

	function FilterU_Unregister(self, load)
		self.filtered = nil
	end

	function FilterU_Enable(self, load)
		local filtered = self.filtered
		if filtered then
			RegisterMsgFilter( self, "unitFilter", "Grid_UnitUpdated", ClearUnitFilters,  filtered )
			RegisterMsgFilter( self, "unitAlive", "Grid_UnitDeadUpdated", RefreshAliveFilter,  load.unitAlive~=nil and filtered )
			RegisterMsgFilter( self, "unitRole", "Grid_PlayerRolesAssigned", RefreshRoleFilter, load.unitRole and filtered )
			RegisterEventFilter( self, "cooldown", "SPELL_UPDATE_USABLE", RefreshCooldownFilter, load.cooldown and filtered )
		end
	end

	function FilterU_Disable(self, load)
		local filtered = self.filtered
		if filtered then
			RegisterMsgFilter( self, "unitFilter", "Grid_UnitUpdated" )
			RegisterMsgFilter( self, "unitAlive", "Grid_UnitDeadUpdated" )
			RegisterMsgFilter( self, "unitRole", "Grid_PlayerRolesAssigned" )
			RegisterEventFilter( self, "cooldown", "SPELL_UPDATE_USABLE" )
			wipe(filtered).source = load
		end
	end

	function FilterU_Refresh(self, load)
		FilterU_Disable(self, load)
		FilterU_Register(self, load or empty)
		self:UpdateDB()
		if self.enabled then
			FilterU_Enable(self, load or empty)
			self:UpdateAllUnits()
		end
	end

end

-------------------------------------------------------------------------
-- Combat filter
-------------------------------------------------------------------------

local FilterC_Enable, FilterC_Disable, FilterC_Refresh
do
	local statuses = statuses.combat
	local IsNotActive = Grid2.Dummy
	local frame, inCombat

	local function CombatEvent(_,event)
		inCombat = (event=='PLAYER_REGEN_DISABLED')
		for status, load in next,statuses do
			local IsActive = status._IsActive
			local Update = status.UpdateIndicators
			status.IsActive = load.combat == inCombat and IsActive or IsNotActive
			for unit in Grid2:IterateGroupedPlayers() do
				if IsActive(status,unit) then
					Update(status,unit)
				end
			end
		end
	end

	-- public
	function FilterC_Enable(status, load)
		if load.combat~=nil then
			frame = frame or CreateFrame("Frame", nil, Grid2LayoutFrame)
			if not next(statuses) then
				frame:SetScript("OnEvent", CombatEvent)
				frame:RegisterEvent("PLAYER_REGEN_ENABLED")
				frame:RegisterEvent("PLAYER_REGEN_DISABLED")
				inCombat = not not InCombatLockdown()
			end
			statuses[status] = load
			if status.IsActive~=IsNotActive then
				status._IsActive = status.IsActive
			end
			if load.combat ~= inCombat then
				status.IsActive = IsNotActive
			end
		end
	end

	function FilterC_Disable(status)
		if statuses[status] then
			statuses[status] = nil
			if status._IsActive then
				status.IsActive = status._IsActive
				status._IsActive = nil
			end
			if not next(statuses) and frame then
				frame:SetScript("OnEvent", nil)
				frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
				frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
			end
		end
	end

	function FilterC_Refresh(status, load)
		FilterC_Disable(status, load)
		status:UpdateDB()
		if status.enabled and load then
			FilterC_Enable(status, load)
			status:UpdateAllUnits()
		end
	end

end

-----------------------------------------------------------------------
-- status methods
-----------------------------------------------------------------------

local status = Grid2.statusPrototype

function status:RegisterLoad() -- called from Grid2:RegisterStatus() in GridStatus.lua
	local load = self.dbx.load
	if load then
		FilterG_Register(self, load)
		FilterU_Register(self, load)
	end
end

function status:UnregisterLoad() -- called from Grid2:UnregisterStatus() in GridStatus.lua
	local load = self.dbx.load
	if load then
		FilterG_Unregister(self, load)
		FilterU_Unregister(self, load)
	end
	self.suspended = nil
end

function status:EnableLoad() -- called from status:RegisterIndicator() when the status is enabled
	local load = self.dbx.load
	if load then
		FilterU_Enable(self, load)
		FilterC_Enable(self, load)
	end
end

function status:DisableLoad() -- called from status:UnregisterIndicator() when the status is disabled
	local load = self.dbx.load
	if load then
		FilterU_Disable(self, load)
		FilterC_Disable(self, load)
	end
end

function status:RefreshLoad() -- used by Grid2Options
	local load = self.dbx.load
	FilterG_Refresh(self, load)
	FilterU_Refresh(self, load)
	FilterC_Refresh(self, load)
end
