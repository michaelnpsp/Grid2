--[[
--  Grid2InsecureGroupHeader, Grid2InsecureGroupPetHeader, Grid2InsecureGroupCustomHeader
--]]

local versionCli = select(4,GetBuildInfo())
local isClassic = versionCli<30000 -- vanilla or tbc
local dummyFunc = function() end
local select = select
local unpack = unpack
local tonumber = tonumber
local floor = math.floor
local ceil = math.ceil
local min = math.min
local max = math.max
local abs = math.abs
local gsub = gsub
local wipe = wipe
local tsort = table.sort
local tinsert = table.insert
local strsplit = strsplit
local strtrim = strtrim
local strfind = strfind
local UnitExists = UnitExists
local GetFrameHandle = GetFrameHandle
local UnitHasVehicleUI = UnitHasVehicleUI
local RegisterUnitWatch = RegisterUnitWatch
local UnregisterUnitWatch = UnregisterUnitWatch
local UnitWatchRegistered = UnitWatchRegistered
local UnitGroupRolesAssigned = UnitGroupRolesAssigned or dummyFunc
local UNKNOWN = UNKNOWNOBJECT or "Unknown"

-- header common methods
local InjectMixins
do
	local callMethod = function(self, name, ...) self[name](self, ...); end
	function InjectMixins(self, headerType)
		self.headerType   = headerType
		self.isInsecure  = true
		self.CallMethod  = callMethod
		self.GetFrameRef = dummyFunc
	end
end

-- manages and queue the execution of functions out of combat
local RunSecure
do
	local frames = {}
	local frameEvent = CreateFrame("Frame")
	frameEvent:Hide()
	frameEvent:SetScript('OnEvent', function()
		frameEvent:UnregisterEvent('PLAYER_REGEN_ENABLED')
		for frame, func in next,frames do
			if frame:IsVisible() then
				func(frame)
			end
		end
		wipe(frames)
	end )
	function RunSecure(func, self, custom)
		if custom and (self:GetAttribute("startingIndex") or 1)<=0 then return end-- ignore frames precreation trick for custom headers.
		if InCombatLockdown() then
			if not next(frames) then frameEvent:RegisterEvent('PLAYER_REGEN_ENABLED') end
			frames[self] = func
			return
		end
		return true
	end
end

-- fill test units table
local function SetupTestMode(self, units)
	local maxPlayers = self:GetAttribute('testMode')
	if maxPlayers then
		if self.headerType~='custom' then
			local unit = self.headerType~='pet' and 'player' or 'pet'
			for i=#units+1,maxPlayers do
				units[i] = unit
			end
		elseif self:GetAttribute('hideEmptyUnits') then
			for i=1,#units do
				units[i] = 'player'
			end
		end
	end
end

-- misc table functions
local function fillArrayTable(tbl, ...) -- fill indexed table
	for i=1, select("#",...) do
		tbl[i] = strtrim( (select(i,...)) )
	end
end

local function fillHashTable(tbl, ...) -- fill hash table
	for i=1, select("#",...) do
		local key = select(i,...)
		tbl[ tonumber(key) or strtrim(key) ] = i
	end
end

local function fillTable(tbl, ...) -- fill index and hash part
	for i=1, select("#",...) do
		local key = strtrim( (select(i,...)) )
		tbl[i] = key
		tbl[ tonumber(key) or key ] = i
	end
end

-- unit watch register helper
local function SetUnitWatch(frame, enabled)
	if enabled~=UnitWatchRegistered(frame) then
		if enabled then
			RegisterUnitWatch(frame)
		else
			UnregisterUnitWatch(frame)
		end
	end
end

