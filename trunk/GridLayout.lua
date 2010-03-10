-- Grid2Layout.lua
-- insert boilerplate
local Grid2Layout = Grid2:NewModule("Grid2Layout")

--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

--}}}

--{{{ Frame config function for secure headers

local function GridLayout_InitialConfigFunction(frame)
	Grid2Frame:RegisterFrame(frame)
	frame:SetAttribute("useparent-allowVehicleTarget", "1")
	frame:SetAttribute("useparent-toggleForVehicle", "1")
end

--}}}

--{{{ Class for group headers

local NUM_HEADERS = 0
local SecureHeaderTemplates = {
	party = "SecurePartyHeaderTemplate",
	partypet = "SecurePartyPetHeaderTemplate",
	raid = "SecureRaidGroupHeaderTemplate",
	raidpet = "SecureRaidPetHeaderTemplate",
}

local GridLayoutHeaderClass = {
	prototype = {},
	new = function (self, type)
		NUM_HEADERS = NUM_HEADERS + 1
		local frame
		if (type == "spacer") then
			frame = CreateFrame("Frame", "Grid2LayoutHeader"..NUM_HEADERS, Grid2Layout.frame)
		else
			frame = CreateFrame("Frame", "Grid2LayoutHeader"..NUM_HEADERS, Grid2Layout.frame, assert(SecureHeaderTemplates[type]))
			frame:SetAttribute("template", "SecureUnitButtonTemplate")
			frame.initialConfigFunction = GridLayout_InitialConfigFunction
		end
		for name, func in pairs(self.prototype) do
			frame[name] = func
		end
		frame:Reset()
		frame:SetOrientation()
		return frame
	end
}

--[[
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinate (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the ammount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)

allowVehicleTarget = [BOOLEAN] - clicking on a vehicle selects it
toggleForVehicle = [BOOLEAN] - GetModifiedUnit will return owner of the vehicle

useOwnerUnit = [BOOLEAN] - if true, then the owner's unit string is set on managed frames "unit" attribute (instead of pet's)
filterOnPet = [BOOLEAN] - if true, then pet names are used when sorting/filtering the list
--]]
local HeaderAttributes = {
	"showPlayer", "showSolo", "nameList", "groupFilter", "strictFiltering",
	"sortDir", "groupBy", "groupingOrder", "maxColumns", "unitsPerColumn",
	"startingIndex", "columnSpacing", "columnAnchorPoint",
	"useOwnerUnit", "filterOnPet",
	"allowVehicleTarget", "toggleForVehicle"
}
function GridLayoutHeaderClass.prototype:Reset()
	if self.initialConfigFunction then
		self:SetAttribute("sortMethod", "NAME")
		for _, attr in ipairs(HeaderAttributes) do
			self:SetAttribute(attr, nil)
		end
	end
	self:Hide()
end

-- nil or false for vertical
function GridLayoutHeaderClass.prototype:SetOrientation(horizontal)
	if not self.initialConfigFunction then return end

	local layoutSettings = Grid2Layout.db.profile
	local groupAnchor = layoutSettings.groupAnchor
	local padding = layoutSettings.Padding
	local xOffset, yOffset, point

	if horizontal then
		if groupAnchor == "TOPLEFT" or groupAnchor == "BOTTOMLEFT" then
			xOffset = padding
			yOffset = 0
			point = "LEFT"
		else
			xOffset = -padding
			yOffset = 0
			point = "RIGHT"
		end
	else
		if groupAnchor == "TOPLEFT" or groupAnchor == "TOPRIGHT" then
			xOffset = 0
			yOffset = -padding
			point = "TOP"
		else
			xOffset = 0
			yOffset = padding
			point = "BOTTOM"
		end
	end

	self:SetAttribute("xOffset", xOffset)
	self:SetAttribute("yOffset", yOffset)
	self:SetAttribute("point", point)
end

--}}}

