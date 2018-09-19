-- Raid Debuffs module, implements raid-debuffs statuses

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local GSRD = Grid2:NewModule("Grid2RaidDebuffs")
local frame = CreateFrame("Frame")

local Grid2 = Grid2
local next = next
local ipairs = ipairs
local strfind = strfind
local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo

GSRD.defaultDB = { profile = { debuffs = {}, enabledModules = {} } }

-- general variables
local instance_id
local instance_map_id
local instance_map_name
local statuses = {}
local spells_order = {}
local spells_status = {}
local spells_count = 0

-- autdetect debuffs variables
local auto_status
local auto_time
local auto_boss
local auto_instance
local auto_debuffs
local auto_blacklist = { [160029] = true, [36032] = true, [6788] = true, [80354] = true, [95223] = true, [114216] = true }

-- LDB Tooltip
Grid2.tooltipFunc['RaidDebuffsCount'] = function(tooltip)
	if instance_map_name then
		tooltip:AddDoubleLine( instance_map_name, string.format("|cffff0000%d|r %s",spells_count,L['debuffs']), 255,255,255, 255,255,0)
	end
end

-- GSRD 
frame:SetScript("OnEvent", function (self, event, unit)
	if not next(Grid2:GetUnitFrames(unit)) then return end
	local index = 1
	while true do
		local name, te, co, ty, du, ex, ca, _, _, id, _, isBoss = UnitDebuff(unit, index)
		if not name then break end
		local order = spells_order[name]
		if not order then
			order, name = spells_order[id], id
		end
		if order then
			spells_status[name]:AddDebuff(order, te, co, ty, du, ex)
		elseif auto_time and (not auto_blacklist[id]) and (ex<=0 or du<=0 or ex-du>=auto_time) then
			order = GSRD:RegisterNewDebuff(id, ca, te, co, ty, du, ex, isBoss)
			if order then
				auto_status:AddDebuff(order, te, co, ty, du, ex)
			end	
		end
		index = index + 1
	end
	for status in next, statuses do
		status:UpdateState(unit)
	end
end)

function GSRD:OnModuleEnable()
	self:UpdateZoneSpells(true)
end

function GSRD:OnModuleDisable()
	self:ResetZoneSpells()
end

function GSRD:UpdateZoneSpells(event)
	local bm = C_Map.GetBestMapForUnit("player")
	if bm then
		local map_id = select(8,GetInstanceInfo()) + 100000 -- +100000 to avoid collisions with instance_id
		if event and map_id==instance_map_id then return end
		self:ResetZoneSpells()
		instance_id = EJ_GetInstanceForMap(bm)
		instance_map_id = map_id
		instance_map_name = GetInstanceInfo()
		for status in next,statuses do
			status:LoadZoneSpells()
		end
		self:UpdateEvents()
		self:ClearAllIndicators()
	else
		C_Timer.After(3, function() self:UpdateZoneSpells(true) end )
	end
end

function GSRD:GetCurrentZone()
	return instance_id, instance_map_id
end

function GSRD:ClearAllIndicators()
	for status in next, statuses do
		status:ClearAllIndicators()
	end	
end

function GSRD:ResetZoneSpells()
	instance_id = nil
	instance_map_id = nil
	instance_map_name = nil
	wipe(spells_order)
	wipe(spells_status)
end

function GSRD:UpdateEvents()
	local new = not ( next(spells_order) or auto_status )
	local old = not frame:IsEventRegistered("UNIT_AURA")
	if new ~= old then
		if new then
			frame:UnregisterEvent("UNIT_AURA")					
		else
			frame:RegisterEvent("UNIT_AURA")
		end
	end
end

function GSRD:Grid_UnitLeft(_, unit)
	for status in next, statuses do
		status:ResetState(unit)
	end	
end

