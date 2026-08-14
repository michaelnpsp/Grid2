--[[ Created by Grid2 original authors, modified by Michael --]]

local Grid2 = Grid2
local next = next
local pairs = pairs
local strfind = strfind
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local pet_of_unit = Grid2.pet_of_unit
local C_Timer_After = C_Timer.After
local SecureButton_GetModifiedUnit = SecureButton_GetModifiedUnit
local Grid2Frame

--{{{ Registered unit frames tracking
local frames_of_unit = setmetatable({}, { __index = function (self, key)
	local result = {}
	self[key] = result
	return result
end})
local activatedFrames = {}  -- only frames assigned to an unit: activatedFrames[frame] = unit
local registeredFrames = {} -- all frames created used and unused: registeredFrames[frameName] = frame

function Grid2:SetFrameUnit(frame, unit)
	local prev_unit = activatedFrames[frame]
	if prev_unit then
		local frames = frames_of_unit[prev_unit]
		frames[frame] = nil
		if not next(frames) then
			frames_of_unit[prev_unit] = nil
			Grid2:RosterUnregisterUnit(prev_unit)
		end
	end
	if unit then
		local frames = frames_of_unit[unit]
		if not next(frames) then
			Grid2:RosterRegisterUnit(unit)
		end
		frames[frame] = true
	end
	activatedFrames[frame] = unit
	frame.unit = unit
end

function Grid2:GetUnitFrames(unit)
	return frames_of_unit[unit]
end

function Grid2:UpdateFramesOfUnit(unit, unitChanged)
	for frame in next, frames_of_unit[unit] do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		local changed = old ~= new
		if changed then
			Grid2:SetFrameUnit(frame, new)
			frame:UpdateIndicators(true)
		else
			frame:UpdateIndicators(unitChanged)
		end
	end
end

--}}}

-- {{ Precalculated backdrop table, shared by all frames
local frameBackdrop
-- }}

--{{{ Grid2Frame script handlers
local GridFrameEvents = {}

function GridFrameEvents:OnShow()
	Grid2Frame:SendMessage("Grid_UpdateLayoutSize")
end

function GridFrameEvents:OnHide()
	Grid2Frame:SendMessage("Grid_UpdateLayoutSize")
end

function GridFrameEvents:OnAttributeChanged(name, value)
	if name == "unit" then
		local old_unit = self.unit
		if value then
			local unit = SecureButton_GetModifiedUnit(self)
			if old_unit ~= unit then
				Grid2Frame:Debug("updated", self:GetName(), name, value, unit, '<=', old_unit)
				Grid2:SetFrameUnit(self, unit)
				self:UpdateIndicators(true)
			end
		elseif old_unit then
			Grid2Frame:Debug("removed", self:GetName(), name, old_unit)
			Grid2:SetFrameUnit(self, nil)
			self:UpdateAuraContainers()
		end
	end
end

-- Dispatch OnEnter, OnLeave events to other modules
local eventHooks = { OnEnter = {}, OnLeave = {} }

function GridFrameEvents:OnEnter()
	for func in pairs(eventHooks.OnEnter) do
		func(self)
	end
end

function GridFrameEvents:OnLeave()
	for func in pairs(eventHooks.OnLeave) do
		func(self)
	end
end
--}}}