-- returns the opposite point and a direction vector
local getAnchorPoints
do
	local points = {
		LEFT        = { "RIGHT",       1, 0 , 1, 0 },
		RIGHT       = { "LEFT",       -1, 0 , 1, 0 },
		TOP         = { "BOTTOM",      0, -1, 0, 1 },
		BOTTOM      = { "TOP",         0, 1 , 0, 1 },
		TOPLEFT     = { "BOTTOMRIGHT", 1, -1, 1, 1 },
		TOPRIGHT    = { "BOTTOMLEFT", -1, -1, 1, 1 },
		BOTTOMLEFT  = { "TOPRIGHT",    1, 1 , 1, 1 },
		BOTTOMRIGHT = { "TOPLEFT",    -1, 1 , 1, 1 },
		CENTER      = { "CENTER",      0, 0 , 0, 0 },
	}
	function getAnchorPoints(point)
		local p = point and points[point:upper()] or points.CENTER
		return point, p[1], p[2], p[3], p[4], p[5]
	end
end

-- roster information
local function GetGroupType(self)
	if IsInRaid() and self:GetAttribute("showRaid") then
		return true, 1, GetNumGroupMembers()
	elseif IsInGroup() and self:GetAttribute("showParty") then
		return false, self:GetAttribute("showPlayer") and 0 or 1, GetNumSubgroupMembers()
	elseif self:GetAttribute("showSolo") then
		return false, 0, GetNumSubgroupMembers()
	end
end

function GetRaidUnitInfo(index)
	local name, _, subgroup, _, _, class, _, _, _, role, _, arole = GetRaidRosterInfo(index)
	if isClassic then
		role, arole = role or 'NONE', 'UNUSED'
	end
	return "raid"..index, name or UNKNOWN, subgroup, class, role, arole
end

local function GetPartyUnitInfo(index)
	local name, class, role, arole, server, _
	local unit = index>0 and "party"..index or "player"
	if UnitExists(unit) then
		name, server = UnitName(unit)
		if server and server~='' then name = name.."-"..server; end
		_, class = UnitClass(unit)
		arole = isClassic and 'UNUSED' or UnitGroupRolesAssigned(unit)
		role = (GetPartyAssignment("MAINTANK",unit) and "MAINTANK") or (GetPartyAssignment("MAINASSIST",unit) and "MAINASSIST") or (isClassic and 'NONE') or nil
	end
	return unit, name, 1, class, role, arole
end

local function GetRosterInfoFunc(raid)
	return raid and GetRaidUnitInfo or GetPartyUnitInfo
end

local function GetPetUnit(raid, index)
	return (raid and 'raidpet'..index) or (index>0 and 'partypet'..index) or 'pet'
end

-- filter and sort stuff
local srtTable, tokTable, grpTable, tmpTable = {}, {}, {}, {}

local function sortByUnit(a, b)
	return srtTable[a] < srtTable[b]
end

local function sortByNameList(a, b)
	return tokTable[srtTable[a]] < tokTable[srtTable[b]]
end

local function sortByGroupAndUnit(a, b)
	local order1 = tokTable[grpTable[a]]
	local order2 = tokTable[grpTable[b]]
	if order1 == order2 then
		return srtTable[a] < srtTable[b]
	elseif order1 then
		return (not order2) or order1 < order2
	else
		return false
	end
end

local function sortByGroupAndID(a, b)
	local order1 = tokTable[grpTable[a]]
	local order2 = tokTable[grpTable[b]]
	if order1==order2 then
		return tonumber(a:match("%d+") or -1) < tonumber(b:match("%d+") or -1)
	elseif order1 then
		return (not order2) or order1<order2
	else
		return false
	end
end

