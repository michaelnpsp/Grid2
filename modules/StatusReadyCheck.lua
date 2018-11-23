-- Original Grid Version: Greltok

local ReadyCheck = Grid2.statusPrototype:new("ready-check")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local GetReadyCheckStatus = GetReadyCheckStatus

local readyChecking
local readyStatuses = {}

local readyCount    = 0
function ReadyCheck:ClearStatusDelayed()
	readyCount = readyCount + 1
	local timerIndex = readyCount
	C_Timer.After( self.dbx.threshold or 0.01, function() if timerIndex==readyCount then self:ClearStatus() end end ) -- check to cancel a previous timer if a new timer is launched
end

function ReadyCheck:ClearStatus()
	if readyChecking then
		readyChecking = nil
		wipe(readyStatuses)
		self:UpdateAllUnits()
	end
end

function ReadyCheck:UpdateNonPetUnits()
	local units, count = Grid2:GetNonPetUnits()
	for i=1,count do
		self:UpdateIndicators(units[i])
	end
end

function ReadyCheck:READY_CHECK()
	readyChecking = true
	local units, count = Grid2:GetNonPetUnits()
	for i=1,count do
		local unit = units[i]
		readyStatuses[unit] = GetReadyCheckStatus(unit)
		self:UpdateIndicators(unit)
	end
end

function ReadyCheck:READY_CHECK_CONFIRM(event, unit)
	if readyChecking then
		self:UpdateIndicators(unit)
	end
end

function ReadyCheck:READY_CHECK_FINISHED()
	readyChecking = true
	self:UpdateNonPetUnits()
	self:ClearStatusDelayed()
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
end

function ReadyCheck:OnDisable()
	self:ClearStatus()
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterMessage("Grid_UnitUpdated")
end

function ReadyCheck:IsActive(unit)
	return readyChecking
end

function ReadyCheck:GetReadyCheckStatus(unit)
	if readyChecking then
		local state = GetReadyCheckStatus(unit)
		if state then
			readyStatuses[unit] = state
		else
			state = readyStatuses[unit] -- we're in the window where we need to persist the readystate
			if state == "waiting" then state = "afk" end -- if a player is AFK then they will display blank while everyone else is tick / cross
		end
		return state
	end	
end

local colors = { waiting = "color1", ready = "color2", notready = "color3", afk = "color4" }
function ReadyCheck:GetColor(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		local color = self.dbx[colors[state]]
		return color.r, color.g, color.b, color.a
	end
end

local icons = { waiting = READY_CHECK_WAITING_TEXTURE, ready = READY_CHECK_READY_TEXTURE, notready = READY_CHECK_NOT_READY_TEXTURE, afk = READY_CHECK_AFK_TEXTURE }
function ReadyCheck:GetIcon(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		return icons[state]
	end
end

local texts = { waiting = L["?"], ready = L["R"], notready = L["X"], afk = L["AFK"] }
function ReadyCheck:GetText(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		return texts[state]
	end
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(ReadyCheck, {"color", "icon", "text"}, baseKey, dbx)

	return ReadyCheck
end

Grid2.setupFunc["ready-check"] = Create

Grid2:DbSetStatusDefaultValue( "ready-check", {type = "ready-check", threshold = 10, colorCount = 4, color1 = {r=1,g=1,b=0,a=1}, color2 = {r=0,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}, color4 = {r=1,g=0,b=1,a=1}})
