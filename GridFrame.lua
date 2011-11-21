--[[ Created by Grid2 original authors, modified by Michael --]]


local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2= Grid2
local SecureButton_GetModifiedUnit = SecureButton_GetModifiedUnit
local UnitFrame_OnEnter= UnitFrame_OnEnter
local UnitFrame_OnLeave= UnitFrame_OnLeave

local Grid2Frame

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
				Grid2Frame:Debug("updated", self:GetName(), name, value, unit)
				self.unit = unit
				self:UpdateIndicators()
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
	Grid2Frame:OnFrameEnter(self)
end

function GridFrameEvents:OnLeave()
	Grid2Frame:OnFrameLeave(self)
end

--{{{ GridFramePrototype
local pairs= pairs
local GridFramePrototype = {}
local function GridFrame_Init(frame, width, height)
	for name, value in pairs(GridFramePrototype) do
		frame[name] = value
	end

	for event, handler in pairs(GridFrameEvents) do
		frame:SetScript(event, handler)
	end

	if frame:CanChangeAttribute() then
		frame:SetAttribute("initial-width", width)
		frame:SetAttribute("initial-height", height)
	end
	
	frame.container = frame:CreateTexture()

	frame:CreateIndicators()

	frame:Layout()

	-- set up click casting
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[frame] = true
end

function GridFramePrototype:Layout()
	local dbx= Grid2Frame.db.profile
	local w= dbx.frameWidth 
	local h= dbx.frameHeight
	-- external border controlled by the border indicator
	local r,g,b,a= self:GetBackdropBorderColor() 
	local frameBorder = dbx.frameBorder
	local borderTexture = Grid2:MediaFetch("border", dbx.frameBorderTexture, "Grid2 Flat")
	self:SetBackdrop({
		bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
		edgeFile = borderTexture, edgeSize = frameBorder,
		insets = {left = frameBorder, right = frameBorder, top = frameBorder, bottom = frameBorder},
	})
	self:SetBackdropBorderColor(r, g, b, a)
	-- inner border color (sure that is the inner border)
	local cf= dbx.frameColor
	self:SetBackdropColor( cf.r, cf.g, cf.b, cf.a )
	-- visible background 
	local container= self.container
	container:SetPoint("CENTER", self, "CENTER")
	-- visible background color
	local cb= dbx.frameContentColor
	container:SetVertexColor(cb.r, cb.g, cb.b, cb.a)
	-- shrink the background, to show part of the real frame background (that is behind) as a inner border.
	local inset= (dbx.frameBorder+dbx.frameBorderDistance)*2
	container:SetSize( w-inset, h-inset )
	-- visible background texture
	local texture = Grid2:MediaFetch("statusbar", dbx.frameTexture, "Gradient" )
	self.container:SetTexture(texture)
	--
	if not InCombatLockdown() then self:SetSize(w,h) end
	--
	self:SetHighlightTexture(dbx.mouseoverHighlight and "Interface\\QuestFrame\\UI-QuestTitleHighlight" or nil)
	-- Adjust indicators position to the new size
	for _, indicator in Grid2:IterateIndicators() do
		indicator:Layout(self)
	end
end

function GridFramePrototype:CreateIndicators()
	for _, indicator in Grid2:IterateIndicators() do
		indicator:Create(self)
	end
end

function GridFramePrototype:UpdateIndicators()
	local unit = self.unit
	if unit then
		for _, indicator in Grid2:IterateIndicators() do
			indicator:Update(self, unit)
		end
	end	
end

--{{{ Grid2Frame

Grid2Frame = Grid2:NewModule("Grid2Frame")

--{{{  AceDB defaults

Grid2Frame.defaultDB = {
	profile = {
		debug = false,
		frameHeight = 48,
		frameWidth  = 48,
		frameBorder = 2,
		frameBorderTexture = "Grid2 Flat",
		frameBorderDistance= 1,
		frameTexture = "Gradient",
		frameColor = { r=0, g=0, b=0, a=1 },
		frameContentColor= { r=0, g=0, b=0, a=1 },
		mouseoverHighlight = false,
		showTooltip = "OOC",
		orientation = "VERTICAL",
		textOrientation = "VERTICAL",
		intensity = 0.5,
	},
}

--}}}

--{{{  

function Grid2Frame:OnModuleInitialize()
	self.registeredFrames = {}
end

function Grid2Frame:OnModuleEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrameUnits")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UNIT_EXITED_VEHICLE")
	self:RegisterMessage("Grid_UnitUpdate", "Grid_UnitUpdate")
	self:UpdateFrameUnits()
	self:UpdateIndicators()
end

function Grid2Frame:OnModuleDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrameUnits")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE", "UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", "UNIT_EXITED_VEHICLE")
	self:UnregisterMessage("Grid_UnitUpdate", "Grid_UnitUpdate")
end

-- When profile changes, the modules reset sequence is: 
-- 1. Disable all modules  2. Update all modules 3. Enable all modules (see Grid2:ProfileChanged)
-- Grid2Layout uses the new frame size and can create/layout new frames when it is enabled, but could be 
-- enabled before Grid2Frame.  This is the reason because we recreate and relayout the indicators here.
function Grid2Frame:OnModuleUpdate()
	self:CreateIndicators()
	self:LayoutFrames()
end

--}}}

function Grid2Frame:RegisterFrame(frame)
	self:Debug("RegisterFrame", frame:GetName())
	GridFrame_Init(frame, self:GetFrameSize())
	self.registeredFrames[frame:GetName()] = frame
end

-- shows the default unit tooltip
local TooltipCheck= { Always= true, Never = false, OOC= function() return not InCombatLockdown() end }
function Grid2Frame:OnFrameEnter(frame)
	if TooltipCheck[self.db.profile.showTooltip] then
		UnitFrame_OnEnter(frame)
	else
		UnitFrame_OnLeave(frame)
	end
end

function Grid2Frame:OnFrameLeave(frame)
	UnitFrame_OnLeave(frame)
end

--}}}

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

function Grid2Frame:LayoutFrames()
	for name, frame in next, self.registeredFrames do
		frame:Layout()
	end
	self:SendMessage("Grid_UpdateLayoutSize")
end

function Grid2Frame:WithAllFrames(func, ...)
	for _, frame in next, self.registeredFrames do
		func(frame, ...)
	end
end

function Grid2Frame:GetFrameSize()
	local p= self.db.profile
	return p.frameWidth, p.frameHeight
end

--{{{ Event handlers
local next = next
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

function Grid2Frame:UNIT_ENTERED_VEHICLE(_, unit)
	for frame in next, Grid2:GetUnitFrames(unit) do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		if old ~= new then
			Grid2:SetFrameUnit(frame, new)
			frame.unit = new
			frame:UpdateIndicators()
		end
	end
end

function Grid2Frame:UNIT_EXITED_VEHICLE(_, unit)
	local pet = Grid2:GetPetUnitidByUnitid(unit) or unit
	for frame in next, Grid2:GetUnitFrames(pet) do
		local old, new = frame.unit, SecureButton_GetModifiedUnit(frame)
		if old ~= new then
			Grid2:SetFrameUnit(frame, new)
			frame.unit = new
			frame:UpdateIndicators()
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
		frame:UpdateIndicators()
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