-- raid debuffs autodetection
function GSRD:RegisterNewDebuff(spellId, caster, te, co, ty, du, ex, isBoss)
	if (not isBoss) and (caster and Grid2:IsGUIDInRaid(UnitGUID(caster))) then return end
	if not auto_debuffs then
		self:RegisterEncounter()
	end	
	local debuffs = auto_status.dbx.debuffs[auto_instance]
	if not debuffs then
		debuffs = {}; auto_status.dbx.debuffs[auto_instance] = debuffs
	end
	local order = #debuffs + 1
	spells_order[spellId]  = order
	spells_status[spellId] = auto_status
	debuffs[order] = spellId
	auto_debuffs[#auto_debuffs+1] = spellId
	return order
end

function GSRD:RegisterEncounter(encounterName)
	encounterName = encounterName or auto_boss or self:GetBossName()
	auto_instance = IsInInstance() and instance_id or instance_map_id
	local debuffs = self.db.profile.debuffs[auto_instance]
	if not debuffs then
		debuffs = { { id = auto_instance, name = instance_map_name, raid = IsInRaid() or nil } }
		self.db.profile.debuffs[auto_instance] = debuffs
	end
	auto_debuffs = debuffs[encounterName]
	if not auto_debuffs then
		local instance = (instance_id or 0)>0 and instance_id or 1028 -- 0=>asuming Azeroth worldmap (1028)
		local encOrder, encName, encID, _ = 0
		EJ_SelectInstance(instance)
		repeat
			encOrder = encOrder + 1
			encName, _, encID = EJ_GetEncounterInfoByIndex(encOrder, instance)
		until encName==nil or encName == encounterName
		auto_debuffs = { order = encOrder, ejid = encID }
		debuffs[encounterName] = auto_debuffs
	end
end

function GSRD:GetBossName()
	return UnitName("boss1") or ((UnitLevel("target")==-1 or UnitLevel("target")>=GetMaxPlayerLevel()+2) and UnitName("target")) or "unknown"
end

function GSRD:ENCOUNTER_START(_,encounterID,encounterName)
	self:RegisterEncounter(encounterName)
end	

function GSRD:PLAYER_REGEN_DISABLED()
	auto_time = GetTime()
	auto_boss = self:GetBossName()
end

function GSRD:PLAYER_REGEN_ENABLED()
	if not UnitIsDeadOrGhost("player") then
		auto_time = nil
		auto_boss = nil
		auto_debuffs = nil
	end	
end

function GSRD:EnableAutodetect(status)
	auto_status = status
	self:UpdateEvents()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ENCOUNTER_START")
	if InCombatLockdown() then self:PLAYER_REGEN_DISABLED()	end	
end

function GSRD:DisableAutodetect()
	auto_status  = nil
	auto_time    = nil
	auto_boss    = nil
	auto_debuffs = nil
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("ENCOUNTER_START")
	self:UpdateEvents()	
end

-- statuses
local class = {
	GetColor          = Grid2.statusLibrary.GetColor,
	IsActive          = function(self, unit) return self.states[unit]      end,
	GetIcon           = function(self, unit) return self.textures[unit]    end,
	GetCount          = function(self, unit) return self.counts[unit]      end,
	GetDuration       = function(self, unit) return self.durations[unit]   end,
	GetExpirationTime = function(self, unit) return self.expirations[unit] end,
}	

function class:ClearAllIndicators()
	local states = self.states
	for unit in pairs(states) do
		states[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function class:LoadZoneSpells()
	if instance_map_id then
		spells_count = 0
		local db = self.dbx.debuffs[ instance_map_id ] or self.dbx.debuffs[ instance_id ]
		if db then
			for index, spell in ipairs(db) do
				local name = spell<0 and -spell or GetSpellInfo(spell)
				if name and (not spells_order[name]) then
					spells_order[name]  = index
					spells_status[name] = self
					spells_count = spells_count + 1
				end
			end
		end
		if GSRD.debugging then
			GSRD:Debug("Zone [%s][%d/%d] Status [%s]: %d raid debuffs loaded", instance_map_name, instance_id, instance_map_id, self.name, spells_count)
		end
	end	
end

function class:OnEnable()
	if not next(statuses) then
		GSRD:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateZoneSpells")
		GSRD:RegisterMessage("Grid_UnitLeft")
	end
	statuses[self] = true
	self:LoadZoneSpells()
	GSRD:UpdateEvents()
end

function class:OnDisable()
	statuses[self] = nil
	if not next(statuses) then
		GSRD:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		GSRD:UnregisterMessage("Grid_UnitLeft")
		GSRD:ResetZoneSpells()
		GSRD:UpdateEvents()
	end	
end

function class:AddDebuff(order, te, co, ty, du, ex, id)
	if order < self.order or ( order == self.order and co > self.count ) then
		self.order      = order
		self.count      = co
		self.texture    = te
		self.type       = ty
		self.duration   = du
		self.expiration = ex
	end
end

function class:UpdateState(unit)
	if self.order<10000 then
		if self.count==0 then self.count = 1 end
		if	true            ~= self.states[unit]    or 
			self.count      ~= self.counts[unit]    or 
			self.type       ~= self.types[unit]     or
			self.texture    ~= self.textures[unit]  or
			self.duration   ~= self.durations[unit] or	
			self.expiration ~= self.expirations[unit]
		then
			self.states[unit]      = true
			self.counts[unit]      = self.count
			self.textures[unit]    = self.texture
			self.types[unit]       = self.type
			self.durations[unit]   = self.duration
			self.expirations[unit] = self.expiration
			self:UpdateIndicators(unit)
		end
		self.order, self.count = 10000, 0
	elseif self.states[unit] then
		self.states[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function class:ResetState(unit)
	self.states[unit]      = nil
	self.counts[unit]      = nil
	self.textures[unit]    = nil
	self.types[unit]       = nil
	self.durations[unit]   = nil
	self.expirations[unit] = nil
end

local function Create(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.states      = {}
	status.textures    = {}
	status.counts      = {}
	status.types       = {}
	status.durations   = {}
	status.expirations = {}
	status.count       = 0
	status.order       = 10000
	status:Inject(class)
	Grid2:RegisterStatus(status, { "icon", "color" }, baseKey, dbx)
	return status
end

Grid2.setupFunc["raid-debuffs"] = Create

Grid2:DbSetStatusDefaultValue( "raid-debuffs", {type = "raid-debuffs", debuffs={}, color1 = {r=1,g=.5,b=1,a=1}} )

-- Hook to update database config
local prev_UpdateDefaults = Grid2.UpdateDefaults
function Grid2:UpdateDefaults()
	prev_UpdateDefaults(self)
	local version = Grid2:DbGetValue("versions", "Grid2RaidDebuffs") or 0
	if version >= 4 then return end
	if version == 0 then 
		Grid2:DbSetMap( "icon-center", "raid-debuffs", 155)
	else -- Remove all enabled debuffs
		for _,db in pairs(Grid2.db.profile.statuses) do
			if db.type == "raid-debuffs" then
				db.debuffs = {}
			end
		end
		GSRD.db.profile.debuffs = {}
		GSRD.db.profile.enabledModules = {}
	end
	Grid2:DbSetValue("versions","Grid2RaidDebuffs",4)
end

-- Hook to load Grid2RaidDebuffOptions module
local prev_LoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
	LoadAddOn("Grid2RaidDebuffsOptions")
	prev_LoadOptions(self)
end
