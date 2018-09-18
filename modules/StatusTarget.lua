local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Target = Grid2.statusPrototype:new("target")

local Grid2 = Grid2
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID
local roster_units = Grid2.roster_units

local guiTarget, curTarget, oldTarget
local function UpdateTarget()
	guiTarget = UnitGUID("target")
	oldTarget = curTarget
	curTarget = guiTarget and roster_units[guiTarget]
end

function Target:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterMessage("Grid_UnitUpdated")
	UpdateTarget()
end

function Target:OnDisable()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterMessage("Grid_UnitUpdated")
	guiTarget, curTarget, oldTarget = nil, nil, nil
end

function Target:Grid_UnitUpdated(_, unit)
	if guiTarget then
		curTarget = roster_units[guiTarget]
	end
end

function Target:PLAYER_TARGET_CHANGED()
	UpdateTarget()
	if oldTarget then self:UpdateIndicators(oldTarget) end
	if curTarget then self:UpdateIndicators(curTarget) end
end

function Target:IsActive(unit)
	return curTarget and UnitIsUnit(unit, curTarget)
end

local text = L["target"]
function Target:GetText()
	return text
end

Target.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Target, {"color", "text"}, baseKey, dbx)

	return Target
end

Grid2.setupFunc["target"] = Create

Grid2:DbSetStatusDefaultValue( "target", {type = "target", color1 = {r=.8,g=.8,b=.8,a=.75}})
