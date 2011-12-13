--[[
Created by Grid2 original authors, modified by Michael
--]]

local pairs, next = pairs, next

local Grid2Blink = Grid2:NewModule("Grid2Blink")
Grid2Blink.defaultDB = {
	profile = {
		type = "Flash", -- or "Blink"
		frequency = 4,
	},
}
Grid2Blink.registry= {}
Grid2Blink.alpha= {}

-- Timer Event for blinking/flash. Limited to ~25 updates per second 
local updateTime= 0
local function OnUpdate( _, elapsed)
	updateTime= updateTime - elapsed
	if updateTime<=0 then
		Grid2Blink.typeFunc(Grid2Blink, (0.04-updateTime) * Grid2Blink.frequency)
		updateTime = 0.04
	end
end

function Grid2Blink:Blink(elapsed)
	local registry = self.registry
	for frame, t in pairs(registry) do
		t = (t + elapsed) % 2
		registry[frame] = t
		if t > 1 then
			frame:Show()
		else
			frame:Hide()
		end
	end
end

function Grid2Blink:Flash(elapsed)
	local registry = self.registry
	for frame, t in pairs(registry) do
		t = (t + elapsed) % 2
		registry[frame] = t
		frame:SetAlpha(t > 1 and 2 - t or t)
	end
end

function Grid2Blink.None()
end

function Grid2Blink:OnModuleInitialize()
	self:Update()
end

function Grid2Blink:OnModuleUpdate()
	self:Update()
end	

function Grid2Blink:OnModuleDisable()
	wipe(self.registry)
	wipe(self.alpha)
end

function Grid2Blink:Update()
	self.frequency= self.db.profile.frequency or 4
	self.typeFunc= Grid2Blink[self.db.profile.type] or Grid2Blink.Flash
	Grid2:IndicatorsBlinkEnabled( self.db.profile.type~="None" )
end

function Grid2Blink:GetFrame()
	local f = CreateFrame("Frame", nil, Grid2LayoutFrame)
	f:Hide()
	f:SetScript("OnUpdate", OnUpdate)
	self.frame = f
	self.GetFrame = function (self) return self.frame end
	return self.frame
end

function Grid2Blink:Add(frame)
	local registry = self.registry
	if (not registry[frame]) then
		if not next(registry) then self:GetFrame():Show() end
		registry[frame] = 0
		self.alpha[frame] = frame:GetAlpha()
	end
end

function Grid2Blink:Remove(frame)
	local registry = self.registry
	if (registry[frame]) then
		registry[frame] = nil
		local alpha = self.alpha
		frame:SetAlpha(alpha[frame])
		alpha[frame] = nil
		if not next(registry) then self.frame:Hide() end
	end
end