--{{{ GridFramePrototype
local GridFramePrototype = {}
local function GridFrame_Init(frame, width, height)
	frame.__auraManager = {}
	for name, value in pairs(GridFramePrototype) do
		frame[name] = value
	end
	for event, handler in pairs(GridFrameEvents) do
		frame:HookScript(event, handler)
	end
	if frame:CanChangeAttribute() then
		frame:SetAttribute("initial-width", width)
		frame:SetAttribute("initial-height", height)
		if PingUtil then
			frame:SetAttribute("ping-receiver", true)
			frame.IsPingable = true
		end
	end
	frame:RegisterForClicks( Grid2Frame.mouseClickType or "AnyUp" )
	if Clique then Clique:UpdateRegisteredClicks(frame) end
	frame.container = frame:CreateTexture()
	frame:CreateIndicators()
	frame:Layout()
	Grid2Frame:SendMessage("Grid_UpdateLayoutSize")
end

local function GridFrame_GetInitialSize(self)
	local header = self:GetParent()
	return header.frameWidth, header.frameHeight
end

function GridFramePrototype:Layout()
	local dbx = Grid2Frame.db.profile
	local w,h = GridFrame_GetInitialSize(self)
	-- external border controlled by the border indicator
	local r,g,b,a = self:GetBackdropBorderColor()
	Grid2:SetFrameBackdrop( self, frameBackdrop )
	if r then
		self:SetBackdropBorderColor(r, g, b, a)
	else
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end
	-- inner border color (sure that is the inner border)
	local cf = dbx.frameColor
	self:SetBackdropColor( cf.r, cf.g, cf.b, cf.a )
	-- visible background
	local container= self.container
	container:SetPoint("CENTER", self, "CENTER")
	-- shrink the background, showing part of the real frame background (that is behind) as a inner border.
	local inset = (dbx.frameBorder+dbx.frameBorderDistance)*2
	container:SetSize( w-inset, h-inset )
	-- visible background texture
	local texture = Grid2:MediaFetch("statusbar", dbx.frameTexture, "Gradient" )
	self.container:SetTexture(texture)
	-- set size
	if not InCombatLockdown() then self:SetSize(w,h) end
	-- highlight texture
	if dbx.mouseoverHighlight then
		self:SetHighlightTexture( Grid2:MediaFetch("background", dbx.mouseoverTexture, "Blizzard Quest Title Highlight") )
		local color = dbx.mouseoverColor
		self:GetHighlightTexture():SetVertexColor(color.r, color.g, color.b, color.a)
	elseif self:GetHighlightTexture() then
		self:SetHighlightTexture('')
		self:GetHighlightTexture():SetVertexColor(0,0,0,0)
	end
	-- self:GetHighlightTexture():SetVertexColor(0,0,0,0)
	-- Adjust indicators position to the new size
	local indicators = Grid2:GetIndicatorsEnabled()
	for i=1,#indicators do
		local indicator = indicators[i]
		if indicator:GetFrame(self) then
			indicator:Layout(self)
		end
	end
end

function GridFramePrototype:UpdateAuraContainers()
	local manager = self.__auraManager
	if manager then
		local unit = self.unit or 'none'
		local enabled = unit ~= 'none'
		for _, container in pairs(manager) do
			if unit ~= container:GetUnit() then
				container:SetUnit(unit)
				container:SetShown(enabled)
				container:SetEnabled(enabled)
			else
				container:UpdateAllAuras()
			end
		end
	end
end

function GridFramePrototype:UpdateIndicators(unitChanged)
	local unit = self.unit
	if unit then
		local indicators = Grid2:GetIndicatorsEnabled()
		for i=1,#indicators do
			indicators[i]:Update(self, unit)
		end
	end
	if unitChanged then
		self:UpdateAuraContainers(unit)
	end
end

function GridFramePrototype:CreateIndicators()
	local indicators = Grid2:GetIndicatorsSorted()
	for i=1,#indicators do
		local indicator = indicators[i]
		if indicator:CanCreate(self) then
			indicator:Create(self)
		end
	end
end

if PingUtil then
	function GridFramePrototype:GetContextualPingType()
		return PingUtil:GetContextualPingTypeForUnit( UnitGUID(self.unit) )
	end
	function GridFramePrototype:GetTargetPingGUID()
		return UnitGUID(self.unit)
	end
end

--}}}

