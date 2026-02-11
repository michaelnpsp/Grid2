local Grid2 = Grid2

local events = {}

local frames = setmetatable( {}, {__index = function(t, unit)
	local f = CreateFrame('Frame')
	f:Hide()
	f:SetScript('OnEvent', function(_, event, ...) events[event](event, ...) end)
	t[unit] = f
	return f
end} )

local Messages = LibStub("AceEvent-3.0"):Embed({})

function Messages:Grid_UnitLeft(unit)
	frames[unit]:UnregisterAllEvents()
end

function Messages:Grid_UnitUpdated(unit, joined)
	if joined then
		local frame = frames[unit]
		for eventname in pairs(events) do
			frame:RegisterUnitEvent(eventname, unit)
		end
	end
end

-- Public Functions

function Grid2:RegisterRosterUnitEvent(event, object, method)
	if events[event] then return end
	if not next(events) then
		Messages:RegisterMessage('Grid_UnitUpdated')
		Messages:RegisterMessage('Grid_UnitLeft')
	end
	for unit in Grid2:IterateRosterUnits() do
		frames[unit]:RegisterUnitEvent(event, unit)
	end
	if method==nil then
		if type(object)=='function' then
			events[event] = function(...) object(...) end
		else -- type(object) == 'table'
			events[event] = function(...) object[event](object, ...) end
		end
	else
		if type(method)=='string' then
			events[event] = function(...) object[method](object, ...) end
		else -- type(method) == 'function'
			events[event] = function(...) method(object, ...) end
		end
	end
end

function Grid2:UnregisterRosterUnitEvent(event)
	if events[event]==nil then return end
	events[event] = nil
	for unit in Grid2:IterateRosterUnits() do
		frames[unit]:UnregisterEvent(event)
	end
	if not next(events) then
		Messages:UnregisterMessage('Grid_UnitUpdated')
		Messages:UnregisterMessage('Grid_UnitLeft')
	end
end

