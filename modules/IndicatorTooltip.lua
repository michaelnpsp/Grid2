--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Tooltip = Grid2.indicatorPrototype:new("tooltip")
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

local tooltipCheck -- function selected from ToolipCheck table, returns true if the tooltip should by displayed
local tooltipOwner -- default frame to anchor the tooltip, usually: Grid2Layout.frame.frameBack
local tooltipDisplayed -- boolean, true if unit tooltip is being displayed
local tooltipHookEnabled -- boolean, true if mouse hook is enabled to detect mouse entering/leaving unit frame
local tooltipFrame  -- unit frame under the mouse, usually parent in indicators code

-- tooltip for the whole unit frame
local function OnFrameEnter(frame)
	if frame then
		local unit = frame.unit
		if unit and tooltipCheck() then
			Tooltip:Display(unit, Tooltip, frame)
		end
	end
	tooltipFrame = frame
end

local function OnFrameLeave()
	if tooltipDisplayed then
		Tooltip:Hide()
		tooltipFrame = nil
	end
end

-- Tooltip indicator methods
function Tooltip:Display(unit, status, owner, anchor)
	local GameTooltip = GameTooltip
	if anchor then -- not used
		GameTooltip:SetOwner(owner, anchor)
	elseif self.dbx.tooltipAnchor then
		tooltipOwner.unit = unit -- needed by external addons that customize the unit tooltip.
		GameTooltip:SetOwner(tooltipOwner, self.dbx.tooltipAnchor)
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, owner or UIParent)
	end
	GameTooltip:SetUnit(unit)
	GameTooltip:Show()
	tooltipDisplayed = true
end

function Tooltip:Hide()
	tooltipOwner.unit = nil
	GameTooltip:Hide()
	tooltipDisplayed = nil
end

function Tooltip:SetMouseHooks(flag)
	if flag~=tooltipHookEnabled and flag then -- if another indicator has tooltips we cannot disable the unit frame event hook
		Grid2Frame:SetEventHook( 'OnEnter', OnFrameEnter, flag )
		Grid2Frame:SetEventHook( 'OnLeave', OnFrameLeave, flag )
		tooltipHookEnabled = flag
	end
end

function Tooltip:OnSuspend()
	self:SetMouseHooks(false)
end

function Tooltip:OnUpdate(parent, unit)
	if parent == tooltipFrame then
		OnFrameEnter(parent)
	end
end

function Tooltip:UpdateDB()
	local dbx  = self.dbx
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