-- players filter
local function ApplyPlayersFilter(self, raid, start, stop)
	-- fill tokens Table
	local strictFiltering = self:GetAttribute("strictFiltering")
	local groupFilter     = self:GetAttribute("groupFilter")
	local roleFilter      = self:GetAttribute("roleFilter")
	local nameList        = self:GetAttribute('nameList')
	wipe(tokTable)
	if groupFilter and roleFilter then -- by group, class and/or role
		fillHashTable(tokTable, strsplit(",", groupFilter))
		fillHashTable(tokTable, strsplit(",", roleFilter))
	elseif roleFilter then
		fillHashTable(tokTable, strsplit(",", roleFilter))
		if strictFiltering then
			fillHashTable(tokTable,1,2,3,4,5,6,7,8,unpack(CLASS_SORT_ORDER))
		end
	else
		fillHashTable(tokTable, strsplit(',', groupFilter or '1,2,3,4,5,6,7,8') )
		if strictFiltering then
			fillHashTable(tokTable,'MAINTANK','MAINASSIST','TANK','HEALER','DAMAGER','NONE')
		end
	end
	if nameList then
		fillHashTable(tokTable, strsplit(",", nameList))
	end
	-- filter roster units
	local GetRosterInfo = GetRosterInfoFunc(raid)
	local groupBy = self:GetAttribute("groupBy")
	for i = start, stop do
		local unit, name, subgroup, class, role, arole, valid = GetRosterInfo(i)
		if strictFiltering then
			valid = tokTable[subgroup] and tokTable[class] and (tokTable[role] or tokTable[arole]) and (not nameList or tokTable[name])
		else
			valid = tokTable[subgroup] or tokTable[class] or tokTable[role] or tokTable[arole] or tokTable[name]
		end
		if valid then
			tinsert(srtTable, unit)
			srtTable[unit] = name
			grpTable[unit] = (groupBy=="GROUP" and subgroup) or (groupBy=="CLASS" and class) or (groupBy=="ROLE" and role) or (groupBy=="ASSIGNEDROLE" and arole)
		end
	end
	-- sort filtered units
	local sortMethod = self:GetAttribute("sortMethod")
	if groupBy then
		fillTable( wipe(tokTable), strsplit(",", gsub(self:GetAttribute("groupingOrder"),"%s+","")) )
		tsort(srtTable, sortMethod=="NAME" and sortByGroupAndUnit or sortByGroupAndID)
	elseif sortMethod=="NAME" then
		tsort(srtTable, sortByUnit)
	elseif sortMethod=='NAMELIST' then
		tsort(srtTable, sortByNameList)
	end
end

-- pets filter
local function ApplyPetsFilter(self, raid, start,stop)
	-- fill tokens Table
	local useOwnerUnit = self:GetAttribute("useOwnerUnit")
	local filterOnPet = self:GetAttribute("filterOnPet")
	local strictFiltering = self:GetAttribute("strictFiltering")
	local groupFilter = self:GetAttribute("groupFilter")
	local nameList = self:GetAttribute("nameList")
	-- fill tokens table
	wipe(tokTable)
	fillHashTable( tokTable, strsplit(",",groupFilter or "1,2,3,4,5,6,7,8") )
	if nameList then
		fillHashTable( tokTable, strsplit(",",nameList) )
	end
	-- filter pets units
	local GetRosterInfo = GetRosterInfoFunc(raid)
	local groupBy = self:GetAttribute("groupBy")
	for i = start, stop do
		local unit, name, subgroup, class, role, valid = GetRosterInfo(i)
		local petUnit = GetPetUnit(raid, i)
		if UnitExists(petUnit) then
			local unitName = filterOnPet and UnitName(petUnit) or name
			if strictFiltering then
				valid = tokTable[subgroup] and tokTable[class] and (not nameList or tokTable[unitName])
			else
				valid = tokTable[subgroup] or tokTable[class] or tokTable[role] or (nameList and tokTable[unitName])
			end
			if valid then
				if not useOwnerUnit then unit = petUnit	end
				tinsert(srtTable, unit)
				srtTable[unit] = unitName
				grpTable[unit] = (groupBy=="GROUP" and subgroup) or (groupBy=="CLASS" and class) or (groupBy=="ROLE" and role)
			end
		end
	end
	-- sort filtered units
	local sortMethod = self:GetAttribute("sortMethod")
	if groupBy then
		fillTable( wipe(tokTable), strsplit(",", self:GetAttribute("groupingOrder")) )
		tsort(srtTable, sortMethod=='NAME' and sortByGroupAndUnit or sortByGroupAndID)
	elseif sortMethod=='NAME' then
		tsort(srtTable, sortByUnit)
	end
end

