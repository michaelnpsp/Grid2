-- Compatibility API functions to enable targetting different versions of the game

local API = {}

-- GetSpellInfo()
local C_Spell_GetSpellInfo = C_Spell and C_Spell.GetSpellInfo
API.GetSpellInfo = GetSpellInfo or function(spellID)
	if spellID then
		local spellInfo = C_Spell_GetSpellInfo(spellID)
		if spellInfo then
			return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
		end
	end
end

-- IsSpellInRange()
local C_Spell_IsSpellInRange = C_Spell.IsSpellInRange
API.IsSpellInRange = IsSpellInRange or function(id, unit)
    local result = C_Spell_IsSpellInRange(id, unit)
    if result == true then
      return 1
    elseif result == false then
      return 0
    end
    return nil
end

-- GetSpellCooldown()
local C_Spell_GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown
API.GetSpellCooldown = GetSpellCooldown or function(spellID)
	local spellCooldownInfo = C_Spell_GetSpellCooldown(spellID)
	if spellCooldownInfo then
		return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate
	end
end

-- GetTexCoordsForRole()
local GetTexCoordsByGrid = GetTexCoordsByGrid
API.GetTexCoordsForRole = GetTexCoordsForRole or function(role)
    if role == "GUIDE" then
        return GetTexCoordsByGrid(1, 1, 256, 256, 67, 67)
    elseif role == "TANK" then
        return GetTexCoordsByGrid(1, 2, 256, 256, 67, 67)
    elseif role == "HEALER" then
        return GetTexCoordsByGrid(2, 1, 256, 256, 67, 67)
    elseif role == "DAMAGER" then
        return GetTexCoordsByGrid(2, 2, 256, 256, 67, 67)
    else
        error("Unknown role: "..tostring(role))
    end
end

-- GetBackgroundTexCoordsForRole()
local GetTexCoordsByGrid = GetTexCoordsByGrid
API.GetBackgroundTexCoordsForRole = GetBackgroundTexCoordsForRole or function(role)
    if role == "TANK" then
        return GetTexCoordsByGrid(2, 1, 256, 128, 75, 75)
    elseif role == "HEALER" then
        return GetTexCoordsByGrid(1, 1, 256, 128, 75, 75)
    elseif role == "DAMAGER" then
        return GetTexCoordsByGrid(3, 1, 256, 128, 75, 75)
    else
        error("Role does not have background: "..tostring(role))
    end
end

-- GetTexCoordsForRoleSmallCircle()
API.GetTexCoordsForRoleSmallCircle = GetTexCoordsForRoleSmallCircle or function(role)
    if role == "TANK" then
        return 0, 19/64, 22/64, 41/64
    elseif role == "HEALER" then
        return 20/64, 39/64, 1/64, 20/64
    elseif role == "DAMAGER" then
        return 20/64, 39/64, 22/64, 41/64
    else
        error("Unknown role: "..tostring(role))
    end
end

-- GetTexCoordsForRoleSmall()
API.GetTexCoordsForRoleSmall = GetTexCoordsForRoleSmall or function(role)
    if role == "TANK" then
        return 0.5, 0.75, 0, 1
    elseif role == "HEALER" then
        return 0.75, 1, 0, 1
    elseif role == "DAMAGER" then
        return 0.25, 0.5, 0, 1
    else
        error("Unknown role: "..tostring(role))
    end
end

--  GetSpellBookItemInfo()
do
	local C_SpellBook_GetSpellBookItemType = C_SpellBook.GetSpellBookItemType
	local bookTypes = { [0] = 'NONE', [1] = 'SPELL', [2] = 'FUTURESPELL', [3] = 'PETACTION', [4] = 'FLYOUT' }
	API.GetSpellBookItemInfo = GetSpellBookItemInfo or function(id, type)
		local typeID, actionID, spellID = C_SpellBook_GetSpellBookItemType(id, type=='pet' and 1 or 0)
		return bookTypes[typeID], spellID or actionID
	end
end

-- Publish functions
Grid2.API = API
