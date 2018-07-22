-- Raid Debuffs module, implements raid-debuffs statuses

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
local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitMap   = C_Map.GetBestMapForUnit
local UnitClassification = UnitClassification
local UnitAffectingCombat = UnitAffectingCombat

GSRD.defaultDB = { profile = { autodetect = { zones = {}, debuffs = {}, incoming = {} }, debuffs = {}, enabledModules = {} } }

-- general variables
local curzone
local curzonetype
local statuses = {}
local spells_order = {}
local spells_status = {}

-- old map ids table
local MapIDToInstID

-- autdetect debuffs variables
local status_auto
local boss_auto
local time_auto
local timer_auto
local spells_known
local bosses_known
local get_known_spells
local get_known_bosses

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
		elseif time_auto and (not spells_known[id]) and (ex<=0 or du<=0 or ex-du>=time_auto) then
			order = GSRD:RegisterNewDebuff(id, ca, te, co, ty, du, ex, isBoss)
			if order then
				status_auto:AddDebuff(order, te, co, ty, du, ex)
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
	local zone, type = self:GetCurrentZone()
	if zone==curzone and event then return end
	curzonetype = type
	self:ResetZoneSpells(zone)
	for status in next,statuses do
		status:LoadZoneSpells()
	end
	self:UpdateEvents()
	self:ClearAllIndicators()
	if status_auto then	
		self:RegisterNewZone() 
	end
end

function GSRD:GetCurrentZone()
	local _,type,_,_,_,_,_,zone = GetInstanceInfo()
	return zone, type
end

function GSRD:ClearAllIndicators()
	for status in next, statuses do
		status:ClearAllIndicators()
	end	
end

function GSRD:ResetZoneSpells(newzone)
	curzone = newzone
	wipe(spells_order)
	wipe(spells_status)
end

function GSRD:UpdateEvents()
	local new = not ( next(spells_order) or status_auto )
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

-- zones & debuffs autodetection
function GSRD:RegisterNewZone()
	if curzone then
		if IsInInstance() then
			self.db.profile.autodetect.zones[curzone] = true
		end
		spells_known = get_known_spells(curzone)
	end
end

function GSRD:RegisterNewDebuff(spellId, caster, te, co, ty, du, ex, isBoss)
	spells_known[spellId] = true
	if (not isBoss) and (caster and Grid2:IsGUIDInRaid(UnitGUID(caster))) then return end
	--
	local zone = status_auto.dbx.debuffs[curzone]
	if not zone then
		zone = {}; status_auto.dbx.debuffs[curzone] = zone
	end
	local order = #zone + 1
	zone[order] = spellId
	spells_order[spellId]  = order
	spells_status[spellId] = status_auto
	--
	if (not boss_auto) then	
		boss_auto = self:CheckBossUnit(caster) 
	end
	--
	local zone_name = curzone .. '@' .. EJ_GetInstanceForMap( UnitMap("player") )
	if boss_auto then
		self.db.profile.autodetect.debuffs[spellId] = zone_name .. '@' .. boss_auto
	else
		self.db.profile.autodetect.incoming[spellId] = zone_name
	end
	--
	return order
end

function GSRD:ProcessIncomingDebuffs()
	local incoming = self.db.profile.autodetect.incoming
	if next(incoming) then
		local debuffs = self.db.profile.autodetect.debuffs
		for spellId,zone in pairs(incoming) do
			debuffs[spellId] = zone .. '@' .. (boss_auto or "")
		end
		wipe(incoming)
	end	
end

function GSRD:EnableAutodetect(status, func_spells, func_bosses)
	status_auto = status
	get_known_spells = func_spells or get_known_spells
	get_known_bosses = func_bosses or get_known_bosses
	self:UpdateEvents()
	self:RegisterNewZone()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if InCombatLockdown() then self:PLAYER_REGEN_DISABLED()	end	
end

function GSRD:DisableAutodetect()
	self:ProcessIncomingDebuffs()
	self:CancelBossTimer()
	time_auto     = nil
	status_auto   = nil
	spells_known  = nil
	bosses_known  = nil
	self:UpdateEvents()	
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

-- boss heuristic detection
function GSRD:CheckBossUnit(unit)
	if unit and UnitAffectingCombat(unit) then
		local name  = UnitName(unit)
		local level = UnitLevel(unit)
		local class = UnitClassification(unit)
		if level==-1 or (bosses_known and bosses_known[name]) or strfind(class or "", "boss") or (curzonetype=="party" and class=="elite" and level>=GetMaxPlayerLevel()+2) then 
			return name
		end
	end
end

function GSRD:CheckBossFrame()
	local boss = UnitName("boss1")
	if boss and boss ~= UNKNOWNOBJECT then 
		return boss
	end
