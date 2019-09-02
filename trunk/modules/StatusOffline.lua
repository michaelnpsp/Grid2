local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local GetTime = GetTime
local UnitIsConnected = UnitIsConnected

local offline = setmetatable({}, {__index = function(t,u) local v= not UnitIsConnected(u); t[u]=v; return v end})

-- Blizzard connection API is completelly bugged, this is a mess, behavior at 2019/09/01:
-- We ignore UnitIsConnected() when possible (because can return wrong values, for example true if recently disconnected & in raid)
-- We only use UnitIsConnected() if the unit is new, and we have not previous data cached about the connection status.
-- UNIT_CONNECTION fires erratically, usually only whe a player is far away, so we have to rely on PARTY_MEMBER_ENABLE & PARTY_MEMBER_DISABLE too
-- PARTY_MEMBER_ENABLE & PARTY_MEMBER_DISABLE fire when a player dies, or disconnects, but only if the player is near (visible range)
--  This two events are fired too when the player cross the UnitIsVisible() limit, ENABLE when a player becomes visible, DISABLE in reverse case.
--  We cannot use UnitIsConnected() inside ENABLE events (can returns wrong values too), so we use some heuristic:
--   On ENABLE  we assume the player is connected without any further check.
--   On DISABLE we check UnitIsConnected() (It does not work always, it seems only works in party, not in raid)
-- This heuristic does not detect all cases.
function Offline:UNIT_CONNECTION(event, unit, hasConnected)
	if Grid2:IsUnitNoPetInRaid(unit) then
		if event == 'UNIT_CONNECTION' then -- hasConnected is only available on this event
			self:SetConnected(unit, hasConnected)
		elseif event == 'PARTY_MEMBER_ENABLE' then -- always connected on this event.
			self:SetConnected(unit, true)
		elseif not UnitIsConnected(unit) then -- PARTY_MEMBER_DISABLE, this does not work always
			self:SetConnected(unit, false)
		end
	end
end

function Offline:Grid_UnitUpdated(_, unit)
	offline[unit] = nil
end

function Offline:Grid_UnitLeft(_, unit)
	offline[unit] = nil
end

function Offline:SetConnected(unit, connected)
	if offline[unit] ~= not connected then
		if connected then
			offline[unit] = false
		else
			offline[unit] = GetTime()
		end
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
