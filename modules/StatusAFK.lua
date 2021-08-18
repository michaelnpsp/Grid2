--[[ afk status, created by Potje, modified by Michael ]]--

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local AFK = Grid2.statusPrototype:new("afk")

local Grid2 = Grid2
local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitIsAFK = UnitIsAFK

local afk_cache = setmetatable({}, {__index = function(t,k) local v=GetTime(); t[k]=v; return v end})

AFK.GetColor = Grid2.statusLibrary.GetColor

local function UpdateUnit(_, unit)
	if unit then
		if not UnitIsAFK(unit) then -- only clear cache, afk_cache is already assigned when metatable lookup fails in GetStartTime()
			afk_cache[ UnitGUID(unit) or 0 ] = nil
		end
		AFK:UpdateIndicators(unit)
	end
end

function AFK:ZONE_CHANGED_NEW_AREA()
	for unit in Grid2:IterateRosterUnits() do
		UpdateUnit(nil,unit)
	end
end

function AFK:OnEnable()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", UpdateUnit)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("READY_CHECK", "ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("READY_CHECK_FINISHED", "ZONE_CHANGED_NEW_AREA")
end

function AFK:OnDisable()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	wipe(afk_cache)
end

function AFK:IsActive(unit)
	return UnitIsAFK(unit)
end

function AFK:GetStartTime(unit)
	return afk_cache[ UnitGUID(unit) ]
end

local text = L["AFK"]
function AFK:GetText(unit)
	return text
end

local function CreateStatusAFK(baseKey, dbx)
	Grid2:RegisterStatus(AFK, {"color", "text"}, baseKey, dbx)
	return AFK
end

Grid2.setupFunc["afk"] = CreateStatusAFK

Grid2:DbSetStatusDefaultValue( "afk", {type = "afk",  color1= {r=1,g=0,b=0,a=1} } )
