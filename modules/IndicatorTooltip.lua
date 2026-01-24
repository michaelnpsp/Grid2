--[[ Created by Grid2 original authors, modified by Michael ]]--
if Grid2.secretsEnabled then return end

local Grid2 = Grid2
local Tooltip = Grid2.indicatorPrototype:new("tooltip")
local next = next
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
local tooltipDefault
local tooltipCheck
local tooltipFrame  -- unit frame under the mouse, usually parent in indicators code
local tooltipOwner  -- default frame to anchor the tooltip if no indicator is provided
local tooltipDisplayed
local OnFrameEnter
local OnFrameLeave

-- tooltip over icons support
local timer
local indicators = {}
local tooltipIndicator -- indicator frame under the mouse, usually parent[indicator.name]

local function TimerEvent()
	if tooltipFrame then
		local unit = tooltipFrame.unit
		if unit then
			for indicator, func in next, indicators do
				local frame = indicator:GetFrame(tooltipFrame)
				if frame and frame:IsMouseOver() then
					if frame:IsVisible() then
						local status, _, extraID, tframe = func(indicator, unit, tooltipFrame, frame)
						if status and status.GetTooltip then
							Tooltip:Display(unit, status, extraID, tframe or frame, indicator.dbx.tooltipAnchor)
							tooltipIndicator = frame
							return
						end
					end
					break
				end
			end
			if tooltipIndicator then
				Tooltip:Hide()
				OnFrameEnter(tooltipFrame)
			end
		end
	end
end

function Grid2.indicatorPrototype:EnableTooltips()
	if self.dbx.tooltipEnabled then
		if not next(indicators) then
			Tooltip:SetMouseHooks(true)
			timer = Grid2:CreateTimer( TimerEvent, 0.25 )
		end
		indicators[self] = self.GetMouseOverStatus or self.GetCurrentStatus
	end
end

function Grid2.indicatorPrototype:DisableTooltips()
	if indicators[self]~=nil then
		indicators[self] = nil
		if not next(indicators) then
			Tooltip:SetMouseHooks(nil)
			timer = Grid2:CancelTimer(timer)
		end
	end
end

-- standard tooltip indicator
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
	tooltipFrame, tooltipIndicator = frame, nil
end

function OnFrameLeave()
	if tooltipDisplayed then
		Tooltip:Hide()
		tooltipFrame = nil
	end
end

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
	if flag==nil then flag = self.dbx.showTooltip~=1 end
	Grid2Frame:SetEventHook( 'OnEnter', OnFrameEnter, flag )
	Grid2Frame:SetEventHook( 'OnLeave', OnFrameLeave, flag )
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
	self:SetMouseHooks( dbx.showTooltip~=1 or next(indicators) )
end

local function Create(indicatorKey, dbx)
	Tooltip.dbx = dbx
	Grid2:RegisterIndicator(Tooltip, { "tooltip" })
	return Tooltip
end

Grid2.setupFunc["tooltip"] = Create
