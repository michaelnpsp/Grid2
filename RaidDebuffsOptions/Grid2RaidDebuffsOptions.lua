-- Grid2RaidDebuffsOptions, Created by Michael
local Grid2Options = Grid2Options
local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local GSRD = Grid2:GetModule("Grid2RaidDebuffs")

local GetSpellInfo = Grid2.API.GetSpellInfo

Grid2Options:RegisterStatusOptions("raid-debuffs", "debuff", function(self, status, options)
	self.RDO:Init()
	options.advanced = {
		type = "group",
		name = L["Raid Debuffs"],
		order = 10,
		args = self.RDO.OPTIONS_ADVANCED,
	}
	options.statuses = {
		type = "group",
		name = L["Statuses"],
		order = 20,
		args = self.RDO.OPTIONS_STATUSES,
	}
	options.modules = {
		type = "group",
		name = L["Modules"],
		order = 30,
		args = self.RDO.OPTIONS_MODULES,
	}
	options.miscellaneous = {
		type = "group",
		name = L["Miscellaneous"],
		order = 40,
		args = self.RDO.OPTIONS_MISCELLANEOUS,
	}
end, {
	hideTitle    = true,
	childGroups  = "tab",
	groupOrder   = 5,
	titleIcon    = Grid2.isClassic and "Interface\\Icons\\Ability_Creature_Cursed_05" or "Interface\\Icons\\Spell_Shadow_Skull",
	-- To avoid creating options for raid-debuffs(2), raid-debuffs(3), etc.
	masterStatus = "raid-debuffs",
})

--===================================================================