-- create an unit frame button
local function CreateButton(self, index)
	-- create and initialize button
	local parentName = self:GetName()
	local button = CreateFrame( self:GetAttribute("templateType") or "Button", parentName.."UnitButton"..index, self, self:GetAttribute("template") )
	button:Hide()
	if not self.initFunc then
		self.initFunc = loadstring('return function(self) '..self:GetAttribute("initialConfigFunction")..' end')()
	end
	self.initFunc(button)
	-- assign attributes without response
	local childName = "child" .. index
	local saved = self:GetAttribute("_ignore")
	self:SetAttribute("_ignore", "attributeChanges")
	self:SetAttribute(childName, button)
	self:SetAttribute("frameref-"..childName, GetFrameHandle(button))
	self:SetAttribute("_ignore", saved)
	-- clique support
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[button] = true
	return button
end

-- display unit frame buttons on screen
local function DisplayButtons(self, unitTable)
	SetupTestMode(self, unitTable)
	local frameSpacing = self:GetAttribute('frameSpacing') or 0
	local unitWatch = not not self:GetAttribute('hideEmptyUnits')
	local startingIndex = self:GetAttribute("startingIndex") or 1
	local maxColumns = self:GetAttribute("maxColumns") or 1
	local unitCount = #unitTable - startingIndex + 1
	local unitsPerColumn = self:GetAttribute("unitsPerColumn") or unitCount
	local numColumns = min( ceil(unitCount/unitsPerColumn), maxColumns )
	local numDisplayed = min( unitCount, numColumns*unitsPerColumn )
	local unitsPerColumn = min( unitsPerColumn, numDisplayed )
	-- create enough buttons
	local numButtons = max(1, numDisplayed)
	for i = #self+1, numButtons do
		self[i] = CreateButton(self, i)
	end
	-- setup the buttons
	local point, relPoint, xOffMult, yOffMult, xMult, yMult = getAnchorPoints(self:GetAttribute("point") or 'TOP')
	local xOffset = self:GetAttribute("xOffset") or 0
	local yOffset = self:GetAttribute("yOffset") or 0
	local colSpacing = self:GetAttribute("columnSpacing") or 0
	local colAnchorPoint, colRelPoint, colxMult, colyMult, colxMultA, colyMultA
	if numColumns>1 then
		colAnchorPoint, colRelPoint, colxMult, colyMult, colxMultA, colyMultA = getAnchorPoints(self:GetAttribute("columnAnchorPoint"))
	end
	local curAnchor, buttonNum, colUnitCount = self, 1, 1
	local start, finish, step
	if self:GetAttribute("sortDir")=='DESC' then
		start  = #unitTable-startingIndex+1
		finish = start-numDisplayed+1
		step   = -1
	else
		start  = startingIndex
		finish = start+numDisplayed-1
		step   = 1
	end
	for i = start, finish, step do
		local unitButton = self[buttonNum]
		unitButton:ClearAllPoints()
		if buttonNum==1 then
			unitButton:SetPoint(point, curAnchor, point, xOffMult*frameSpacing, yOffMult*frameSpacing)
			if colAnchorPoint then unitButton:SetPoint(colAnchorPoint, curAnchor, colAnchorPoint, colxMult*frameSpacing, colyMult*frameSpacing) end
		elseif colUnitCount==1 then
			unitButton:SetPoint(colAnchorPoint, self[buttonNum-unitsPerColumn], colRelPoint, colxMult*colSpacing, colyMult*colSpacing)
		else
			unitButton:SetPoint(point, curAnchor, relPoint, xMult*xOffset, yMult*yOffset)
		end
		local unit = unitTable[i]
		unitButton:SetAttribute("unit", unit)
		SetUnitWatch(unitButton, unitWatch)
		if not unitWatch or UnitExists(unit) then
			unitButton:Show()
		else
			unitButton:Hide()
		end
		colUnitCount = colUnitCount<unitsPerColumn and colUnitCount+1 or 1
		buttonNum = buttonNum + 1
		curAnchor = unitButton
	end
	-- hide unused buttons
	local index = numDisplayed+1
	local unitButton = self[index]
	while unitButton and unitButton:IsVisible() do
		unitButton:Hide()
		unitButton:ClearAllPoints()
		unitButton:SetAttribute("unit", nil)
		index = index + 1; unitButton = self[index]
	end
	-- calculate total header size
	local buttonWidth, buttonHeight = self[1]:GetWidth(), self[1]:GetHeight()
	if numDisplayed>0 then
		local width  = buttonWidth  + (unitsPerColumn-1) * (xMult*buttonWidth  + xOffMult*xOffset)
		local height = buttonHeight + (unitsPerColumn-1) * (yMult*buttonHeight + yOffMult*yOffset)
		self:SetWidth ( width  + (numColumns-1) * (colxMultA or 0) * (width +colSpacing) + frameSpacing*2 )
		self:SetHeight( height + (numColumns-1) * (colyMultA or 0) * (height+colSpacing) + frameSpacing*2 )
	else
		self:SetWidth ( max(self:GetAttribute("minWidth")  or yMult*buttonWidth, 0.1) )
		self:SetHeight( max(self:GetAttribute("minHeight") or xMult*buttonHeight,0.1) )
	end
