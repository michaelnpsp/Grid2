--=====================================================================
-- blizzard aura containers & slots managament
--=====================================================================

local ipairs = ipairs
local rawget = rawget
local tostring = tostring
local tremove = table.remove
local ShouldAurasBeSecret = C_Secrets.ShouldAurasBeSecret

local indicator = Grid2.indicatorPrototype

--=====================================================================

function indicator:StatusChanged(status, priority)
	if status.GetAurasFilter then
		self.auraMode = (self.auraMode or 0) + (priority and 1 or -1)
		if self.auraMode==0 then self.auraMode = nil end
	else
		self.iconMode = (self.iconMode or 0) + (priority and 1 or -1)
		if self.iconMode==0 then self.iconMode = nil end
	end
	-- self:UpdateFilter()
	-- self:UpdateHighlight(status)
end

function indicator:GetStatusAurasFilter()
	for _,status in ipairs(self.statuses) do
		if status.GetAurasFilter then
			return status:GetAurasFilter(), status
		end
	end
end

function indicator:IterateStatusAurasFilters(max)
	local statuses, mid, idx = self.statuses, 0, 0
	return function()
		if mid>=max then return end
		while idx<#statuses do
			idx = idx + 1
			local status = statuses[idx]
			if status.GetAurasFilter then
				mid = mid + 1
				return status:GetAurasFilter(), status, mid
			end
		end
	end
end

function indicator:SetAuraButtonTooltip(button)
	if self.dbx.tooltipEnabled then
		button:EnableMouse(true)
		button:SetTooltipAnchorPoint(self.dbx.tooltipAnchor or "ANCHOR_BOTTOMLEFT")
	else
		button:EnableMouse(false)
	end
end

--=====================================================================

-- a new container is born enabled at unitToken "none", where it collects every unit's auras
-- TODO verify if this is really necessary, because hidden auraContainers dont register unit events
-- and the only auraContainers with "none" unit are the hidden ones (unit frames with no unit assigned).
-- There should be only one case when this could be necessary: when a relayout is done and auraContainers
-- are recreated, but this should only happen when active theme changes and in this case the Layout
-- is reloaded, units frames headers are disabled/reenabled and GridFramePrototype:UpdateAuraContainers()
-- is already called for each reenabled unit frame, reasigning the correct unit for every active unit frame.
local function BindAuraContainer(container, unit)
	if unit then
		container:SetUnit(unit)
		container:SetShown(true)
		container:SetEnabled(true)
	else
		container:SetEnabled(false)
		container:SetShown(false)
	end
end

--=====================================================================

function indicator:AcquireAuraContainer(parent, key, frame)
	local container = parent.__auraManager[key] -- __auraManager declared in GridFrame.lua
	if not container then
		container = CreateFrame("AuraContainer", nil, frame or parent, "CustomAuraContainerTemplate")
		BindAuraContainer(container, parent.unit)
		parent.__auraManager[key] = container
	end
	return container
end

function indicator:ReleaseAuraContainer(parent, key)
	local container = parent.__auraManager[key]
	if container then
		container:SetEnabled(false)
		container:SetShown(false)
		container:SetParent(nil)
		container:SetUnit('none')
		parent.__auraManager[key] = nil
	end
end

--=====================================================================

local function GetAuraSlotKey(self, key)
	local prefixKey = self.dbx.type .. (key or '')
	return prefixKey..self.name, prefixKey -- prefixKey: key to store disabled slots for later reuse, with no reference to a specific indicator name
end

local function GetAuraSlotsContainer(parent)
	local container = parent.__auraManager[0] -- __auraManager declared in GridFrame.lua
	if not container then
		container = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
		BindAuraContainer(container, parent.unit)
		container.slotCount = 0
		container.slotEnabled = {}
		container.slotDisabled = {}
		parent.__auraManager[0] = container
	end
	return container
end

local function ClearAuraSlotWidgets(button)
	button:ClearIcon()
	button:ClearDispelTypeTextures()
	button:ClearApplicationCount()
	button:ClearDurationCooldown()
	button:ClearDurationText()
	button:ClearDurationBar()
	button:ClearApplicationBar()
end

function indicator:AcquireAuraSlotButton(parent, filter, initFunc, releaseFunc, key)
	local status
	if not filter then
		filter, status = self:GetStatusAurasFilter()
	end
	local container = GetAuraSlotsContainer(parent)
	local buttonKey, prefixKey = GetAuraSlotKey(self, key)
	local button = container.slotEnabled[buttonKey]
	if ShouldAurasBeSecret() then -- we cannot reuse slot buttons if auras are secret
		if button then
			button = self:ReleaseAuraSlotButton(parent, key)
		end
	elseif not button then  -- search a disabled compatible slot button
		local buttons = container.slotDisabled[prefixKey]
		button = buttons and tremove(buttons, #buttons)
		container.slotEnabled[buttonKey] = button
	end
	if button then -- configure already existing slot button
		if button.__dirty then
			ClearAuraSlotWidgets(button)
			button.__dirty = nil
		end
		local slotKey = button.__slotKey
		container:SetAuraSlotFilterString(slotKey, filter.filter)
		container:SetAuraSlotCandidateFilters(slotKey, filter.candidateFilters)
		container:SetAuraSlotSortMethod(slotKey, filter.sortRule or 0, filter.sortDir or 0)
		self:SetAuraButtonTooltip(button)
		if initFunc then
			initFunc(indicator, parent, button, filter, status, key)
		end
	else -- create new slot button
		container.slotCount = container.slotCount + 1
		local slotKey = tostring(container.slotCount)
		button = container:AddAuraSlot(slotKey, filter.filter, {
			sortMethod = filter.sortRule or 0,
			sortDirection = filter.sortDir or 0,
			candidateFilters = filter.candidateFilters,
			initializeFrame = function(button)
				self:SetAuraButtonTooltip(button)
				if initFunc then
					initFunc(indicator, parent, button, filter, status, key)
				end
			end
		} )
		container.slotEnabled[buttonKey] = button
		button.__slotKey = slotKey -- key used by blizzard aura container system
		button.__releaseFunc = releaseFunc
	end
	return button, filter, status
end

function indicator:ReleaseAuraSlotButton(parent, key)
	local container = parent.__auraManager[0]
	if not container then return end
	local buttonKey, prefixKey = GetAuraSlotKey(self, key)
	local button = container.slotEnabled[buttonKey]
	if button then
		if ShouldAurasBeSecret() then
			button.__dirty = true
		else
			button:Hide()
			local func = button.__releaseFunc
			if func then
				func(self, parent, button)
			else
				ClearAuraSlotWidgets(button)
			end
		end
		container:SetAuraSlotFilterString(button.__slotKey, "")
		local disabledButtons = container.slotDisabled
		local buttons = disabledButtons[prefixKey]
		if buttons then
			buttons[#buttons+1] = button
		else
			disabledButtons[prefixKey] = { button }
		end
		container.slotEnabled[buttonKey] = nil
	end
end
