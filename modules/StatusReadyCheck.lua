-- Original Grid Version: Greltok

local ReadyCheck = Grid2.statusPrototype:new("ready-check")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local GetReadyCheckStatus = GetReadyCheckStatus

local readyChecking
local readyCount = 0
local readyStatuses = {}

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
	local units, count = Grid2:GetNonPetUnits()
	for i=1,count do
		self:UpdateIndicators(units[i])
	end
end

function ReadyCheck:READY_CHECK()
	readyChecking = true
	readyCount = readyCount + 1
	self:UpdatePlayerUnits()
end

function ReadyCheck:READY_CHECK_CONFIRM(_, unit)
	-- warning do not remove the line below (without this line Icons indicator fails for the last player because it delays the update 
	-- to the next frame OnUpdate() when ReadyCheck has already finished and GetReadyCheckStatus() inside GetIcon() or GetText() returns nil 
	readyStatuses[unit] = GetReadyCheckStatus(unit) 
	self:UpdateIndicators(unit)
end

function ReadyCheck:READY_CHECK_FINISHED()
	self:UpdatePlayerUnits()
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
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterMessage("Grid_UnitUpdated")
	wipe(readyStatuses)
	readyCount = readyCount + 1	
	readyChecking = nil
end

function ReadyCheck:IsActive(unit)
	return readyChecking
end

function ReadyCheck:GetReadyCheckStatus(unit)
	local state = GetReadyCheckStatus(unit)
	if state then
		readyStatuses[unit] = state
	else
		state = readyStatuses[unit] 
		if state == "waiting" then state = "afk" end
	end
	return state
end

local colors = { waiting = "color1", ready = "color2", notready = "color3", afk = "color4" }
function ReadyCheck:GetColor(unit)
	local state = self:GetReadyCheckStatus(unit)
	if state then
		local color = self.dbx[colors[state]]
		return color.r, color.g, color.b, color.a
	end
end

local icons = { waiting = READY_CHECK_WAITING_TEXTURE, ready = READY_CHECK_READY_TEXTURE, notready = READY_CHECK_NOT_READY_TEXTURE, afk = READY_CHECK_AFK_TEXTURE }
function ReadyCheck:GetIcon(unit)
	local state = self:GetReadyCheckStatus(unit)
	if state then
		return icons[state]
	end
end

local texts = { waiting = L["?"], ready = L["R"], notready = L["X"], afk = L["AFK"] }
function ReadyCheck:GetText(unit)
	local state = self:GetReadyCheckStatus(unit)
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
