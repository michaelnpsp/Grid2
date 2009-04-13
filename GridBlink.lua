local Grid2Blink = Grid2:NewModule("Grid2Blink")
Grid2Blink.defaultDB = {
	profile = {
		type = "Flash", -- or "Blink"
		frequency = 4,
	},
}

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

function Grid2Blink:OnInitialize()
	self.registry = {}
	self.alpha = {}
end

function Grid2Blink:GetFrame()
	local f = CreateFrame("Frame", nil, Grid2LayoutFrame)
	f:Hide()
	f:SetScript("OnUpdate", function (_, elapsed)
		local p = self.db.profile
		self[p.type](self, elapsed * p.frequency)
	end)
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
--		frame:Hide()
		if not next(registry) then self.frame:Hide() end
	end
end