--{{{ Grid2Layout
--{{{  Initialization

--{{{  AceDB defaults

Grid2Layout.defaultDB = {
	profile = {
		debug = false,

		FrameDisplay = "Always",
		layouts = {
			solo = L["Solo w/Pet"],
			party = L["By Group 5 w/Pets"],
			raid10 = L["By Group 10 w/Pets"],
			raid15 = L["By Group 15 w/Pets"],
			raid20 = L["By Group 25 w/Pets"],
			raid25 = L["By Group 25 w/Pets"],
			raid40 = L["By Group 40"],
			pvp = L["By Group 40"],
			arena = L["By Group 5 w/Pets"],
		},
		horizontal = true,
		clamp = true,
		FrameLock = false,
		ClickThrough = false,

		Padding = 1,
		Spacing = 10,
		ScaleSize = 1,
		BorderR = .5,
		BorderG = .5,
		BorderB = .5,
		BorderA = 1,
		BackgroundR = .1,
		BackgroundG = .1,
		BackgroundB = .1,
		BackgroundA = .65,

		anchor = "BOTTOMLEFT",
		groupAnchor = "BOTTOMLEFT",

		PosX = 400,
		PosY = 100,
	},
}

--}}}
--}}}

Grid2Layout.layoutSettings = {}
Grid2Layout.layoutHeaderClass = GridLayoutHeaderClass

function Grid2Layout:OnInitialize()
	self.core.defaultModulePrototype.OnInitialize(self)
	self.groups = {
		raid = {},
		raidpet = {},
		party = {},
		partypet = {},
		spacer = {},
	}
	self.indexes = {
		raid = 0,
		raidpet = 0,
		party = 0,
		partypet = 0,
		spacer = 0,
	}
end

function Grid2Layout:OnEnable()
	if not self.frame then
		self:CreateFrame()
	end
	self:LoadLayout(self.db.profile.layout)
	-- position and scale frame
	self:RestorePosition()
	self:Scale()

	self:RegisterMessage("Grid_GroupTypeChanged")
	self:RegisterMessage("Grid_UpdateLayoutSize", "UpdateSize")

	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	self.core.defaultModulePrototype.OnEnable(self)
end

function Grid2Layout:OnDisable()
	self.frame:Hide()
	self.core.defaultModulePrototype.OnDisable(self)
end

function Grid2Layout:Reset()
	self.core.defaultModulePrototype.Reset(self)

	self:ReloadLayout()
	-- position and scale frame
	self:RestorePosition()
	self:Scale()
end

--{{{ Event handlers

local reloadLayoutQueued, updateSizeQueued, restorePositionQueued
function Grid2Layout:PLAYER_REGEN_ENABLED()
	if reloadLayoutQueued then return self:ReloadLayout() end
	if updateSizeQueued then return self:UpdateSize() end
	if restorePositionQueued then return self:RestorePosition() end
end

function Grid2Layout:Grid_GroupTypeChanged(_, type)
	Grid2Layout:Debug("GroupTypeChanged", type)
	self.partyType = type
	self:ReloadLayout()
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

-- locked = nil : toggle
-- locked = false : disable movement
-- locked = true : enable movement
function Grid2Layout:FrameLock(locked)
	local p = self.db.profile
	if (locked == nil) then
		p.FrameLock = not p.FrameLock
	else
		p.FrameLock = locked
	end
	if (not p.FrameLock and p.ClickThrough) then
		p.ClickThrough = false
		self.frame:EnableMouse(true)
	end
end

--
-- ConfigMode support
--

-- Create the global table if it does not exist yet
CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}

-- Declare our handler
CONFIGMODE_CALLBACKS["Grid2"] = function(action)
	if (action == "ON") then
		Grid2Layout:FrameLock(false)
	elseif (action == "OFF") then
		Grid2Layout:FrameLock(true)
	end
end

function Grid2Layout:CreateFrame()
	-- create main frame to hold all our gui elements
	local f = CreateFrame("Frame", "Grid2LayoutFrame", UIParent)
	f:EnableMouse(not (self.db.profile.FrameLock and self.db.profile.ClickThrough))
	f:SetMovable(true)
	f:SetClampedToScreen(self.db.profile.clamp)
	f:SetPoint("CENTER", UIParent, "CENTER")
	f:SetScript("OnMouseUp", function () self:StopMoveFrame() end)
	f:SetScript("OnHide", function () self:StopMoveFrame() end)
	f:SetScript("OnMouseDown", function (_, button) self:StartMoveFrame(button) end)
	f:SetFrameStrata("MEDIUM")
	-- create background
	f:SetFrameLevel(0)
	f:SetBackdrop({
				 bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
				 edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
				 insets = {left = 4, right = 4, top = 4, bottom = 4},
			 })
	-- create bg texture
	f.texture = f:CreateTexture(nil, "BORDER")
	f.texture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	f.texture:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
	f.texture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
	f.texture:SetBlendMode("ADD")
	f.texture:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .2, .2, .2, 0.5)

	self.frame = f
	self.CreateFrame = nil
end

local function getRelativePoint(point, horizontal)
	if point == "TOPLEFT" then
		if horizontal then
			return "BOTTOMLEFT", 1, -1
		else
			return "TOPRIGHT", 1, -1
		end
	elseif point == "TOPRIGHT" then
		if horizontal then
			return "BOTTOMRIGHT", -1, -1
		else
			return "TOPLEFT", -1, -1
		end
	elseif point == "BOTTOMLEFT" then
		if horizontal then
			return  "TOPLEFT", 1, 1
		else
			return "BOTTOMRIGHT", 1, 1
		end
	elseif point == "BOTTOMRIGHT" then
		if horizontal then
			return "TOPRIGHT", -1, 1
		else
			return "BOTTOMLEFT", -1, 1
		end
	end
end

local previousFrame
function Grid2Layout:PlaceGroup(frame, groupNumber)

	local settings = self.db.profile
	local horizontal = settings.horizontal
	local padding = settings.Padding
	local spacing = settings.Spacing
	local groupAnchor = settings.groupAnchor

	local relPoint, xMult, yMult = getRelativePoint(groupAnchor, horizontal)

	if groupNumber == 1 then
		frame:ClearAllPoints()
		frame:SetParent(self.frame)
		frame:SetPoint(groupAnchor, self.frame, groupAnchor, spacing * xMult, spacing * yMult)
	else
		if horizontal then
			xMult = 0
		else
			yMult = 0
		end

		frame:ClearAllPoints()
		frame:SetPoint(groupAnchor, previousFrame, relPoint, padding * xMult, padding * yMult)
	end

	self:Debug("Placing group", groupNumber, frame:GetName(), groupAnchor, previousFrame and previousFrame:GetName(), relPoint)

	previousFrame = frame
end

function Grid2Layout:AddLayout(layoutName, layout)
	self.layoutSettings[layoutName] = layout
	if Grid2Options then
		Grid2Options:AddLayout(layoutName, layout)
	end
end

function Grid2Layout:SetClamp()
	self.frame:SetClampedToScreen(self.db.profile.clamp)
end

function Grid2Layout:ReloadLayout()
	if InCombatLockdown() then
		reloadLayoutQueued = true
		return
	end
	reloadLayoutQueued = false

	local layout = self.db.profile.layouts[self.partyType or "solo"]
	self:LoadLayout(layout)
end

local function getColumnAnchorPoint(point, horizontal)
	if not horizontal then
		if point == "TOPLEFT" or point == "BOTTOMLEFT" then
			return "LEFT"
		elseif point == "TOPRIGHT" or point == "BOTTOMRIGHT" then
			return "RIGHT"
		end
	else
		if point == "TOPLEFT" or point == "TOPRIGHT" then
			return "TOP"
		elseif point == "BOTTOMLEFT" or point == "BOTTOMRIGHT" then
			return "BOTTOM"
		end
	end
	return point
end

function Grid2Layout:LoadLayout(layoutName)
	local p = self.db.profile
	local horizontal = p.horizontal
	local layout = self.layoutSettings[layoutName]
	if not layout then return end

	self:Debug("LoadLayout", layoutName)

	for type, headers in pairs(self.groups) do
		self.indexes[type] = 0
		for _, g in ipairs(headers) do
			g:Reset()
		end
	end

	local defaults = layout.defaults
	local default_type = defaults and defaults.type or "raid"

	for i, l in ipairs(layout) do
		local type = l.type or default_type
		local headers = assert(self.groups[type], "Bad " .. type)
		local index = self.indexes[type] + 1
		local layoutGroup = headers[index]
		if not layoutGroup then
			layoutGroup = self.layoutHeaderClass:new(type)
			headers[index] = layoutGroup
		end
		self.indexes[type] = index

		if type ~= "spacer" then
			if defaults then
				for attr, value in pairs(defaults) do
					if attr == "unitsPerColumn" then
						layoutGroup:SetAttribute("unitsPerColumn", value)
						layoutGroup:SetAttribute("columnSpacing", p.Padding)
						layoutGroup:SetAttribute("columnAnchorPoint", getColumnAnchorPoint(p.groupAnchor, p.horizontal))
					elseif attr ~= "type" then
						layoutGroup:SetAttribute(attr, value)
					end
				end
			end
			for attr, value in pairs(l) do
				if attr == "unitsPerColumn" then
					layoutGroup:SetAttribute("unitsPerColumn", value)
					layoutGroup:SetAttribute("columnSpacing", p.Padding)
					layoutGroup:SetAttribute("columnAnchorPoint", getColumnAnchorPoint(p.groupAnchor, p.horizontal))
				elseif attr ~= "type" then
					layoutGroup:SetAttribute(attr, value)
				end
			end
			layoutGroup:SetOrientation(horizontal)
		end
		self:PlaceGroup(layoutGroup, i)
		layoutGroup:Show()
	end

	self:UpdateDisplay()
end

function Grid2Layout:UpdateDisplay()
	self:UpdateColor()
	self:CheckVisibility()
	self:UpdateSize()
end

function Grid2Layout:UpdateSize()
	if InCombatLockdown() then
		updateSizeQueued = true
		return
	end
	updateSizeQueued = false

	local p = self.db.profile
	local curWidth, curHeight, maxWidth, maxHeight = 0, 0, 0, 0
	local Padding, Spacing = p.Padding, p.Spacing * 2

	local GridFrame = Grid2:GetModule("Grid2Frame")
	for i = 1, self.indexes.spacer do
		self.groups.spacer[i]:SetSize(GridFrame:GetFrameSize())
	end

	for type, headers in pairs(self.groups) do
		for i = 1, self.indexes[type] do
			local g = headers[i]
			local width, height = g:GetWidth(), g:GetHeight()
			curWidth = curWidth + width + Padding
			curHeight = curHeight + height + Padding
			if maxWidth < width then maxWidth = width end
			if maxHeight < height then maxHeight = height end
		end
	end

	local x, y
	if p.horizontal then
		x = maxWidth + Spacing
		y = curHeight + Spacing
	else
		x = curWidth + Spacing
		y = maxHeight + Spacing
	end

	self.frame:SetWidth(x)
	self.frame:SetHeight(y)
end

function Grid2Layout:UpdateColor()
	local settings = self.db.profile

	self.frame:SetBackdropBorderColor(settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA)
	self.frame:SetBackdropColor(settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA)
	self.frame.texture:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .2, .2, .2, settings.BackgroundA/2 )
end

function Grid2Layout:CheckVisibility()
	local frameDisplay = self.db.profile.FrameDisplay

	if frameDisplay == "Always" then
		self.frame:Show()
	elseif frameDisplay == "Grouped" and self.partyType ~= "solo" then
		self.frame:Show()
	elseif frameDisplay == "Raid" and (self.partyType == "raid10" or self.partyType == "raid15" or self.partyType == "raid20" or self.partyType == "raid25") then
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

function Grid2Layout:SavePosition()
	local f = self.frame
	local s = f:GetEffectiveScale()
	local uiScale = UIParent:GetEffectiveScale()
	local anchor = self.db.profile.anchor

	local x, y

	if not f:GetLeft() or not f:GetWidth() then return end

	if anchor == "CENTER" then
		x = (f:GetLeft() + f:GetWidth() / 2) * s - UIParent:GetWidth() / 2 * uiScale
		y = (f:GetTop() - f:GetHeight() / 2) * s - UIParent:GetHeight() / 2 * uiScale
	elseif anchor == "TOP" then
		x = (f:GetLeft() + f:GetWidth() / 2) * s - UIParent:GetWidth() / 2 * uiScale
		y = f:GetTop() * s - UIParent:GetHeight() * uiScale
	elseif anchor == "LEFT" then
		x = f:GetLeft() * s
		y = (f:GetTop() - f:GetHeight() / 2) * s - UIParent:GetHeight() / 2 * uiScale
	elseif anchor == "RIGHT" then
		x = f:GetRight() * s - UIParent:GetWidth() * uiScale
		y = (f:GetTop() - f:GetHeight() / 2) * s - UIParent:GetHeight() / 2 * uiScale
	elseif anchor == "BOTTOM" then
		x = (f:GetLeft() + f:GetWidth() / 2) * s - UIParent:GetWidth() / 2 * uiScale
		y = f:GetBottom() * s
	elseif anchor == "TOPLEFT" then
		x = f:GetLeft() * s
		y = f:GetTop() * s - UIParent:GetHeight() * uiScale
	elseif anchor == "TOPRIGHT" then
		x = f:GetRight() * s - UIParent:GetWidth() * uiScale
		y = f:GetTop() * s - UIParent:GetHeight() * uiScale
	elseif anchor == "BOTTOMLEFT" then
		x = f:GetLeft() * s
		y = f:GetBottom() * s
	elseif anchor == "BOTTOMRIGHT" then
		x = f:GetRight() * s - UIParent:GetWidth() * uiScale
		y = f:GetBottom() * s
	end

	if x and y then
		self.db.profile.PosX = x
		self.db.profile.PosY = y
		self:Debug("Saved Position", anchor, x, y)
	end
end

function Grid2Layout:ResetPosition()
	local uiScale = UIParent:GetEffectiveScale()

	self.db.profile.PosX = UIParent:GetWidth() / 2 * uiScale
	self.db.profile.PosY = - UIParent:GetHeight() / 2 * uiScale
	self.db.profile.anchor = "TOPLEFT"

	self:RestorePosition()
	self:SavePosition()
end

function Grid2Layout:RestorePosition()
	if InCombatLockdown() then
		restorePositionQueued = true
		return
	end
	restorePositionQueued = false

	local f = self.frame
	local s = f:GetEffectiveScale()
	local x, y = self.db.profile.PosX / s, self.db.profile.PosY / s
	local anchor = self.db.profile.anchor

	f:ClearAllPoints()
	f:SetPoint(anchor, x, y)

	self:Debug("Restored Position", anchor, x, y)
end

function Grid2Layout:Scale()
	self:SavePosition()
	self.frame:SetScale(self.db.profile.ScaleSize)
	self:RestorePosition()
end

function Grid2Layout:SetFrameLock(FrameLock, ClickThrough)
	local p = self.db.profile
	p.FrameLock = FrameLock
	if not FrameLock then
		ClickThrough = false
	end
	p.ClickThrough = ClickThrough
	self.Frame:EnableMouse(not ClickThrough)
end

--}}}
_G.Grid2Layout = Grid2Layout
