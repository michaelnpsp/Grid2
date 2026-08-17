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

-- Aura slot buttons are created by Blizzard's aura container with
-- DenyTaintedAccessWhenAurasAreSecret (see Blizzard_AuraContainer), so addon
-- code cannot touch them at all while auras are secret - which is the entire
-- duration of an arena, regardless of when the button was created. The
-- initializeFrame callback passed to AddAuraSlot runs before the restriction
-- is applied and is the only styling window available in that state. Styling
-- a button after AddAuraSlot returns therefore only works out of arenas,
-- which is why aura indicators died for the whole match after a reload or
-- disconnect into an arena: every post-acquire styling call was denied (and
-- the first denial aborted the frame's entire indicator layout).
--
-- The fix: indicators hand their button styling to AcquireAuraSlotButton as a
-- function, which runs it inside initializeFrame for new buttons, or directly
-- for reused buttons when auras are not secret. A reused button that cannot
-- be restyled keeps the style baked at its creation, and a full relayout is
-- queued for when secrecy ends.
local function CanAccessAuraButtons()
	return not (C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret())
end
Grid2.CanAccessAuraButtons = CanAccessAuraButtons

local relayoutPending = false
local relayoutFrame = CreateFrame("Frame")
relayoutFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
relayoutFrame:SetScript("OnEvent", function()
	if relayoutPending and CanAccessAuraButtons() then
		relayoutPending = false
		local Grid2Frame = _G.Grid2Frame
		if Grid2Frame and Grid2Frame.LayoutFrames then
			Grid2Frame:LayoutFrames()
		end
	end
end)

local function RequestRelayoutWhenAccessible()
	relayoutPending = true
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
		-- bookkeeping lives addon-side, keyed by button reference: raw field
		-- access on a restricted button is not proven legal while auras are
		-- secret, and these must be readable at any time
		container.slotKeys = {}
		container.slotReleaseFuncs = {}
		parent.__auraManager[0] = container
	end
	return container
end

function indicator:AcquireAuraSlotButton(parent, filter, releaseFunc, key, styleFunc)
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
		 local slotKey = container.slotKeys[button]
		 container:SetAuraSlotFilterString(slotKey, filter.filter)
		 container:SetAuraSlotCandidateFilters(slotKey, filter.candidateFilters)
		 container:SetAuraSlotSortMethod(slotKey, filter.sortRule or 0, filter.sortDir or 0)
		 container.slotReleaseFuncs[button] = releaseFunc
		 if CanAccessAuraButtons() then
			if styleFunc then
				styleFunc(self, parent, button, filter, status)
			end
			self:SetAuraButtonTooltip(button)
		 else
			-- the button keeps the style baked at its creation; a relayout
			-- replays this styling once auras stop being secret
			RequestRelayoutWhenAccessible()
		 end
	else -- create new slot button
		container.slotCount = container.slotCount + 1
		local slotKey = tostring(container.slotCount)
		local acquiringIndicator = self
		button = container:AddAuraSlot(slotKey, filter.filter, {
			sortMethod = filter.sortRule or 0,
			sortDirection = filter.sortDir or 0,
			candidateFilters = filter.candidateFilters,
			-- runs before the access restriction is applied to the new
			-- button: the only place a button born while auras are secret
			-- can ever be styled
			initializeFrame = function(newButton)
				if styleFunc then
					styleFunc(acquiringIndicator, parent, newButton, filter, status)
				end
				acquiringIndicator:SetAuraButtonTooltip(newButton)
			end,
		} )
		container.slotEnabled[buttonKey] = button
		container.slotKeys[button] = slotKey -- key used by blizzard aura container system
		container.slotReleaseFuncs[button] = releaseFunc
	end
	return button, filter, status
end

function indicator:ReleaseAuraSlotButton(parent, key)
	local container = parent.__auraManager[0]
	if not container then return end
	local buttonKey, prefixKey = GetAuraSlotKey(self, key)
	local button = container.slotEnabled[buttonKey]
	if button then
		-- emptying the filter is a container call and always permitted; the
		-- visual clears touch the button and are only possible while auras
		-- are not secret. A button released while secret shows nothing (its
		-- filter is empty), keeps its stale visuals for later reuse, and the
		-- queued relayout restyles whatever acquires it again.
		container:SetAuraSlotFilterString(container.slotKeys[button], "")
		if CanAccessAuraButtons() then
			button:Hide()
			local func = container.slotReleaseFuncs[button]
			if func then
				func(self, parent, button)
			else
				button:ClearIcon()
				button:ClearDispelTypeTextures()
				button:ClearApplicationCount()
				button:ClearDurationCooldown()
				button:ClearDurationText()
				button:ClearDurationBar()
				button:ClearApplicationBar()
			end
		else
			RequestRelayoutWhenAccessible()
		end
		container.slotReleaseFuncs[button] = nil
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
