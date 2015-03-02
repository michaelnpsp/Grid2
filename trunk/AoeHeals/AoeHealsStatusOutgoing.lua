-- Status: Aoe-Heals

local AOEM = Grid2:GetModule("Grid2AoeHeals")

local Grid2 = Grid2
local next = next
local pairs = pairs
local select = select
local GetTime = GetTime

local playerGUID
local timer
local timerDelay = 2
local spells = {}
local icons = {}
local status_events
local statuses_enabled = {}

local defaultSpells = {
	SHAMAN  = { 1064, 73921, 127944 },     -- Chain Heal, Healing Rain, Tide Totem
	PRIEST  = { 34861, 23455, 88686, 64843 }, -- Circle of Healing, Holy Nova, Holy Word: Sanctuary, Divine Himn
	PALADIN = { 85222, 114871, 119952 },   -- Light of Dawn, Holy Prism, Arcing Light(Light Hammer's effect)
	DRUID   = { 81269, 740 }, 			   -- Wild Mushroom, Tranquility
	MONK    = { 124040, 130654, 124101, 132463, 115310 }, -- Chi Torpedo, Chi Burst, Zen Sphere: Detonate, Chi Wave, Revival
}

local function TimerEvent()
	local count = 0
	local time  = GetTime()
	for status in pairs(statuses_enabled) do
		local heal_cache = status.heal_cache
		local time_cache = status.time_cache
		for unit,expire in pairs(time_cache) do
			if time>=expire then
				heal_cache[unit] = nil
				time_cache[unit] = nil
				status:UpdateIndicators(unit)
			end
		end
		if next(status.time_cache) then
			count = count + 1
		end
	end	
	if count == 0 then
		Grid2:CancelTimer(timer)
		timer = nil
	end
end

local function CombatLogEvent(...)
	local spellName = select(14,...)
	local status = spells[spellName]
	if status then
		local subEvent = select(3,...)	
		if subEvent=="SPELL_HEAL" or subEvent=="SPELL_PERIODIC_HEAL" then
			local mine = status.mine
			if mine == nil or status.mine == (select(5,...)==playerGUID) then
				local unit = Grid2:GetUnitidByGUID( select(9,...) )
				if unit then
					local prev = status.heal_cache[unit]
					status.heal_cache[unit] = spellName
					status.time_cache[unit] = GetTime() + status.activeTime
					if prev~=spellName then
						status:UpdateIndicators(unit)
						if not timer then
							timer = Grid2:ScheduleRepeatingTimer(TimerEvent, timerDelay)
						end	
					end	
				end
			end
		end	
	end
end

local function OnEnable(self)
	if not next(statuses_enabled) then
		status_events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
	end
	statuses_enabled[self] = true
	self:UpdateDB()
end

local function OnDisable(self)
	wipe(self.heal_cache)
	wipe(self.time_cache)
	statuses_enabled[self] = nil
	if not next(statuses_enabled) then
		status_events:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end	
end

local function IsActive(self, unit)
	if self.heal_cache[unit] then return true end
end

local function GetColor(self, unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

local function GetIcon(self, unit)
	local spell = self.heal_cache[unit]
	if spell then return icons[ spell ] end	
end

local function GetText(self, unit)
	return self.heal_cache[unit]
end

local function UpdateDB(self)
	for key,status in pairs(spells) do
		if status == self then
			spells[key] = nil
		end
	end
	if self.dbx.spellList then
		for _,spell in next, self.dbx.spellList do
			local name,_,icon = GetSpellInfo(spell)
			if name then
				spells[name] = self
				icons[name]  = icon
			end
		end
	end	
	self.activeTime = self.dbx.activeTime or 2
	self.mine = self.dbx.mine -- mine => true (only mine spells) / false (not mine spells) / nil (any spell)
	timerDelay = math.max(0.1, math.min(timerDelay, self.activeTime / 4) )
end

Grid2.setupFunc["aoe-heals"] = function(baseKey, dbx)
	playerGUID = UnitGUID("player")
	local status = Grid2.statusPrototype:new(baseKey)
	status.defaultSpells = defaultSpells -- Used by Grid2Options
	status.heal_cache = {}
	status.time_cache = {}
	status.OnEnable = OnEnable
	status.OnDisable = OnDisable
	status.IsActive = IsActive
	status.GetColor = GetColor
	status.GetIcon = GetIcon
	status.GetText = GetText
	status.UpdateDB = UpdateDB
	if not status_events then 
		status_events = status
	end
	if not dbx.spellList then 
		dbx.spellList = defaultSpells[AOEM.playerClass] or {} 
	end	
	Grid2:RegisterStatus(status, {"color", "icon", "text"}, baseKey, dbx)
	return status
end

Grid2:DbSetStatusDefaultValue( "aoe-heals", {
	type = "aoe-heals",
	mine = true,
	activeTime = 2,
	color1 = {r=0,g=0.8,b=1,a=1}
})
