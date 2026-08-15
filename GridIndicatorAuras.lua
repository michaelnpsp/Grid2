--=====================================================================

local rawget = rawget
local tostring = tostring

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
	return prefixKey..self.name, prefixKey
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

function indicator:AcquireAuraSlotButton(parent, filter, releaseFunc, key)
	local status
	if not filter then
		filter, status = self:GetStatusAurasFilter()
	end
	local container = GetAuraSlotsContainer(parent)
	local buttonKey, prefixKey = GetAuraSlotKey(self, key)
	local button = container.slotEnabled[buttonKey]
	if not button then -- search a disabled compatible slot button
		local buttons = container.slotDisabled[prefixKey]
		button = buttons and table.remove(buttons, #buttons)
		container.slotEnabled[buttonKey] = button
	end
	if button then -- configure already existing slot button
		 local slotKey = button.__slotKey
		 container:SetAuraSlotFilterString(slotKey, filter.filter)
		 container:SetAuraSlotCandidateFilters(slotKey, filter.candidateFilters)
		 container:SetAuraSlotSortMethod(slotKey, filter.sortRule or 0, filter.sortDir or 0)
	else -- create new slot button
		container.slotCount = container.slotCount + 1
		local slotKey = tostring(container.slotCount)
		button = container:AddAuraSlot(slotKey, filter.filter, {
			sortMethod = filter.sortRule or 0,
			sortDirection = filter.sortDir or 0,
			candidateFilters = filter.candidateFilters,
		} )
		container.slotEnabled[buttonKey] = button
		button.__slotKey = slotKey -- key used by blizzard aura container system
		button.__releaseFunc = releaseFunc
	end
	self:SetAuraButtonTooltip(button)
	return button, filter, status
end

function indicator:ReleaseAuraSlotButton(parent, key)
	local container = GetAuraSlotsContainer(parent)
	local buttonKey, prefixKey = GetAuraSlotKey(self, key)
	local button = container.slotEnabled[buttonKey]
	if button then
		button:Hide()
		local func = button.__releaseFunc
		if func then
			func(self, parent, button)
		else
			button:ClearIcon()
			button:ClearDispelTypeTextures()
			button:ClearApplicationCount()
			button:ClearDurationCooldown()
			button:ClearApplicationBar()
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
