--[[
Created by Michael, based on Grid2Options\GridDefaults.lua from original Grid2 authors
--]]

local Grid2 = Grid2

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

	local version= Grid2:DbGetValue("versions","Grid2") or 0
	if version>=6 then return end
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
	end
	-- Set database version
	Grid2:DbSetValue("versions","Grid2",6)

end
