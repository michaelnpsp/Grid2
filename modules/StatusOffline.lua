local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local next = next
local GetTime = GetTime
local UnitIsConnected = UnitIsConnected

-- cache management variables
local timer
local offline = {}

-- workaround to blizzard bugs
local function TimerEvent()
	local ct = GetTime()
	for unit,dt in next,offline do
		if UnitIsConnected(unit) and (ct-dt)>=25 then
			offline[unit] = nil
			Offline:UpdateIndicators(unit)
		end
	end
	if not next(offline) then
		timer = Grid2:CancelTimer(timer)
	end
end

-- set offline cache
local function SetOfflineCache(unit, off)
	if off then timer = timer or Grid2:CreateTimer(TimerEvent, 3) end
	offline[unit] = off and GetTime() or nil
end

-- Blizzard connection API is completelly bugged, this is a mess, behavior at 2019/09/21:
-- UNIT_CONNECTION fires erratically, usually only whe a player is far away, so we have to rely on PARTY_MEMBER_ENABLE & PARTY_MEMBER_DISABLE when in party
-- PARTY_MEMBER_ENABLE & PARTY_MEMBER_DISABLE fire when a player dies, or disconnects, but only if the player is near (visible range)
--  This two events are fired too when the player cross the UnitIsVisible() limit, ENABLE when a player becomes visible, DISABLE in reverse case.
--  We cannot use UnitIsConnected() inside ENABLE events (can returns wrong values too), so we use some heuristic:
--   On ENABLE  we assume the player is connected without any further check.
--   On DISABLE we check UnitIsConnected() (Only works in party, not in raid)
-- This heuristic does not detect all cases.
function Offline:UNIT_CONNECTION(event, unit, hasConnected)
	if Grid2:IsPlayerInRaid(unit) then
		if event == 'UNIT_CONNECTION' then -- hasConnected is only available on this event
			self:SetOffline(unit, not hasConnected)
		elseif event == 'PARTY_MEMBER_ENABLE' then -- always connected on this event.
			self:SetOffline(unit, false)
		elseif not UnitIsConnected(unit) then -- PARTY_MEMBER_DISABLE
			self:SetOffline(unit, true)
		end
	end
end

function Offline:Grid_UnitUpdated(_, unit)
	SetOfflineCache(unit, not UnitIsConnected(unit))
end

function Offline:Grid_UnitLeft(_, unit)
	offline[unit] = nil
end

function Offline:SetOffline(unit, off)
	if not offline[unit] == off then
		SetOfflineCache(unit, off)
		self:UpdateIndicators(unit)
	end
end

function Offline:OnEnable()
	self:RegisterEvent("UNIT_CONNECTION")
	self:RegisterEvent('PARTY_MEMBER_ENABLE',  'UNIT_CONNECTION')
	self:RegisterEvent('PARTY_MEMBER_DISABLE', 'UNIT_CONNECTION')
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
end

function Offline:OnDisable()
	self:UnregisterEvent("UNIT_CONNECTION")
	self:UnregisterEvent('PARTY_MEMBER_ENABLE')
	self:UnregisterEvent('PARTY_MEMBER_DISABLE')
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(offline)
end

function Offline:IsActive(unit)
	return offline[unit]
end

function Offline:GetStartTime(unit)
	return offline[unit]
end

local text = L["Offline"]
function Offline:GetText(unit)
	return text
end

function Offline:GetPercent(unit)
	return self.dbx.color1.a, text
end

function Offline:GetTexCoord()
	return 0.2, 0.8, 0.2, 0.8
end

function Offline:GetIcon()
	return "Interface\\CharacterFrame\\Disconnect-Icon"
end

Offline.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Offline, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Offline
end

Grid2.setupFunc["offline"] = Create

Grid2:DbSetStatusDefaultValue( "offline", {type = "offline", color1 = {r=1,g=1,b=1,a=1}})
