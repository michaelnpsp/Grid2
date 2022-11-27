-- Implements indicator load filter

local Grid2 = Grid2
local playerClass = Grid2.playerClass
local indicatorPrototype = Grid2.indicatorPrototype

local function MakeUpdateFunction(indicator)
	local GetFrame  = indicator.GetFrame
	local OnUpdate  = indicator.OnUpdate
	local GetStatus = indicator.GetCurrentStatus
	return function(self, parent, unit)
		if GetFrame(self, parent) then
			OnUpdate(self, parent, unit, GetStatus(self, unit) )
		end
	end
end

function indicatorPrototype:CanCreate(parent)
	local load = self.load
	return not ( load and (
		( load.unitType    and not load.unitType[ parent:GetParent().headerName ] ) or
		( load.playerClass and not load.playerClass[ playerClass ] )
	) )
end

function indicatorPrototype:GetFrame(parent)
	return parent[self.name]
end

function indicatorPrototype:UpdateFilter() -- Called from Grid2:RegisterIndicator() in GridIndicator.lua
	self.load = self.dbx.load
	if not self.parentName and self.load then
		self.Update = self.UpdateOverride or MakeUpdateFunction(self)
	else
		self.Update = self.UpdateOverride or indicatorPrototype.Update
	end
end
