local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Target = Grid2.statusPrototype:new("target")

local Grid2= Grid2
local UnitIsUnit= UnitIsUnit
local UnitGUID= UnitGUID

local curTarget

function Target:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Target:PLAYER_TARGET_CHANGED(event)
	if curTarget then 
		self:UpdateIndicators(curTarget) 
	end
	local guid= UnitGUID("target")
	if guid then
		curTarget= Grid2:GetUnitidByGUID( guid )
		if curTarget then 
			self:UpdateIndicators(curTarget) 
		end
	else
		curTarget= nil
	end	
end

function Target:OnDisable()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	curTarget= nil
end

function Target:IsActive(unit)
	return UnitIsUnit(unit, "target")
end

function Target:GetColor(unitid)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local text = L["target"]
function Target:GetText(unitid)
	return text
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Target, {"color", "text"}, baseKey, dbx)

	return Target
end

Grid2.setupFunc["target"] = Create

Grid2:DbSetStatusDefaultValue( "target", {type = "target", color1 = {r=.8,g=.8,b=.8,a=.75}})
