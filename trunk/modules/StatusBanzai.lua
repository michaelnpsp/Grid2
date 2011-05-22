-- Banzai status: tracks harmfull spells casted by hostile units over raid members ( created by Michael )

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Banzai = Grid2.statusPrototype:new("banzai")

local Grid2= Grid2
local GetTime= GetTime
local UnitGUID= UnitGUID
local UnitCastingInfo= UnitCastingInfo
local UnitChannelInfo= UnitChannelInfo

local timer
local banzais_sources= {}
local banzais= {}
local banzais_guids= {}
local banzais_durations= {}
local banzais_expirations= {}
local banzais_icons= {}
local target = setmetatable({}, {__index = function(t,k) local v=k.."target" t[k]=v return v end})

--{{ Combat Log
local function StopCast(guid)
	banzais_sources[guid]= nil
	local unit= banzais_guids[guid]
	if unit then banzais_expirations[unit]= 0 end
end

local banzaiEvents={
	SPELL_CAST_START 		= function(guid) banzais_sources[guid]= UnitCastingInfo end,
	SPELL_CAST_SUCCESS      = function(guid) banzais_sources[guid]= UnitChannelInfo end,
	SPELL_CAST_INTERRUPTED 	= StopCast,
	SPELL_MISSED            = StopCast,
	UNIT_DIED               = StopCast,
}

function Banzai:COMBAT_LOG_EVENT_UNFILTERED(_,_,event,_,sourceGUID)
	local action= banzaiEvents[event]
	if action then 
		local unit= Grid2:GetUnitidByGUID(sourceGUID)
		if not unit then action(sourceGUID) end	
	end	
end
--}}

--{{ Checks target and targettarget of focus and roster units, looking for banzais sources and destinations
local defaultIcon= "Interface\\ICONS\\Ability_Creature_Cursed_02"
local curTime
local function CheckBanzaiUnit(unit)
	local sourceUnit= target[unit]
	local sourceGUID= UnitGUID(sourceUnit)
	if sourceGUID then
		local funcSpellInfo= banzais_sources[sourceGUID]
		if funcSpellInfo then
			local destGUID= UnitGUID(target[sourceUnit])
			if destGUID then
				local destUnit= Grid2:GetUnitidByGUID(destGUID)
				if destUnit then
					local icon, _, endTime= select(4,funcSpellInfo(sourceUnit))
					endTime= endTime and endTime/1000 or curTime+0.5 
					banzais[destUnit]= sourceGUID
					banzais_durations[destUnit]= endTime - curTime
					banzais_expirations[destUnit]= endTime
					banzais_guids[sourceGUID]= destUnit
					banzais_icons[destUnit] = icon or defaultIcon
					Banzai:UpdateIndicators(destUnit)
				end
			end	
			banzais_sources[sourceGUID]= nil
			if not next(banzais_sources) then return true end	
		end	
	end
end

local function UpdateBanzais()
	curTime= GetTime()
	-- Delete expired banzais
	for unit,guid in pairs(banzais) do
		if curTime>=banzais_expirations[unit] then
			banzais[unit], banzais_durations[unit], banzais_icons[unit], banzais_expirations[unit], banzais_guids[guid] = nil, nil, nil, nil, nil
			Banzai:UpdateIndicators(unit)
		end
	end
	-- Look for new banzais
	if next(banzais_sources) then
		if not CheckBanzaiUnit("focus") then 
			for unit,_ in Grid2:IterateRosterUnits() do
				if CheckBanzaiUnit(unit) then 
					return 
				end
			end
			wipe(banzais_sources)
		end	
	end
end
--}}

function Banzai:PLAYER_REGEN_DISABLED()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if not timer then
		timer= Grid2:ScheduleRepeatingTimer(UpdateBanzais, self.dbx.updateRate or 0.1)
	end	
end

function Banzai:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if timer then
		Grid2:CancelTimer(timer)
		timer= nil
	end	
	self:ClearBanzais()
end

function Banzai:ClearBanzais()
	wipe(banzais_guids)
	wipe(banzais_sources)
	wipe(banzais_durations)
	wipe(banzais_expirations)
	wipe(banzais_icons)
	for unit,_ in pairs(banzais) do
		banzais[unit]= nil
		Banzai:UpdateIndicators(unit)
	end
end

function Banzai:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function Banzai:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function Banzai:IsActive(unit)
	return banzais[unit] and true
end

function Banzai:GetDuration(unit)
	return banzais_durations[unit]
end

function Banzai:GetExpirationTime(unit)
	return banzais_expirations[unit]
end

function Banzai:GetPercent(unit)
	local t= GetTime()
	return ((banzais_expirations[unit] or t) - t) / (banzais_durations[unit] or 1)
end

function Banzai:GetIcon(unit)
	return banzais_icons[unit]
end

function Banzai:GetColor(unit)
	local c= self.dbx.color1
	return c.r, c.g, c.b, c.a
end

local textBanzai= L["banzai"]
function Banzai:GetText(unit)
	return textBanzai
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Banzai, {"color", "text", "percent", "icon" }, baseKey, dbx)

	return Banzai
end

Grid2.setupFunc["banzai"] = Create