end

--[[ Grid2InsecureGroupHeader & Grid2InsecureGroupPetHeader
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
roleFilter = [STRING] -- a comma seperated list of MT/MA/Tank/Healer/DPS role strings
strictFiltering = [BOOLEAN]
-- if true, then
---- if only groupFilter is specified then characters must match both a group and a class from the groupFilter list
---- if only roleFilter is specified then characters must match at least one of the specified roles
---- if both groupFilter and roleFilters are specified then characters must match a group and a class from the groupFilter list and a role from the roleFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME", "NAMELIST"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE", "ASSIGNEDROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinite (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the amount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
Additional properties for pet headers:
useOwnerUnit = [BOOLEAN] - if true, then the owner's unit string is set on managed frames "unit" attribute (instead of pet's)
filterOnPet = [BOOLEAN] - if true, then pet names are used when sorting/filtering the list
--]]
do
	local function Update(self)
		if RunSecure(Update, self) then
			wipe(srtTable)
			local raid, start, stop = GetGroupType(self)
			if raid~=nil then
				if self.headerType == 'pet' then
					ApplyPetsFilter(self, raid, start, stop)
				else
					ApplyPlayersFilter(self, raid, start, stop)
				end
			end
			DisplayButtons(self, srtTable)
		end
	end

	local function AttributeChanged(self, name, value)
		if name ~= "_ignore" and not self:GetAttribute("_ignore") and self:IsVisible() then
			Update(self)
		end
	end

	local function Show(self)
		self:RegisterEvent("GROUP_ROSTER_UPDATE")
		self:RegisterEvent("UNIT_NAME_UPDATE")
		if self.headerType == 'pet' then
			self:RegisterEvent("UNIT_PET")
		end
		Update(self)
	end

	local function Hide(self)
		self:UnregisterEvent("GROUP_ROSTER_UPDATE")
		self:UnregisterEvent("UNIT_NAME_UPDATE")
		if self.headerType == 'pet' then
			self:UnregisterEvent("UNIT_PET")
		end
	end

	function Grid2InsecureGroupHeader_OnLoad(self, isPet)
		InjectMixins(self, isPet and 'pet' or 'player')
		self:SetScript('OnAttributeChanged', AttributeChanged)
		self:SetScript('OnShow', Show)
		self:SetScript('OnHide', Hide)
		self:SetScript('OnEvent', Update)
	end
end

