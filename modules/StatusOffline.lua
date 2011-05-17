local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local UnitIsConnected = UnitIsConnected
local UnitExists = UnitExists

-- UNIT_CONNECTION event seems bugged (not fired when player reconnect):
-- Using a timer to track when a offline unit reconnects.
local offline={}
local timer
local function tevent()
	for unit,_ in pairs(offline) do
		if UnitExists(unit) then
			if UnitIsConnected(unit) then
				Offline:UpdateIndicators(unit)
				offline[unit]= nil
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
		offline[unit]= true
		self:UpdateIndicators(unit)
		if not timer then
			timer= Grid2:ScheduleRepeatingTimer(tevent, 1)
		end	
	end
end

function Offline:OnEnable()
	self:RegisterEvent("UNIT_CONNECTION")
end

function Offline:OnDisable()
	self:UnregisterEvent("UNIT_CONNECTION")
	wipe(offline)
end

function Offline:IsActive(unit)
	return not UnitIsConnected(unit)
end

function Offline:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Offline:GetPercent(unit)
	return (not UnitIsConnected(unit)) and self.dbx.color1.a
end

local text= L["Offline"]
function Offline:GetText(unit)
	if not UnitIsConnected(unit) then
		return text
	end
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Offline, {"color", "percent", "text"}, baseKey, dbx)

	return Offline
end

Grid2.setupFunc["offline"] = Create
