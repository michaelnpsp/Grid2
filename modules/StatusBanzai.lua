-- banzai & banzai-threat statuses ( created by Michael )

local Banzai
local BanzaiThreat

local Grid2 = Grid2
local next = next
local type = type
local GetTime = GetTime
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local GetSpellInfo = GetSpellInfo
local UnitCanAttack = UnitCanAttack
local roster_units = Grid2.roster_units

local timer
local statuses = {}
local sguids   = {} -- enemy guid -> enemy unit
local tguids   = {} -- enemy guid -> friendly unit targeted by the enemy
local target   = setmetatable({}, {__index = function(t,k) local v=k.."target" t[k]=v return v end})

-- events management
local RegisterEvent, UnregisterEvent
do
	local Events = {}
	local frame
	function RegisterEvent(event, func)
		if not frame then
			frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			frame:SetScript( "OnEvent",  function(_, event, ...) Events[event](...) end )
		end
		frame:RegisterEvent(event)
		Events[event] = func
	end
	function UnregisterEvent(event)
		frame:UnregisterEvent( event )
		Events[event] = nil
	end
end

-- methods and events shared by all statuses
local function CheckEnemyUnit( sunit )
	if UnitCanAttack(sunit, "player") then
		local sg = UnitGUID(sunit)
		if sg and (not sguids[sg]) then
			local tg = UnitGUID( target[sunit] )
			if tg then
				local tunit = roster_units[tg]
				if tunit then
					tguids[sg] = tunit
					sguids[sg] = sunit
				end
			end
		end
	end
end

local extra_units = { focus = true, boss1= true, boss2 = true, boss3 = true, boss4 = true }
local function SearchEnemyUnits()
	for unit in Grid2:IterateRosterUnits() do
		CheckEnemyUnit( target[unit] )
	end
	for unit in next, extra_units do
		CheckEnemyUnit( unit )
	end
end

local function TimerEvent()
	SearchEnemyUnits()
	for status in next,statuses do
		status:Update()
	end
	wipe(sguids)
	wipe(tguids)
end

local function TimerEnable()
	timer = timer or Grid2:CreateTimer( TimerEvent, BanzaiThreat.dbx.updateRate or 0.2 )
end

local function TimerDisable()
	timer = Grid2:CancelTimer(timer)
end

local function CombatEnterEvent()
	if Banzai and Banzai.enabled then
		RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Banzai.CombatLogEvent)
	end
	TimerEnable()
end

local function CombatExitEvent()
	if Banzai and Banzai.enabled then
		UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
	for status in next,statuses do
		status:ClearIndicators()
	end
	TimerDisable()
end

local function PlateAddedEvent(unit)
	if UnitCanAttack(unit, "player") then
		extra_units[unit] = true
	end
end

local function PlateRemovedEvent(unit)
	extra_units[unit] = nil
end

local function status_OnEnable(self)
	if not next(statuses) then
		RegisterEvent("NAME_PLATE_UNIT_ADDED", PlateAddedEvent)
		RegisterEvent("NAME_PLATE_UNIT_REMOVED", PlateRemovedEvent)
		if Grid2.isClassic and BanzaiThreat.dbx.alwaysActive then
			TimerEnable()
		else
			RegisterEvent("PLAYER_REGEN_ENABLED" , CombatExitEvent)
			RegisterEvent("PLAYER_REGEN_DISABLED", CombatEnterEvent)
		end
	end
	if self.UpdateDB then
		self:UpdateDB()
	end
	statuses[self] = true
end

local function status_OnDisable(self)
	statuses[self] = nil
	if not next(statuses) then
		UnregisterEvent("NAME_PLATE_UNIT_ADDED")
		UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
		if Grid2.isClassic and BanzaiThreat.dbx.alwaysActive then
			TimerDisable()
		else
			UnregisterEvent("PLAYER_REGEN_ENABLED")
			UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
	end
end

local function status_SetUpdateRate(self, delay)
	BanzaiThreat.dbx.updateRate = delay
	if Banzai then Banzai.dbx.updateRate = delay end
end

-- banzai-threat status
BanzaiThreat = Grid2.statusPrototype:new("banzai-threat", false)

local units, units_prev = {}, {}

function BanzaiThreat:Update(reset)
	units, units_prev = units_prev, units
	if not reset then
		for g,unit in next, tguids do
			local name = UnitName( sguids[g] )
			units[unit] = name
			units_prev[unit] = units_prev[unit]~=name and name or nil
		end
	end
	for unit in next, units_prev do
		self:UpdateIndicators(unit)
	end
	wipe(units_prev)
end

function BanzaiThreat:ClearIndicators()
	self:Update(true)
end

function BanzaiThreat:IsActive(unit)
	if units[unit] then	return true end
end

function BanzaiThreat:GetText(unit)
	return units[unit]
end

BanzaiThreat.OnEnable  = status_OnEnable
BanzaiThreat.OnDisable = status_OnDisable
BanzaiThreat.SetUpdateRate = status_SetUpdateRate
BanzaiThreat.GetColor  = Grid2.statusLibrary.GetColor

