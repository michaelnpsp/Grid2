--[[
Created by Azethoth, modified by Michael
--]]

local TargetIcon = Grid2.statusPrototype:new("raid-icon-target")
local TargetIconPlayer = Grid2.statusPrototype:new("raid-icon-player")

local iconText = {
	[1] = RAID_TARGET_1, -- Star
	[2] = RAID_TARGET_2, -- Circle
	[3] = RAID_TARGET_3, -- Diamond
	[4] = RAID_TARGET_4, -- Triangle
	[5] = RAID_TARGET_5, -- Moon
	[6] = RAID_TARGET_6, -- Square
	[7] = RAID_TARGET_7, -- Cross
	[8] = RAID_TARGET_8  -- Skull
}
local iconTexture = {
	[1] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", -- Star
	[2] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Circle
	[3] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", -- Diamond
	[4] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", -- Triangle
	[5] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", -- Moon
	[6] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", -- Square
	[7] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", -- Cross
	[8] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"  -- Skull
}

function TargetIcon:UpdateUnit(event, unit)
	self:UpdateIndicators(unit)
end

function TargetIcon:UpdateAllUnits(event)
	for unit, guid in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function TargetIcon:OnEnable()
	self:RegisterEvent("RAID_TARGET_UPDATE", "UpdateAllUnits")
	self:RegisterEvent("UNIT_TARGET", "UpdateUnit")
end

function TargetIcon:OnDisable()
	self:UnregisterEvent("RAID_TARGET_UPDATE")
	self:UnregisterEvent("UNIT_TARGET")
end

function TargetIcon:IsActive(unit)
	local unitTarget = unit .. "target"
	if (UnitExists(unitTarget)) then
		return GetRaidTargetIndex(unitTarget)
	end
	return nil
end

function TargetIcon:GetColor(unit)
	local unitTarget = unit .. "target"
	local iconIndex = GetRaidTargetIndex(unitTarget)

	local color = self.dbx["color" .. iconIndex]
	local opacity = self.dbx.opacity or 1
	return color.r, color.g, color.b, opacity
end

function TargetIcon:GetIcon(unit)
	local unitTarget = unit .. "target"
	local iconIndex = GetRaidTargetIndex(unitTarget)

	return iconTexture[iconIndex]
end

function TargetIcon:GetText(unit)
	local unitTarget = unit .. "target"
	local iconIndex = GetRaidTargetIndex(unitTarget)
	return iconText[iconIndex]
end

local function CreateTargetIcon(baseKey, dbx)
	Grid2:RegisterStatus(TargetIcon, {"color", "icon", "text"}, baseKey, dbx)
	return TargetIcon
end

Grid2.setupFunc["raid-icon-target"] = CreateTargetIcon

function TargetIconPlayer:UpdateUnit(event, unit)
	self:UpdateIndicators(unit)
end

function TargetIconPlayer:UpdateAllUnits(event)
	for unit, guid in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function TargetIconPlayer:OnEnable()
	self:RegisterEvent("RAID_TARGET_UPDATE", "UpdateAllUnits")
	self:RegisterEvent("UNIT_TARGET", "UpdateUnit")
end

function TargetIconPlayer:OnDisable()
	self:UnregisterEvent("RAID_TARGET_UPDATE")
	self:UnregisterEvent("UNIT_TARGET")
end

function TargetIconPlayer:IsActive(unit)
	if (UnitExists(unit)) then
		return GetRaidTargetIndex(unit)
	end
	return nil
end

function TargetIconPlayer:GetColor(unit)
	local iconIndex = GetRaidTargetIndex(unit)
	local color = self.dbx["color" .. iconIndex]
	local opacity = self.dbx.opacity or 1
	return color.r, color.g, color.b, opacity
end

function TargetIconPlayer:GetIcon(unit)
	local iconIndex = GetRaidTargetIndex(unit)
	return iconTexture[iconIndex]
end

function TargetIconPlayer:GetText(unit)
	local iconIndex = GetRaidTargetIndex(unit)
	return iconText[iconIndex]
end

local function CreateTargetIconPlayer(baseKey, dbx)
	Grid2:RegisterStatus(TargetIconPlayer, {"color", "icon", "text"}, baseKey, dbx)

	return TargetIconPlayer
end

Grid2.setupFunc["raid-icon-player"] = CreateTargetIconPlayer

