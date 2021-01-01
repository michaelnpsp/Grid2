--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2Layout = Grid2:NewModule("Grid2Layout")

local Grid2 = Grid2
local pairs, ipairs, next, strmatch, strsplit = pairs, ipairs, next, strmatch, strsplit

--{{{ Frame config function for secure headers
local function GridHeader_InitialConfigFunction(self, name)
	Grid2Frame:RegisterFrame(_G[name])
end
--}}}

--{{{ Class for group headers

local NUM_HEADERS = 0
local FRAMES_TEMPLATE = "SecureUnitButtonTemplate"                        .. (BackdropTemplateMixin and ",BackdropTemplate" or "")
local FRAMEC_TEMPLATE = "ClickCastUnitTemplate,SecureUnitButtonTemplate"  .. (BackdropTemplateMixin and ",BackdropTemplate" or "")
local SECURE_INIT_TMP =  [[
	self:SetAttribute("*type1", "target")
	self:SetAttribute("*type2", "togglemenu")
	self:SetAttribute("useparent-toggleForVehicle", true)
	self:SetAttribute("useparent-allowVehicleTarget", true)
	self:SetAttribute("useparent-unitsuffix", true)
	local header = self:GetParent()
	local clickcast = header:GetFrameRef("clickcast_header")
	if clickcast then
		clickcast:SetAttribute("clickcast_button", self)
		clickcast:RunAttribute("clickcast_register")
	end
	header:CallMethod("initialConfigFunction", self:GetName())
]]
local SECURE_INIT = SECURE_INIT_TMP

local GridLayoutHeaderClass = {
	prototype = {},
	new = function (self, template)
		NUM_HEADERS = NUM_HEADERS + 1
		local frame = CreateFrame("Frame", "Grid2LayoutHeader"..NUM_HEADERS, Grid2Layout.frame, template )
		for name, func in pairs(self.prototype) do
			frame[name] = func
		end
		if ClickCastHeader and not self.isInsecure then
			frame:SetAttribute("template", FRAMEC_TEMPLATE)
			SecureHandler_OnLoad(frame)
			frame:SetFrameRef("clickcast_header", Clique.header)
		else
			frame:SetAttribute("template", FRAMES_TEMPLATE)
		end
		frame.initialConfigFunction = GridHeader_InitialConfigFunction
		frame:SetAttribute("initialConfigFunction", SECURE_INIT)
		frame:Reset()
		frame:SetOrientation()
		return frame
	end,
	template = function(self, header, insecure)
		if header.type=='special' then
			return 'Grid2InsecureGroupSpecialHeaderTemplate'
		elseif insecure or (header.nameList and (header.roleFilter or header.groupFilter)) then
			return header.type=='pet' and 'Grid2InsecureGroupPetHeaderTemplate' or 'Grid2InsecureGroupHeaderTemplate'
		else
			return header.type=='pet' and 'SecureGroupPetHeaderTemplate' or 'SecureGroupHeaderTemplate'
		end
	end,
}

-- "hideEmptyUnits"&"unitsFilter" are extra attributes used only by Grid2 Special Group Header
local HeaderAttributes = {
	"nameList", "groupFilter", "roleFilter", "strictFiltering",
	"sortDir", "groupBy", "groupingOrder", "maxColumns", "unitsPerColumn",
	"startingIndex", "columnSpacing", "columnAnchorPoint",
	"useOwnerUnit", "filterOnPet", "unitsuffix", "sortMethod",
	"toggleForVehicle", "showSolo", "showPlayer", "showParty", "showRaid",
	"hideEmptyUnits", "unitsFilter"
}

function GridLayoutHeaderClass.prototype:Reset()
	-- Hide the header before initializing attributes to avoid a lot of unnecesary SecureGroupHeader_Update() calls
	self:Hide()
	-- SecureGroupFrames code does not correctly resets all the buttons, we need to do it manually because
	-- Grid2Frame relies on :OnAttributeChanged() event to add/delete units in roster and unit_frames tables.
	for _,uframe in ipairs(self) do
		if uframe.unit==nil then break end
		uframe:SetAttribute("unit", nil)
	end
	-- Initialize attributes
	self.tokenNames, self.tokenFilter = nil, nil
	local defaults = Grid2Layout.customDefaults
	for _, attr in ipairs(HeaderAttributes) do
		self:SetAttribute(attr, defaults[attr] or nil  )
	end
end

local anchorPoints = {
	[false] = { TOPLEFT = "TOP" , TOPRIGHT= "TOP"  , BOTTOMLEFT = "BOTTOM", BOTTOMRIGHT = "BOTTOM" },
	[true]  = { TOPLEFT = "LEFT", TOPRIGHT= "RIGHT", BOTTOMLEFT = "LEFT"  , BOTTOMRIGHT = "RIGHT"  },
	TOP = -1, BOTTOM = 1, LEFT = 1, RIGHT = -1,
}

-- nil or false for vertical
function GridLayoutHeaderClass.prototype:SetOrientation(horizontal)
	if not self.initialConfigFunction then return end
	local settings  = Grid2Layout.db.profile
	local vertical  = not horizontal
	local point     = anchorPoints[not vertical][settings.groupAnchor]
	local direction = anchorPoints[point]
	local xOffset   = horizontal and settings.Padding*direction or 0
	local yOffset   = vertical   and settings.Padding*direction or 0
	self:SetAttribute( "xOffset", xOffset )
	self:SetAttribute( "yOffset", yOffset )
	self:ClearChildPoints()
	self:SetAttribute( "point", point )
end

-- Force a header Update, frame units and header size are updated
function GridLayoutHeaderClass.prototype:Update()
	if self:IsVisible() then
		self:Hide()
		self:Show()
	end
end

-- MSaint fix see: https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/unit-frames/grid-grid2/222108-grid-compact-party-raid-unit-frames?page=11#c219
-- Must be called just before assigning the attributes: "point", "columnAnchorPoint" or "unitsPerColumn". But for optimization purposes we are calling the funcion only before
-- assigning "point" attribute inside SetOrientation() method, because this is the last attribute assigned when a layout is loaded.
-- Be carefull when changing the order in which these attributes are assigned in future changes.
function GridLayoutHeaderClass.prototype:ClearChildPoints()
	local count, uframe = 1, self:GetAttribute("child1")
	while uframe do
		uframe:ClearAllPoints()
		count = count + 1
		uframe = self:GetAttribute("child" .. count)
	end
end

--{{{ Grid2Layout

-- AceDB defaults
Grid2Layout.defaultDB = {
	profile = {
		--theme options ( active theme options in: self.db.profile, first theme options in: self.dba.profile, extra themes in: self.dba.profile.extraThemes[] )
		layouts = { solo = "By Group", party = "By Group", arena = "By Group", raid  = "By Group" },
		FrameDisplay = "Always",
		horizontal = true,
		clamp = true,
		FrameLock = false,
		Padding = 0,
		Spacing = 10,
		ScaleSize = 1,
		BorderTexture = "Blizzard Tooltip",
		BackgroundTexture = "Blizzard ChatFrame Background",
		BorderR = .5,
		BorderG = .5,
		BorderB = .5,
		BorderA = 1,
		BackgroundR = .1,
		BackgroundG = .1,
		BackgroundB = .1,
		BackgroundA = .65,
		anchor = "TOPLEFT",
		groupAnchor = "TOPLEFT",
		PosX = 500,
		PosY = -200,
		-- profile options shared by all themes, but stored on default/first theme
		minimapIcon = { hide = false },
	},
	global = {
		customLayouts  = {},
		customDefaults = { toggleForVehicle = true, showSolo = true, showPlayer = true, showParty = true, showRaid = true },
	},
}

Grid2Layout.groupFilters =  {
	{ groupFilter = "1" }, { groupFilter = "2" }, { groupFilter = "3" }, {	groupFilter = "4" },
	{ groupFilter = "5" }, { groupFilter = "6" }, {	groupFilter = "7" }, {	groupFilter = "8" },
}

Grid2Layout.groupsFilters = { "1", "1,2", "1,2,3", "1,2,3,4", "1,2,3,4,5", "1,2,3,4,5,6", "1,2,3,4,5,6,7", "1,2,3,4,5,6,7,8" }

Grid2Layout.relativePoints = {
	[false] = { TOPLEFT = "BOTTOMLEFT", TOPRIGHT = "BOTTOMRIGHT", BOTTOMLEFT = "TOPLEFT",     BOTTOMRIGHT = "TOPRIGHT"   },
	[true]  = { TOPLEFT = "TOPRIGHT",   TOPRIGHT = "TOPLEFT",     BOTTOMLEFT = "BOTTOMRIGHT", BOTTOMRIGHT = "BOTTOMLEFT" },
	xMult   = { TOPLEFT =  1, TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT = -1 },
	yMult   = { TOPLEFT = -1, TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT =  1 },
}

Grid2Layout.layoutSettings = {}

Grid2Layout.layoutHeaderClass = GridLayoutHeaderClass

function Grid2Layout:OnModuleInitialize()
	-- useful variables
	self.dba = self.db
	self.db = { global = self.dba.global, profile = self.dba.profile, shared = self.dba.profile }
	self.groups  = setmetatable( {}, { __index = function(t,k) t[k]= {}; return t[k]; end } )
	self.indexes = setmetatable( {}, { __index = function(t,k) return 0;  end } )
	self.groupsUsed = {}
	-- create main frame
	self.frame = CreateFrame("Frame", "Grid2LayoutFrame", UIParent)
	self.frame:SetMovable(true)
	self.frame:SetPoint("CENTER", UIParent, "CENTER")
	self.frame:SetScript("OnMouseUp", function () self:StopMoveFrame() end)
	self.frame:SetScript("OnHide", function () self:StopMoveFrame() end)
	self.frame:SetScript("OnMouseDown", function (_, button) self:StartMoveFrame(button) end)
	-- extra frame for background and border textures, to be able to resize in combat
	self.frameBack = CreateFrame("Frame", "Grid2LayoutFrameBack", self.frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
	-- custom defaults
	self.customDefaults = self.db.global.customDefaults
	-- add custom layouts
	self:AddCustomLayouts()
end

function Grid2Layout:OnModuleEnable()
	self:UpdateMenu()
	self:FixLayouts()
	self:UpdateFrame()
	self:UpdateTextures()
	self:RegisterMessage("Grid_RosterUpdate")
	self:RegisterMessage("Grid_GroupTypeChanged")
	self:RegisterMessage("Grid_UpdateLayoutSize")
	self:RegisterEvent("UI_SCALE_CHANGED")
	if not Grid2.isClassic then
		self:RegisterEvent("PET_BATTLE_OPENING_START", "PetBattleTransition")
		self:RegisterEvent("PET_BATTLE_CLOSE", "PetBattleTransition")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
	end
end

function Grid2Layout:OnModuleDisable()
	self:UnregisterMessage("Grid_RosterUpdate")
	self:UnregisterMessage("Grid_GroupTypeChanged")
	self:UnregisterMessage("Grid_UpdateLayoutSize")
	if not Grid2.isClassic then
		self:UnregisterEvent("PET_BATTLE_OPENING_START")
		self:UnregisterEvent("PET_BATTLE_CLOSE")
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
	end
	self.frame:Hide()
end

function Grid2Layout:OnModuleUpdate()
	self:UpdateMenu()
	self:FixLayouts()
	self:RefreshTheme()
end

function Grid2Layout:UpdateTheme()
	local themes = self.dba.profile.extraThemes
	self.db.profile = themes and themes[Grid2.currentTheme] or self.dba.profile
	self.db.shared = self.dba.profile
	self.frameWidth, self.frameHeight = nil, nil
end

function Grid2Layout:RefreshTheme()
	self:UpdateFrame()
	self:ReloadLayout(true)
end

--{{{ Event handlers
function Grid2Layout:Grid_GroupTypeChanged(_, groupType, instType, maxPlayers)
	self:Debug("GroupTypeChanged", groupType, instType, maxPlayers)
	if not Grid2:ReloadTheme() then
		if not self:ReloadLayout() then
			self:UpdateVisibility()
		end
	end
end

function Grid2Layout:Grid_RosterUpdate(_, unknowns)
	if unknowns and not self.db.global.useInsecureHeaders then
		Grid2:RunThrottled(self, "FixRoster", .25)
	end
end

-- Fixing Shadowlands bug when entering Maw Zone, see ticket #901.
function Grid2Layout:ZONE_CHANGED_NEW_AREA()
	if C_Map.GetBestMapForUnit("player")==1543 then
		self.flagEnteringMaw = true
	end
end

function Grid2Layout:UNIT_TARGETABLE_CHANGED(_,unit)
	if unit=="player" and self.flagEnteringMaw then
		self.flagEnteringMaw = nil
		if not Grid2:RunSecure(10, self, "UpdateHeaders") then
			self:UpdateHeaders()
		end
	end
end

-- Maintain Grid2 window on the same position if the screen scale is changed.
function Grid2Layout:UI_SCALE_CHANGED()
	self:RestorePosition()
	self:Debug("UI Scale Change detected: main frame position restored:", GetCVar("uiScale") )
end

-- We delay UpdateSize() call to avoid calculating the wrong window size, because when "Grid_UpdateLayoutSize"
-- message is triggered the blizzard code has not yet updated the size of the secure group headers.
function Grid2Layout:Grid_UpdateLayoutSize()
	Grid2:RunThrottled(self, "UpdateSize", 0.01)
end

function Grid2Layout:PetBattleTransition(event)
	if self.db.profile.HideInPetBattle then
		local inBattle = (event == "PET_BATTLE_OPENING_START") or nil
		if inBattle or self.inBattlePet then -- PET_BATTLE_CLOSE event fires twice so we check "inBattlePet" variable to ignore the second event
			self.inBattlePet = inBattle
			self:UpdateVisibility()
		end
	end
end
--}}}

-- PopupMenu
function Grid2Layout:UpdateMenu()
	local v = Grid2Frame.db.profile.menuDisabled
	if v ~= self.RightClickMenuDisabled then
		self.RightClickMenuDisabled = v
		SECURE_INIT = v and gsub( SECURE_INIT_TMP, '"togglemenu"', 'nil' ) or SECURE_INIT_TMP
		Grid2Frame:WithAllFrames( function(f) f:SetAttribute("*type2",(not v) and "togglemenu" or nil); end )
	end
end

-- Workaround to a blizzard bug in SecureGroupHeaders.lua (see: https://www.wowace.com/projects/grid2/issues/628 )
-- In patch 8.1 SecureTemplates code does not display "unknown entities" because GetRaidRosterInfo() returns nil for these units:
-- If unknown entities are detected in roster, we update the headers every 1/4 seconds until all unknown entities are gone.
function Grid2Layout:FixRoster()
	print("FixRosterEntering...")
	if Grid2:RosterHasUnknowns() then
		if not Grid2:RunSecure(5, self, "FixRoster") then
			print("Updating Headers........")
			self:UpdateHeaders()
			Grid2:UpdateRoster()
		end
	end
end

function Grid2Layout:StartMoveFrame(button)
	if not self.db.profile.FrameLock and button == "LeftButton" then
		self.frame:StartMoving()
		self.frame.isMoving = true
	end
end

function Grid2Layout:StopMoveFrame()
	if self.frame.isMoving then
		self.frame:StopMovingOrSizing()
		self:SavePosition()
		self.frame.isMoving = false
		 if not InCombatLockdown() then	self:RestorePosition() end
	end
end

-- nil:toggle, false:disable movement, true:enable movement
function Grid2Layout:FrameLock(locked)
	local p = self.db.profile
	if locked == nil then
		p.FrameLock = not p.FrameLock
	else
		p.FrameLock = locked
	end
	self.frame:EnableMouse(not p.FrameLock)
end

-- display: Never, Always, Grouped, Raid, false|nil = toggle Never/Always
function Grid2Layout:FrameVisibility(display)
	local p = self.db.profile
	p.FrameDisplay = display or (p.FrameDisplay=='Never' and 'Always' or 'Never')
	self:UpdateVisibility()
end

--{{{ ConfigMode support
CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}
CONFIGMODE_CALLBACKS["Grid2"] = function(action)
	if action == "ON" then
		Grid2Layout:FrameLock(false)
	elseif action == "OFF" then
		Grid2Layout:FrameLock(true)
	end
end
--}}}

function Grid2Layout:UpdateFrame()
	local p = self.db.profile
	local f = self.frame
	f:SetClampedToScreen(p.clamp)
	f:SetFrameStrata( p.FrameStrata or "MEDIUM")
	f:SetFrameLevel(1)
	f:EnableMouse(not p.FrameLock)
	local f = self.frameBack
	f:SetFrameStrata( p.FrameStrata or "MEDIUM")
	f:SetFrameLevel(0)
end

function Grid2Layout:SetClamp()
	self.frame:SetClampedToScreen(self.db.profile.clamp)
end

function Grid2Layout:ResetHeaders()
	self.layoutHasSpecial = nil
	self.layoutHasFilter  = nil
	self.layoutHasAuto    = nil
	for type, headers in pairs(self.groups) do
		for i=self.indexes[type],1,-1 do
			headers[i]:Reset()
		end
		self.indexes[type] = 0
	end
	wipe(self.groupsUsed)
end

function Grid2Layout:PlaceHeaders()
	local settings   = self.db.profile
	local horizontal = settings.horizontal
	local vertical   = not horizontal
	local padding    = settings.Padding
	local spacing    = settings.Spacing
	local anchor     = settings.groupAnchor
	local relPoint   = self.relativePoints[vertical][anchor]
	local xMult1     = self.relativePoints.xMult[anchor]
	local yMult1     = self.relativePoints.yMult[anchor]
	local xMult2 	 = vertical   and xMult1*padding or 0
	local yMult2 	 = horizontal and yMult1*padding or 0
	local prevFrame
	for i, frame in ipairs(self.groupsUsed) do
		frame:SetOrientation(horizontal)
		frame:ClearAllPoints()
		frame:SetParent(self.frame)
		if i == 1 then
			frame:SetPoint(anchor, self.frame, anchor, spacing * xMult1, spacing * yMult1)
		else
			frame:SetPoint(anchor, prevFrame, relPoint, xMult2, yMult2 )
		end
		frame:Show()
		self:Debug("Placing group", groupNumber, frame:GetName(), anchor, prevFrame and prevFrame:GetName(), relPoint)
		prevFrame = frame
	end
end

function Grid2Layout:UpdateHeaders()
	for _, header in ipairs(self.groupsUsed) do
		header:Update()
	end
end

function Grid2Layout:RefreshLayout()
	self:ReloadLayout(true)
end

-- If player does not exist (this can happen just before a load screen when changing instances if layout load is delayed by RunSecure()
-- due to combat restrictions) we cannot setup SecureGroupHeaders so we ignore the layout change, anyway the layour will be reloaded
-- on PLAYER_ENTERING_WORLD event when the load screen finish. See Ticket #923.
function Grid2Layout:ReloadLayout(force)
	if not UnitExists('player') then self:Debug("ReloadLayout Ignored because player unit does not exist"); return end
	local p = self.db.profile
	local partyType, instType, maxPlayers = Grid2:GetGroupType()
	local layoutName = p.layouts[maxPlayers] or p.layouts[partyType.."@"..instType] or p.layouts[partyType]
	if layoutName ~= self.layoutName or (self.layoutHasAuto and maxPlayers ~= self.instMaxPlayers) or force or self.forceReload then
		self.forceReload = force
		if not Grid2:RunSecure(3, self, "ReloadLayout") then
			self.forceReload    = nil
			self.partyType      = partyType
			self.instType       = instType
			self.instMaxPlayers = maxPlayers
			self.instMaxGroups  = math.ceil( maxPlayers/5 )
			self:LoadLayout( layoutName )
		end
		return true
	end
end

function Grid2Layout:LoadLayout(layoutName)
	local layout = self.layoutSettings[layoutName]
	if layout then
		self:Debug("LoadLayout", layoutName)
		self.layoutName = layoutName
		self:RestorePosition()
		self:ResetHeaders()
		if layout[1] then
			for _, layoutHeader in ipairs(layout) do
				if layoutHeader=="auto" then
					self:GenerateHeaders(layout.defaults)
				else
					self:AddHeader(layoutHeader, layout.defaults)
				end
			end
		elseif not layout.empty then
			self:GenerateHeaders(layout.defaults)
		end
		self:PlaceHeaders()
		self:UpdateDisplay()
	end
end

--{{ Header management
function Grid2Layout:AddHeader(layoutHeader, defaults)
	local template = self.layoutHeaderClass:template(layoutHeader, self.db.global.useInsecureHeaders)
	local index    = self.indexes[template] + 1
	local headers  = self.groups[template]
	local header   = headers[index]
	if not header then
		header = self.layoutHeaderClass:new(template)
		headers[index] = header
	end
	if layoutHeader.type=='special' then
		self.layoutHasSpecial = true
	end
	header.headerType = layoutHeader.type
	self.indexes[template] = index
	self.groupsUsed[#self.groupsUsed+1] = header
	self:SetHeaderAttributes(header, defaults)
	self:SetHeaderAttributes(header, layoutHeader)
	self:FixHeaderAttributes(header)
end

function Grid2Layout:GenerateHeaders(defaults)
	self.layoutHasAuto = not self.db.global.displayAllGroups or nil
	local m = self.layoutHasAuto and self.instMaxGroups or 8
	for i=1,m do
		self:AddHeader(self.groupFilters[i], defaults)
	end
end

function Grid2Layout:SetHeaderAttributes(header, layoutHeader)
	if layoutHeader then
		for attr, value in next, layoutHeader do
			if attr ~= 'type' then
				header:SetAttribute(attr, value)
			end
		end
	end
end

-- Apply defaults and some special cases for each header and apply workarounds to some blizzard bugs
function Grid2Layout:FixHeaderAttributes(header)
	local p = self.db.profile
	-- fix unitsPerColumn
	local unitsPerColumn = header:GetAttribute("unitsPerColumn")
	if not unitsPerColumn then
		header:SetAttribute("unitsPerColumn", 5)
		unitsPerColumn = 5
	end
	header:SetAttribute("columnSpacing", p.Padding)
	header:SetAttribute("columnAnchorPoint", anchorPoints[not p.horizontal][p.groupAnchor] or p.groupAnchor )
	-- fix maxColumns
	local autoEnabled = not self.db.global.displayAllGroups or nil
	if header:GetAttribute("maxColumns") == "auto" then
		self.layoutHasAuto = autoEnabled
		header:SetAttribute( "maxColumns", math.ceil((autoEnabled and self.instMaxPlayers or 40)/unitsPerColumn) )
	end
	-- fix groupFilter
	local groupFilter = header:GetAttribute("groupFilter")
	if groupFilter then
		if groupFilter == "auto" then
			self.layoutHasAuto = autoEnabled
			groupFilter = self.groupsFilters[autoEnabled and self.instMaxGroups or 8] or "1"
			header:SetAttribute("groupFilter", groupFilter)
		end
		if header:GetAttribute("strictFiltering") then
			groupFilter = groupFilter .. ",DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR"
			header:SetAttribute("groupFilter", groupFilter)
		end
	end
	-- workaround to blizzard pet bug
	if header.headerType == 'pet' then -- force these so that the bug in SecureGroupPetHeader_Update doesn't trigger
		header:SetAttribute("filterOnPet", true)
		header:SetAttribute("useOwnerUnit", false)
		header:SetAttribute("unitsuffix", nil)
	end
	-- workaround to blizzard bug
	self:ForceFramesCreation(header)
end
--}}

-- Precreate frames to avoid a blizzard bug that prevents initializing unit frames in combat
-- https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/unit-frames/grid-grid2/222076-grid?page=159#c3169
function Grid2Layout:ForceFramesCreation(header)
	local startingIndex = header:GetAttribute("startingIndex")
	local maxColumns = header:GetAttribute("maxColumns") or 1
	local unitsPerColumn = header:GetAttribute("unitsPerColumn") or 5
	local maxFrames = maxColumns * unitsPerColumn
	local count= header.FrameCount
	if not count or count<maxFrames then
		header:Show()
		header:SetAttribute("startingIndex", 1-maxFrames )
		header:SetAttribute("startingIndex", startingIndex)
		header.FrameCount= maxFrames
		header:Hide()
	end
end

function Grid2Layout:UpdateDisplay()
	self:UpdateTextures()
	self:UpdateColor()
	self:UpdateVisibility()
	self:UpdateFramesSize()
end

function Grid2Layout:UpdateFramesSize()
	local nw,nh = Grid2Frame:GetFrameSize()
	local ow,oh = self.frameWidth or nw, self.frameHeight or nh
	self.frameWidth, self.frameHeight = nw, nh
	if nw~=ow or nh~=oh then
		Grid2Frame:LayoutFrames()
		Grid2Frame:UpdateIndicators()
		self:UpdateHeaders() -- Force headers size update because this triggers a "Grid_UpdateLayoutSize" message.
	end
	if self.frame:GetWidth()==0 then
		self.frame:SetSize(1,1) -- assign a default size, to make frame visible if we are in combat after a UI reload
	end
end

function Grid2Layout:UpdateSize()
	local p = self.db.profile
	local mcol,mrow,curCol,maxRow,remSize = "GetWidth","GetHeight",0,0,0
	if p.horizontal then mcol,mrow = mrow,mcol end
	for _,g in ipairs(self.groupsUsed) do
		local row = g[mrow](g)
		if maxRow<row then maxRow = row end
		local col = g[mcol](g) + p.Padding
		curCol = curCol + col
		remSize = (g.headerType=='special' or (g[1] and g[1]:IsVisible())) and 0 or remSize + col
	end
	local col = math.max( curCol - remSize + p.Spacing*2 - p.Padding, 1 )
	local row = math.max( maxRow + p.Spacing*2, 1 )
	if p.horizontal then col,row = row,col end
	self.frameBack:SetSize(col,row)
	if not Grid2:RunSecure(6, self, "UpdateSize") then
		self.frame:SetSize(col,row)
	end
end

function Grid2Layout:UpdateTextures()
	local p = self.db.profile
	Grid2:SetFrameBackdrop(	self.frameBack, Grid2:GetBackdropTable( Grid2:MediaFetch("border", p.BorderTexture), 16, Grid2:MediaFetch("background", p.BackgroundTexture), false, nil, 4  ) )
end

function Grid2Layout:UpdateColor()
	local settings = self.db.profile
	local frame    = self.frameBack
	frame:SetBackdropBorderColor(settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA)
	frame:SetBackdropColor(settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA)
	frame:SetShown( settings.BorderA~=0 or settings.BackgroundA~=0 )
end

function Grid2Layout:UpdateVisibility()
	if not Grid2:RunSecure(7, self, "UpdateVisibility") then
		local fd, pt = self.db.profile.FrameDisplay, Grid2:GetGroupType()
		self.frame:SetShown(
			fd~='Never' and
			( (fd == "Always") or (fd == "Grouped" and pt ~= "solo") or (fd == "Raid" and pt == "raid" ) ) and
			not (self.db.profile.HideInPetBattle and self.inBattlePet)
		)
	end
end

-- Grid2 uses UI Root coordinates to store the window position (always 768 pixels height) so these coordinates are
-- independent of the UI Frame Scale Coordinates and monitor physical resolution (assuming the same aspect ratio).
function Grid2Layout:SavePosition()
	local f = self.frame
	if f:GetLeft() and f:GetWidth() then
		local a = self.db.profile.anchor
		local s = f:GetEffectiveScale()
		local t = UIParent:GetEffectiveScale()
		local x = (a:find("LEFT")  and f:GetLeft()*s) or
				  (a:find("RIGHT") and f:GetRight()*s-UIParent:GetWidth()*t) or
				  (f:GetLeft()+f:GetWidth()/2)*s-UIParent:GetWidth()/2*t
		local y = (a:find("BOTTOM") and f:GetBottom()*s) or
				  (a:find("TOP")    and f:GetTop()*s-UIParent:GetHeight()*t) or
				  (f:GetTop()-f:GetHeight()/2)*s-UIParent:GetHeight()/2*t
		self.db.profile.PosX = x
		self.db.profile.PosY = y
		self:Debug("Saved Position", a, x, y)
	end
end

-- Restores the Grid2 window position, the window is always placed in the same exact absolute screen position
-- even if the WoW UI Scale or Grid2 window Scale was changed (assuming the screen aspect ratio has not changed).
function Grid2Layout:RestorePosition()
	local f = self.frame
	local b = self.frameBack
	local p = self.db.profile
	f:SetScale(p.ScaleSize)
	local s = f:GetEffectiveScale()
	local x = p.PosX / s
	local y = p.PosY / s
	local a = p.anchor
	f:ClearAllPoints()
	f:SetPoint(a, x, y)
	b:ClearAllPoints()
	b:SetPoint(p.groupAnchor) -- Using groupAnchor instead of anchor, see ticket #442.
	self:Debug("Restored Position", a, p.ScaleSize, x, y)
end

function Grid2Layout:ResetPosition()
	local s = UIParent:GetEffectiveScale()
	self.db.profile.PosX =   UIParent:GetWidth()  / 2 * s
	self.db.profile.PosY = - UIParent:GetHeight() / 2 * s
	self.db.profile.anchor = "TOPLEFT"
	self:RestorePosition()
	self:SavePosition()
end

function Grid2Layout:AddLayout(layoutName, layout)
	self.layoutSettings[layoutName] = layout
end

-- Fix non existent layouts for a theme
function Grid2Layout:FixLayoutsTable(db)
	local defaults = self.defaultDB.profile.layouts
	for groupType,layoutName in pairs(db) do
		if not self.layoutSettings[layoutName] then
			db[groupType] = defaults[groupType] or defaults['raid'] or "By Group"
		end
	end
end

-- Fix non existent layouts for all themes
function Grid2Layout:FixLayouts()
	self:FixLayoutsTable(self.dba.profile.layouts)
	for _,theme in ipairs(self.dba.profile.extraThemes or {}) do
		self:FixLayoutsTable(theme.layouts)
	end
end

-- Register user defined layouts (called from Grid2Options do not remove)
function Grid2Layout:AddCustomLayouts()
	self.customLayouts = self.db.global.customLayouts
	if self.customLayouts then
		for n,l in pairs(self.customLayouts) do
			for _,h in ipairs(l) do
				h.type = strmatch(h.type or '', 'pet') -- conversion of old format
				if Grid2.isClassic and h.groupBy == 'ASSIGNEDROLE' then -- convert non existant roles in classic
					h.groupBy, h.groupingOrder = 'ROLE', 'MAINTANK,MAINASSIST,NONE'
				end
			end
			self:AddLayout(n,l)
		end
	end
end

--}}}
_G.Grid2Layout = Grid2Layout
