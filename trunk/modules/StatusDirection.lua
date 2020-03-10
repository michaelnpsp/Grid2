-- Direction status, shows arrows pointing to the players, created by Michael
local Direction = Grid2.statusPrototype:new("direction")

local Grid2 = Grid2
local PI = math.pi
local PI2 = PI*2
local sqrt = math.sqrt
local floor = math.floor
local atan2 = math.atan2
local pairs = pairs
local GetPlayerFacing = GetPlayerFacing
local UnitPosition = UnitPosition
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID
local C_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local f_env = {
	UnitIsUnit = UnitIsUnit,
	UnitGroupRolesAssigned = UnitGroupRolesAssigned or (function() return 'NONE' end),
	UnitInRange = UnitInRange,
	UnitIsVisible = UnitIsVisible,
	UnitIsDead = UnitIsDead,
}

local timer
local distances
local directions = {}
local UnitCheck
local mouseover = ""

local guessDirections = false
local roster_units    = Grid2.roster_units
local curtime   = 0
local plates    = {}  -- [guid] = PlateFrame.UnitFrame
local guid2guid = {}  --
local guid2time	= {}  --
local playerx,playery

--
local function PlateAdded(_, unit)
	local plateFrame = C_GetNamePlateForUnit(unit)
	if plateFrame then
		plates[ UnitGUID(unit) ] = plateFrame.UnitFrame
	end
end

local function PlateRemoved(_, unit )
	plates[ UnitGUID(unit) ] = nil
end

local function CombatLogEvent()
	local timestamp, event,_,srcGUID, _,_,_, dstGUID = CombatLogGetCurrentEventInfo()
	if event=='SWING_DAMAGE' then
		local unit = roster_units[srcGUID]
		if unit then
			guid2guid[srcGUID] = dstGUID
			guid2time[srcGUID] = timestamp
		end
	end
	curtime = timestamp
end

local function GetPlate(guid)
	local dguid = guid2guid[guid]
	return dguid and curtime-guid2time[guid]<3 and plates[dguid]
end
--

local function UpdateDirections()
	local x1,y1, _, map1 = UnitPosition("player")
	if x1 or guessDirections then
		local facing = GetPlayerFacing()
		if facing then
			for unit,guid in Grid2:IterateRosterUnits() do
				local direction, distance, update
				if not UnitIsUnit(unit, "player") and UnitCheck(unit, mouseover) then
					local x2,y2, _, map2 = UnitPosition(unit)
					if map1 == map2 then
						if x2 then
							local dx, dy = x2 - x1, y2 - y1
							direction = floor((atan2(dy,dx)-facing) / PI2 * 32 + 0.5) % 32
							if distances then distance = floor( ((dx*dx+dy*dy)^0.5)/10 ) + 1 end
						elseif guessDirections then -- disabled guessDirections, this condition is never true
							local frame = plates[guid] or GetPlate(guid)
							if frame then
								local s = frame:GetEffectiveScale()
								local x, y = frame:GetCenter()
								local dx, dy = x*s - playerx, y*s - playery
								direction = floor( (atan2(dy,dx)/PI2+0.75) * 32 ) % 32
							end
						end
					end
				end
				if distances and distances[unit]~=distance then
					distances[unit], update  = distance, true
				end
				if direction~=directions[unit] then
					directions[unit], update = direction, true
				end
				if update then
					Direction:UpdateIndicators(unit)
				end
			end
			return
		end
	end
	for unit,_ in pairs(directions) do
		directions[unit]= nil
		Direction:UpdateIndicators(unit)
	end
end

function Direction:SetTimer(enable)
	if enable then
		timer = timer or Grid2:CreateTimer(UpdateDirections)
		timer:SetDuration(self.dbx.updateRate or 0.2)
		timer:Play()
	elseif timer then
		timer:Stop()
	end
end

function Direction:RestartTimer()
	if timer and timer:IsPlaying() then
		self:SetTimer(true)
	end
