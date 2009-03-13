-- Grid2Frame.lua

--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")
local GridRange = GridRange
local Grid2Frame

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
		self.unit = value
		if value then
			Grid2Frame:Debug("updated", self:GetName(), name, value)
			Grid2Frame:UpdateIndicators(self)
		else
			Grid2Frame:Debug("removed", self:GetName(), name, value)
		end
		Grid2:SetFrameUnit(self, value)
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

	frame:SetBackdrop({
		bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
		edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	frame:SetBackdropBorderColor(0, 0, 0, 1)
	frame:SetBackdropColor(0, 0, 0, 1)

	frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

	for _, indicator in Grid2:IterateIndicators() do
		indicator:Create(frame)
	end

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

function GridFramePrototype:Reset()
	if not InCombatLockdown() then
		self:SetWidth(Grid2Frame:GetFrameWidth())
		self:SetHeight(Grid2Frame:GetFrameHeight())
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
		self:SetScript("OnUpdate", UnitFrame_OnUpdate)
	else
		self:OnLeave()
	end
end

function GridFramePrototype:OnLeave()
	UnitFrame_OnLeave(self)
	self:SetScript("OnUpdate", nil)
end

function GridFramePrototype:LayoutIndicators()
	for _, indicator in Grid2:IterateIndicators() do
		indicator:Layout(self)
	end
end

-- SetPoint for lazy people
function GridFramePrototype:SetPosition(parentFrame, x, y)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
end

function GridFramePrototype:SetBar(value, max)
	if max == nil then
		max = 100
	end
	self.Bar:SetValue(value/max*100)
end

--}}}

--{{{ Grid2Frame

Grid2Frame = Grid2:NewModule("Grid2Frame")

--{{{  AceDB defaults

Grid2Frame.defaultDB = {
	profile = {
		frameHeight = 36,
		frameWidth = 56,
		debug = false,
		showTooltip = "OOC",
	},
}

--}}}

function Grid2Frame:OnInitialize()
	self.core.defaultModulePrototype.OnInitialize(self)
	self.debugging = self.db.profile.debug

	self.frames = {}
	self.registeredFrames = {}
end

function Grid2Frame:OnEnable()
	self:RegisterMessage("Grid_StatusGained", "UpdateUnitFrame")
	self:RegisterMessage("Grid_StatusLost", "UpdateUnitFrame")
	self:ResetAllFrames()
	self:UpdateAllFrames()
end

function Grid2Frame:OnDisable()
	self:Debug("OnDisable")
	-- should probably disable and hide all of our frames here
end

function Grid2Frame:Reset()
	self.core.defaultModulePrototype.Reset(self)
	self:ResetAllFrames()
	self:UpdateAllFrames()
end

function Grid2Frame:RegisterFrame(frame)
	self:Debug("RegisterFrame", frame:GetName())

	GridFrame_Init(frame, self:GetFrameWidth(), self:GetFrameHeight())
	self.registeredFrames[frame:GetName()] = frame
end

function Grid2Frame:WithAllFrames(func, ...)
	for _, frame in pairs(self.registeredFrames) do
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
		f:SetWidth(w)
		f:SetHeight(h)
	end
	function Grid2Frame:ResizeAllFrames()
		local w, h = self:GetFrameWidth(), self:GetFrameHeight()
		self:WithAllFrames(resize_handler, w, h)
		self:SendMessage("Grid_UpdateLayoutSize")
	end
end

do
	local update_handler = function (f)
		if f.unit then
			Grid2Frame:UpdateIndicators(f)
		end
	end
	function Grid2Frame:UpdateAllFrames()
		self:WithAllFrames(update_handler)
	end
end

function Grid2Frame:GetFrameWidth()
	return self.db.profile.frameWidth
end

function Grid2Frame:GetFrameHeight()
	return self.db.profile.frameHeight
end

function Grid2Frame:UpdateIndicators(frame)
	local unitid = frame.unit or frame:GetAttribute("unit")
	if not unitid then return end

	for _, indicator in self.core:IterateIndicators() do
		indicator:Update(frame, unitid)
	end
end

--{{{ Event handlers

function Grid2Frame:UpdateUnitFrame()
	for _, frame in pairs(self.registeredFrames) do
		if frame.unit == unit then
			self:UpdateIndicators(frame)
		end
	end
end

--}}}

--{{ Debugging

function Grid2Frame:ListRegisteredFrames()
	self:Debug("--[ BEGIN Registered Frame List ]--")
	self:Debug("FrameName", "UnitId", "UnitName", "Status")
	for frameName, frame in pairs(self.registeredFrames) do
		local frameStatus = "|cff00ff00"

		if frame:IsVisible() then
			frameStatus = frameStatus .. "visible"
		elseif frame:IsShown() then
			frameStatus = frameStatus .. "shown"
		else
			frameStatus = "|cffff0000"
			frameStatus = frameStatus .. "hidden"
		end

		frameStatus = frameStatus .. "|r"

		self:Debug(
			frameName == frame:GetName() and
				"|cff00ff00"..frameName.."|r" or
				"|cffff0000"..frameName.."|r",
			frame.unit == frame:GetAttribute("unit") and
					"|cff00ff00"..(frame.unit or "nil").."|r" or
					"|cffff0000"..(frame.unit or "nil").."|r",
				"|cff00ff00"..(UnitName(frame.unit) or "nil").."|r",
			frame:GetAttribute("type1"),
			frame:GetAttribute("*type1"),
			frameStatus)
	end
	Grid2Frame:Debug("--[ END Registered Frame List ]--")
end

--}}}
_G.Grid2Frame = Grid2Frame
-- Allow other modules/addons to easily modify the grid unit frames
Grid2Frame.Events = GridFrameEvents
Grid2Frame.Prototype = GridFramePrototype
