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
API.GetSpellBookItemInfo = GetSpellBookItemInfo or function(id, type)
    local bookType, typeName
    if type == "spell" then bookType = Enum.SpellBookSpellBank.Player end
    local type, spellID = C_SpellBook.GetSpellBookItemType(id, bookType)
    if type == Enum.SpellBookItemType.None then typeName = "NONE" end
    if type == Enum.SpellBookItemType.Spell then typeName = "SPELL" end
    if type == Enum.SpellBookItemType.FutureSpell then typeName = "FUTURESPELL" end
    if type == Enum.SpellBookItemType.PetAction then typeName = "PETACTION" end
    if type == Enum.SpellBookItemType.Flyout then typeName = "FLYOUT" end
    return typeName, spellID
end

-- Publish functions
Grid2.API = API
