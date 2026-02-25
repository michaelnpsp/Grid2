local L = Grid2Options.L

local GetSpellInfo = Grid2.API.GetSpellInfo

local BuffSubTypes= {
	buff = L["Single Buff"],
	buffs = L["Group of Buffs"],
	mbuffs = L["Blizzard Buffs"],
}

local BuffPrefixes = {
	buff = 'buff',
	buffs = 'buffs',
	mbuffs = 'buffs',
}

local NewAuraUsageDescription= L["You can include a descriptive prefix using separators \"@#>\""]
							   .. " "..
							   L["examples: Druid@Regrowth Chimaeron>Low Health"]

local NewAuraHandlerMT = {
	Init = function (self)
		self.name = ""
		self.mine = self.subType == "Buff" and 1 or nil
		self.spellName = nil
	end,
	GetKey = function (self)
		local name = self.name:gsub("[ %.\"]", "")
		if name ~= "" then
			local mine = (self.mine==2 and "-not-mine") or (self.mine and "-mine") or ""
			return string.format("%s-%s%s", BuffPrefixes[self.subType], name, mine )
		end
	end,
	GetName = function (self)
		return self.name
	end,
	SetName = function (self, info, value)
		local spellName
		local prefix, spell= string.match(value, "^(.-[@#>])(.*)$")
		if not spell then
			spell, prefix = value, ""
		end
		spellName = tonumber(spell) or spell
		if type(spellName)=="number" then
			spell= GetSpellInfo(spellName)
			if spell==nil then
				spell,spellName= "", nil
			end
		end
		self.spellName = spellName
		self.name = prefix .. spell
	end,
	GetMine = function (self)
		return self.mine == 1
	end,
	SetMine = function (self, info, value)
		self.mine = value and 1
	end,
	GetNotMine = function (self)
		return self.mine == 2
	end,
	SetNotMine = function (self, info, value)
		self.mine = value and 2
	end,
	IsNotDebuff = function(self)
		return self.subType ~= "Debuff"
	end,
	IsBlizzard = function(self)
		return self.subType == "mbuffs"
	end,
	GetAvailableSubTypes = function(self)
	    return self.subTypes
	end,
	GetSubType= function(self)
		return self.subType
	end,
	SetSubType= function(self,info,value)
		self.subType  = value
		if value=='buff' then
			self.spellName = nil
			self.name = ""
			self.mine = 1
		else
			self.spellName = value
			self.name = ""
			self.mine = nil
		end
	end,
	Create = function (self)
		local baseKey = self:GetKey()
		if baseKey then
			--Add to options and runtime db
			local color = { r = self.color.r , g = self.color.g, b = self.color.b , a = self.color.a }
			if self.subType=='mbuffs' then -- midnight buffs filter
				dbx = { type = 'mbuffs', color1 = color }
			elseif self.subType=='buffs' then -- non-secret buffs group
				dbx = { type = 'buffs', auras = {}, mine = self.mine, color1 = color }
			else -- non-secret single buff
				dbx = { type = 'buff', spellName = self.spellName, mine = self.mine, color1 = color }
			end
			Grid2.db.profile.statuses[baseKey]= dbx
			--Create the status
			local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
			--Create the status options
			Grid2Options:MakeStatusOptions(status)
			Grid2Options:SelectGroup('statuses', Grid2Options:GetStatusCategory(status), status.name)
			self:Init()
		end
	end,
	IsDisabled = function (self)
		local key = self:GetKey()
		if key and self.spellName then
			return not not Grid2.statuses[key]
		end
		return true
	end,
}
NewAuraHandlerMT.__index = NewAuraHandlerMT
-- }}

--{{ Buff Creation options
local NewBuffHandler = setmetatable({type = "buff", subType="mbuffs", subTypes= BuffSubTypes, color = {r=1,g=1,b=1,a=1}}, NewAuraHandlerMT)

NewBuffHandler.options = {
	newStatusBuffType = {
		type = "select",
		order = 5,
		width="full",
		name = L["Select Type"],
		desc = L["Select Type"],
		get = "GetSubType",
		set = "SetSubType",
		values = "GetAvailableSubTypes",
		handler = NewBuffHandler,
	},
	newStatusBuffName = {
		type = "input", dialogControl = "EditBoxGrid2Buffs",
		order = 5.1,
		width = "full",
		name = function(info)
			return info.handler.subType=='buff' and L["Name or SpellId"] or L["Type a descriptive name for this status"]
		end,
		usage = NewAuraUsageDescription,
		get = "GetName",
		set = "SetName",
		handler = NewBuffHandler,
	},
	newStatusBuffMine = {
		type = "toggle",
		order = 5.2,
		name = L["Show if mine"],
		desc = L["Display status only if the buff was cast by you."],
		get = "GetMine",
		set = "SetMine",
		hidden = "IsBlizzard",
		handler = NewBuffHandler,
	},
	newStatusBuffNotMine = {
		type = "toggle",
		order = 5.3,
		name = L["Show if not mine"],
		desc = L["Display status only if the buff was not cast by you."],
		get = "GetNotMine",
		set = "SetNotMine",
		hidden = "IsBlizzard",
		handler = NewBuffHandler,
	},
	newStatusBuffSpacer = {
		type = "header",
		order = 5.4,
		name = "",
	},
	newStatusBuff = {
		type = "execute",
		order = 5.5,
		name = L["Create"],
		desc = L["Create a new Buff."],
		func = "Create",
		disabled = "IsDisabled",
		handler = NewBuffHandler,
	},
}
NewBuffHandler:Init()

Grid2Options:RegisterStatusCategoryOptions("buff", NewBuffHandler.options)
--}}

