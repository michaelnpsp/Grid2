--===================================================================
-- More efficient AceEvents replacement, these events are only fired
-- for units in roster so no extra checks are required to filter
-- non-roster units like nameplates.
-- These register/unregister functions are embeded by default in all
-- statuses, the "method_name" defaults to "event":
--   status:RegisterRosterUnitEvent(event, method_name)
--   status:RegisterRosterUnitEvent(event, function)
--   status:RegisterRosterUnitEvent(event)
--   status:UnregisterRosterUnitEvent(event)
-- Register/unregister examples:
--   status:RegisterRosterUnitEvent("UNIT_AURA")
--   status:RegisterRosterUnitEvent("UNIT_AURA", function)
--   status:RegisterRosterUnitEvent("UNIT_AURA", "UpdateAuras")
-- Direct call examples:
--   Grid2.UnregisterRosterUnitEvent(table, "UNIT_HEALTH")
--   Grid2.RegisterRosterUnitEvent(table, "UNIT_HEALTH", function)
-- Event handling function/method example:
--   function status:UpdateAuras(event, unit, ...)
--      self:UpdateIndicators(unit)
--   end
-- If a string is passed as method_name a direct function reference
-- is saved (not the method name) so if the function/method body is
-- changed a new RegisterRosterUnitEvent() call is required to
-- register the new function callback.
--===================================================================

local Grid2 = Grid2

local next = next
local type = type

local events = {}

local frames = setmetatable( {}, {__index = function(t, unit)
	local f = CreateFrame('Frame')
	f:Hide()
	f:SetScript('OnEvent', function(_, event, ...)
		for obj, func in next, events[event] do
			func(obj, event, ...)
		end
	end)
	t[unit] = f
	return f
end} )

local Messages = LibStub("AceEvent-3.0"):Embed({})

function Messages:Grid_UnitLeft(_, unit)
	frames[unit]:UnregisterAllEvents()
end

function Messages:Grid_UnitUpdated(_, unit, joined)
	if joined then
		local frame = frames[unit]
		for eventname in next, events do
			frame:RegisterUnitEvent(eventname, unit)
		end
	end
end

-- Public Functions

function Grid2.RegisterRosterUnitEvent(object, event, method)
	if not next(events) then
		Messages:RegisterMessage('Grid_UnitUpdated')
		Messages:RegisterMessage('Grid_UnitLeft')
	end
	local objects = events[event]
	if objects == nil then
		objects = {}
		events[event] = objects
		for unit in Grid2:IterateRosterUnits() do
			frames[unit]:RegisterUnitEvent(event, unit)
		end
	end
	objects[object] = type(method)=='function' and method or object[method or event]
end

function Grid2.UnregisterRosterUnitEvent(object, event)
	local objects = events[event]
	if objects then
		objects[object] = nil
		if not next(objects) then
			events[event] = nil
			for unit in Grid2:IterateRosterUnits() do
				frames[unit]:UnregisterEvent(event)
			end
			if not next(events) then
				Messages:UnregisterMessage('Grid_UnitUpdated')
				Messages:UnregisterMessage('Grid_UnitLeft')
			end
		end
	end
end
