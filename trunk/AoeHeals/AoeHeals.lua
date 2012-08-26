--[[ Aoe Heals module, created by Michael
	
	* Created statuses
	aoe-ChainHeal			Best targets to use Shaman "Chain Heal"
	aoe-PrayerOfHealing		Best target in every raid group to use Priest "Prayer of Healing"
	aoe-CircleOfHealing		Best targets to use Priest "Circle of Healing"
	aoe-WildGrowth			Best targets to use Druid "Wild Growth"
	aoe-neighbors			Tracks how many units are near every unit (radius is configurable from options)
	aoe-highlighter			Highlight nearby units when the mouse enters on a cell unit.

	* Roster units structure, data calculated by UpdateRoster() and GetFilteredRoster()
		unit, group      Unit name and group index (example: "raid5", 2 )       
		deficit			 Health deficit + incoming heals
		percent			 Health percent (range 0-1)
		x,y				 Position of unit
		curMask          Bitmask of the current unit, each roster[index] element has a bitmask of 2^(index-1)
--]]

local AOEM = Grid2:NewModule("Grid2AoeHeals")

AOEM.defaultDB = {
	profile = {
		updateRate   = 0.25,
		showInCombat = true,
		showInRaid   = false,
	}
}
AOEM.playerClass = select(2, UnitClass("player"))

local Grid2 = Grid2
local Grid2Layout = Grid2Layout
local UnitExists = UnitExists
local UnitIsEnemy = UnitIsEnemy
local UnitIsVisible = UnitIsVisible
local InCombatLockdown = InCombatLockdown
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitGetIncomingHeals = UnitGetIncomingHeals
local GetNumRaidMembers = Grid2.GetNumRaidMembers
local GetNumPartyMembers = Grid2.GetNumPartyMembers 
local next = next 
local min = math.min
local max= math.max
local floor= math.floor
local select = select
local tsort = table.sort
local tinsert = table.insert
local tostring = tostring
local bit_band = bit.band

--{{
local raidSizes = {raid40= 25, raid25= 25, raid20= 20, raid15=15, raid10=10, party=5, solo=5}

local frame, timer
local statuses = {} 
local hlStatuses = {}

local roster  = {}		-- current roster, array part indexed by position, hash part indexed by unit
local rosterv = {}		-- valid roster,  excluded: out of range, dead, charmed units (or units at full health for chainheal status)
local rosterRaid    	-- precalculated roster tables (25 units) to avoid garbage

local rosterValid       -- True if roster units are up to date
local rosterPosValid	-- True if roster units position and health data was updated

local mapValid, mapWidth, mapHeight
--}}

