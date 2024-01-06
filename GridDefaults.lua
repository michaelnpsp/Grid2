--[[
Created by Michael, based on Grid2Options\GridDefaults.lua from original Grid2 authors
--]]

local Grid2 = Grid2

-- Latest database profile version
local DB_VERSION = 14

-- Database manipulation functions
function Grid2:DbSetStatusDefaultValue(name, value)
	self.defaults.profile.statuses[name] = value
	if self.db then -- if acedb was already created, copy by hand the defaults to the current profile
		local statuses = self.db.profile.statuses
		statuses[name] = Grid2.CopyTable( value, statuses[name] )
	end
end

function Grid2:DbSetValue(section, name, value)
  self.db.profile[section][name]= value
end

function Grid2:DbGetValue(section, name)
  return self.db.profile[section][name]
end;

function Grid2:DbGetIndicator(name)
    return self.db.profile.indicators[name]
end

function Grid2:DbSetIndicator(name, value)
	if value==nil then
		local map = Grid2.db.profile.statusMap
		if map[name] then map[name]= nil end
	end
    self.db.profile.indicators[name]= value
end

function Grid2:DbSetMap(indicatorName, statusName, priority)
	local map = self.db.profile.statusMap
	if priority then
		if not map[indicatorName] then
			map[indicatorName] =  {}
		end
		map[indicatorName][statusName] =  priority
	else
		if map[indicatorName] and map[indicatorName][statusName] then
			map[indicatorName][statusName] = nil
		end
	end
end

-- Plugins can hook this function to initialize or update values in database
function Grid2:UpdateDefaults()

	local version = Grid2:DbGetValue("versions","Grid2") or 0
	if version>=DB_VERSION then return end
	if version==0 then
		self:MakeDefaultsCommon()
		self:MakeDefaultsClass()
	else
		local health = Grid2:DbGetValue("indicators", "health")
		local heals  = Grid2:DbGetValue("indicators", "heals")
		if version<2 then
			-- Upgrade health&heals indicator to version 2
			if health and heals then heals.parentBar = "health"	end
		end
		if version<4 then
			-- Upgrade health&heals indicator to version 4
			if heals and heals.parentBar then
				heals.anchorTo = heals.parentBar
				heals.parentBar = nil
			end
			if health and health.childBar then
				health.childBar = nil
			end
		end
		if version<5 then
			-- Upgrade buffs and debuffs groups statuses
			for _, status in pairs(self.db.profile.statuses) do
				if status.auras and (status.type == "buff" or status.type=="debuff") then
					status.type = status.type .. "s"  -- Convert type: buff -> buffs , debuff -> debuffs
					if status.type == "debuffs" then
						status.useWhiteList = true
					end
				end
			end
		end
		if version<6 then
			Grid2:DbSetValue( "indicators", "tooltip", {type = "tooltip", displayUnitOOC = true} )
		end
		if version<7 then
			Grid2:DbSetValue( "indicators", "background", {type = "background"})
		end
		if version<8 then
			-- upgrade multibars
			for _,dbx in pairs(self.db.profile.indicators) do
				if dbx.type=='multibar' then
					local opacity = math.min(dbx.opacity or 1, dbx.invertColor and 0.8 or 1)
					dbx.textureColor = dbx.textureColor or {}
					dbx.textureColor.a = math.min( dbx.textureColor.a or 1, opacity )
					dbx.backColor  = dbx.backColor or (dbx.invertColor and {r=0,g=0,b=0,a=1}) -- now invert color needs a background color&texture
					dbx.backAnchor = dbx.backColor and (dbx.backMainAnchor and 1 or 2) -- change background anchor codes, now nil means fills the whole background
					for i=1,(dbx.barCount or 0) do
						local bar = dbx['bar'..i] or {}
						bar.color = bar.color or {}
						bar.color.a = math.min( opacity, bar.color.a or 1 )
						dbx[i], dbx['bar'..i] = bar, nil
					end
					dbx.barCount, dbx.opacity, dbx.backMainAnchor = nil, nil, nil
				end
			end
		end
		if version<9 then
			-- upgrade class filter
			for _,dbx in pairs(self.db.profile.statuses) do
				if dbx.playerClass then
					dbx.load = { playerClass = { [dbx.playerClass] = true } }
					dbx.playerClass = nil
				end
			end
		end
		if version<10 then
			-- move some Grid2Layout options from global section to profile section
			local dbx = Grid2Layout.dba.global
			local val = (dbx.detachHeaders and 'player') or (dbx.detachPetHeaders and 'pet') or nil
			if val or dbx.displayAllGroups then
				local dba = Grid2Layout.dba.profile
				for theme in Grid2.IterateValues(dba, unpack(dba.extraThemes or {}) ) do
					theme.detachedHeaders = val
					theme.displayAllGroups = dbx.displayAllGroups
				end
				dbx.detachHeaders = nil
				dbx.detachPetHeaders = nil
			end
		end
		if version<11 then
			local threat = self.db.profile.statuses.threat
			threat.blinkThreshold = not threat.disableBlink
			threat.disableBlink = nil
		end
		if version<12 then
			local dbx = self.db.profile.statuses.mana
			if dbx.showOnlyHealers then
				dbx.load = dbx.load or {}
				dbx.load.unitRole = { HEALER = true }
				dbx.showOnlyHealers = nil
			end
		end
		if version<13 and self.db.profile.formatting.percentFormat==nil then
			self.db.profile.formatting.percentFormat = self.defaults.profile.formatting.percentFormat
		end
		if version<14 and self.db.profile.hideBlizzardRaidFrames then
			local dbx = self.db.profile
			local hid = dbx.hideBlizzardRaidFrames
			if hid then
				dbx.hideBlizzardRaidFrames = nil
				dbx.hideBlizzard = dbx.hideBlizzard or {}
				dbx.hideBlizzard.raid  = (hid==true or hid==2) or nil
				dbx.hideBlizzard.party = (hid==true or hid==1) or nil
			end
		end
	end
	-- Set database version
	Grid2:DbSetValue("versions","Grid2",DB_VERSION)

end
