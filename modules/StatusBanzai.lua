-- Banzai status: tracks harmfull spells casted by hostile units over raid members ( created by Michael )

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Banzai = Grid2.statusPrototype:new("banzai")

local Grid2= Grid2
local GetTime= GetTime
local UnitGUID= UnitGUID
local UnitCastingInfo= UnitCastingInfo

local timer
local banzais_sources= {}
local banzais= {}
local banzais_guids= {}
local banzais_durations= {}
local banzais_expirations= {}

local function UpdateBanzais()
	local curTime= GetTime()
	for unit,guid in pairs(banzais) do
		if curTime>=banzais_expirations[unit] then
			banzais[unit], banzais_durations[unit], banzais_expirations[unit], banzais_guids[guid] = nil, nil, nil, nil
			Banzai:UpdateIndicators(unit)
		end
	end
	if next(banzais_sources) then
		for unit,_ in Grid2:IterateRosterUnits() do
			local sourceUnit= unit.."target"
			local sourceGUID= UnitGUID(sourceUnit)
			if sourceGUID and banzais_sources[sourceGUID] then
				local destGUID= UnitGUID(unit.."targettarget")
				if destGUID then
					local destUnit= Grid2:GetUnitidByGUID(destGUID)
					if destUnit then
						local endTime= select(6,UnitCastingInfo(sourceUnit))
						if endTime then
							endTime= endTime / 1000 
							banzais[destUnit]= sourceGUID
							banzais_durations[destUnit]= endTime - curTime
							banzais_expirations[destUnit]= endTime
							banzais_guids[sourceGUID] = destUnit
							Banzai:UpdateIndicators(destUnit)
						end
					end
				end	
				banzais_sources[sourceGUID]= nil
				if not next(banzais_sources) then return end	
			end
		end
		wipe(banzais_sources)
	end
end

local banzaiEvents={
	SPELL_CAST_START 		= true,
	SPELL_CAST_INTERRUPTED 	= false,
	SPELL_MISSED            = false,
	UNIT_DIED               = false,
}
function Banzai:COMBAT_LOG_EVENT_UNFILTERED(_,_,event, _, sourceGUID)
	local action= banzaiEvents[event]
	if action ~= nil then
		local unit= Grid2:GetUnitidByGUID(sourceGUID)
		if not unit then
			if action then
				banzais_sources[sourceGUID]= true
			else
				local unit= banzais_guids[sourceGUID]
				if unit then banzais_expirations[unit]= 0 end
			end
		end	
	end
end

function Banzai:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if not timer then
		timer= Grid2:ScheduleRepeatingTimer(UpdateBanzais, 0.1)
	end	
end

function Banzai:OnDisable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	wipe(banzais)
	wipe(banzais_guids)
	wipe(banzais_sources)
	wipe(banzais_durations)
	wipe(banzais_expirations)
	if timer then
		Grid2:CancelTimer(timer)
	end	
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

function Banzai:GetPercent(self, unit)
	local t= GetTime()
	return ((banzais_expirations[unit] or t) - t) / (banzais_durations[unit] or 1)
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
	Grid2:RegisterStatus(Banzai, {"color", "text", "percent" }, baseKey, dbx)

	return Banzai
end

Grid2.setupFunc["banzai"] = Create