--{{ Misc functions

local function ClearAllIndicators()
	for _, status in next,statuses do
		status:ClearIndicators()
	end
end

local function UpdateRoster()
	ClearAllIndicators()
	wipe(roster)
	local m= min(GetNumRaidMembers(),25)
	if m>0 then
		local g = raidSizes[Grid2Layout.partyType or "solo"]  / 5
		local i  = 1
		for j=1,m do 
			local h = select( 3, GetRaidRosterInfo(j) )
			if h<=g then
				local p = rosterRaid[i]
				roster[i] = p
				p.group   = h
				p.unit    = "raid" .. j
				roster[p.unit] = p
				i = i + 1
			end
		end	
		tsort( roster, function(a,b) return a.group<b.group end )
		for i=1,#roster do
			roster[i].curMask = 2^(i-1)
		end
	else
		for i=1,5 do
			local p= rosterRaid[i]
			roster[i] = p
			p.group   = 1
			p.curMask = 2^(i-1)
			p.unit    = (i==1) and "player" or "party"..(i-1)
			roster[p.unit] = p
		end
	end
	rosterValid = true
end

-- Initialize data tables

local function Init()
	if not rosterRaid then
		rosterRaid  = {}
		for i=1,25 do
			rosterRaid[i] = { neighbors={} } 
		end	
	end
end

--{{ Timer

local function TimerEvent()
	mapWidth, mapHeight = AOEM:MapGetSize()
	if mapWidth then
		mapValid = true
		rosterPosValid = false
		for _, status in next,statuses do
			status:Update()
		end
	elseif mapValid then
		mapValid = false
		ClearAllIndicators()
	end	
end

local function SetTimer(enable)
	if enable == not timer then
		rosterValid = false
		if enable then
			timer= Grid2:ScheduleRepeatingTimer(TimerEvent, AOEM.db.profile.updateRate)
			AOEM:Debug("Aoe Heals Timer Enabled.")
		else
			Grid2:CancelTimer(timer)
			timer = nil
			if mapValid then ClearAllIndicators() end
			AOEM:Debug("Aoe Heals Timer Disabled.")
		end
	end
end

--{{{{ statuses private methods

local function status_GetRoster()
	return roster
end

local function status_GetFilteredRoster()
	if not rosterPosValid then
		local chEnabled= AOEM.chEnabled
		if not rosterValid then	UpdateRoster() end
		wipe(rosterv)
		for i=1,#roster do
			local p = roster[i]
			local u = p.unit
			if UnitExists(u) and (not UnitIsDeadOrGhost(u)) and UnitIsVisible(u) and (not UnitIsEnemy("player", u)) then
				local hc = UnitHealth(u)
				local hm = UnitHealthMax(u)
				local hd = hm - hc
				if hd>0 or (not chEnabled) then
					local x,y = GetPlayerMapPosition(u)
					p.deficit = max( hd - (UnitGetIncomingHeals(u) or 0), 0 )
					p.percent = hc / hm
					p.x 	  = x * mapWidth
					p.y 	  = y * mapHeight
					rosterv[#rosterv+1] = p
				end	
			end	
		end
		AOEM:Debug("Calculating units positions. Valid units count: ", #rosterv)
		rosterPosValid = true
	end
	return rosterv
end

local function status_SwapUnits(self)
	self.states, self.statesu = self.statesu, self.states  
end

local function status_UpdateUnits(self)
	for unit in next, self.statesu do
		self:UpdateIndicators(unit)
	end
	wipe(self.statesu)
end

local function status_AddUnit(self, p)
	local unit    = p.unit
	local count   = p.count
	self.states[unit] = count
	if self.statesu[unit]~=count then
		self.statesu[unit]= count
	else
		self.statesu[unit]= nil
	end
	return true
end

local function status_ClearIndicators(self)
	status_SwapUnits(self)
	status_UpdateUnits(self)
end

local function status_GetHighlightMask(self, unit)
	if unit and self.states[unit] then
		return roster[unit][self.HighlightField] or 0
	end
end

--{{{{ statuses public interface methods

local function UpdateTimerState(InCombat)
	if InCombat==nil then InCombat = InCombatLockdown() end
	local disabled= (AOEM.db.profile.showInCombat and (not InCombat) ) or
	                (AOEM.db.profile.showInRaid and GetNumRaidMembers()==0) or
	                (GetNumRaidMembers()==0 and GetNumPartyMembers()==0)
	SetTimer(not disabled)
end

local function FrameEvents(self, event)
	local dbx= AOEM.db.profile
	if event=="RAID_ROSTER_UPDATE" or event=="GROUP_ROSTER_UPDATE" then
		rosterValid = false  
		if dbx.showInRaid or (not timer) then 
			UpdateTimerState() 
		end	
	elseif event=="PARTY_MEMBERS_CHANGED" then
		if GetNumRaidMembers()==0 then 
			rosterValid = false
			UpdateTimerState() 
		end	
	elseif dbx.showInCombat then  -- REGEN_DISABLED and REGEN_ENABLED events
		UpdateTimerState( event=="PLAYER_REGEN_DISABLED" )
	end	
end

local function status_OnEnable(self)
	if self.isChainHeal then AOEM.chEnabled= true end
	Init()
	if #statuses==0 then
		if not frame then
			frame = CreateFrame("Frame")
			frame:SetScript("OnEvent", FrameEvents )
		end
		frame:RegisterEvent( Grid2.wowMoP and "GROUP_ROSTER_UPDATE" or "RAID_ROSTER_UPDATE" )
		frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		frame:RegisterEvent("PLAYER_REGEN_DISABLED")
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		AOEM:MapEnable()
		UpdateTimerState()
	end	
	tinsert(statuses, self)
	tsort(statuses, function(a,b) return a.order<b.order end )
	if self.StatusEnabled then self:StatusEnabled() end
end

local function status_OnDisable(self)
	for i=1,#statuses do
	  if statuses[i]==self then tremove(statuses,i)	break end
	end 
	if #statuses==0 and frame then
		frame:UnregisterEvent(Grid2.wowMoP and "GROUP_ROSTER_UPDATE" or "RAID_ROSTER_UPDATE")
		frame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		frame:UnregisterEvent("PLAYER_REGEN_DISABLED" )
		frame:UnregisterEvent("PLAYER_REGEN_ENABLED" )
		AOEM:MapDisable()
		SetTimer(false)
	end	
	if self.StatusDisabled then	self:StatusDisabled() end
	if self.isChainHeal then AOEM.chEnabled= nil end
end

local function status_IsActive(self, unit)
	if self.states[unit] then
		return true
	end
end

local function status_GetIcon(self, unit)
	return self.texture
end

local function status_GetBorder()
	return 1
end

local function status_GetCount(self,unit)
	return bit_band( self.states[unit], 0x00FF)
end

local function status_GetText(self,unit)
	return tostring( bit_band( self.states[unit], 0x00FF) )
end

local function status_GetColor(self, unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

--{{ Statuses Creation

local function Create(baseKey, dbx)
	local setupFunc= AOEM.setupFunc[baseKey]
	if setupFunc then
		local status = Grid2.statusPrototype:new(baseKey)
		status.states    = {}
		status.statesu   = {}
		status.order     = 0
		-- private methods 
		status.GetRoster         = status_GetRoster
		status.GetFilteredRoster = status_GetFilteredRoster
		status.AddUnit           = status_AddUnit
 		status.SwapUnits         = status_SwapUnits
		status.UpdateUnits       = status_UpdateUnits
		status.ClearIndicators   = status_ClearIndicators
		status.GetHighlightMask  = status_GetHighlightMask
		-- public interface methods
		status.OnEnable  = status_OnEnable
		status.OnDisable = status_OnDisable
		status.IsActive  = status_IsActive
		status.GetIcon   = status_GetIcon
		status.GetBorder = status_GetBorder
		status.GetColor  = status_GetColor
		status.GetCount  = status_GetCount
		status.GetText   = status_GetText
		Grid2:RegisterStatus(status, setupFunc(status,dbx) or {"color", "icon", "text"}, baseKey, dbx)
		if status.HighlightField then hlStatuses[baseKey] = status end
		return status
	end	
end

AOEM.setupFunc = {}

AOEM.hlStatuses = hlStatuses
AOEM.statuses   = statuses

--{{ Module methods
function AOEM:OnModuleInitialize()
	for key in next,self.setupFunc do
		Grid2.setupFunc[key] = Create
	end
end

function AOEM:PlayerHasGlyph(id)
	for i=1,9 do
		if id == select(4,GetGlyphSocketInfo(i)) then
			return true
		end
	end
end

function AOEM.SortByDeficit(p1,p2)
	return p1.percent<p2.percent 
end

function AOEM:RefreshUpdateRate()
	if timer then
		SetTimer(false)
		SetTimer(true)
	end
end

function AOEM:RefreshDisplayState()
	if #statuses>0 then
		UpdateTimerState()
	end	
end

--}}