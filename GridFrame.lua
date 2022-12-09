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

-- bugfix: wrath toggleForVehicle bug workaround
-- https://github.com/Stanzilla/WoWUIBugs/issues/274
local fix_tfv_enabled, FixToggleForVehicleBugTargeting
if Grid2.isWrath then
	local vehicle_instances = {
		[616] = true, -- malygos raid
		[578] = true, -- oculus dungeon
		-- [603] = true, -- ulduar, test
		-- [571] = true, -- northend, test
	}
	local gsub = string.gsub
	local format = string.format
	local UnitHasVehicleUI = UnitHasVehicleUI
	local SecureButton_GetModifiedUnit_Orig = SecureButton_GetModifiedUnit
	local SecureButton_GetModifiedAttribute = SecureButton_GetModifiedAttribute
	-- this blizzard api function is bugged (it does not swap players with pets) so we have to replace it
	local function SecureButton_GetModifiedUnit_Patched(self)
		local unit = SecureButton_GetModifiedAttribute(self, 'unit')
		if unit then
			local hadPet = strfind(unit,'pet')
			local noPet = (hadPet==nil and unit) or (unit=='pet' and 'player') or gsub(unit, 'pet(%d)', '%1')
			local noPetNoTarget, hadTarget = gsub(noPet, 'target', '')
			if UnitHasVehicleUI(noPetNoTarget) and
			   SecureButton_GetModifiedAttribute(self, 'toggleForVehicle') and
			   noPetNoTarget == gsub( gsub( gsub( noPetNoTarget,'^mouseover','' ), '^focus','' ) ,'^arena%d','' )
			then
				if hadPet then
					unit = noPet
				elseif hadTarget == 0 or SecureButton_GetModifiedAttribute(self, 'allowVehicleTarget')  then
					unit = gsub( gsub(unit, '^player', 'pet'), '^([%a]+)([%d]+)', '%1pet%2')
				end
			end
			return unit
		end
	end
	-- we have to use a macro for targeting but only on players, because pets units can be created in combat and we cannot set macros while in combat
	-- this ugly workaround should work in malygos because players are not targetable while mounted on the drakos, but this does not work on other
	-- vehicles if the player is targetable while is mounted on the vehicle. The macro targets the player pet if the player is not targetable.
	function FixToggleForVehicleBugTargeting(self, unit)
		if unit then
			if not strfind(unit,'pet') and unit~=self.click_unit and SecureButton_GetModifiedAttribute(self,"toggleForVehicle") then
				local pet = unit=='player' and 'pet' or gsub(unit,'^([%a]+)([%d]+)','%1pet%2')
				self:SetAttribute('*type1', 'macro')
				self:SetAttribute('*macrotext1', format('/tar [@%s,help][@%s,help][@%s]', unit, pet, unit) )
				self.click_unit = unit
			end
		elseif self:GetAttribute('*macrotext1') then
			self:SetAttribute('*type1', 'target')
			self:SetAttribute('*macrotext1', nil)
			self.click_unit = nil
		end
	end
	-- Enable/Disable toggleForVehicle bug workaround, called from GridRoster.lua when zone changed
	function Grid2:RefreshToggleForVehicleWorkaround(instID)
	   local enabled = vehicle_instances[instID]
		if enabled ~= fix_tfv_enabled then
			SecureButton_GetModifiedUnit = enabled and SecureButton_GetModifiedUnit_Patched or SecureButton_GetModifiedUnit_Orig
			Grid2Frame:WithAllFrames(function (f)
				FixToggleForVehicleBugTargeting(f, enabled and f.unit or nil)
			end)
			fix_tfv_enabled = enabled
			self:Debug( "WotLK ToggleForVehicle Bug Workaround:", enabled and "enabled!" or "disabled!" )
		end
	end
end