--{{{ Grid2Frame
Grid2Frame = Grid2:NewModule("Grid2Frame")

Grid2Frame.defaultDB = {
	profile = {
		-- theme options ( active theme options in: self.db.profile, first theme options in: self.dba.profile, extra themes in: self.dba.profile.extraThemes[] )
		frameHeight = 48,
		frameWidth  = 48,
		frameBorder = 2,
		frameBorderColor = {r=0, g=0, b=0, a=0},
		frameBorderTexture = "Grid2 Flat",
		frameBorderDistance= 1,
		frameTexture = "Gradient",
		frameColor = { r=0, g=0, b=0, a=1 },
		frameContentColor= { r=0, g=0, b=0, a=1 },
		mouseoverHighlight = false,
		mouseoverColor = { r=1, g=1, b=1, a=1 },
		mouseoverTexture = "Blizzard Quest Title Highlight",
		frameWidths  = {},
		frameHeights = {},
		frameHeaderLocks = {},
		frameHeaderWidths = {},
		frameHeaderHeights = {},
		-- default values for indicators
		orientation = "VERTICAL",
		barTexture = "Gradient",
		font =  nil,
		fontSize = 11,
		iconSize = 14,
		-- profile options shared by all themes, but stored on default/first theme
		blinkType = "Flash",
		blinkFrequency = 2,
	}
}

function Grid2Frame:OnModuleInitialize()
	self.dba = self.db
	self.db = { global = self.dba.global, profile = self.dba.profile, shared = self.dba.profile }
end

function Grid2Frame:OnModuleEnable()
	self.mouseClickType = Grid2.db.global.clickOnMouseDown and "AnyDown" or "AnyUp"
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrameUnits")
	Grid2.RegisterRosterUnitEvent(self, "UNIT_FACTION")
	self:CreateIndicators()
	self:RefreshIndicators()
	self:LayoutFrames()
	self:UpdateFrameUnits()
	self:UpdateIndicators()
end

function Grid2Frame:OnModuleDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	Grid2.UnregisterRosterUnitEvent(self, "UNIT_FACTION")
end

function Grid2Frame:OnModuleUpdate()
	self:CreateIndicators()
	self:RefreshTheme()
end

-- fix for auras not displayed after watching a cinematic (CF issue #1535)
function Grid2Frame:UNIT_FACTION(_, unit)
	for frame in next, Grid2:GetUnitFrames(unit) do
		frame:UpdateAuraContainers()
	end
end

function Grid2Frame:UpdateTheme()
	local themes = self.dba.profile.extraThemes
	self.db.profile = themes and themes[Grid2.currentTheme] or self.dba.profile
	self.db.shared = self.dba.profile
	self:UpgradeThemeDB()
end

function Grid2Frame:RefreshTheme()
	self:UpdateBackdrop()
	self:RefreshIndicators(true)
end

function Grid2Frame:UpgradeThemeDB()
	local p = self.db.profile
	p.frameWidths  = p.frameWidths  or {}
	p.frameHeights = p.frameHeights or {}
	p.frameHeaderLocks = p.frameHeaderLocks or {}
	p.frameHeaderWidths = p.frameHeaderWidths or {}
	p.frameHeaderHeights = p.frameHeaderHeights or {}
	if p.fontFlags=='NONE' then p.fontFlags = nil end
end

-- wakeup/suspend indicators according to the current theme
function Grid2Frame:RefreshIndicators(update)
	local _, _, suspended = Grid2:GetCurrentTheme()
	for _,indicator in ipairs(Grid2.indicatorSorted) do
		if not indicator.parentName then
			local s1 = indicator.suspended
			local s2 = suspended[indicator.name]
			if s1~=s2 then
				if s2 then
					Grid2:SuspendIndicator(indicator)
				else
					Grid2:WakeUpIndicator(indicator)
				end
			elseif not s1 and update then
				indicator:UpdateDB()
			end
		end
	end
end

function Grid2Frame:RegisterFrame(frame)
	GridFrame_Init(frame, GridFrame_GetInitialSize(frame))
	registeredFrames[frame:GetName()] = frame
end

function Grid2Frame:CreateIndicators()
	for _, frame in next, registeredFrames do
		frame:CreateIndicators()
	end
end

function Grid2Frame:UpdateIndicators()
	for frame in next, activatedFrames do
		frame:UpdateIndicators()
	end
end

function Grid2Frame:UpdateBackdrop()
	local dbx = self.db.profile
	frameBackdrop = Grid2:GetBackdropTable( Grid2:MediaFetch("border", dbx.frameBorderTexture, "Grid2 Flat"), dbx.frameBorder, "Interface\\Addons\\Grid2\\media\\white16x16", true, 16 )
end

function Grid2Frame:LayoutFrames(notify)
	self:UpdateBackdrop()
	for _,header in ipairs(Grid2Layout.groupsUsed) do
		for _,frame in ipairs(header) do
			frame:Layout()
		end
	end
	if notify then self:SendMessage("Grid_UpdateLayoutSize") end
end

-- Grid2Frame:WithAllFrames()
do
	local type, with = type, {}
	with["table"] = function(self, object, func, ...)
		if type(func) == "string" then func = object[func] end
		for _, frame in next, registeredFrames do
			func(object, frame, ...)
		end
	end
	with["function"] = function(self, func, ...)
		for _, frame in next, registeredFrames do
			func(frame, ...)
		end
	end
	function Grid2Frame:WithAllFrames( param , ... )
		with[type(param)](self, param, ...)
	end
end

-- Allow other modules to hook unit frames OnEnter, OnExit events
function Grid2Frame:SetEventHook( event, func, enabled )
	eventHooks[event][func] = enabled or nil
end

-- Event handlers
function Grid2Frame:UpdateFrameUnits()
	for frame, old_unit in next, activatedFrames do
		local unit = SecureButton_GetModifiedUnit(frame)
		if old_unit ~= unit then
			Grid2:SetFrameUnit(frame, unit)
			frame:UpdateIndicators(true)
		end
	end
end

--}}}

_G.Grid2Frame = Grid2Frame

-- Allow other modules/addons to easily modify the grid unit frames
Grid2Frame.Prototype = GridFramePrototype
-- Allow other modules to access the variable for speed optimization
Grid2Frame.frames_of_unit = frames_of_unit
Grid2Frame.activatedFrames = activatedFrames
Grid2Frame.registeredFrames = registeredFrames