Grid2.setupFunc["banzai-threat"] = function(baseKey, dbx)
	Grid2:RegisterStatus(BanzaiThreat, {"color", "text" }, baseKey, dbx)
	return BanzaiThreat
end

Grid2:DbSetStatusDefaultValue( "banzai-threat", { type = "banzai-threat", color1 = {r=1,g=0,b=0,a=1} })

-- banzai status
if Grid2.isClassic then return end -- sorry, no banzai status in Classic

Banzai = Grid2.statusPrototype:new("banzai", false)

local bsrc = {} -- bsrc[enemy guid]  = function to check enemy unit casting info
local bgid = {} -- bgid[enemy guid]  = friendly unit in roster
local bfun = {} -- bfun[enemy guid]  = function to check cast/channel info
local buni = {} -- buni[roster unit] = enemy guid
local bspl = {} -- bspl[roster unit] = spellID casted against the unit
local bdur = {} -- bdur[roster unit] = enemy cast duration
local bexp = {} -- bexp[roster unit] = enemy cast expiration
local bico = {} -- bico[roster unit] = enemy cast icon
do
	local UnitCastingInfo = UnitCastingInfo
	local UnitChannelInfo = UnitChannelInfo
	local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
	local e = {}
	e.SPELL_CAST_START   = function(g,s) bsrc[g]= UnitCastingInfo end
	e.SPELL_CAST_SUCCESS = function(g,s) bsrc[g]= UnitChannelInfo end
	e.SPELL_INTERRUPT    = function(g)   bsrc[g]= nil; local unit = bgid[g]; if unit then bexp[unit]=0 end end
	e.UNIT_DIED = e.SPELL_INTERRUPT
	function Banzai.CombatLogEvent()
		local _, event,_,sourceGUID,srcName,_,_,destGUID, dstName, _, dstFlags, spellID, spellName , _, extraSpellID = CombatLogGetCurrentEventInfo()
		local action = e[event]
		if action then
			local guid = (not extraSpellID) and sourceGUID or destGUID -- for SPELL_INTERRUPT & UNIT_DIED & SPELL_AURA_APPLIED enemy is destGUID
			if not roster_units[guid] then
				action(guid, spellName)
			end
		end
	end
end

function Banzai:Update()
	local ct = GetTime()
	for unit,guid in next,buni do -- Delete expired or canceled banzais
		if ct>=(bexp[unit] or 0) or not (bfun[guid] and bfun[guid](sguids[guid] or 0)) then
			buni[unit], bdur[unit], bico[unit], bexp[unit], bspl[unit], bgid[guid], bfun[guid] = nil, nil, nil, nil, nil, nil, nil
			self:UpdateIndicators(unit)
		end
	end
	local spells = self.spells
	for g,func in next, bsrc do	-- Search new banzais
		local unit = tguids[g]
		if unit then
			local name,_,ico,_,et,_,_,spellId2,spellId1 = func(sguids[g], g) -- Casting spellId1=9th, Channeling spellId2=8th
			if name and (spells==nil or spells[name]) then
				et         = et and et/1000 or ct+0.25
				bgid[g]    = unit
				bfun[g]    = func
				buni[unit] = g
				bspl[unit] = spellId1 or spellId2 or name
				bdur[unit] = et - ct
				bexp[unit] = et
				bico[unit] = ico or "Interface\\ICONS\\Ability_Creature_Cursed_02"
				self:UpdateIndicators(unit)
			end
		end
	end
	wipe(bsrc)
end

function Banzai:GetTooltip(unit, tip)
	local spellID = bspl[unit]
	if type(spellID) == 'number' then
		tip:SetSpellByID(spellID)
	end
end

function Banzai:ClearIndicators()
	wipe(bsrc)
	wipe(bgid)
	wipe(bico)
	wipe(bdur)
	wipe(bexp)
	wipe(bfun)
	wipe(bspl)
	for unit in next,buni do
		buni[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function Banzai:IsActive(unit)
	if buni[unit] then return true end
end

function Banzai:GetDuration(unit)
	return bdur[unit]
end

function Banzai:GetExpirationTime(unit)
	return bexp[unit]
end

function Banzai:GetPercent(unit)
	local t = GetTime()
	return ((bexp[unit] or t) - t) / (bdur[unit] or 1)
end

function Banzai:GetBorder()
	return 0
end

function Banzai:GetIcon(unit)
	return bico[unit]
end

function Banzai:GetText(unit)
	local spell = bspl[unit]
	return type(spell)=='number' and GetSpellInfo(spell) or spell
end

function Banzai:UpdateDB()
	local spells
	if self.dbx.spells then
		spells = {}
		for _,name in ipairs(self.dbx.spells) do
			spells[name] = true
		end
	end
	self.spells = spells
end

Banzai.SetUpdateRate = status_SetUpdateRate
Banzai.GetColor      = Grid2.statusLibrary.GetColor
Banzai.OnDisable     = status_OnDisable
Banzai.OnEnable      = status_OnEnable

Grid2.setupFunc["banzai"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Banzai, {"color", "text", "percent", "icon", "tooltip" }, baseKey, dbx)
	return Banzai
end

Grid2:DbSetStatusDefaultValue( "banzai", { type = "banzai", color1 = {r=1,g=0,b=1,a=1} })

