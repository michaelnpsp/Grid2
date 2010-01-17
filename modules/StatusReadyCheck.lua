-- Original Grid Version: Greltok

local ReadyCheck = Grid2.statusPrototype:new("ready-check")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local readyChecking, timerClearStatus
local readyStatuses = {}

ReadyCheck.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = 0, a = 1 },
		color2 = { r = 0, g = 1, b = 0, a = 1 },
		color3 = { r = 1, g = 0, b = 0, a = 1 },
		color4 = { r = 1, g = 0, b = 0, a = 1 },
		threshold = 10,
	}
}

function ReadyCheck:READY_CHECK(event, originator)
    if IsRaidLeader() or IsRaidOfficer() or IsPartyLeader() then
        if timerClearStatus then
			Grid2:CancelTimer(timerClearStatus, true)
			timerClearStatus = nil
		end
        readyChecking = true

        for _, unit in Grid2:IterateRoster() do
			readyStatuses[unit] = GetReadyCheckStatus(unit)
        	if not Grid2:UnitIsPet(unit) then
				self:UpdateIndicators(unit)
            end
        end
    end
end

function ReadyCheck:READY_CHECK_CONFIRM(event, unit)
    if readyChecking then
		self:UpdateIndicators(unit)
    end
end

function ReadyCheck:READY_CHECK_FINISHED()
    for _, unit in Grid2:IterateRoster() do
        if not Grid2:UnitIsPet(unit) then
			self:UpdateIndicators(unit)
        end
    end
    timerClearStatus = Grid2:ScheduleTimer(self.ClearStatus, ReadyCheck.db.profile.threshold or 0, self)
end

function ReadyCheck:RAID_ROSTER_UPDATE()
    -- If you lose raid assist, you may not receive the READY_CHECK_FINISHED event.
    if (GetNumRaidMembers() > 0) then
        local newAssist = IsRaidLeader() or IsRaidOfficer()
        if readyChecking and not newAssist then
			self:ClearStatus()
        end
    end
end

function ReadyCheck:CheckClearStatus()
    -- Unfortunately, GetReadyCheckTimeLeft() only returns integral values.
    if readyChecking and GetReadyCheckTimeLeft() <= 0 then
			self:ClearStatus()
    end
end

function ReadyCheck:ClearStatus()
	if readyChecking then
		readyChecking = nil
		for _, unit in Grid2:IterateRoster() do
			self:UpdateIndicators(unit)
		end
		timerClearStatus = nil
	end
end


function ReadyCheck:OnEnable()
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "CheckClearStatus")
	self:RegisterMessage("Grid_GroupTypeChanged", "CheckClearStatus")
end

function ReadyCheck:OnDisable()
	self:ClearStatus()
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_GroupTypeChanged")
end

function ReadyCheck:IsActive(unit)
	return readyChecking
end

function ReadyCheck:GetReadyCheckStatus(unit)
	if not readyChecking then return end
	local state = GetReadyCheckStatus(unit)
	if not state then
		--we're in the window where we need to persist the readystate
		state = readyStatuses[unit]
		--with the blizz UI, if a player is AFK then they will display blank
		-- while everyone else is tick / cross. Emulate that here
		if state == "waiting" then state = "afk" end
	else
		readyStatuses[unit] = state
	end
	return state
end

local colors = {
    waiting =  "color1",
    ready = "color2",
    notready = "color3",
    afk = "color4",
}
function ReadyCheck:GetColor(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		local color = self.db.profile[colors[state]]
		return color.r, color.g, color.b, color.a
	end
end

local icons = {
    waiting =  READY_CHECK_WAITING_TEXTURE,
    ready = READY_CHECK_READY_TEXTURE,
    notready = READY_CHECK_NOT_READY_TEXTURE,
    afk = READY_CHECK_AFK_TEXTURE,
}
function ReadyCheck:GetIcon(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		return icons[state]
	end
end

local texts = {
    waiting =  L["?"],
    ready = L["R"],
    notready = L["X"],
    afk = L["AFK"],
}
function ReadyCheck:GetText(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		return texts[state]
	end
end

Grid2:RegisterStatus(ReadyCheck, { "color", "icon", "text" })

--[[
local function getstatuscolor(key)
    local color = GridStatusReadyCheck.db.profile.ready_check.colors[key]
    return color.r, color.g, color.b, color.a
end

local function setstatuscolor(key, r, g, b, a)
    local color = GridStatusReadyCheck.db.profile.ready_check.colors[key]
    color.r = r
    color.g = g
    color.b = b
    color.a = a or 1
    color.ignore = true
end

--{{{ additional options
local readyCheckOptions = {
    ["waiting"] = {
        type = "color",
        name = L["Waiting color"],
        desc = L["Color for Waiting."],
        order = 86,
        hasAlpha = true,
        get = function () return getstatuscolor("waiting") end,
        set = function (r, g, b, a) setstatuscolor("waiting", r, g, b, a) end,
    },
    ["ready"] = {
        type = "color",
        name = L["Ready color"],
        desc = L["Color for Ready."],
        order = 87,
        hasAlpha = true,
        get = function () return getstatuscolor("ready") end,
        set = function (r, g, b, a) setstatuscolor("ready", r, g, b, a) end,
    },
    ["notready"] = {
        type = "color",
        name = L["Not Ready color"],
        desc = L["Color for Not Ready."],
        order = 88,
        hasAlpha = true,
        get = function () return getstatuscolor("notready") end,
        set = function (r, g, b, a) setstatuscolor("notready", r, g, b, a) end,
    },
    ["afk"] = {
        type = "color",
        name = L["AFK color"],
        desc = L["Color for AFK."],
        order = 89,
        hasAlpha = true,
        get = function () return getstatuscolor("afk") end,
        set = function (r, g, b, a) setstatuscolor("afk", r, g, b, a) end,
    },
    ["delay"] = {
        type = "range",
        name = L["Delay"],
        desc = L["Set the delay until ready check results are cleared."],
        max = 10,
        min = 0,
        step = 1,
        get = function()
            return GridStatusReadyCheck.db.profile.ready_check.delay
        end,
        set = function(v)
            GridStatusReadyCheck.db.profile.ready_check.delay = v
        end,
    },

    ["color"] = false,
    ["range"] = false,
}
--}}}
--]]
