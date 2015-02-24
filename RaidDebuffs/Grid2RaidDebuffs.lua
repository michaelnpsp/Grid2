-- Raid Debuffs module, implements raid-debuffs statuses

local GSRD = Grid2:NewModule("Grid2RaidDebuffs")
local frame = CreateFrame("Frame")

local Grid2 = Grid2
local next = next
local ipairs = ipairs
local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo
local UnitLevel = UnitLevel
local UnitClassification = UnitClassification
local UnitAffectingCombat = UnitAffectingCombat

GSRD.defaultDB = { profile = { autodetect = { zones = {}, debuffs = {}, incoming = {} }, debuffs = {}, enabledModules = {} } }

-- general variables
local curzone
local curzonetype
local statuses = {}
local spells_order = {}
local spells_status = {}

-- autdetect debuffs variables
local status_auto
local boss_auto
local time_auto
local timer_auto
local spells_known
local get_known_spells

-- GSRD 
frame:SetScript("OnEvent", function (self, event, unit)
	if not next(Grid2:GetUnitFrames(unit)) then return end
	local index = 1
	while true do
		local name, _, te, co, ty, du, ex, ca, _, _, id, _, isBoss = UnitDebuff(unit, index)
		if not name then break end
		local order = spells_order[name]
		if not order then
			order, name = spells_order[id], id
		end
		if order then
			spells_status[name]:AddDebuff(order, te, co, ty, du, ex)
		elseif time_auto and (not spells_known[id]) and (ex<=0 or du<=0 or ex-du>=time_auto) then
			GSRD:RegisterNewDebuff(id, ca, te, co, ty, du, ex, isBoss)
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
	if status_auto then	self:RegisterNewZone(zone) end
	self:ResetZoneSpells(zone)
	for status in next,statuses do
		status:LoadZoneSpells()
	end
	self:UpdateEvents()
	self:ClearAllIndicators()
end

function GSRD:GetCurrentZone()
	local current_zone_on_worldmap = GetCurrentMapAreaID()
	SetMapToCurrentZone()
	local zone = GetCurrentMapAreaID()
	if zone ~= current_zone_on_worldmap then 
		SetMapByID(current_zone_on_worldmap) 
	end
	return zone
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
function GSRD:RegisterNewZone(zone)
	if zone then
		if IsInInstance() then
			self.db.profile.autodetect.zones[zone] = true
		end
		spells_known = get_known_spells and get_known_spells(zone) or {}
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
	--
	if (not boss_auto) then	boss_auto = self:CheckBossUnit(caster) end
	--
	self:ProcessIncomingDebuff(spellId)
	--
	spells_order[spellId]  = order
	spells_status[spellId] = status_auto
	status_auto:AddDebuff(order, te, co, ty, du, ex)
end

function GSRD:ProcessIncomingDebuff(spellId)
	local zone =  curzone .. '@' ..(EJ_GetCurrentInstance() or 0)
	if boss_auto then
		self.db.profile.autodetect.debuffs[spellId] = zone .. '@' .. boss_auto
	else
		self.db.profile.autodetect.incoming[spellId] = zone
	end
end

function GSRD:ProcessIncomingDebuffs(boss)
	local incoming = self.db.profile.autodetect.incoming
	if next(incoming) then
		local debuffs = self.db.profile.autodetect.debuffs
		boss = boss or ""
		for spellId,zone in pairs(incoming) do
			debuffs[spellId] = zone .. '@' .. boss
		end
		wipe(incoming)
	end	
end

function GSRD:EnableAutodetect(status, func)
	status_auto = status
	get_known_spells = func or get_known_spells
	self:UpdateEvents()
	self:RegisterNewZone(curzone)
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if InCombatLockdown() then self:PLAYER_REGEN_DISABLED()	end	
end

function GSRD:DisableAutodetect()
	self:ProcessIncomingDebuffs(boss_auto)
	self:CancelBossTimer()
	time_auto    = nil
	status_auto  = nil
	spells_known = nil
	self:UpdateEvents()	
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

-- boss heuristic detection
function GSRD:CheckBossUnit(unit)
	if unit and UnitAffectingCombat(unit) then
		local level = UnitLevel(unit)
		local isBoss = level==-1
		if not isBoss then
			local class = UnitClassification(unit) or ""
			isBoss = string.find(class, "boss")
			if (not isBoss) and curzonetype=="party" then -- 5 man instances bosses
				isBoss = class == "elite" and level>=GetMaxPlayerLevel()+2 
			end
		end
		if isBoss then 
			return UnitName(unit)
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
				self:ProcessIncomingDebuffs(boss_auto) 
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
	self:ProcessIncomingDebuffs(boss_auto)
	time_auto = GetTime()
	boss_auto = self:CheckBossFrame() or self:CheckBossUnit("target") or self:CheckBossUnit("targettarget") or self:CheckBossUnit("focus")
	self:CreateBossTimer()
end

function GSRD:PLAYER_REGEN_ENABLED()
	self:ProcessIncomingDebuffs(boss_auto)
	if UnitIsDeadOrGhost("player") then return end
	self:CancelBossTimer()
	time_auto = nil
	boss_auto = nil
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
		local db = self.dbx.debuffs[curzone]
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
