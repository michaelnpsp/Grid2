-- Direction status, shows arrows pointing to the players, created by Michael
local Direction = Grid2.statusPrototype:new("direction")

local Grid2= Grid2
local PI= math.pi
local PI2 = PI*2
local floor = math.floor
local atan2 = math.atan2
local sqrt  = math.sqrt
local GetPlayerFacing = GetPlayerFacing
local UnitPosition = UnitPosition
local UnitIsUnit= UnitIsUnit
local UnitGUID = UnitGUID
local C_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local f_env = {
	UnitIsUnit= UnitIsUnit,
	UnitGroupRolesAssigned = UnitGroupRolesAssigned,
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
--

local function UpdateDirections()
	local function GetPlate(guid)
		local dguid = guid2guid[guid]
		return dguid and curtime-guid2time[guid]<3 and plates[dguid]
	end
	local x1,y1, _, map1 = UnitPosition("player")
	local facing = GetPlayerFacing()
	for unit,guid in Grid2:IterateRosterUnits() do
		local direction, distance, update
		if not UnitIsUnit(unit, "player") and UnitCheck(unit, mouseover) then
			local x2,y2, _, map2 = UnitPosition(unit)
			if map1 == map2 then
				if x2 then
					local dx, dy = x2 - x1, y2 - y1
					direction = floor((atan2(dy,dx)-facing) / PI2 * 32 + 0.5) % 32
					if distances then distance = floor( ((dx*dx+dy*dy)^0.5)/10 ) + 1 end
				elseif guessDirections then
					local frame = plates[guid] or GetPlate(guid) 					
					if frame then
						local s = frame:GetEffectiveScale()
						local x, y = frame:GetCenter()
						local dx, dy = x*s - playerx, y*s - playery
						direction = floor( (atan2(dy,dx)/PI2+0.75) * 32 ) % 32 
					end
				else
					Direction:ClearDirections()
					return
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
end

function Direction:SetTimer(enable)
	if enable then
		if not timer then
			timer= Grid2:ScheduleRepeatingTimer(UpdateDirections, self.dbx.updateRate or 0.2)
		end
	else
		if timer then
			Grid2:CancelTimer(timer)
			timer= nil
		end
	end
end

function Direction:RestartTimer()
	if timer then
		self:SetTimer(false)
		self:SetTimer(true)
	end
end

function Direction:ClearDirections()
	for unit,_ in pairs(directions) do
		directions[unit]= nil
		self:UpdateIndicators(unit)
	end
end

local SetMouseoverHooks -- UnitIsUnit(unit, "mouseover") does not work for units that are not Visible
do
	local prev_OnEnter
	local function OnMouseEnter(self, frame)
		mouseover = frame.unit
		prev_OnEnter(self, frame)
	end

	local prev_OnLeave
	local function OnMouseLeave(self, frame)
		mouseover = ""
		prev_OnLeave(self, frame)
	end

	SetMouseoverHooks = function(enable)
		if not prev_OnEnter and enable then
			prev_OnEnter = Grid2Frame.OnFrameEnter
			prev_OnLeave = Grid2Frame.OnFrameLeave
			Grid2Frame.OnFrameEnter = OnMouseEnter
			Grid2Frame.OnFrameLeave = OnMouseLeave
		elseif prev_OnEnter and not enable then
			Grid2Frame.OnFrameEnter = prev_OnEnter
			Grid2Frame.OnFrameLeave = prev_OnLeave
			prev_OnEnter = nil
			prev_OnLeave = nil
			mouseover = ""
		end
	end
end

function Direction:UpdateDB()
	local isRestr
	t= {}
	t[1] = "return function(unit) return "
	if not self.dbx.showOnlyStickyUnits then
		if self.dbx.ShowOutOfRange 	then t[#t+1]= "and (not UnitInRange(unit)) "; isRestr=true 	end
		if self.dbx.ShowVisible 	then t[#t+1]= "and UnitIsVisible(unit) "; isRestr=true		end
		if self.dbx.ShowDead 		then t[#t+1]= "and UnitIsDead(unit) "; isRestr=true			end
	end
	if isRestr or self.dbx.showOnlyStickyUnits then
		if self.dbx.StickyTarget	then t[#t+1]= "or  UnitIsUnit(unit, 'target') "		end
		if self.dbx.StickyMouseover	then t[#t+1]= "or  UnitIsUnit(unit, mouseover) "
										 t[1]	= "return function(unit, mouseover) return " end
		if self.dbx.StickyFocus		then t[#t+1]= "or  UnitIsUnit(unit, 'focus') "	end
		if self.dbx.StickyTanks		then t[#t+1]= "or  UnitGroupRolesAssigned(unit)=='TANK' " end
	end
	if t[2] then
		t[2] = t[2]:sub(5)
	else
		t[2] = "true " 
	end
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
	--
	guessDirections = self.dbx.guessDirections
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