--[[ Grid2InsecureGroupCustomHeader
unitsFilter = "target, focus, player, party1, boss1, boss2, boss3, arena1, arena2, arena3, .."
hideEmptyUnits = true|nil
--]]
do
	--Forze size changed event to refresh decoration visibility
	local function TriggerSizeChangedEvent(self)
		if self:GetAttribute('hideEmptyUnits') then
			local func = self:GetScript("OnSizeChanged")
			if func then
				C_Timer.After(0, function()	func(self) end)	end
		end
	end

	-- notify grid2 roster for unit changes, OnUnitStateChanged() defined in Grid2Frame.lua
	local function RefreshButtons(self, pattern)
		local index, unitButton = 1, self[1]
		while unitButton and unitButton.unit do
			if pattern==nil or strfind(unitButton.unit,pattern) then
				unitButton:OnUnitStateChanged()
			end
			index = index + 1; unitButton = self[index]
		end
		TriggerSizeChangedEvent(self)
	end

	-- event register management
	local function SetRegisterEvent(self, enabled, event)
		if not enabled ~= not self:IsEventRegistered(event) then
			if enabled then
				self:RegisterEvent(event)
			else
				self:UnregisterEvent(event)
			end
		end
	end

	local function RegisterEvents(self, unitTable)
		local bossUnits, arenaUnits, normalUnits
		self.buttonTarget, self.buttonFocus = nil, nil
		for i, unit in ipairs(unitTable) do
			if unit=='target' then
				self.buttonTarget = self[i]
			elseif unit=='focus' then
				self.buttonFocus = self[i]
			elseif strfind(unit,"^boss") then
				bossUnits = true
			elseif strfind(unit,"^arena") then
				arenaUnits = true
			else
				normalUnits = true
			end
		end
		SetRegisterEvent( self, self.buttonTarget, 'PLAYER_TARGET_CHANGED' )
		SetRegisterEvent( self, self.buttonFocus, 'PLAYER_FOCUS_CHANGED' )
		SetRegisterEvent( self, self.buttonTarget or self.buttonFocus, 'PLAYER_ENTERING_WORLD' )
		SetRegisterEvent( self, bossUnits, 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' )
		SetRegisterEvent( self, arenaUnits, 'ARENA_OPPONENT_UPDATE' )
		SetRegisterEvent( self, normalUnits, 'GROUP_ROSTER_UPDATE' )
	end

	local function ApplySpecialFilter(self)
		wipe(srtTable)
		local unitsFilter = self:GetAttribute('unitsFilter')
		if unitsFilter then
			fillArrayTable( srtTable, strsplit(",",unitsFilter) )
		end
	end

	-- update header
	local function Update(self)
		if RunSecure(Update, self, true) then
			ApplySpecialFilter( self )
			DisplayButtons( self, srtTable )
			RegisterEvents( self, srtTable )
			RefreshButtons( self )
		end
	end

	-- event callbacks
	local function OnHide(self)
		SetRegisterEvent( self, false, 'GROUP_ROSTER_UPDATE' )
		SetRegisterEvent( self, false, 'PLAYER_TARGET_CHANGED' )
		SetRegisterEvent( self, false, 'PLAYER_FOCUS_CHANGED' )
		SetRegisterEvent( self, false, 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' )
		SetRegisterEvent( self, false, 'PLAYER_REGEN_ENABLED' )
		SetRegisterEvent( self, false, 'PLAYER_ENTERING_WORLD' )
		SetRegisterEvent( self, false, 'ARENA_OPPONENT_UPDATE' )
	end

	local function OnAttributeChanged(self, name, value)
		if name ~= "_ignore" and not self:GetAttribute("_ignore") and self:IsVisible() then
			Update(self)
		end
	end

	local function OnEvent(self, event)
		if event=='PLAYER_TARGET_CHANGED' then
			self.buttonTarget:OnUnitStateChanged()
			TriggerSizeChangedEvent(self)
		elseif event=='PLAYER_FOCUS_CHANGED' then
			self.buttonFocus:OnUnitStateChanged()
			TriggerSizeChangedEvent(self)
		elseif event=='INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
			RefreshButtons(self, "^boss")
		elseif event=='PLAYER_REGEN_ENABLED' then
			RefreshButtons(self, "^boss")
		elseif event=='ARENA_OPPONENT_UPDATE' then
			RefreshButtons(self, "^arena")
		elseif event=='PLAYER_ENTERING_WORLD' then
			if self.buttonTarget then self.buttonTarget:OnUnitStateChanged() end
			if self.buttonFocus  then self.buttonFocus:OnUnitStateChanged() end
		else -- GROUP_ROSTER_UPDATE
			RefreshButtons(self)
		end
	end

	-- header load
	function Grid2InsecureGroupCustomHeader_OnLoad(self)
		InjectMixins(self, 'custom')
		self:SetScript('OnAttributeChanged', OnAttributeChanged)
		self:SetScript('OnShow', Update)
		self:SetScript('OnHide', OnHide)
		self:SetScript('OnEvent', OnEvent)
	end
end