end

function GSRD:CreateBossTimer()
	if not (boss_auto or timer_auto) then
		timer_auto = Grid2:ScheduleRepeatingTimer(function()
			if not boss_auto then
				boss_auto = self:CheckBossFrame() or self:CheckBossUnit("target") or self:CheckBossUnit("targettarget")
			end
			if boss_auto then
				self:CancelBossTimer()
				self:ProcessIncomingDebuffs() 
			end
		end, 1.5)
	end	
end

function GSRD:CancelBossTimer()
	if timer_auto then
		Grid2:CancelTimer(timer_auto)
		timer_auto = nil
	end
end

function GSRD:PLAYER_REGEN_DISABLED()
	self:ProcessIncomingDebuffs()
	time_auto = GetTime()
	-- It's more correct to collect zone bosses from RegisterNewZone(), but EJ_GetCurrentInstance() returns a wrong instanceID 
	-- (the previous instanceID) just after a zone change, so we cannot collect known boses in the zone_change event.
	bosses_known = get_known_bosses( EJ_GetInstanceForMap( UnitMap("player") ) ) 
	boss_auto = self:CheckBossFrame() or self:CheckBossUnit("target") or self:CheckBossUnit("targettarget") or self:CheckBossUnit("focus")
	self:CreateBossTimer()
end

function GSRD:PLAYER_REGEN_ENABLED()
	self:ProcessIncomingDebuffs()
	if not UnitIsDeadOrGhost("player") then
		self:CancelBossTimer()
		time_auto = nil
		boss_auto = nil
	end	
end

-- Old databases fix
function GSRD:FixOldDatabase(db, key)
	if db[key] then
		local fixed = {}
		for mapID, data in pairs(db[key]) do
			local instID = MapIDToInstID[mapID]
			if instID then
				fixed[instID] = data	
			end
		end
		db[key] = fixed
	end	
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
	if curzone then
		local count = 0
		local db = self.dbx.debuffs[ curzone ]
		if db then
			for index, spell in ipairs(db) do
				local name = spell<0 and -spell or GetSpellInfo(spell)
				if name and (not spells_order[name]) then
					spells_order[name]  = index
					spells_status[name] = self
					count = count + 1
				end
			end
		end
		if GSRD.debugging then
			GSRD:Debug("Zone [%s] Status [%s]: %d raid debuffs loaded", curzone or "", self.name, count)
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

-- Hook to load Grid2RaidDebuffOptions module
local prev_LoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
	LoadAddOn("Grid2RaidDebuffsOptions")
	prev_LoadOptions(self)
end

-- Hook to update database config
local prev_UpdateDefaults = Grid2.UpdateDefaults
function Grid2:UpdateDefaults()
	prev_UpdateDefaults(self)
	local version = Grid2:DbGetValue("versions", "Grid2RaidDebuffs") or 0
	if version >= 3 then return end
	if version == 0 then 
		Grid2:DbSetMap( "icon-center", "raid-debuffs", 155)
	else 
		-- Upgrade statuses debuffs databases: convert mapIDs to InstanceIDs
		for name,db in pairs(Grid2.db.profile.statuses) do
			if db.type == "raid-debuffs" then
				GSRD:FixOldDatabase( db, "debuffs" )
			end
		end
		-- Upgrade custom debuffs
		GSRD:FixOldDatabase( GSRD.db.profile, "debuffs" )
	end
	Grid2:DbSetValue("versions","Grid2RaidDebuffs",3)
end

