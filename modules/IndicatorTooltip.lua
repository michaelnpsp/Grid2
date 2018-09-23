--[[ Created by Grid2 original authors, modified by Michael ]]--

local Tooltip = Grid2.indicatorPrototype:new("tooltip")

local InCombatLockDown = InCombatLockDown

Tooltip.Create = Grid2.Dummy
Tooltip.Layout = Grid2.Dummy

local TooltipCheck= {
	[1] = function() return false end, -- never
	[2] = function() return true  end, -- always
	[3] = InCombatLockdown,            -- in combat
	[4] = function() return not InCombatLockdown() end, -- out of combat
}

local tooltipOOC
local tooltipCheck
local tooltipFrame
local tooltipDisplayed

local function OnFrameEnter(frame)
	local unit = frame.unit
	if unit then
		if tooltipOOC and not InCombatLockdown() then
			Tooltip:Display(unit, Tooltip)
		elseif #Tooltip.statuses>0 and tooltipCheck() then
			local status = Tooltip:GetCurrentStatus(unit)
			if status then
				Tooltip:Display(unit, status)
			end
		end
	end	
	tooltipFrame = frame
end

local function OnFrameLeave(frame, keep)
	Tooltip:Hide()
	tooltipFrame = nil 
end

-- Special case to get unit info without linking "name" status to the indicator
function Tooltip:GetTooltip(unit, tip)
	tip:SetUnit(unit)
end

function Tooltip:Display(unit, object)
	local anchor = self.dbx.tooltipAnchor
	if anchor then
		GameTooltip:SetOwner(Grid2Layout.frameBack, anchor)
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	end
	object:GetTooltip(unit, GameTooltip)	
	GameTooltip:Show()
	tooltipDisplayed = true
end

function Tooltip:Hide()
	if tooltipDisplayed then
		GameTooltip:Hide()
		tooltipDisplayed = nil
	end
end

function Tooltip:OnUpdate(parent, unit, status)
	if parent == tooltipFrame then
		if status then
			OnFrameEnter(parent)
		else
			Tooltip:Hide()
		end
	end	
end

function Tooltip:UpdateDB(dbx)
	dbx = dbx or self.dbx
	local show = dbx.showTooltip or 1
	tooltipOOC = dbx.displayUnitOOC
	tooltipCheck = TooltipCheck[show]
	Grid2Frame.Events.OnEnter = ( show~=1 or tooltipOOC ) and OnFrameEnter or nil
	Grid2Frame.Events.OnLeave = ( show~=1 or tooltipOOC ) and OnFrameLeave or nil
	Grid2Frame:WithAllFrames(function (f)
		f:SetScript('OnEnter', Grid2Frame.Events.OnEnter)
		f:SetScript('OnLeave', Grid2Frame.Events.OnLeave)
	end)
end

local function Create(indicatorKey, dbx)
	Tooltip.dbx = dbx
	Tooltip:UpdateDB(dbx)
	Grid2:RegisterIndicator(Tooltip, { "tooltip" })
	return Tooltip
end

Grid2.setupFunc["tooltip"] = Create
