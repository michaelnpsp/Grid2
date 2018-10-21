--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2Layout = Grid2:NewModule("Grid2Layout")

local pairs, ipairs, next, strmatch = pairs, ipairs, next, strmatch

--{{{ Frame config function for secure headers
local function GridHeader_InitialConfigFunction(self, name)
	Grid2Frame:RegisterFrame(_G[name])
end
--}}}

--{{{ Class for group headers

local NUM_HEADERS = 0

local GridLayoutHeaderClass = {
	prototype = {},
	new = function (self, type)
		NUM_HEADERS = NUM_HEADERS + 1
		local frame = CreateFrame("Frame", "Grid2LayoutHeader"..NUM_HEADERS, Grid2Layout.frame, type=='pet' and "SecureGroupPetHeaderTemplate" or "SecureGroupHeaderTemplate" )
		for name, func in pairs(self.prototype) do
			frame[name] = func
		end
		if ClickCastHeader then
			frame:SetAttribute("template", "ClickCastUnitTemplate,SecureUnitButtonTemplate")
			SecureHandler_OnLoad(frame)
			frame:SetFrameRef("clickcast_header", Clique.header)
		else
			frame:SetAttribute("template", "SecureUnitButtonTemplate")
		end
		frame.initialConfigFunction = GridHeader_InitialConfigFunction
		frame:SetAttribute("initialConfigFunction", [[
			RegisterUnitWatch(self)
			self:SetAttribute("*type1", "target")
			self:SetAttribute("*type2", "menu")
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
		]])
		frame:Reset()
		frame:SetOrientation()
		return frame
	end
}

local HeaderAttributes = {
	"nameList", "groupFilter", "strictFiltering",
	"sortDir", "groupBy", "groupingOrder", "maxColumns", "unitsPerColumn",
	"startingIndex", "columnSpacing", "columnAnchorPoint",
	"useOwnerUnit", "filterOnPet", "unitsuffix",
	"allowVehicleTarget", "toggleForVehicle"
}
function GridLayoutHeaderClass.prototype:Reset()
	if self.initialConfigFunction then
		self:SetLayoutAttribute("sortMethod", "NAME")
		for _, attr in ipairs(HeaderAttributes) do
			self:SetLayoutAttribute(attr, nil)
		end
	end
	self:SetAttribute("showSolo", true)
	self:SetAttribute("showPlayer", true)
	self:SetAttribute("showParty", true)
	self:SetAttribute("showRaid", true)	
	self:Hide()
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
	self:SetLayoutAttribute( "xOffset", xOffset )
	self:SetLayoutAttribute( "yOffset", yOffset )
	self:SetLayoutAttribute( "point", point )
end

-- MSaint fix see: https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/unit-frames/grid-grid2/222108-grid-compact-party-raid-unit-frames?page=11#c219
-- To maintain the code consistent all calls to SetAttribute were replaced with SetLayoutAttribute
-- including those which not affect anchors, the only exception: calls from GridLayoutHeaderClass.new)
function GridLayoutHeaderClass.prototype:SetLayoutAttribute(name, value)
	if name == "point" or name == "columnAnchorPoint" or name == "unitsPerColumn" then
		local count, uframe = 1, self:GetAttribute("child1")
		while uframe do
			uframe:ClearAllPoints()
			count = count + 1
			uframe = self:GetAttribute("child" .. count)
		end
	end
   self:SetAttribute(name, value)
end

--{{{ Grid2Layout

-- AceDB defaults
Grid2Layout.defaultDB = {
	profile = {
		--theme options ( active theme options in: self.db.profile, first theme options in: self.dba.profile, extra themes in: self.dba.profile.extraThemes[] )
		layouts = { solo = "Solo w/Pet", party = "Party w/Pets", arena = "By Group w/Pets", raid  = "By Group w/Pets" },
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
}

Grid2Layout.groupFilters =  {
	{ groupFilter = "1" }, { groupFilter = "2" }, { groupFilter = "3" }, {	groupFilter = "4" },
	{ groupFilter = "5" }, { groupFilter = "6" }, {	groupFilter = "7" }, {	groupFilter = "8" },
}

Grid2Layout.frameBackdrop = {
	 bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	 tile = false, tileSize = 16, edgeSize = 16,
	 insets = {left = 4, right = 4, top = 4, bottom = 4},
}

Grid2Layout.layoutSettings = {}

Grid2Layout.layoutHeaderClass = GridLayoutHeaderClass

function Grid2Layout:OnModuleInitialize()
	self.dba = self.db
	self.db = { global = self.dba.global, profile = self.dba.profile, shared = self.dba.profile } 
	self.groups = { player = {}, pet = {} }
	self.indexes = { player = 0,  pet = 0  }
	self.groupsUsed = {}
	self:AddCustomLayouts()
end

function Grid2Layout:OnModuleEnable()
	self:CreateFrame()
	self:RestorePosition()
	self:RegisterMessage("Grid_GroupTypeChanged")
	self:RegisterMessage("Grid_UpdateLayoutSize", "UpdateSizeThrottled")
end

function Grid2Layout:OnModuleDisable()
	self:UnregisterMessage("Grid_GroupTypeChanged")
	self:UnregisterMessage("Grid_UpdateLayoutSize")
	self.frame:Hide()
end

function Grid2Layout:OnModuleUpdate()
	self:RefreshTheme()
end

function Grid2Layout:UpdateTheme()
	local themes = self.dba.profile.extraThemes
	self.db.profile = themes and themes[Grid2.currentTheme] or self.dba.profile
	self.db.shared = self.dba.profile
end

function Grid2Layout:RefreshTheme()
	self:RestorePosition()
	self:UpdateFrame()
	self:RefreshLayout()
end

--{{{ Event handlers
function Grid2Layout:Grid_GroupTypeChanged(_, groupType, instType, maxPlayers)
	Grid2Layout:Debug("GroupTypeChanged", groupType, instType, maxPlayers)
	if not Grid2:ReloadTheme() then
		self:ReloadLayout()
	end	
end
--}}}

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
		self:RestorePosition()
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

function Grid2Layout:CreateFrame()
	local p = self.db.profile
	-- create main frame to hold all our gui elements
	local f = CreateFrame("Frame", "Grid2LayoutFrame", UIParent)
	self.frame = f
	f:SetMovable(true)
	f:SetPoint("CENTER", UIParent, "CENTER")
	f:SetScript("OnMouseUp", function () self:StopMoveFrame() end)
	f:SetScript("OnHide", function () self:StopMoveFrame() end)
	f:SetScript("OnMouseDown", function (_, button) self:StartMoveFrame(button) end)
	-- Extra frame for background and border textures, to be able to resize in combat
	self.frameBack = CreateFrame("Frame", "Grid2LayoutFrameBack", self.frame)
	--
	self:UpdateFrame()
	self:UpdateTextures()
	self.CreateFrame = Grid2.Dummy
end

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

local relativePoints = {
	[false] = { TOPLEFT = "BOTTOMLEFT", TOPRIGHT = "BOTTOMRIGHT", BOTTOMLEFT = "TOPLEFT",     BOTTOMRIGHT = "TOPRIGHT"   },
	[true]  = { TOPLEFT = "TOPRIGHT",   TOPRIGHT = "TOPLEFT",     BOTTOMLEFT = "BOTTOMRIGHT", BOTTOMRIGHT = "BOTTOMLEFT" },
	xMult   = { TOPLEFT =  1, TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT = -1 },
	yMult   = { TOPLEFT = -1, TOPRIGHT = -1, BOTTOMLEFT = 1, BOTTOMRIGHT =  1 },
}

function Grid2Layout:UpdateHeaders()
	local settings   = self.db.profile
	local horizontal = settings.horizontal
	local vertical   = not horizontal
	local padding    = settings.Padding
	local spacing    = settings.Spacing
	local anchor     = settings.groupAnchor
	local relPoint   = relativePoints[vertical][anchor]
	local xMult1     = relativePoints.xMult[anchor]
	local yMult1     = relativePoints.yMult[anchor]
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
		prevFrame = frame
		self:Debug("Placing group", groupNumber, frame:GetName(), anchor, prevFrame and prevFrame:GetName(), relPoint)
	end	
end

function Grid2Layout:RefreshLayout()
	self.instMaxPlayers = nil -- force layout reload
	self:ReloadLayout()
end

function Grid2Layout:ReloadLayout()
	local p = self.db.profile
	local partyType, instType, maxPlayers = Grid2:GetGroupType()
	local layoutName = p.layouts[maxPlayers] or p.layouts[partyType.."@"..instType] or p.layouts[partyType]
	if layoutName ~= self.layoutName or maxPlayers ~= self.instMaxPlayers then
		if not Grid2:RunSecure(3, self, "ReloadLayout") then
			self.partyType      = partyType
			self.instType       = instType
			self.instMaxPlayers = maxPlayers
			self.instMaxGroups  = math.floor( (maxPlayers + 4) / 5 )
			self:LoadLayout( layoutName )
		end
	end
end

local groupFilters = { "1", "1,2", "1,2,3", "1,2,3,4", "1,2,3,4,5", "1,2,3,4,5,6", "1,2,3,4,5,6,7", "1,2,3,4,5,6,7,8" }

local function SetAllAttributes(header, p, list, fix)
	for attr, value in next, list do
		if attr=="groupFilter" and value=="auto" then
			value = groupFilters[Grid2Layout.instMaxGroups] or "1"
		end
		if attr == "unitsPerColumn" then
			header:SetLayoutAttribute("columnSpacing", p.Padding)
			header:SetLayoutAttribute("unitsPerColumn", value)
			header:SetLayoutAttribute("columnAnchorPoint", anchorPoints[not p.horizontal][p.groupAnchor] or p.groupAnchor )
		elseif attr ~= "type" then
			header:SetLayoutAttribute(attr, value)
		end
	end
	if fix then
		if strmatch(list.type or '','pet') then
			-- force these so that the bug in SecureGroupPetHeader_Update doesn't trigger
			header:SetLayoutAttribute("filterOnPet", true)
			header:SetLayoutAttribute("useOwnerUnit", false)
			header:SetLayoutAttribute("unitsuffix", nil)
		end
		if not header:GetAttribute("unitsPerColumn") then
			header:SetLayoutAttribute("unitsPerColumn", 5)
		end
	end
end

-- Precreate frames to avoid a blizzard bug that prevents initializing unit frames in combat
-- https://authors.curseforge.com/forums/world-of-warcraft/official-addon-threads/unit-frames/grid-grid2/222076-grid?page=159#c3169
local function ForceFramesCreation(header)
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
	end
end

local function AddLayoutHeader(self, profile, defaults, header)
	local type = header.type and strmatch(header.type,'pet') or 'player'
	local headers = self.groups[type]
	local index = self.indexes[type] + 1
	local group = headers[index]
	if not group then
		group = self.layoutHeaderClass:new(type)
		headers[index] = group
	end
	self.indexes[type] = index
	if defaults then
		SetAllAttributes(group, profile, defaults)
	end
	SetAllAttributes(group, profile, header, true)
	ForceFramesCreation(group)
	self.groupsUsed[#self.groupsUsed+1] = group
	self.layoutMaxColumns = self.layoutMaxColumns + (group:GetAttribute("maxColumns") or 1)
	self.layoutMaxRows    = max( self.layoutMaxRows, group:GetAttribute("unitsPerColumn") or 40 )
end

local function GenerateLayoutHeaders(self, profile, defaults)
	for i=1,self.instMaxGroups do
		AddLayoutHeader( self, profile, defaults, self.groupFilters[i] )
	end
end

function Grid2Layout:LoadLayout(layoutName)
	local layout = self.layoutSettings[layoutName]
	if not layout then return end

	self:Debug("LoadLayout", layoutName)

	self.layoutName = layoutName

	self:Scale()

	self.layoutMaxColumns = 0
	self.layoutMaxRows = 0
	wipe(self.groupsUsed)
	for type, headers in pairs(self.groups) do
		self.indexes[type] = 0
		for _, g in ipairs(headers) do
			g:Reset()
		end
	end

	local profile = self.db.profile
	local defaults = layout.defaults

	if layout[1] then
		for _, header in ipairs(layout) do
			if header=="auto" then
				GenerateLayoutHeaders(self, profile, defaults)
			else
				AddLayoutHeader(self, profile, defaults, header)
			end
		end
	elseif not layout.empty then
		GenerateLayoutHeaders(self, profile, defaults)
	end

	self:UpdateHeaders()
	self:UpdateDisplay()
end

function Grid2Layout:UpdateDisplay()
	self:UpdateTextures()
	self:UpdateColor()
	self:CheckVisibility()
	self:UpdateFramesSize()
	self:UpdateSize()
end

function Grid2Layout:UpdateFramesSize()
	local nw,nh = Grid2Frame:GetFrameSize()
	local ow = self.layoutFrameWidth  or nw
	local oh = self.layoutFrameHeight or nh
	if nw~=ow or nh~=oh then
		self.layoutFrameWidth  = nw
		self.layoutFrameHeight = nh
		Grid2Frame:LayoutFrames()
		self:UpdateHeadersSize()
	end
	self.layoutFrameWidth  = nw
	self.layoutFrameHeight = nh
end

-- We delay UpdateSize() call to avoid calculating the wrong window size, because when "Grid_UpdateLayoutSize" 
-- message is triggered the blizzard code has not yet updated the size of the secure group headers.
function Grid2Layout:UpdateSizeThrottled()
	Grid2:RunThrottled(self, "UpdateSize")
end

function Grid2Layout:UpdateSize()
	local p = self.db.profile
	local mcol,mrow,curCol,maxRow,remSize = "GetWidth","GetHeight",0,0,0
	if p.horizontal then mcol,mrow = mrow,mcol end
	for i,g in ipairs(self.groupsUsed) do
		local row = g[mrow](g)
		if maxRow<row then maxRow = row end
		local col = g[mcol](g) + p.Padding
		curCol = curCol + col
		local child = g:GetAttribute("child1")
		remSize = child and child:IsVisible() and 0 or remSize + col
	end
	local col = curCol - remSize + p.Spacing*2 - p.Padding
	local row = maxRow + p.Spacing*2
	if p.horizontal then col,row = row,col end
	self.frameBack:SetSize(col,row)
	updateSizeQueued = InCombatLockdown()
	if not Grid2:RunSecure(4, self, "UpdateSize") then
		self.frame:SetSize(col,row)
	end	
end

function Grid2Layout:UpdateTextures()
	local f = self.frameBack
	local p = self.db.profile
	self.frameBackdrop.bgFile   = Grid2:MediaFetch("background", p.BackgroundTexture)
	self.frameBackdrop.edgeFile = Grid2:MediaFetch("border", p.BorderTexture)
	f:SetBackdrop( self.frameBackdrop )
end

function Grid2Layout:UpdateColor()
	local settings = self.db.profile
	local frame    = self.frameBack
	frame:SetBackdropBorderColor(settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA)
	frame:SetBackdropColor(settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA)
	frame:SetShown( settings.BorderA~=0 or settings.BackgroundA~=0 )
end

-- Force GridLayoutHeaders size refresh, without this g:GetWidth/g:GetHeight in UpdateSize() return old values.
function Grid2Layout:UpdateHeadersSize()
	for type, headers in pairs(self.groups) do
		for i = 1, self.indexes[type] do
			local g = headers[i]
			g:Hide()
			g:Show()
		end
	end
end

function Grid2Layout:CheckVisibility()
	local frameDisplay = self.db.profile.FrameDisplay
	if (frameDisplay == "Always") or
       (frameDisplay == "Grouped" and self.partyType ~= "solo"    ) or
	   (frameDisplay == "Raid"    and self.partyType == "raid" ) then
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

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

function Grid2Layout:ResetPosition()
	local s = UIParent:GetEffectiveScale()
	self.db.profile.PosX =   UIParent:GetWidth()  / 2 * s
	self.db.profile.PosY = - UIParent:GetHeight() / 2 * s
	self.db.profile.anchor = "TOPLEFT"
	self:RestorePosition()
	self:SavePosition()
end

function Grid2Layout:RestorePosition()
	local f = self.frame
	local b = self.frameBack
	local s = f:GetEffectiveScale()
	local p = self.db.profile
	local x = p.PosX / s
	local y = p.PosY / s
	local a = p.anchor
	f:ClearAllPoints()
	f:SetPoint(a, x, y)
	b:ClearAllPoints()
	b:SetPoint(p.groupAnchor) -- Using groupAnchor instead of anchor, see ticket #442.
	self:Debug("Restored Position", a, x, y)
end

function Grid2Layout:Scale()
	self:SavePosition()
	self.frame:SetScale(self.db.profile.ScaleSize)
	self:RestorePosition()
end

function Grid2Layout:AddLayout(layoutName, layout)
	self.layoutSettings[layoutName] = layout
end

function Grid2Layout:AddCustomLayouts()
	local customLayouts = self.db.global.customLayouts
	if customLayouts then
		for n,l in pairs(customLayouts) do
			Grid2Layout:AddLayout(n,l)
		end
	end
end

--}}}
_G.Grid2Layout = Grid2Layout
