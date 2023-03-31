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

-- If a Load filter is setup for an indicator, the default Update() function must be changed to check if
-- the indicator frame exists for each unit frame, if the indicator does not exist do nothing.
-- Called from Grid2:RegisterIndicator() in GridIndicator.lua
function indicatorPrototype:UpdateFilter()
	self.load = self.dbx.load
	if self.UpdateO then -- Custom update function defined by multibar/icons indicators
		self.Update  = self.UpdateO
	    self.UpdateF = nil
	elseif not self.parentName and self.load then
		self.Update = MakeUpdateFunction(self)
		self.UpdateF = self.Update
	else
		self.Update = indicatorPrototype.Update
	    self.UpdateF = nil
	end
end
