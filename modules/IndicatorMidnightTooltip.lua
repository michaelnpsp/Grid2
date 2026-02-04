--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Tooltip = Grid2.indicatorPrototype:new("tooltip")
local next = next
local InCombatLockDown = InCombatLockDown

Tooltip.Create = Grid2.Dummy
Tooltip.Layout = Grid2.Dummy

-- tooltip indicator settings
local TooltipCheck= {
	[1] = function() return false end, -- never
	[2] = function() return true  end, -- always
	[3] = InCombatLockdown,            -- in combat
	[4] = function() return not InCombatLockdown() end, -- out of combat
}
local tooltipOOC
local tooltipDefault
local tooltipCheck
local tooltipOwner  -- default frame to anchor the tooltip if no indicator is provided
local tooltipDisplayed
local tooltipHookEnabled
-- whole unit frame
local tooltipFrame  -- unit frame under the mouse, usually parent in indicators code
local OnFrameEnter
local OnFrameLeave
-- indicator under the mouse
local tooltipIndicatorFrame -- indicator frame under the mouse, usually parent[indicator.name]
local tooltipIndicatorEnabled
local OnFrameIndicatorEnter
local OnFrameIndicatorLeave
local ShowFrameTooltip
local RefreshFrameTooltip

ResfreshFrameTooltip = Grid2:CreateTimer( function()
	if tooltipIndicatorFrame then
		ShowFrameTooltip(tooltipIndicatorFrame)
	else
		ResfreshFrameTooltip:Stop()
	end
end, 0.25, false)

ShowFrameTooltip = function(frame)
	if tooltipFrame and tooltipFrame.unit then
		local indicator = frame.tooltipIndicator
		if indicator then
			local func = indicator.GetMouseOverStatus or indicator.GetCurrentStatus
			local status, _, extraID, tframe = func(indicator, tooltipFrame.unit, tooltipFrame, frame)
			if status and status.GetTooltip then
				Tooltip:Display(tooltipFrame.unit, status, extraID, tframe or frame, indicator.dbx.tooltipAnchor)
				tooltipIndicatorFrame = frame
				return true
			elseif tooltipIndicatorFrame then
				Tooltip:Hide()
				OnFrameEnter(tooltipFrame)
				return false
			end
		end
	end
end

function Grid2.indicatorPrototype:EnableFrameTooltips(frame, enabled)
	enabled = not not enabled
	frame.tooltipIndicator = enabled and self or nil
	frame:EnableMouse(enabled)
	frame:SetPropagateMouseMotion(enabled)
	frame:SetPropagateMouseClicks(enabled)
	frame:SetMouseClickEnabled(false)
	frame:SetScript("OnEnter", enabled and OnFrameIndicatorEnter or nil)
	frame:SetScript("OnLeave", enabled and OnFrameIndicatorLeave or nil)
	if enabled then
		Tooltip:SetMouseHooks(true)
		tooltipIndicatorEnabled = enabled
	end
end

-- tooltip for indicator frames
function OnFrameIndicatorEnter(frame)
	if ShowFrameTooltip(frame) then
		ResfreshFrameTooltip:Play()
	end
end

function OnFrameIndicatorLeave(frame)
	if tooltipDisplayed then
		Tooltip:Hide()
		if tooltipFrame then
			OnFrameEnter(tooltipFrame)
		end
	end
end

-- tooltip for the whole unit frame
function OnFrameEnter(frame)
	local unit = frame.unit
	if unit then
		if tooltipOOC and not InCombatLockdown() then
			Tooltip:Display(unit, Tooltip)
		elseif tooltipCheck() then
			local status = Tooltip:GetCurrentStatus(unit, frame)
			if status or tooltipDefault then
				Tooltip:Display(unit, status or Tooltip)
			end
		end
	end
	tooltipFrame, tooltipIndicatorFrame = frame, nil
end

function OnFrameLeave()
	if tooltipDisplayed then
		Tooltip:Hide()
		tooltipFrame = nil
	end
end

-- Tooltip indicator methods
function Tooltip:GetTooltip(unit, tip)
	tip:SetUnit(unit) -- Special case to get unit info without linking "name" status to the indicator
end

function Tooltip:Display(unit, status, extraID, owner, anchor)
	if anchor then
		GameTooltip:SetOwner(owner, anchor)
	elseif self.dbx.tooltipAnchor then
		GameTooltip:SetOwner(tooltipOwner, self.dbx.tooltipAnchor)
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	end
	status:GetTooltip(unit, GameTooltip, extraID)
	GameTooltip:Show()
	tooltipDisplayed = true
end

function Tooltip:Hide()
	GameTooltip:Hide()
	tooltipDisplayed = nil
end

function Tooltip:OnUpdate(parent, unit, status)
	if parent == tooltipFrame then
		if status then
			OnFrameEnter(parent)
		elseif tooltipDisplayed then
			Tooltip:Hide()
		end
	end
end

function Tooltip:SetMouseHooks(flag)
	if flag~=tooltipHookEnabled and (flag or not tooltipIndicatorEnabled) then -- if another indicator has tooltips we cannot disable the unit frame event hook
		Grid2Frame:SetEventHook( 'OnEnter', OnFrameEnter, flag )
		Grid2Frame:SetEventHook( 'OnLeave', OnFrameLeave, flag )
		tooltipHookEnabled = flag
	end
end

function Tooltip:OnSuspend()
	self:SetMouseHooks(false)
end

function Tooltip:UpdateDB()
	local dbx  = self.dbx
	tooltipOOC = dbx.displayUnitOOC
	tooltipDefault = dbx.showDefault
	tooltipCheck = TooltipCheck[dbx.showTooltip or 4]
	tooltipOwner = Grid2Layout.frame.frameBack
	self:SetMouseHooks(dbx.showTooltip~=1)
end

local function Create(indicatorKey, dbx)
	Tooltip.dbx = dbx
	Grid2:RegisterIndicator(Tooltip, { "tooltip" })
	return Tooltip
end

Grid2.setupFunc["tooltip"] = Create