local RDDK = {}
local RDDB = setmetatable( {}, { __newindex = function (t,k,v) rawset(t,k,v); RDDK[#RDDK+1] = k end } )
local RDO  = {
	-- Grid2RaidDebuffs status acedb database
	db = GSRD.db,
	-- Static raid debuffs database modules
	RDDK = RDDK,
	RDDB = RDDB,
	-- raid-debuffs statuses
	statuses = {},
	statusesIndexes = {},
	statusesNames = {},
	-- debuffs autodetection
	auto_enabled = nil,
}
Grid2Options.RDO = RDO

--===================================================================

-- Called from debuffs database modules (see: RaidDebuffsWoW.lua)
function Grid2Options:GetRaidDebuffsTable()
	return RDDB
end

-- Initialization (Called on first run or when acedb profile change)
function RDO:Init()
	self:FixWrongInstances()
	self:LoadStatuses()
	self:InitAdvancedOptions()
	self:InitGeneralOptions()
end

-- Enable/Disable Raid Debuffs Autodetect
function RDO:SetAutodetect(v)
	if v then
		GSRD:EnableAutodetect( self.statuses[GSRD.db.profile.auto_status or 1] or statuses[1] )
	else
		GSRD:DisableAutodetect()
	end
	self.auto_enabled = v
end

function RDO:RefreshAutodetect()
	if self.auto_enabled then
		self:SetAutodetect(false)
		self:SetAutodetect(true)
	end
end

-- Fix several things in database
function RDO:FixWrongInstances()
	-- Trying to fix or delete instances in old database formats, now the instance keys must be integers, we don't allow strings.
	local saved = {}
	for mapid, data in pairs(RDO.db.profile.debuffs) do
		if type(mapid)~="number" then
			if tonumber(mapid) then saved[tonumber(mapid)] = data end
			RDO.db.profile.debuffs[mapid] = nil
		end
	end
	for k,v in pairs(saved) do
		RDO.db.profile.debuffs[k] = v
	end
	-- remove enabled but non existant modules
	for key in pairs(RDO.db.profile.enabledModules) do
		if not RDDB[key] then
			RDO.db.profile.enabledModules[key] = nil
		end
	end
end

function RDO:EnableInstanceAllDebuffs(curModule, curInstance)
	local debuffs = {}
	for instance,values in pairs(RDDB[curModule][curInstance]) do
		for boss,spellId in ipairs(values) do
			debuffs[#debuffs+1] = spellId
		end
	end
	local rddbx = RDO.db.profile.debuffs
	if rddbx and rddbx[curInstance] then
		for instance,boss in pairs(rddbx[curInstance]) do
			for _,spellId in ipairs(boss) do
				debuffs[#debuffs+1] = spellId
			end
		end
	end
	self.statuses[1].dbx.debuffs[curInstance]= debuffs
	self:UpdateZoneSpells(curInstance)
end

function RDO:DisableInstanceAllDebuffs(curInstance)
	for index,status in ipairs(self.statuses) do
		status.dbx.debuffs[curInstance] = nil
	end
	self:UpdateZoneSpells(curInstance)
end

function RDO:UpdateZoneSpells(instance)
	local zone1, zone2 = GSRD:GetCurrentZone()
	if (not instance) or instance == zone1 or instance == zone2 then
		GSRD:UpdateZoneSpells()
	end
end

-- data export
function RDO:ExportData(data)
	local AceGUI = LibStub("AceGUI-3.0")
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("LUA CODE Export")
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); collectgarbage() end)
	frame:SetWidth(350)
	frame:SetHeight(150)
	local edit = AceGUI:Create("MultiLineEditBox")
	edit:SetFullWidth(true)
	edit:SetFullHeight(true)
	frame:AddChild(edit)
	edit:SetLabel("Press CTRL-C to copy data to Clipboard")
	edit:DisableButton(true)
	edit:SetText(data)
	edit.editBox:SetFocus()
	edit.editBox:HighlightText()
end

-- raid debuffs statuses names management
function RDO:LoadStatuses()
	wipe(self.statuses)
	wipe(self.statusesIndexes)
	wipe(self.statusesNames)
	for _,status in Grid2:IterateStatuses() do
		if status.dbx and status.dbx.type == "raid-debuffs" then
			self.statuses[#self.statuses+1] = status
		end
	end
	table.sort( self.statuses, function(a,b) return (tonumber(strmatch(a.name,"(%d+)")) or 1) < (tonumber(strmatch(b.name,"(%d+)")) or 1) end )
	local LI = Grid2Options.LI
	local text = L["raid-debuffs"]
	for index, status in ipairs(self.statuses) do
		self.statusesIndexes[status] = index
		self.statusesNames[index] = LI[status.name] or string.format("%s(%d)", text, index) or text
	end
end

function RDO:GetStatusName(status)
	return Grid2Options.LI[status.name] or L[status.name]
end

function RDO:SetStatusName(status, newname)
	local oldname = status.name
	newname = (strlen(newname)>=5 and newname~=Grid2Options.LI[oldname] and newname~=L[oldname] and newname~=oldname) and newname or nil
	Grid2Options.LI[oldname] = newname
	local index = self.statusesIndexes[status]
	self.statusesNames[index] = newname or string.format( "%s(%d)", L["raid-debuffs"], index )
end

-- Util functions to access nested tables values
function RDO.DbGetValue(db, ...)
   local count = select("#",...)
   for i = 1, count do
      local field = select(i,...)
      if not (field and db[field]) then return end
      db = db[field]
   end
   return db
end

function RDO.DbSetValue(value, db, ...)
   local count = select("#",...)
   for i = 1, count-1 do
      local field = select(i,...)
      if not db[field] then db[field] = {} end
      db = db[field]
   end
   db[select(count,...)] = value
   return #db
end

function RDO.DbAddTableValue(value, db, ...)
	local count = select("#",...)
	for i = 1, count do
		local field = select(i,...)
		if db[field]==nil then db[field] = {} end
		db = db[field]
	end
	db[#db+1] = value
	return #db
end

function RDO.DbDelTableValue(value, db, ...)
   local count = select("#",...)
   local function Remove(dbi, index, ...)
		if index<=count then
			local field = select(index, ...)
			local data = dbi[field]
			if data then
				Remove(data, index+1, ...)
				if not next(data) then dbi[field] = nil end
			end
		else
			local i = 1
			while i<=#dbi do
				if dbi[i] == value then
					table.remove(dbi,i)
				else
					i = i + 1
				end
			end
			if #dbi==0 then wipe(dbi) end
		end
   end
   Remove(db, 1, ...)
end

--==============================================
