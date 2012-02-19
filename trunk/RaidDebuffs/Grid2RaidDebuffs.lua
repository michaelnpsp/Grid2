--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2 = Grid2
local ipairs = ipairs
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo

local BZ = LibStub("LibBabble-Zone-3.0"):GetReverseLookupTable()
local GSRD = Grid2:NewModule("Grid2RaidDebuffs")
local status = Grid2.statusPrototype:new("raid-debuffs")
local frame = CreateFrame("Frame")
local spells = {}
local states = {}
local textures = {}
local counts = {}
local types = {}
local durations = {}
local expirations = {}

function status:UpdateZoneSpells()
	local db, zone = self:GetCurrentZoneSpells()
	wipe(spells)
	local spell_order = 1
	if db then
		for _, spellId in ipairs(db) do
			local name = spellId<0 and -spellId or GetSpellInfo(spellId)
			if name and (not spells[name]) then
				spells[name] = spell_order
				spell_order = spell_order + 1
			end
		end
	end
	if spell_order == 1 then
		frame:UnregisterEvent("UNIT_AURA")
	else
		frame:RegisterEvent("UNIT_AURA")
	end
	-- Debug Code
	if IsInInstance() then
		GSRD:Debug("Zone [%s]: %d raid debuffs loaded", zone, spell_order-1)
	end
end

function status:GetCurrentZoneSpells()
	local db, zone = self:GetZoneSpells( GetRealZoneText() )
	if not db then 
		db, zone = self:GetZoneSpells( GetInstanceInfo() )
	end
	return db, zone
end

function status:GetZoneSpells(zone)
	if zone then
		zone = BZ[zone] or zone
		return self.dbx.debuffs[zone], zone
	end	
end

function status:Grid_UnitLeft(_, unit)
	states[unit] = nil
	textures[unit] = nil
	counts[unit] = nil
	durations[unit] = nil
	expirations[unit] = nil
end

function status:OnEnable()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateZoneSpells")
	self:RegisterMessage("Grid_UnitLeft")
	self:UpdateZoneSpells()
end

function status:OnDisable()
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterMessage("Grid_UnitLeft")
end

function status:IsActive(unit)
	return states[unit]
end

function status:GetIcon(unit)
	return textures[unit]
end

function status:GetCount(unit)
	return counts[unit]
end

function status:GetDuration(unit)
	return durations[unit]
end

function status:GetExpirationTime(unit)
	return expirations[unit]
end

status.GetColor = Grid2.statusLibrary.GetColor

frame:SetScript("OnEvent", function (self, event, unit)
	local index, n_order, n_count, n_texture, n_type, n_duration, n_expiration = 1, 10000, 0
	while true do
		local name, _, te, count, ty, du, ex, _, _, _, id = UnitDebuff(unit, index)
		if not name then break end
		local order = spells[name] or spells[id]
		if order and ( order < n_order or ( order == n_order and count > n_count ) ) then
			n_order      = order
			n_count      = count
			n_texture    = te
			n_type       = ty
			n_duration   = du
			n_expiration = ex
		end
		index = index + 1
	end
	if n_texture then
		if n_count==0 then n_count = 1 end
		if	true         ~= states[unit]    or 
			n_count      ~= counts[unit]    or 
			n_type       ~= types[unit]     or
			n_texture    ~= textures[unit]  or
			n_duration   ~= durations[unit] or	
			n_expiration ~= expirations[unit]
		then
			states[unit]      = true
			counts[unit]      = n_count
			textures[unit]    = n_texture
			types[unit]       = n_type
			durations[unit]   = n_duration
			expirations[unit] = n_expiration
			status:UpdateIndicators(unit)
		end
	elseif states[unit] then
		states[unit] = nil
		status:UpdateIndicators(unit)
	end
end)

local function Create(baseKey, dbx)
	if not dbx.debuffs then
		dbx.debuffs = {}
	end
	Grid2:RegisterStatus(status, { "icon", "color", "text" }, baseKey, dbx)
	return status
end

Grid2.setupFunc["raid-debuffs"] = Create

Grid2:DbSetStatusDefaultValue( "raid-debuffs", {type = "raid-debuffs", color1 = {r=1,g=.5,b=1,a=1}} )

-- Hook to load Grid2RaidDebuffOptions module
local prev_LoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
	LoadAddOn("Grid2RaidDebuffsOptions")
	prev_LoadOptions()
end

-- Hook to update database config
local prev_UpdateDefaults= Grid2.UpdateDefaults
function Grid2:UpdateDefaults()
	prev_UpdateDefaults(self)
	if not Grid2:DbGetValue("versions", "Grid2RaidDebuffs") then 
		Grid2:DbSetMap( "icon-center", "raid-debuffs", 155)
		Grid2:DbSetValue("versions","Grid2RaidDebuffs",1)
	end	
end
