-- Original Grid Version: Greltok

local ReadyCheck = Grid2.statusPrototype:new("ready-check")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local GetReadyCheckStatus = GetReadyCheckStatus

local readyChecking
local readyCount = 0
local readyStatuses = {}
local roster_players = Grid2.roster_players

function ReadyCheck:ClearStatusDelayed()
	readyCount = readyCount + 1
	local timerIndex = readyCount
	C_Timer.After( self.dbx.threshold or 0.01, function()
		if timerIndex==readyCount then -- do nothing if a new timer or readycheck was launched
			readyChecking = nil
			wipe(readyStatuses)
			self:UpdatePlayerUnits()
		end
	end )
end

function ReadyCheck:UpdatePlayerUnits()
	for unit in Grid2:IterateGroupedPlayers() do
		self:UpdateIndicators(unit)
	end
end

function ReadyCheck:READY_CHECK()
	readyChecking = true
	readyCount = readyCount + 1
	self:UpdatePlayerUnits()
end

function ReadyCheck:READY_CHECK_CONFIRM(_, unit)
	if readyChecking then
		readyStatuses[unit] = GetReadyCheckStatus(unit) -- warning do not remove this line (without this line Icons indicator fails for the last player because it delays the update
		self:UpdateIndicators(unit)                     -- to the next frame OnUpdate() when ReadyCheck has already finished and GetReadyCheckStatus() inside GetIcon() or GetText() returns nil
	end
end

function ReadyCheck:READY_CHECK_FINISHED()
	if readyChecking then
		self:UpdatePlayerUnits()
		self:ClearStatusDelayed()
	end
end

function ReadyCheck:PLAYER_REGEN_DISABLED()
	if readyChecking then
		readyChecking = nil
		wipe(readyStatuses)
		self:UpdatePlayerUnits()
	end
end

function ReadyCheck:Grid_UnitUpdated(_, unit)
	if readyChecking then
		readyStatuses[unit] = nil
	end
end

function ReadyCheck:OnEnable()
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterMessage("Grid_UnitUpdated")
	if self.dbx.clearInCombat then
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
	end
end

function ReadyCheck:OnDisable()
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterMessage("Grid_UnitUpdated")
	if self.dbx.clearInCombat then
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	end
	wipe(readyStatuses)
	readyCount = readyCount + 1
	readyChecking = nil
end

function ReadyCheck:IsActive(unit)
	return readyChecking and roster_players[unit]
end

function ReadyCheck:GetReadyCheckStatus(unit)
	local state = GetReadyCheckStatus(unit)
	if state then
		readyStatuses[unit] = state
		return state
	else
		state = readyStatuses[unit]
		return state~="waiting" and state or 'afk'
	end
end

local colors = { waiting = "color1", ready = "color2", notready = "color3", afk = "color4" }
function ReadyCheck:GetColor(unit)
	local state = self:GetReadyCheckStatus(unit)
	local color = self.dbx[ colors[state] ]
	return color.r, color.g, color.b, color.a
end

local icons = {
	waiting = "Interface\\RaidFrame\\ReadyCheck-Waiting",
	ready = "Interface\\RaidFrame\\ReadyCheck-Ready",
	notready = "Interface\\RaidFrame\\ReadyCheck-NotReady",
	afk = "Interface\\RaidFrame\\ReadyCheck-NotReady",
}

function ReadyCheck:GetIcon(unit)
	local state = self:GetReadyCheckStatus(unit)
	return icons[state]
end

local texts = { waiting = L["?"], ready = L["R"], notready = L["X"], afk = L["AFK"] }
function ReadyCheck:GetText(unit)
	local state = self:GetReadyCheckStatus(unit)
	return texts[state]
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(ReadyCheck, {"color", "icon", "text"}, baseKey, dbx)

	return ReadyCheck
end

Grid2.setupFunc["ready-check"] = Create

Grid2:DbSetStatusDefaultValue( "ready-check", {type = "ready-check", threshold = 10, colorCount = 4, color1 = {r=1,g=1,b=0,a=1}, color2 = {r=0,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}, color4 = {r=1,g=0,b=1,a=1}})
