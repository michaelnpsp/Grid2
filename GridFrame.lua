-- Grid2Frame.lua

--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")
local GridRange = GridRange
local Grid2Frame
local SecureButton_GetModifiedUnit = SecureButton_GetModifiedUnit

--}}}
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
		if value then
			local unit = SecureButton_GetModifiedUnit(self)
			if self.unit ~= unit then
				self.unit = unit

				Grid2Frame:Debug("updated", self:GetName(), name, value, unit)
				Grid2Frame:UpdateIndicators(self)
				Grid2:SetFrameUnit(self, unit)
			end
		elseif self.unit then
			Grid2Frame:Debug("removed", self:GetName(), name, self.unit)
			self.unit = nil
			Grid2:SetFrameUnit(self, nil)
		end
	end
end

function GridFrameEvents:OnEnter()
	self:OnEnter()
end

function GridFrameEvents:OnLeave()
	self:OnLeave()
end

function GridFrameEvents:OnSizeChanged(w, h)
	--@FIXME throttle this ?
	self:LayoutIndicators()
end

--}}}
--{{{ GridFramePrototype

local GridFramePrototype = {}
local function GridFrame_Init(frame, width, height)
	for name, value in pairs(GridFramePrototype) do
		frame[name] = value
	end

	for event, handler in pairs(GridFrameEvents) do
		frame:SetScript(event, handler)
	end

	local frameBorder = Grid2Frame.db.profile.frameBorder
	frame:SetBackdrop({
		bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
		edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = frameBorder,
		insets = {left = frameBorder, right = frameBorder, top = frameBorder, bottom = frameBorder},
	})
	frame:SetBackdropBorderColor(0, 0, 0, 1)
	frame:SetBackdropColor(0, 0, 0, 1)

	frame:EnableMouseoverHighlight(Grid2Frame.db.profile.mouseoverHighlight)

	for _, indicator in Grid2:IterateIndicators() do
		indicator:Create(frame)
	end
	Grid2:InterleaveHealsHealth(frame)

	frame:SetAttribute("initial-width", width)
	frame:SetAttribute("initial-height", height)
	-- set our left-click action
	frame:SetAttribute("type1", "target")
	frame:SetAttribute("*type1", "target")

	frame:Reset()

	-- set up click casting
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[frame] = true
end

function GridFramePrototype:EnableMouseoverHighlight(enabled)
	self:SetHighlightTexture(enabled and "Interface\\QuestFrame\\UI-QuestTitleHighlight" or nil)
end

function GridFramePrototype:Reset()
	if not InCombatLockdown() then
		self:SetSize(Grid2Frame:GetFrameSize())
		self:EnableMouseoverHighlight(Grid2Frame.db.profile.mouseoverHighlight)
	end
end

-- shows the default unit tooltip
function GridFramePrototype:OnEnter()
	local st = Grid2Frame.db.profile.showTooltip
	if st == "Always" or
		(st == "OOC" and
			(not InCombatLockdown() or
				(self.unit and UnitIsDeadOrGhost(self.unit)))) then

		UnitFrame_OnEnter(self)
--		self:SetScript("OnUpdate", UnitFrame_OnUpdate)
	else
		self:OnLeave()
	end
end

function GridFramePrototype:OnLeave()
	UnitFrame_OnLeave(self)
--	self:SetScript("OnUpdate", nil)
end

function GridFramePrototype:LayoutIndicators()
	for _, indicator in Grid2:IterateIndicators() do
		indicator:Layout(self)
	end
	Grid2:InterleaveHealsHealth(self)
end

-- SetPoint for lazy people
function GridFramePrototype:SetPosition(parentFrame, x, y)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
end

--}}}

