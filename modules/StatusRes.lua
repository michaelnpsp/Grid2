-- Resurrection status, created by Michael --

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Resurrection = Grid2.statusPrototype:new("resurrection")

local Grid2= Grid2
local GetTime= GetTime
local UnitExists= UnitExists
local UnitIsDeadOrGhost= UnitIsDeadOrGhost
local UnitHasIncomingResurrection= UnitHasIncomingResurrection
local next= next

local TimerId
local res_cache= {}
local cnt_cache= {}

function Resurrection:Timer()
	for unit in next, cnt_cache do
		if not (UnitExists(unit) and UnitIsDeadOrGhost(unit)) then
			res_cache[unit]= nil
			cnt_cache[unit]= nil
			self:UpdateIndicators(unit)
		end
	end
	if not next(cnt_cache) then
		Grid2:CancelTimer(TimerId)
		TimerId= nil
	end		
end

function Resurrection:INCOMING_RESURRECT_CHANGED(_, unit)
	if unit then
		if UnitHasIncomingResurrection(unit) then
			if UnitIsDeadOrGhost(unit) then
				local old= res_cache[unit]
				local new= GetTime()
				if not old then
					res_cache[unit]= new
					cnt_cache[unit]= 1
					self:UpdateIndicators(unit)
					if not TimerId then
						TimerId = Grid2:ScheduleRepeatingTimer(Resurrection.Timer, 0.25, self)
					end
				elseif new-old>0.5 then -- Event is called twice for each res cast so try to filter redundant events
					cnt_cache[unit]= (cnt_cache[unit] or 0)+1
				end
			end
		else
			local old= res_cache[unit] 
			res_cache[unit]= nil
			if old then
				self:UpdateIndicators(unit)
			end
		end
	end	
end

function Resurrection:OnEnable()
	self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
end

function Resurrection:OnDisable()
	self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
	wipe(res_cache)
	wipe(cnt_cache)
end

function Resurrection:IsActive(unit)
	if cnt_cache[unit] then
		return true
	end
end

function Resurrection:GetCount(unit)
	return cnt_cache[unit] or 1
end

function Resurrection:GetColor(unit)
	local c= res_cache[unit] and self.dbx.color1 or self.dbx.color2
	return c.r, c.g, c.b, c.a
end

function Resurrection:GetIcon(unit)
	return "Interface\\RaidFrame\\Raid-Icon-Rez"
end

function Resurrection:GetBorder(unit)
	return 1
end

local resText1= L["Reviving"]
local resText2= L["Revived"]
function Resurrection:GetText(unit)
	return res_cache[unit] and resText1 or resText2
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Resurrection, {"text","icon"}, baseKey, dbx)
	return Resurrection
end

Grid2.setupFunc["resurrection"] = Create
