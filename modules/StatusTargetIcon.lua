--[[
Created by Azethoth, modified by Michael
--]]

local TargetIcon = Grid2.statusPrototype:new("raid-icon-target")
local TargetIconPlayer = Grid2.statusPrototype:new("raid-icon-player")

local Grid2 = Grid2
local UnitExists = UnitExists
local GetRaidTargetIndex = GetRaidTargetIndex
local rawget= rawget

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

local target_cache= setmetatable({}, {__index = function(t,unit)
	local target= unit .. "target"
	local v= UnitExists(target) and GetRaidTargetIndex(target) or false
	t[unit]= v 
	return v
end})

function TargetIcon:UpdateUnit( _, unit)
	local target= unit .. "target"
	target_cache[unit] = UnitExists(target) and GetRaidTargetIndex(target) or false
	self:UpdateIndicators(unit)
end

function TargetIcon:UpdateAllUnits()
	for unit, _ in Grid2:IterateRosterUnits() do
		local target= unit .. "target"
		local prev  = rawget( target_cache, unit )
		local new   = UnitExists(target) and GetRaidTargetIndex(target) or false
		if new ~= prev then
			target_cache[unit] = new
			self:UpdateIndicators(unit)
		end
	end
end

function TargetIcon:OnEnable()
	self:RegisterEvent("RAID_TARGET_UPDATE", "UpdateAllUnits")
	self:RegisterEvent("UNIT_TARGET", "UpdateUnit")
end

function TargetIcon:OnDisable()
	self:UnregisterEvent("RAID_TARGET_UPDATE")
	self:UnregisterEvent("UNIT_TARGET")
	wipe(target_cache)
end

function TargetIcon:IsActive(unit)
	return target_cache[unit]
end

function TargetIcon:GetColor(unit)
	local c = self.dbx[ "color" .. target_cache[unit] ]
	return c.r, c.g, c.b, self.dbx.opacity or 1
end

function TargetIcon:GetIcon(unit)
	return iconTexture[ target_cache[unit] ]
end

function TargetIcon:GetText(unit)
	return iconText[ target_cache[unit] ]
end

local function CreateTargetIcon(baseKey, dbx)
	Grid2:RegisterStatus(TargetIcon, {"color", "icon", "text"}, baseKey, dbx)
	return TargetIcon
end

Grid2.setupFunc["raid-icon-target"] = CreateTargetIcon

local player_cache= setmetatable({}, {__index = function(t,unit) 
	local v= GetRaidTargetIndex(unit) or false
	t[unit]= v 
	return v
end})

function TargetIconPlayer:UpdateAllUnits()
	for unit, _ in Grid2:IterateRosterUnits() do
		local prev= rawget( player_cache, unit )
		local new = GetRaidTargetIndex(unit) or false
		if new ~= prev then
			player_cache[unit] = new
			self:UpdateIndicators(unit)
		end
	end
end

function TargetIconPlayer:OnEnable()
	self:RegisterEvent("RAID_TARGET_UPDATE", "UpdateAllUnits")
end

function TargetIconPlayer:OnDisable()
	self:UnregisterEvent("RAID_TARGET_UPDATE")
	wipe(player_cache)
end

function TargetIconPlayer:IsActive(unit)
	return player_cache[unit]
end

function TargetIconPlayer:GetColor(unit)
	local c = self.dbx[ "color" .. player_cache[unit] ]
	return c.r, c.g, c.b, self.dbx.opacity or 1
end

function TargetIconPlayer:GetIcon(unit)
	return iconTexture[ player_cache[unit] ]
end

function TargetIconPlayer:GetText(unit)
	return iconText[ player_cache[unit] ]
end

local function CreateTargetIconPlayer(baseKey, dbx)
	Grid2:RegisterStatus(TargetIconPlayer, {"color", "icon", "text"}, baseKey, dbx)

	return TargetIconPlayer
end

Grid2.setupFunc["raid-icon-player"] = CreateTargetIconPlayer
