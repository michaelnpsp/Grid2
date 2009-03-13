local Voice = Grid2.statusPrototype:new("voice")

local cache = {}

function Voice:OnEnable()
	self:RegisterEvent("VOICE_START")
	self:RegisterEvent("VOICE_STOP")
end

function Voice:OnDisable()
	self:UnregisterEvent("VOICE_START")
	self:UnregisterEvent("VOICE_STOP")
	while true do
		local k = next(cache)
		if not k then break end
		cache[k] = nil
	end
end

function Voice:VOICE_START(_, unit)
	cache[unit] = true
	return self:UpdateIndicators(unit)
end

function Voice:VOICE_STOP(_, unit)
	cache[unit] = nil
	return self:UpdateIndicators(unit)
end

function Voice:IsActive(unit)
	return cache[unit]
end

Voice.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = 0, a = 1 },
	}
}

function Voice:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(Voice, { "color" })