-- Battle for Azeroth upgrade stuff: mapID_to_InstID[ mapID ] = InstanceID
-- InstanceID = select(8,GetInstanceInfo())
-- mapID      = GetCurrentMapAreaID() // this function was removed from api, we must convert mapID to InstanceID
MapIDToInstID = {
-- Burning Crusade Dungeons
[733] = 269, -- Opening of the Dark Portal
[710] = 540, -- Hellfire Citadel: The Shattered Halls
[725] = 542, -- Hellfire Citadel: The Blood Furnace
[797] = 543, -- Hellfire Citadel: Ramparts
[727] = 545, -- Coilfang: The Steamvault
[726] = 546, -- Coilfang: The Underbog
[728] = 547, -- Coilfang: The Slave Pens
[731] = 552, -- Tempest Keep: The Arcatraz
[729] = 553, -- Tempest Keep: The Botanica
[730] = 554, -- Tempest Keep: The Mechanar
[724] = 555, -- Auchindoun: Shadow Labyrinth
[723] = 556, -- Auchindoun: Sethekk Halls
[732] = 557, -- Auchindoun: Mana-Tombs
[722] = 558, -- Auchindoun: Auchenai Crypts
[734] = 560, -- The Escape from Durnholde
[798] = 585, -- Magister's Terrace
-- Burning Crusade Raids
[799] = 532, -- Karazhan
[775] = 534, -- The Battle for Mount Hyjal
[779] = 544, -- Magtheridon's Lair
[780] = 548, -- Coilfang: Serpentshrine Cavern
[782] = 550, -- Tempest Keep
[796] = 564, -- Black Temple
[776] = 565, -- Gruul's Lair
[789] = 580, -- The Sunwell
-- WotLK Dungeons
[523] = 574, -- Utgarde Keep
[524] = 575, -- Utgarde Pinnacle
[520] = 576, -- The Nexus
[528] = 578, -- The Oculus
[521] = 595, -- The Culling of Stratholme
[526] = 599, -- Halls of Stone
[534] = 600, -- Drak'Tharon Keep
[533] = 601, -- Azjol-Nerub
[525] = 602, -- Halls of Lightning
[530] = 604, -- Gundrak
[536] = 608, -- Violet Hold
[522] = 619, -- Ahn'kahet: The Old Kingdom
[601] = 632, -- The Forge of Souls
[542] = 650, -- Trial of the Champion
[602] = 658, -- Pit of Saron
[603] = 668, -- Halls of Reflection
-- WotLK Raids
[535] = 533, -- Naxxramas
[529] = 603, -- Ulduar
[531] = 615, -- The Obsidian Sanctum
[527] = 616, -- The Eye of Eternity
[532] = 624, -- Vault of Archavon
[604] = 631, -- Icecrown Citadel
[543] = 649, -- Trial of the Crusader
[609] = 724, -- The Ruby Sanctum
-- Cataclysm Dungeons
[781] = 568, -- Zul'Aman
[767] = 643, -- Throne of the Tides
[759] = 644, -- Halls of Origination
[753] = 645, -- Blackrock Caverns
[769] = 657, -- The Vortex Pinnacle
[757] = 670, -- Grim Batol
[768] = 725, -- The Stonecore
[747] = 755, -- Lost City of the Tol'vir
[793] = 859, -- Zul'Gurub
[820] = 938, -- End Time
[816] = 939, -- Well of Eternity
[819] = 940, -- Hour of Twilight
[803] = 951, -- Nexus Legendary
-- Cataclysm Raids
[754] = 669, -- Blackwing Descent
[758] = 671, -- The Bastion of Twilight
[800] = 720, -- Firelands
[773] = 754, -- Throne of the Four Winds
[752] = 757, -- Baradin Hold
[824] = 967, -- Dragon Soul
-- Pandaria Dungeons
[877] = 959, -- Shado-Pan Monastery
[867] = 960, -- Temple of the Jade Serpent
[876] = 961, -- Stormstout Brewery
[875] = 962, -- Gate of the Setting Sun
[885] = 994, -- Mogu'shan Palace
[887] = 1011, -- Siege of Niuzao Temple
-- Pandaria Raids
[886] = 996, -- Terrace of Endless Spring
[896] = 1008, -- Mogu'shan Vaults
[897] = 1009, -- Heart of Fear
[930] = 1098, -- Throne of Thunder
[953] = 1136, -- Siege of Orgrimmar
-- Warlords Dungeons
[964] = 1175, -- Bloodmaul Slag Mines
[969] = 1176, -- Shadowmoon Burial Grounds
[984] = 1182, -- Auchindoun
[987] = 1195, -- Iron Docks
[993] = 1208, -- Grimrail Depot
[989] = 1209, -- Skyreach
[1008] = 1279, -- The Everbloom
[995] = 1358, -- Upper Blackrock Spire
-- Warlords Raids
[988] = 1205, -- Blackrock Foundry
[994] = 1228, -- Highmaul
[1026] = 1448, -- Hellfire Citadel
-- Legion Dungeons
[1046] = 1456, -- Eye of Azshara
[1065] = 1458, -- Neltharion's Lair
[1067] = 1466, -- Darkheart Thicket
[1041] = 1477, -- Halls of Valor
[1042] = 1492, -- Maw of Souls
[1045] = 1493, -- Vault of the Wardens
[1081] = 1501, -- Black Rook Hold
[1079] = 1516, -- The Arcway
[1066] = 1544, -- Assault on Violet Hold
[1087] = 1571, -- Court of Stars
[1115] = 1651, -- Return to Karazhan
[1146] = 1677, -- Cathedral of Eternal Night
[1178] = 1753, -- Seat of the Triumvirate
-- Legion Raids
[1094] = 1520, -- The Emerald Nightmare
[1088] = 1530, -- The Nighthold
[1114] = 1648, -- Trial of Valor
[1147] = 1676, -- Tomb of Sargeras
[1188] = 1712, -- Antorus, the Burning Throne
}