end

local SetMouseoverHooks -- UnitIsUnit(unit, "mouseover") does not work for units that are not Visible
do
	local function OnMouseEnter(frame)
		mouseover = frame.unit
	end

	local function OnMouseLeave()
		mouseover = ""
	end

	SetMouseoverHooks = function(enable)
		Grid2Frame:SetEventHook( 'OnEnter', OnMouseEnter, enable )
		Grid2Frame:SetEventHook( 'OnLeave', OnMouseLeave, enable )
		if not enable then mouseover = "" end
	end
end

function Direction:UpdateDB()
	local isRestr
	t= {}
	t[1] = "return function(unit, mouseover) return "
	if not self.dbx.showOnlyStickyUnits then
		if self.dbx.ShowOutOfRange 	then t[#t+1]= "and (not UnitInRange(unit)) "; isRestr=true 	end
		if self.dbx.ShowVisible 	then t[#t+1]= "and UnitIsVisible(unit) "; isRestr=true		end
		if self.dbx.ShowDead 		then t[#t+1]= "and UnitIsDead(unit) "; isRestr=true			end
	end
	if isRestr or self.dbx.showOnlyStickyUnits then
		if self.dbx.StickyTarget	then t[#t+1]= "or  UnitIsUnit(unit, 'target') "		     end
		if self.dbx.StickyMouseover	then t[#t+1]= "or  UnitIsUnit(unit, mouseover) "          end
		if self.dbx.StickyFocus		then t[#t+1]= "or  UnitIsUnit(unit, 'focus') "	         end
		if self.dbx.StickyTanks		then t[#t+1]= "or  UnitGroupRolesAssigned(unit)=='TANK' " end
	end
	t[2] = t[2] and t[2]:sub(5) or "true "
	t[#t+1]= "end"
	SetMouseoverHooks((isRestr or self.dbx.showOnlyStickyUnits) and self.dbx.StickyMouseover)
	UnitCheck = assert(loadstring(table.concat(t)))()
	setfenv(UnitCheck, f_env)
	--
	local count = self.dbx.colorCount or 1
	if count>1 then
		distances = distances or {}
		self.GetVertexColor = Direction.GetDistanceColor
		self.colors = self.colors or {}
		for i=1,count do
			self.colors[i] = self.dbx["color"..i]
		end
	else
		distances = nil
		self.GetVertexColor = Grid2.statusLibrary.GetColor
	end
	-- disabled because doesn't work due to new Nameplates restrictions, GetCenter() cannot be called in combat now
	-- guessDirections = self.dbx.guessDirections
end

function Direction:OnEnable()
	self:UpdateDB()
	self:SetTimer(true)
	if guessDirections then
		playerx = UIParent:GetWidth()  * UIParent:GetEffectiveScale() / 2
		playery = UIParent:GetHeight() * UIParent:GetEffectiveScale() / 2
		self:RegisterEvent("NAME_PLATE_UNIT_ADDED", PlateAdded )
		self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", PlateRemoved )
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
	end
end

function Direction:OnDisable()
	self:SetTimer(false)
	if guestDirections then
		self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
		self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function Direction:IsActive(unit)
	return directions[unit] and true
end

function Direction:GetIcon(unit)
	return "Interface\\Addons\\Grid2\\media\\Arrows32-32x32"
end

function Direction:GetTexCoord(unit)
	local y= directions[unit] / 32
	return 0.05, 0.95, y+0.0015625, y+0.028125
end

function Direction:GetDistanceColor(unit)
	local distance = distances[unit]
	local color = distance and self.colors[distance] or self.colors[5]
	return color.r, color.g, color.b, color.a
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Direction, {"icon"}, baseKey, dbx)

	return Direction
end

Grid2.setupFunc["direction"] = Create

Grid2:DbSetStatusDefaultValue( "direction", { type = "direction", color1 = { r= 0, g= 1, b= 0, a=1 } })
