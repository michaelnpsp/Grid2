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
local roster_units = Grid2.roster_units

local timer
local colors
local distances
local mouseover = ""
local directions = {}
local UnitCheck

local CODE = [[
local UnitIsUnit = UnitIsUnit
local UnitInRange = UnitInRange
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitGroupRolesAssigned = UnitGroupRolesAssigned or (function() return 'NONE' end)
return function(unit, mouseover) return (%s) end
]]

local function UpdateDirections()
	local x1,y1, _, map1 = UnitPosition("player")
	if x1 then
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
	local dbx, t, u = self.dbx, {}, {}
	SetMouseoverHooks(dbx.StickyMouseover)
	if dbx.ShowOutOfRange  then u[#u+1]= "(not UnitInRange(unit))" end
	if dbx.ShowVisible 	   then u[#u+1]= "UnitIsVisible(unit)" end
	if dbx.ShowDead 	   then u[#u+1]= "UnitIsDeadOrGhost(unit) " end
	if #u>0                then t[#t+1]= table.concat(u, dbx.lazyFilter and ' or ' or ' and '); wipe(u) end
	if dbx.StickyTarget	   then u[#u+1]= "UnitIsUnit(unit,'target')" end
	if dbx.StickyMouseover then u[#u+1]= "UnitIsUnit(unit,mouseover)" end
	if dbx.StickyFocus	   then u[#u+1]= "UnitIsUnit(unit,'focus')" end
	if dbx.StickyTanks	   then u[#u+1]= "UnitGroupRolesAssigned(unit)=='TANK'" end
	if #u>0                then t[#t+1]= table.concat(u, ' or '); wipe(u) end
	local s = string.format( CODE, #t>0 and table.concat(t, dbx.showAlwaysStickyUnits and ') or (' or ') and (') or 'true' )
	UnitCheck = assert(loadstring(s))()
	local count = dbx.colorCount or 1
	if count>1 then
		distances = distances or {}
		colors = colors or {}
		for i=1,count do colors[i] = dbx["color"..i] end
		self.GetVertexColor = self.GetDistanceColor
	else
		distances = nil
		self.GetVertexColor = Grid2.statusLibrary.GetColor
	end
end

function Direction:OnEnable()
	self:SetTimer(true)
end

function Direction:OnDisable()
	self:SetTimer(false)
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
	local color = distance and colors[distance] or colors[5]
	return color.r, color.g, color.b, color.a
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Direction, {"icon"}, baseKey, dbx)

	return Direction
end

Grid2.setupFunc["direction"] = Create

Grid2:DbSetStatusDefaultValue( "direction", { type = "direction", color1 = { r= 0, g= 1, b= 0, a=1 } })