--{{{ Registered unit frames tracking
local frames_of_unit = setmetatable({}, { __index = function (self, key)
	local result = {}
	self[key] = result
	return result
end})
local unit_of_frame = {}

function Grid2:SetFrameUnit(frame, unit)
	local prev_unit = unit_of_frame[frame]
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
	unit_of_frame[frame] = unit
end

function Grid2:GetUnitFrames(unit)
	return frames_of_unit[unit]
end

function Grid2:UpdateFramesOfUnit(unit)
	for frame in next, frames_of_unit[unit] do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		if old ~= new then
			Grid2:SetFrameUnit(frame, new)
			frame.unit = new
		end
		frame:UpdateIndicators()
	end
end

function Grid2:RefreshFramesOfUnit(unit)
	Grid2:RosterRegisterUnit(unit)
	for frame in next, frames_of_unit[unit] do
		frame:UpdateIndicators()
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
				self.unit = unit
				Grid2:SetFrameUnit(self, unit)
				self:UpdateIndicators()
				if fix_tfv_enabled then FixToggleForVehicleBugTargeting(self,value) end
			end
		elseif old_unit then
			Grid2Frame:Debug("removed", self:GetName(), name, old_unit)
			self.unit = nil
			Grid2:SetFrameUnit(self, nil)
			if fix_tfv_enabled then FixToggleForVehicleBugTargeting(self) end
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
	for name, value in pairs(GridFramePrototype) do
		frame[name] = value
	end
	for event, handler in pairs(GridFrameEvents) do
		frame:HookScript(event, handler)
	end
	if frame:CanChangeAttribute() then
		frame:SetAttribute("initial-width", width)
		frame:SetAttribute("initial-height", height)
	end
	frame:RegisterForClicks( Grid2Frame.mouseClickType or "AnyUp" )
	if Clique then Clique:UpdateRegisteredClicks(frame) end
	frame.container = frame:CreateTexture()
	frame:CreateIndicators()
	frame:Layout()
end

local function GridFrame_GetInitialSize(self)
	local header = self:GetParent()
	return header.frameWidth, header.frameHeight
end

function GridFramePrototype:OnUnitStateChanged()
	Grid2:RosterRefreshUnit(self.unit)
	self:UpdateIndicators() -- TODO maybe do not update if not visible and unit does not exist
end

function GridFramePrototype:Layout()
	local dbx = Grid2Frame.db.profile
	local w,h = GridFrame_GetInitialSize(self)
	-- external border controlled by the border indicator
	local r,g,b,a = self:GetBackdropBorderColor()
	Grid2:SetFrameBackdrop( self, frameBackdrop )
	if r then self:SetBackdropBorderColor(r, g, b, a) end
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
	else
		self:SetHighlightTexture('')
	end
	-- Adjust indicators position to the new size
	local indicators = Grid2:GetIndicatorsEnabled()
	for i=1,#indicators do
		indicators[i]:Layout(self)
	end
end

function GridFramePrototype:UpdateIndicators()
	local unit = self.unit
	if unit then
		local indicators = Grid2:GetIndicatorsEnabled()
		for i=1,#indicators do
			indicators[i]:Update(self, unit)
		end
	end
end

function GridFramePrototype:CreateIndicators()
	local indicators = Grid2:GetIndicatorsSorted()
	for i=1,#indicators do
		indicators[i]:Create(self)
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
	self.registeredFrames = {}
end

function Grid2Frame:OnModuleEnable()
	self.mouseClickType = Grid2.db.global.clickOnMouseDown and "AnyDown" or "AnyUp"
	if Grid2.versionCli>=30000 then
		self:RegisterEvent("UNIT_ENTERED_VEHICLE")
		self:RegisterEvent("UNIT_EXITED_VEHICLE")
	end
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrameUnits")
	self:CreateIndicators()
	self:RefreshIndicators()
	self:LayoutFrames()
	self:UpdateFrameUnits()
	self:UpdateIndicators()
end

function Grid2Frame:OnModuleDisable()
	if Grid2.versionCli>=30000 then
		self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
		self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Grid2Frame:OnModuleUpdate()
	self:CreateIndicators()
	self:RefreshTheme()
end

function Grid2Frame:UpdateTheme()
	local themes = self.dba.profile.extraThemes
	self.db.profile = themes and themes[Grid2.currentTheme] or self.dba.profile
	self.db.shared = self.dba.profile
	self:UpgradeThemeDB()
end

function Grid2Frame:RefreshTheme()
	self:RefreshIndicators(true)
end

function Grid2Frame:UpgradeThemeDB()
	local p = self.db.profile
	p.frameWidths  = p.frameWidths  or {}
	p.frameHeights = p.frameHeights or {}
	p.frameHeaderWidths = p.frameHeaderWidths or {}
	p.frameHeaderHeights = p.frameHeaderHeights or {}
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
			elseif not s1 and update and indicator.UpdateDB then
				indicator:UpdateDB()
			end
		end
	end
end

function Grid2Frame:RegisterFrame(frame)
	GridFrame_Init(frame, GridFrame_GetInitialSize(frame))
	self.registeredFrames[frame:GetName()] = frame
end

function Grid2Frame:CreateIndicators()
	for _, frame in next, self.registeredFrames do
		frame:CreateIndicators()
	end
end

function Grid2Frame:UpdateIndicators()
	for _, frame in next, self.registeredFrames do
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
		for _, frame in next, self.registeredFrames do
			func(object, frame, ...)
		end
	end
	with["function"] = function(self, func, ...)
		for _, frame in next, self.registeredFrames do
			func(frame, ...)
		end
	end
	function Grid2Frame:WithAllFrames( param , ... )
		with[type(param)](self, param, ...)
	end
end

-- Alow other modules to hook unit frames OnEnter, OnExit events
function Grid2Frame:SetEventHook( event, func, enabled )
	eventHooks[event][func] = enabled or nil
end

-- Event handlers
function Grid2Frame:UpdateFrameUnits()
	for _, frame in next, self.registeredFrames do
		local old_unit = frame.unit
		local unit = SecureButton_GetModifiedUnit(frame)
		if old_unit ~= unit then
			Grid2:SetFrameUnit(frame, unit)
			frame.unit = unit
			frame:UpdateIndicators()
		end
	end
end

-- Manage togleForVehicle owners/pets swap
-- this event is fired when the vehicle pet unit does not exist yet, so we have to use a timer
-- to delay frame updates if pet unit does not exist or exists but does not represent a vehicle yet.
function Grid2Frame:UNIT_ENTERED_VEHICLE(event, unit)
	if unit then
		for frame in next, frames_of_unit[unit] do
			local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
			if old ~= new then
				Grid2:SetFrameUnit(frame, new)
				frame.unit = new
				if UnitExists(new) and (event==nil or strfind(UnitGUID(new),'^Vehicle')) then -- new is a player or is a vehicle pet
					frame:UpdateIndicators()
				else -- only for pets: pet unit does not exist or exists but is not a vehicle yet
					C_Timer_After( 1.5, function() Grid2:RefreshFramesOfUnit(new) end )
				end
			end
		end
		self:UNIT_ENTERED_VEHICLE( nil, pet_of_unit[unit] ) -- event==nil => unit is a pet
	end
end
Grid2Frame.UNIT_EXITED_VEHICLE = Grid2Frame.UNIT_ENTERED_VEHICLE

--}}}

_G.Grid2Frame = Grid2Frame

-- Allow other modules/addons to easily modify the grid unit frames
Grid2Frame.Prototype = GridFramePrototype
-- Allow other modules to access the variable for speed optimization
Grid2.frames_of_unit = frames_of_unit
