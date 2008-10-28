local Grid2Alert = Grid2:NewModule("Grid2Alert", "LibSink-2.0")

local media = LibStub("LibSharedMedia-3.0")

media:Register("sound", "Aggro", "Interface\\Addons\\Grid2Alert\\sounds\\aggro.wav")
media:Register("sound", "Detox", "Sound\\interface\\AuctionWindowOpen.wav")

local function Alert_Enable(self)
	if not self.HookName then
		local status = self.status
		if status.HasStateChanged then
			-- Aura Status don't call UpdateIndicators
			self.HookName = "HasStateChanged"
			self.hook = function (status, unit)
				local changed = self.prev(status, unit)
				if changed then
					self:Update(unit, status:IsActive(unit))
				end
			end
		else
			self.HookName = "UpdateIndicators"
			self.hook = function (status, unit)
				self.prev(status, unit)
				self:Update(unit, status:IsActive(unit))
			end
		end
		self.prev = status[self.HookName]
	end
	status[self.HookName] = self.hook
end

local function Alert_Disable(self)
	if not self.HookName then return end
	self.status[self.HookName] = self.prev
end

local function Alert_UpdateSelfGain(self, unit, isActive)
	if UnitIsUnit(unit, "player") then
		if not self.active and isActive then
			self:TriggerAlert(unit)
		end
		self.active = isActive
	end
end

local function Alert_UpdateSelfLost(self, unit, isActive)
	if UnitIsUnit(unit, "player") then
		if self.active and not isActive then
			self:TriggerAlert(unit)
		end
		self.active = isActive
	end
end

local function Alert_UpdateAnyGain(self, unit, isActive)
	if UnitIsUnit(unit, "player") then
		if isActive and self.count == 0 then
			self:TriggerAlert(unit)
		end
		self.count = self.count + (isActive and 1 or -1)
	end
end

local function Alert_UpdateAllLost(self, unit, isActive)
	if UnitIsUnit(unit, "player") then
		self.count = self.count + (isActive and 1 or -1)
		if not isActive and self.count == 0 then
			self:TriggerAlert(unit)
		end
	end
end

local function Alert_TriggerAlert(self, unit)
	return Grid2Alert:TriggerAlert(self.name, unit)
end

local function Alert_Initialize(self, type)
	if type == "self-gain" then
		self.Update = Alert_UpdateSelfGain
	elseif type == "self-lost" then
		self.Update = Alert_UpdateSelfLost
	elseif type == "any-gain" then
		self.count = 0
		self.Update = Alert_UpdateAnyGain
	elseif type == "all-lost" then
		self.count = 0
		self.Update = Alert_UpdateAllLost
	end
end

function Grid2Alert:HookStatus(status, name)
	local Alert = {
		status = status,
		name = name,
		Enable = Alert_Enable,
		Disable = Alert_Disable,
		TriggerAlert = Alert_TriggerAlert,
	}

	Alert_Initialize(Alert, type)
	self.alerts[Alert] = status

	return Alert
end

Grid2Layout.defaultDB = {
	profile = {
		debug = false,
		alerts = {
			Aggro = {
				status = "aggro",
				type = "self-gain",
				message = "Aggro !",
				sound = "Aggro",
			},
			Detox = {
				status = "GetDetoxStatus",
				type = "any-gain",
				message = nil,
				sound = "Detox",
			},
		}
	},
}

function Grid2Alert:OnInitialize()
	self.core.defaultModulePrototype.OnInitialize(self)
	self.alerts = {}
	self.notification_times = {}

	self:SetSinkStorage(self.db.profile.sinkOptions)
	-- media.RegisterCallback(self, "LibSharedMedia_Registered", "UpdateMedia")
end

function Grid2Alert:OnEnable(first)
	if first then
		for name, info in pairs(self.db.profile.alerts) do
			local statusList = self:GetStatusList(info.status)
			for _, status in ipairs(statusList) do
				self:HookStatus(status, name)
			end
		end
	end
	for alert in pairs(self.alerts) do
		alert:Enable()
	end
end

function Grid2Alert:OnDisable()
	for alert in pairs(self.alerts) do
		alert:Disable()
	end
end

function GridAlert:TriggerAlert(alert, unit)
	local p = self.db.profile
	local settings = p.alerts[alert]
	if not settings then
		self:Debug("Invalid alert played : \"%s\", I don't know it\n", alert)
		return
	end
	local cur_time = GetTime()

	if cur_time - (self.last_play_time or 0) < p.min_pause or
	   cur_time - (self.notification_times[alert] or 0) < settings.min_pause then
		self:Debug("Skipping alert \"%s\"", alert)
	else
		self.last_play_time = cur_time
		self.notification_times[alert] = cur_time

		self:SendMessage("GridAlert_Notify", alert)
		if settings.sound then
			PlaySoundFile(media:Fetch("sound", settings.sound))
		end
        local message = settings.message
		if message then
            message = message:gsub("%%t", UnitName(unit))
			self:Pour(message, 1, 0, 0)
		end
	end
end
