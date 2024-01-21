-- Group of Debuffs status
local Grid2 = Grid2
local UnitAura = Grid2.UnitAuraLite
local myUnits = Grid2.roster_my_units
local typeColors = Grid2.debuffTypeColors
local dispelTypes = Grid2.debuffDispelTypes
local playerDispelTypes = Grid2.debuffPlayerDispelTypes
local wipe = wipe

local emptyTable = {}
local textures = {}
local counts = {}
local expirations = {}
local durations = {}
local colors = {}
local slots = {}
local spells = {}

local code_standard = [[ return %s ]]

local code_stacks = [[
	if not (%s) then return end
	if not self.seen then self.currentName=name; return true; end
	if name==self.currentName then self.cnt[unit] = self.cnt[unit] + count; end
]]

-- Compile a filter function, the function is called from StatusAura.lua to filter auras
local function CompileUpdateStateFilter(self, lazy, useSpellId, code)
	local dbx = self.dbx
	local t = {}
	if dbx.filterDispelDebuffs~=nil then
		t[#t+1] = string.format( "%s dispel[typ]", dbx.filterDispelDebuffs and '' or 'not')
	end
	if dbx.filterLongDebuffs~=nil then
		t[#t+1] = string.format( "%s (duration>=300)", dbx.filterLongDebuffs and 'not' or '')
	end
	if dbx.filterPermaDebuffs~=nil then
		t[#t+1] = string.format( "%s (duration==0)", dbx.filterPermaDebuffs and 'not' or '')
	end
	if dbx.filterBossDebuffs~=nil then
		t[#t+1] = string.format( "%s boss", dbx.filterBossDebuffs and 'not' or '')
	end
	if dbx.filterCaster~=nil then
		t[#t+1] = string.format( "%s (caster=='player' or caster=='pet' or caster=='vehicle')", dbx.filterCaster and 'not' or '')
	end
	if dbx.filterTyped~=nil then
		t[#t+1] = string.format( "%s typ", dbx.filterTyped and 'not' or '')
	end
	local q -- special case for black/white lists because they are always strict (non lazy).
	if dbx.useWhiteList then
		q = useSpellId and "(self.spells[sid] or self.spells[name])" or "self.spells[name]"
	elseif next(self.spells) then
		q = useSpellId and "not (self.spells[sid] or self.spells[name])" or "not self.spells[name]"
	end
	local r = table.concat( t, lazy and ' or ' or ' and ' )
	if r=='' then
		r = q or 'true'
	elseif q then
		r = string.format("%s and (%s)", q, r)
	end
	return assert(loadstring( "return function(self, unit, sid, name, count, duration, caster, boss, typ, dispel) " .. string.format(code, r) .. ' end' ))()
end

-- Called by "icons" indicator, standard
local function status_GetIconsFilterStandard(self, unit, max)
	local UpdateState, i, j, name, debuffType, caster, boss, _ = self.UpdateState, 1, 1
	repeat
		name, textures[j], counts[j], debuffType, durations[j], expirations[j], caster, _, _, sid, _, boss = UnitAura(unit, i, 'HARMFUL')
		if not name then break end
		if UpdateState(self, unit, sid, name, counts[j], durations[j], caster, boss, debuffType, playerDispelTypes) then
			colors[j] = typeColors[debuffType] or self.color
			slots[j] = i
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors, slots
end

-- Called by "icons" indicator, combine stacks
local function status_GetIconsFilterStacks(self, unit, max)
	local CheckState, i, j, name, texture, count, debuffType, duration, expiration, caster, spellId, boss, _ = self.CheckState, 1, 1
	wipe(spells)
	repeat
		name, texture, count, debuffType, duration, expiration, caster, _, _, spellId, _, boss = UnitAura(unit, i, 'HARMFUL')
		if not name then break end
		if CheckState(self, unit, name, count, duration, caster, boss, debuffType, playerDispelTypes) then
			local k = spells[name]
			if k then -- add extra stacks
				counts[k] = counts[k] + (count==0 and 1 or count)
				if expiration > expirations[k] then expirations[k] = expiration end
			else -- add new debuff
				spells[name]   = j
				colors[j]      = typeColors[debuffType] or self.color
				counts[j]      = count==0 and 1 or count
				textures[j]    = texture
				durations[j]   = duration
				expirations[j] = expiration
				slots[j] = i
				j = j + 1
			end

		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors, slots
end

-- Called by status:UpdateDB()
local function status_Update(self, dbx)
	self.color = dbx.color1
	self.spells = self.spells or emptyTable
	self.UpdateState = CompileUpdateStateFilter(self, dbx.lazyFiltering, dbx.useSpellId, code_standard)
	if dbx.combineStacks then
		self.fullUpdate = true
		self.GetIcons = status_GetIconsFilterStacks
		self.CheckState = self.UpdateState
		self.UpdateState = CompileUpdateStateFilter(self, dbx.lazyFiltering, dbx.useSpellId, code_stacks)
	else
		self.fullUpdate = nil
		self.CheckState = nil
		self.GetIcons = status_GetIconsFilterStandard
	end
end

-- Registration
do
	local statusTypes = { "color", "icon", "icons", "percent", "text", "tooltip" }
	Grid2.setupFunc["debuffs"] = function(baseKey, dbx)
		if Grid2.classicDurations then
			UnitAura = LibStub("LibClassicDurations").UnitAuraDirect
		end
		if dbx.spellName then -- fix possible wrong data in old database
			dbx.spellName = nil
		end
		local status = Grid2.statusPrototype:new(baseKey, false)
		status.OnUpdate = status_Update
		return Grid2.CreateStatusAura(status, basekey, dbx, 'debuff', statusTypes)
	end
end

--[[ status database configuration
	type = "debuffs"
	auras = { "Riptide", 12323, "Earth Shield", ... }
	useWhiteList = true | nil  				-- auras is a whitelist or blacklist
	-- nil=no filter; true=apply filter; false=apply inverted filter
	filterLong   = nil | true | false       -- long debuffs (>5min)
	filterBoss   = nil | true | false       -- boss debuffs
	filterCaster = nil | true | false       -- self casted or casted by me
	-- colors
	debuffTypeColorize = true | nil		-- return the color of the debuffType
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--]]
