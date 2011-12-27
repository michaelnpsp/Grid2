local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected
local next = next 

-- UNIT_CONNECTION event seems bugged (not fired when player reconnect):
-- Using a timer to track when a offline unit reconnects.
local offline={}
local timer
local function tevent()
	for unit in next,offline do
		if UnitExists(unit) then
			if UnitIsConnected(unit) then
				offline[unit]= nil
				Offline:UpdateIndicators(unit)
			end	
		else
			offline[unit]= nil
		end
	end
	if not next(offline) then
		Grid2:CancelTimer(timer)
		timer= nil
	end
end

function Offline:UNIT_CONNECTION(_, unit, hasConnected)
	if not hasConnected then
		self:UnitDisconnected(unit)
		self:UpdateIndicators(unit)
	end
end

function Offline:Grid_UnitJoined(_, unit)
	if not UnitIsConnected(unit) then
		self:UnitDisconnected(unit)
	end
end

function Offline:Grid_UnitLeft(_, unit)
	offline[unit] = nil
end

function Offline:OnEnable()
	self:RegisterEvent("UNIT_CONNECTION")
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitChanged", "Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitLeft")
end

function Offline:OnDisable()
	self:UnregisterEvent("UNIT_CONNECTION")
	self:UnregisterMessage("Grid_UnitChanged")
	self:UnregisterMessage("Grid_UnitJoined")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(offline)
end

function Offline:UnitDisconnected(unit)
	offline[unit] = true
	if not timer then
		timer= Grid2:ScheduleRepeatingTimer(tevent, 1)
	end	
end

function Offline:IsActive(unit)
	return offline[unit]
end

function Offline:GetColor(unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function Offline:GetPercent(unit)
	return self.dbx.color1.a
end

local text= L["Offline"]
function Offline:GetText(unit)
	return text
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Offline, {"color", "percent", "text"}, baseKey, dbx)

	return Offline
end

Grid2.setupFunc["offline"] = Create
