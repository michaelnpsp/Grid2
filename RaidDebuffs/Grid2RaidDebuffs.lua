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
local WorldMapAreaID

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
	local zone = self:GetCurrentZone()
	if zone==curzone and event then return end
	curzonetype = select(2,GetInstanceInfo())
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
	return UnitMap("player")
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
		local db = self.dbx.debuffs[ WorldMapAreaID[curzone] ]
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
	if not Grid2:DbGetValue("versions", "Grid2RaidDebuffs") then 
		Grid2:DbSetMap( "icon-center", "raid-debuffs", 155)
		Grid2:DbSetValue("versions","Grid2RaidDebuffs",1)
	end	
end

-- Battle for Azeroth compatibility stuff: WorldMapAreaID[ UiMapID ] = old_map_Id
-- see https://wow.gamepedia.com/Patch_8.0.1/API_changes
WorldMapAreaID = {
4,4,4,4,4,4,9,9,9,11,11,13,14,16,17,17,
19,20,20,20,21,22,23,23,24,26,27,27,27,27,27,28,
28,28,28,29,30,30,30,30,30,32,32,32,32,32,34,35,
36,37,38,39,39,39,39,40,41,41,41,41,41,42,43,61,
81,101,101,101,121,141,161,161,161,161,161,181,182,201,201,241,
261,261,281,301,321,321,341,362,381,382,401,443,461,462,463,463,
464,464,464,465,466,467,471,473,475,476,477,478,479,480,481,482,
485,486,488,490,491,492,493,495,496,499,501,502,504,504,510,512,
520,521,521,522,523,523,523,524,524,525,525,526,527,528,528,528,
528,528,529,529,529,529,529,529,530,530,531,532,533,533,533,534,
534,535,535,535,535,535,535,536,540,541,542,543,543,544,544,544,
544,544,545,545,545,545,601,602,603,604,604,604,604,604,604,604,
604,605,605,605,605,606,607,609,610,611,613,614,615,626,640,640,
640,673,0,0,680,0,0,0,684,685,686,687,688,688,688,689,
690,691,691,691,691,692,692,696,697,699,699,699,699,699,699,699,
700,704,704,708,709,710,717,718,720,721,721,721,721,721,721,722,
722,723,723,724,725,726,727,727,728,729,730,730,731,731,731,732,
733,734,736,737,747,0,749,750,750,752,753,753,754,754,755,755,
755,755,756,756,757,758,758,758,759,759,759,760,761,762,762,762,
762,763,763,763,763,764,764,764,764,764,764,764,765,765,766,766,
766,767,767,768,769,0,772,773,775,776,779,780,781,782,789,789,
793,795,796,796,796,796,796,796,796,796,797,798,798,799,799,799,
799,799,799,799,799,799,799,799,799,799,799,799,799,799,800,800,
800,803,806,806,806,806,806,807,807,808,809,809,809,809,809,809,
809,809,809,810,810,811,811,811,811,811,811,811,813,816,819,819,
820,820,820,820,820,820,823,823,824,824,824,824,824,824,824,851,
856,857,857,857,857,858,860,862,864,864,866,866,867,867,871,871,
873,873,874,874,875,875,876,876,876,876,877,877,877,877,878,880,
881,882,883,884,885,885,885,886,887,887,887,888,889,890,891,891,
892,892,893,894,895,895,896,896,896,897,897,898,898,898,898,899,
900,900,906,0,0,911,912,914,914,919,919,919,919,919,919,919,
919,920,922,922,924,924,925,928,928,928,929,930,930,930,930,930,
930,930,930,933,933,934,935,937,937,938,939,940,941,941,941,941,
941,941,941,941,941,945,946,946,946,946,947,947,947,948,949,949,
949,949,949,949,949,950,950,950,950,951,951,953,953,953,953,953,
953,953,953,953,953,953,953,953,953,953,955,962,964,969,969,969,
970,970,971,971,971,973,0,0,976,976,976,978,978,980,0,983,
984,986,987,988,988,988,988,988,989,989,0,0,0,993,993,993,
993,994,994,994,994,994,994,995,995,995,1007,1008,1008,1009,1010,1011,
1014,1014,1014,1014,1014,1015,1015,1015,1015,1017,1017,1017,1017,1017,1017,1017,
1018,1018,1018,1018,1020,1021,1021,1021,1022,1024,1024,1024,1024,1024,1024,1024,
1024,1024,1024,1024,1026,1026,1026,1026,1026,1026,1026,1026,1026,1026,1027,1028,
1028,1028,1028,1031,1032,1032,1032,1033,1033,1033,1033,1033,1033,1033,1033,1033,
1033,1033,1033,1033,1033,1034,1035,1037,1038,1039,1039,1039,1039,1040,1041,1041,
1041,1042,1042,1042,1044,1045,1045,1045,1046,1047,1048,1049,1050,1051,1052,1052,
1052,0,1054,0,1056,1057,0,1059,1060,0,1065,1066,1067,1068,1068,1069,
1070,1071,1072,1073,1073,1075,1075,1076,1076,1076,1077,1078,1079,1080,1081,1081,
1081,1081,1081,1081,1082,1084,1085,1086,1087,1087,1087,1088,1088,1088,1088,1088,
1088,1088,1088,1088,1090,1090,1091,1092,1094,1094,1094,1094,1094,1094,1094,1094,
1094,1094,1094,1094,1094,1096,1097,1097,1099,1100,1100,1100,1100,1102,1104,1104,
1104,1104,1104,1105,1105,1114,1114,1114,1115,1115,1115,1115,1115,1115,1115,1115,
1115,1115,1115,1115,1115,1115,1116,1126,1127,1129,1130,1131,1132,1135,1135,1135,
1135,1136,1137,1137,1139,1140,1142,1143,1143,1143,1144,1145,1146,1146,1146,1146,
1146,1147,1147,1147,1147,1147,1147,1147,1148,1149,1150,1151,1152,1153,1154,1155,
1156,1156,1157,1158,1159,1159,1160,1161,1161,1161,1162,1163,1164,1165,1165,1165,
1166,1170,1170,1170,1171,1171,1171,1172,1173,1173,1174,1174,1174,1174,1175,1176,
1177,1177,1177,1177,1177,1177,1178,1183,1184,1185,1186,1187,1188,1188,1188,1188,
1188,1188,1188,1188,1188,1188,1188,1188,1190,1191,1192,1193,1194,1195,1196,1197,
1198,1199,1200,1201,1202,1204,1204,1205,0,1210,1211,1212,1212,1213,1214,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,1215,1216,1217,1219,1219,1219,
1219,1219,1219,1219,1220,0,0,0,0,0,0,0,0,0,0,0,
0,1184,0,0,0,382,}
setmetatable( WorldMapAreaID, { __index = function(t,k) return k end } )
-- publish the table, used by Grid2RaidDebuffsOptions
GSRD.WorldMapAreaID = WorldMapAreaID
