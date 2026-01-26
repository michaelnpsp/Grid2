-- Hide blizzard frames
local InCombatLockdown = InCombatLockdown
local secretsEnabled = Grid2.secretsEnabled
local grouped_units = Grid2.grouped_units

local hiddenFrame = CreateFrame('Frame')
hiddenFrame:Hide()

local function rehide(self)
	if not InCombatLockdown() then self:Hide() end
end

local function unregister(f)
	if f then f:UnregisterAllEvents() end
end

local function hideFrame(frame,dontsave)
	if frame then
		UnregisterUnitWatch(frame)
		frame:Hide()
		frame:UnregisterAllEvents()
		frame:SetParent(hiddenFrame)
		frame:HookScript("OnShow", rehide)
		unregister(frame.healthbar)
		unregister(frame.manabar)
		unregister(frame.powerBarAlt)
		unregister(frame.spellbar)
		if dontsave then
			frame:SetDontSavePosition(true)
		end
	end
end

local function UnregisterUnitEvents(frame)
	local unit = frame.unit
	if grouped_units[unit] then
		pcall(function()
			frame:UnregisterAllEvents()
			frame:RegisterUnitEvent("UNIT_AURA", unit, frame.displayedUnit and frame.displayedUnit or nil)
			frame:RegisterEvent("PLAYER_REGEN_ENABLED")
			frame:RegisterEvent("PLAYER_REGEN_DISABLED")
		end)
	end
end

-- party frames, only for retail
local function HidePartyFrames()
	if not PartyFrame then return end
	hideFrame(PartyFrame)
	for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
		hideFrame(frame)
		hideFrame(frame.HealthBar)
		hideFrame(frame.ManaBar)
	end
	PartyFrame.PartyMemberFramePool:ReleaseAll()
	hideFrame(CompactPartyFrame)
	UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") -- used by compact party frame
end

-- raid frames
local function HideRaidFrames()
	if not CompactRaidFrameManager then return end
	local function HideFrame(frame)
		pcall(function()
			frame:SetAlpha(0)
			if not InCombatLockdown() then
				frame:SetScale(0.001)
				frame:Hide()
			end
		end)
		if not secretsEnabled then
			pcall(function() frame:UnregisterAllEvents() end)
		end
	end
	local function HideFrames()
		HideFrame(CompactRaidFrameContainer)
		HideFrame(CompactRaidFrameManager)
	end
	hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", UnregisterUnitEvents)
	hooksecurefunc('CompactRaidFrameManager_UpdateShown', HideFrames)
	CompactRaidFrameManager:HookScript('OnShow', HideFrames)
	CompactRaidFrameContainer:HookScript('OnShow', HideFrames)
	HideFrames()
end

-- public method
function Grid2:UpdateBlizzardFrames()
	local hide = self.db.profile.hideBlizzard
	if hide then
		if hide.raid then
			HideRaidFrames()
		end
		if hide.party then
			HidePartyFrames()
		end
		if hide.pet then
			hideFrame(PetFrame, true)
		end
		if hide.focus then
			hideFrame(FocusFrame, true)
			hideFrame(FocusFrameToT)
		end
		if hide.target then
			hideFrame(TargetFrame,true)
			hideFrame(TargetFrameToT)
			hideFrame(ComboFrame)
		end
		if hide.player then
			hideFrame(PlayerFrame, true)
			hideFrame(PlayerFrameAlternateManaBar)
			hideFrame(AlternatePowerBar)
		end
	end
	self.UpdateBlizzardFrames = nil
end
