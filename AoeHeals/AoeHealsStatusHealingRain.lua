-- Status: Aoe-HealingRain

local Grid2 = Grid2
local next = next
local select = select
local GetTime = GetTime
local GetSpellCooldown = GetSpellCooldown

local HealingRain
local playerGUID
local rainIcon
local spellName

local timer
local rain_cache = {}

local function TimerEvent()
	local ct = GetTime()
	if GetSpellCooldown(spellName)==0 then ct = ct + 10 end -- Hack to clear all indicators
	for unit,ut in next, rain_cache do
		if ct-ut>2 then
			rain_cache[unit] = nil
			HealingRain:UpdateIndicators(unit)
		end
	end
	if not next(rain_cache) then
		Grid2:CancelTimer(timer)
		timer = nil
	end
end

local function CombatLogEvent(...)
	if select(3,...)=="SPELL_HEAL" and select(13,...)==73921 and select(5,...)==playerGUID then
		local unit = Grid2:GetUnitidByGUID( select(9,...) )
		if unit then
			local prev = rain_cache[unit]
			rain_cache[unit] = GetTime()
			if not prev then
				HealingRain:UpdateIndicators(unit)
				if not timer then
					timer = Grid2:ScheduleRepeatingTimer(TimerEvent, 1)
				end	
			end	
		end
	end
end

local function OnEnable(self)
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
end

local function OnDisable(self)
	wipe(rain_cache)
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function IsActive(self, unit)
	if rain_cache[unit] then return true end
end

local function GetColor(self, unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

local function GetIcon(self, unit)
	return rainIcon
end

Grid2.setupFunc["aoe-HealingRain"] = function(baseKey, dbx)
	playerGUID            = UnitGUID("player")
	spellName,_,rainIcon  = GetSpellInfo(73921)
	HealingRain           = HealingRain or Grid2.statusPrototype:new("aoe-HealingRain")
	HealingRain.OnEnable  = OnEnable
	HealingRain.OnDisable = OnDisable
	HealingRain.IsActive  = IsActive
	HealingRain.GetColor  = GetColor
	HealingRain.GetIcon   = GetIcon
	Grid2:RegisterStatus(HealingRain, {"color", "icon"}, baseKey, dbx)
	return HealingRain
end
