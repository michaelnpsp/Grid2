-- Original Grid Version: Greltok

local ReadyCheck = Grid2.statusPrototype:new("ready-check")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local checkStatus = {}
local readyChecking, raidAssist, timerClearStatus


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
    if (raidAssist or IsPartyLeader()) then
        Grid2:CancelTimer(timerClearStatus, true)
		timerClearStatus = nil
        readyChecking = true
        local originatorguid = Grid2:GetGUIDByFullName(originator)

        for guid, unitid in Grid2:IterateRoster() do
            if (not Grid2:GetOwnerUnitidByGUID(guid)) then
                if (guid ~= originatorguid) then
                    checkStatus[unitid] = "waiting"
                else
                    checkStatus[unitid] = "ready"
                end
				self:UpdateIndicators(unitid)
            end
        end
    end
end

function ReadyCheck:READY_CHECK_CONFIRM(event, id, confirm)
    if (readyChecking) then
        local unitid = ((GetNumRaidMembers() > 0) and ("raid"..id)) or ("party"..id)
        if (confirm == 1) then
            checkStatus[unitid] = "ready"
        else
            checkStatus[unitid] = "not_ready"
        end
		self:UpdateIndicators(unitid)
    end
end

function ReadyCheck:READY_CHECK_FINISHED()
    for guid, unitid in Grid2:IterateRoster() do
        if (not Grid2:GetOwnerUnitidByGUID(guid)) then
            if (checkStatus[unitid] == "waiting") then
                checkStatus[unitid] = "afk"
            end
        end
		self:UpdateIndicators(unitid)
    end
    timerClearStatus = Grid2:ScheduleTimer(self.ClearStatus, ReadyCheck.db.profile.threshold or 0, self)
end

function ReadyCheck:PARTY_LEADER_CHANGED()
    -- If you change party leader, you may not receive the READY_CHECK_FINISHED event.
    self:CheckClearStatus()
end

function ReadyCheck:RAID_ROSTER_UPDATE()
    -- If you lose raid assist, you may not receive the READY_CHECK_FINISHED event.
    if (GetNumRaidMembers() > 0) then
        local newAssist = IsRaidLeader() or IsRaidOfficer()
        if (readyChecking and newAssist ~= raidAssist) then
            timerClearStatus = Grid2:ScheduleTimer(self.ClearStatus, 0, self)
        end
        raidAssist = newAssist
    else
        raidAssist = nil
    end
end

function ReadyCheck:Grid_GroupTypeChanged(current_state, old_state)
    -- If you leave the group, you may not receive the READY_CHECK_FINISHED event.
    self:CheckClearStatus()
end

function ReadyCheck:CheckClearStatus()
    -- Unfortunately, GetReadyCheckTimeLeft() only returns integral values.
    if (readyChecking and GetReadyCheckTimeLeft() == 0) then
        timerClearStatus = Grid2:ScheduleTimer(self.ClearStatus, 0, self)
    end
end

function ReadyCheck:ClearStatus()
    readyChecking = nil
    wipe(checkStatus)
	for guid, unitid in Grid2:IterateRoster() do
		self:UpdateIndicators(unitid)
	end
end


function ReadyCheck:OnEnable()
	self:RegisterEvent("READY_CHECK", "READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM", "READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED", "READY_CHECK_FINISHED")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "PARTY_LEADER_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "RAID_ROSTER_UPDATE")
	self:RegisterMessage("Grid_GroupTypeChanged", "Grid_GroupTypeChanged")
end

function ReadyCheck:OnDisable()
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_GroupTypeChanged")
	Grid2:CancelTimer(timerClearStatus, true)
	timerClearStatus = nil
end

function ReadyCheck:IsActive(unitid)
	return checkStatus[unitid]
end

local colors = {
    waiting =  "color1",
    ready = "color2",
    not_ready = "color3",
    afk = "color4",
}
function ReadyCheck:GetColor(unitid)
	local state = checkStatus[unitid]
	if (state) then
	local color = self.db.profile[colors[state]]
		return color.r, color.g, color.b, color.a
	end
end

local icons = {
    waiting =  READY_CHECK_WAITING_TEXTURE,
    ready = READY_CHECK_READY_TEXTURE,
    not_ready = READY_CHECK_NOT_READY_TEXTURE,
    afk = READY_CHECK_AFK_TEXTURE,
}
function ReadyCheck:GetIcon(unitid)
	local state = checkStatus[unitid]
	if (state) then
		return icons[state]
	end
end

local texts = {
    waiting =  L["?"],
    ready = L["R"],
    not_ready = L["X"],
    afk = L["AFK"],
}
function ReadyCheck:GetText(unitid)
	local state = checkStatus[unitid]
	if (state) then
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
    ["not_ready"] = {
        type = "color",
        name = L["Not Ready color"],
        desc = L["Color for Not Ready."],
        order = 88,
        hasAlpha = true,
        get = function () return getstatuscolor("not_ready") end,
        set = function (r, g, b, a) setstatuscolor("not_ready", r, g, b, a) end,
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