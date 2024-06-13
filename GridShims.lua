-- Compatibility Shims to enable targetting different versions of the game
local GetSpellCooldownShim = function(spellID)
	local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID);
	if spellCooldownInfo then
		return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;
	end
end

local GetSpellInfoShim = function(spellID)
	if not spellID then
		return nil;
	end

	local spellInfo = C_Spell.GetSpellInfo(spellID);
	if spellInfo then
		return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
	end
end

local GetTexCoordsForRoleShim = function(role)
    local textureHeight, textureWidth = 256, 256;
    local roleHeight, roleWidth = 67, 67;

    if ( role == "GUIDE" ) then
        return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
    elseif ( role == "TANK" ) then
        return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
    elseif ( role == "HEALER" ) then
        return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
    elseif ( role == "DAMAGER" ) then
        return GetTexCoordsByGrid(2, 2, textureWidth, textureHeight, roleWidth, roleHeight);
    else
        error("Unknown role: "..tostring(role));
    end
end;

local GetBackgroundTexCoordsForRoleShim = function(role)
    local textureHeight, textureWidth = 128, 256;
    local roleHeight, roleWidth = 75, 75;

    if ( role == "TANK" ) then
        return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
    elseif ( role == "HEALER" ) then
        return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
    elseif ( role == "DAMAGER" ) then
        return GetTexCoordsByGrid(3, 1, textureWidth, textureHeight, roleWidth, roleHeight);
    else
        error("Role does not have background: "..tostring(role));
    end
end;

local GetTexCoordsForRoleSmallCircleShim = function(role)
    if ( role == "TANK" ) then
        return 0, 19/64, 22/64, 41/64;
    elseif ( role == "HEALER" ) then
        return 20/64, 39/64, 1/64, 20/64;
    elseif ( role == "DAMAGER" ) then
        return 20/64, 39/64, 22/64, 41/64;
    else
        error("Unknown role: "..tostring(role));
    end
end;

local GetTexCoordsForRoleSmallShim = function(role)
    if ( role == "TANK" ) then
        return 0.5, 0.75, 0, 1;
    elseif ( role == "HEALER" ) then
        return 0.75, 1, 0, 1;
    elseif ( role == "DAMAGER" ) then
        return 0.25, 0.5, 0, 1;
    else
        error("Unknown role: "..tostring(role));
    end
end

local IsSpellInRangeShim = function(id, unit)
    local result = C_Spell.IsSpellInRange(id, unit)
    if result == true then
      return 1
    elseif result == false then
      return 0
    end
    return nil
end

local GetSpellBookItemInfoShim = function(id, type)
    local bookType
    if(type == "spell") then bookType = Enum.SpellBookSpellBank.Player end

    local type, spellID = C_SpellBook.GetSpellBookItemType(id, bookType) 

    local typeName

    if type == Enum.SpellBookItemType.None then typeName = "NONE" end
    if type == Enum.SpellBookItemType.Spell then typeName = "SPELL" end
    if type == Enum.SpellBookItemType.FutureSpell then typeName = "FUTURESPELL" end
    if type == Enum.SpellBookItemType.PetAction then typeName = "PETACTION" end
    if type == Enum.SpellBookItemType.Flyout then typeName = "FLYOUT" end

    return typeName, spellID
end

Grid2.Shims = {}

Grid2.Shims.GetSpellInfo = GetSpellInfo or GetSpellInfoShim
Grid2.Shims.GetSpellCooldown = GetSpellCooldown or GetSpellCooldownShim
Grid2.Shims.GetTexCoordsForRole = GetTexCoordsForRole or GetTexCoordsForRoleShim
Grid2.Shims.GetBackgroundTexCoordsForRole = GetBackgroundTexCoordsForRole or GetBackgroundTexCoordsForRoleShim
Grid2.Shims.GetTexCoordsForRoleSmallCircle = GetTexCoordsForRoleSmallCircle or GetTexCoordsForRoleSmallCircleShim
Grid2.Shims.GetTexCoordsForRoleSmall = GetTexCoordsForRoleSmall or GetTexCoordsForRoleSmallShim
Grid2.Shims.IsSpellInRange = IsSpellInRange or IsSpellInRangeShim
Grid2.Shims.GetSpellBookItemInfo = GetSpellBookItemInfo or GetSpellBookItemInfoShim