--{{{ Grid2Frame

Grid2Frame = Grid2:NewModule("Grid2Frame")

--{{{  AceDB defaults

Grid2Frame.defaultDB = {
	profile = {
		frameHeight = 36,
		frameWidth = 56,
		frameBorder = 2,
		debug = false,
		mouseoverHighlight = true,
		showTooltip = "OOC",
		orientation = "VERTICAL",
		textOrientation = "VERTICAL",
		intensity = 0.5,
	},
}

--}}}

function Grid2Frame:OnInitialize()
	self.core.defaultModulePrototype.OnInitialize(self)
	self.debugging = self.db.profile.debug

	self.registeredFrames = {}
end

function Grid2Frame:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrameUnits")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UNIT_EXITED_VEHICLE")
	self:RegisterMessage("Grid_UnitUpdate", "Grid_UnitUpdate")
	self:ResetAllFrames()
	self:UpdateFrameUnits()
	self:UpdateAllFrames()
end

function Grid2Frame:OnDisable()
	self:Debug("OnDisable")
	-- should probably disable and hide all of our frames here
end

function Grid2Frame:Reset()
	self.core.defaultModulePrototype.Reset(self)
	self:ResetAllFrames()
	self:UpdateFrameUnits()
	self:UpdateAllFrames()
end

function Grid2Frame:RegisterFrame(frame)
	self:Debug("RegisterFrame", frame:GetName())

	GridFrame_Init(frame, self:GetFrameSize())
	self.registeredFrames[frame:GetName()] = frame
end

function Grid2Frame:WithAllFrames(func, ...)
	for _, frame in next, self.registeredFrames do
		func(frame, ...)
	end
end

do
	local reset_handler = function (f) f:Reset() end
	function Grid2Frame:ResetAllFrames()
		self:WithAllFrames(reset_handler)
		self:SendMessage("Grid_UpdateLayoutSize")
	end
end

do
	local resize_handler = function (f, w, h)
		f:SetSize(w, h)
	end
	function Grid2Frame:ResizeAllFrames()
		self:WithAllFrames(resize_handler, self:GetFrameSize())
		self:SendMessage("Grid_UpdateLayoutSize")
	end
end

do
	local update_handler = function (f)
		Grid2Frame:UpdateIndicators(f)
	end
	function Grid2Frame:UpdateAllFrames()
		self:WithAllFrames(update_handler)
	end
end

function Grid2Frame:GetFrameSize()
	local p = self.db.profile
	return p.frameWidth, p.frameHeight
end

function Grid2Frame:UpdateIndicators(frame)
	local unit = frame.unit
	if not unit then return end

	for _, indicator in self.core:IterateIndicators() do
		indicator:Update(frame, unit)
	end
end

--{{{ Event handlers
local next = next
function Grid2Frame:UpdateFrameUnits()
	for frameName, frame in next, self.registeredFrames do
		local old_unit = frame.unit
		local unit = SecureButton_GetModifiedUnit(frame)
		if old_unit ~= unit then
			Grid2:SetFrameUnit(frame, unit)
			frame.unit = unit
			self:UpdateIndicators(frame)
		end
	end
end

function Grid2Frame:UNIT_ENTERED_VEHICLE(_, unit)
	for frame in next, Grid2:GetUnitFrames(unit) do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		if old ~= new then
			Grid2:SetFrameUnit(frame, new)
			frame.unit = new
			self:UpdateIndicators(frame)
		end
	end
end

function Grid2Frame:UNIT_EXITED_VEHICLE(_, unit)
	local pet = Grid2:GetPetUnitidByUnitid(unit) or unit
assert(pet, "Grid2Frame:UNIT_EXITED_VEHICLE nil pet for unit: " .. tostring(unit))
	for frame in next, Grid2:GetUnitFrames(pet) do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		if old ~= new then
			Grid2:SetFrameUnit(frame, new)
			frame.unit = new
			self:UpdateIndicators(frame)
		end
	end
end

function Grid2Frame:Grid_UnitUpdate(_, unit)
	for frame in next, Grid2:GetUnitFrames(unit) do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		if old ~= new then
			Grid2:SetFrameUnit(frame, new)
			frame.unit = new
		end
		self:UpdateIndicators(frame)
	end
end

--}}}

--{{ Debugging

function Grid2Frame:ListRegisteredFrames()
	print("--[ BEGIN Registered Frame List ]--")
	print("FrameName", "UnitId", "UnitName", "Status")
	for frameName, frame in pairs(self.registeredFrames) do
		local frameStatus

		if frame:IsVisible() then
			frameStatus = "|cff00ff00visible|r"
		elseif frame:IsShown() then
			frameStatus = "|cff00ff00shown|r"
		else
			frameStatus = "|cffff0000hidden|r"
		end

		print(
			(frameName == frame:GetName() and "|cff00ff00" or "|cffff0000")
				..frameName.."|r",
			(frame.unit == frame:GetAttribute("unit") and "|cff00ff00" or "|cffff0000")
				..(frame.unit or "nil").."|r",
				"|cff00ff00"..(frame.unit and UnitName(frame.unit) or "nil").."|r",
			frameStatus)
	end
	print("--[ END Registered Frame List ]--")
end

--}}}
_G.Grid2Frame = Grid2Frame
-- Allow other modules/addons to easily modify the grid unit frames
Grid2Frame.Events = GridFrameEvents
Grid2Frame.Prototype = GridFramePrototype
