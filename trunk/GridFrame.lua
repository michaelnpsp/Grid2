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
	if (name == "unit") then
		if (value) then
			local unitid = self:GetModifiedUnit()
			self.unit = unitid
			local unitGUID = UnitGUID(unitid)
--			self.unit = value
--			local unitGUID = UnitGUID(value)
			if (unitGUID ~= nil) then
				self.unitGUID = unitGUID
			end

			Grid2Frame:Debug("updated", self:GetName(), name, value, unitid, "unitGUID", unitGUID)
			Grid2Frame:UpdateIndicators(self)
		else
			Grid2Frame:Debug("removed", self:GetName(), name, self.unit, "unitGUID", unitGUID)

			self.unitGUID = nil
			self.unit = nil
		end
		Grid2:SetFrameUnit(self, value)
	elseif (name == "type1" and (not value or value == "")) then
--ToDo: when does this arise and does it need handling?
print("type1 set to target, value: <", value, "> ******")
		self:SetAttribute("type1", "target")
	elseif (name == "*type1" and (not value or value == "")) then
print("*type1 set to target, value: <", value, "> ******")
		self:SetAttribute("*type1", "target")
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

function GridFramePrototype:GetModifiedUnit()
	return SecureButton_GetModifiedUnit(self)
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
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrameUnits")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateFrameUnits")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateFrameUnits")
	self:RegisterMessage("Grid_RosterUpdated", "UpdateFrameUnits")
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
--print("RegisterFrame", frame:GetName())

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
--		if f.unit then
			Grid2Frame:UpdateIndicators(f)
--		end
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
	local unitid = frame:GetModifiedUnit()
--print("Grid2Frame:UpdateIndicators unitid", unitid)
	if (not unitid) then
		return
	end

	for _, indicator in self.core:IterateIndicators() do
		indicator:Update(frame, unitid)
	end
end

--{{{ Event handlers

function Grid2Frame:UpdateFrameUnits()
	for frameName, frame in pairs(self.registeredFrames) do
		local old_unit = frame.unit
		local unitid = frame:GetModifiedUnit()
		local unitGUID = unitid and UnitGUID(unitid) or nil
		local old_guid = frame.unitGUID
		if (old_unit ~= unitid or old_guid ~= unitGUID) then

--			local unitid = frame.unit
--			local unitGUID = unitid and UnitGUID(unitid) or nil
--			local old_guid = frame.unitGUID
--			if (old_guid ~= unitGUID) then

--				self:Debug("Updating", frame_name, "to", unitid, unitGUID, "was", old_unit, old_guid)
			if (unitid) then
				frame.unit = unitid
				frame.unitGUID = unitGUID

				if (unitGUID) then
					self:UpdateIndicators(frame)
				end
			else
				frame.unit = nil
				frame.unitGUID = nil

				frame:Reset() -- ToDo: is this right?
			end
		end
	end
end

--}}}

--{{ Debugging

function Grid2Frame:ListRegisteredFrames()
	print("--[ BEGIN Registered Frame List ]--")
	print("FrameName", "UnitId", "UnitName", "Status")
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

		print(
			frameName == frame:GetName() and
				"|cff00ff00"..frameName.."|r" or
				"|cffff0000"..frameName.."|r",
			frame.unit == frame:GetAttribute("unit") and
					"|cff00ff00"..(frame.unit or "nil").."|r" or
					"|cffff0000"..(frame.unit or "nil").."|r",
				"|cff00ff00"..(frame.unit and UnitName(frame.unit) or "nil").."|r",
			frame:GetAttribute("type1"),
			frame:GetAttribute("*type1"),
			frameStatus)
	end
	print("--[ END Registered Frame List ]--")
end

--}}}
_G.Grid2Frame = Grid2Frame
-- Allow other modules/addons to easily modify the grid unit frames
Grid2Frame.Events = GridFrameEvents
Grid2Frame.Prototype = GridFramePrototype
