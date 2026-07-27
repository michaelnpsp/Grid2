--=====================================================================

local rawget = rawget
local tostring = tostring

local indicator = Grid2.indicatorPrototype

--=====================================================================

function GetAuraSlotKey(self, key)
	local prefixKey = self.dbx.type .. (key or '')
	return prefixKey..self.name, prefixKey
end

--=====================================================================

function indicator:AcquireAuraContainer(parent, key)
	local manager = parent.__auraManager
	if not manager then
		manager = setmetatable( {}, { __index = function(t,k)
			local c = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
			if k==0 then -- special AuraContainer to manage all single aura slots for each unit frame
				c.slotCount = 0
				c.slotEnabled = {}
				c.slotDisabled = {}
			end
			t[k] = c
			return c
		end } )
		parent.__auraManager = manager
	end
	return manager[key]
end

function indicator:ReleaseAuraContainer(parent, key)
	local manager = parent.__auraManager
	if manager then
		local container = rawget( manager, key )
		if container then
			container:SetEnabled(false)
			container:SetShown(false)
			container:SetParent(nil)
			container:SetUnit('none')
			manager[key] = nil
		end
	end
end

--=====================================================================

function indicator:AcquireAuraSlotButton(parent, filter, releaseFunc, key)
	filter = filter or self:GetStatusAurasFilter()
	local container = self:AcquireAuraContainer(parent, 0)
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
	return button, filter
end

function indicator:ReleaseAuraSlotButton(parent, key)
	local container = self:AcquireAuraContainer(parent, 0)
	local buttonKey, prefixKey = GetAuraSlotKey(self, key)
	local button = container.slotEnabled[buttonKey]
	if button then
		button:Hide()
		container:SetAuraSlotFilterString(button.__slotKey, "HELPFUL|HARMFUL")
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
