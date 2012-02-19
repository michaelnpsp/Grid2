local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local next = next 
local UnitIsConnected = UnitIsConnected

-- UNIT_CONNECTION event seems bugged (not fired when player reconnect):
-- Using a timer to track when a offline unit reconnects.
local offline = {}
local timer
local function tevent()
	for unit in next,offline do
		if UnitIsConnected(unit) then
			offline[unit] = nil
			Offline:UpdateIndicators(unit)
		end	
	end
	if not next(offline) then
		Grid2:CancelTimer(timer)
		timer = nil
	end
end

function Offline:UNIT_CONNECTION(_, unit, hasConnected)
	if not hasConnected then
		self:UnitDisconnected(unit)
		self:UpdateIndicators(unit)
	end
end

function Offline:Grid_UnitUpdated(_, unit)
	if UnitIsConnected(unit) then
		offline[unit] = nil
	else
		self:UnitDisconnected(unit)
	end
end

function Offline:Grid_UnitLeft(_, unit)
	offline[unit] = nil
end

function Offline:UnitDisconnected(unit)
	offline[unit] = true
	if not timer then timer = Grid2:ScheduleRepeatingTimer(tevent, 1) end	
end

function Offline:OnEnable()
	self:RegisterEvent("UNIT_CONNECTION")
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
end

function Offline:OnDisable()
	self:UnregisterEvent("UNIT_CONNECTION")
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(offline)
end

function Offline:IsActive(unit)
	return offline[unit]
end

local text = L["Offline"]
function Offline:GetText(unit)
	return text
end

function Offline:GetIcon()
	return "Interface\\CharacterFrame\\Disconnect-Icon"
end 

Offline.GetColor = Grid2.statusLibrary.GetColor
Offline.GetPercent = Grid2.statusLibrary.GetPercent

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Offline, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Offline
end

Grid2.setupFunc["offline"] = Create

Grid2:DbSetStatusDefaultValue( "offline", {type = "offline", color1 = {r=1,g=1,b=1,a=1}})
