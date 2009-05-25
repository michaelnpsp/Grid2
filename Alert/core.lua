local Grid2Alert = Grid2:NewModule("Grid2Alert", "LibSink-2.0")

local media = LibStub("LibSharedMedia-3.0")

media:Register("sound", "threat", "Interface\\Addons\\Grid2Alert\\sounds\\aggro.wav")
media:Register("sound", "Detox", "Sound\\interface\\AuctionWindowOpen.wav")

local function Alert_Enable(self)
	local status = self.status
	if not self.HookName then
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
	else
		Grid2:Print("ERROR ! invalid alert type", type)
	end
end

function Grid2Alert:HookStatus(status, name, alert_type)
	if type(status) == "string" then
		status = Grid2.statuses[status]
	end
	local Alert = {
		status = status,
		name = name,
		Enable = Alert_Enable,
		Disable = Alert_Disable,
		TriggerAlert = Alert_TriggerAlert,
	}

	Alert_Initialize(Alert, alert_type)
	self.alerts[Alert] = status

	return Alert
end

Grid2Alert.defaultDB = {
	profile = {
		debug = false,
		alerts = {
			Aggro = {
				status = "threat",
				type = "self-gain",
				message = "Aggro !",
				sound = "threat",
				min_pause = 0.5,
			},
			Detox = {
				status = "GetDetoxStatus",
				type = "any-gain",
				message = nil,
				sound = "Detox",
				min_pause = 0.5,
			},
		},
		min_pause = 0.2,
		sinkOptions = {},
	},
}

function Grid2Alert:OnInitialize()
	self.core.defaultModulePrototype.OnInitialize(self)
	self.alerts = {}
	self.notification_times = {}

	self:SetSinkStorage(self.db.profile.sinkOptions)
	-- media.RegisterCallback(self, "LibSharedMedia_Registered", "UpdateMedia")
end

function Grid2Alert:GetStatusList(status)
	if type(status) == "string" and type(self[status]) == "function" then
		return self[status](self)
	elseif type(status) == "list" then
		return status
	else
		return { status }
	end
end

function Grid2Alert:GetDetoxStatus()
	local class = select(2, UnitClass"player")
	if class == "DRUID" then
		return { "debuff-Curse", "debuff-Poison" }
	elseif class == "MAGE" then
		return { "debuff-Curse" }
	elseif class == "PALADIN" then
		return { "debuff-Magic", "debuff-Poison", "debuff-Disease" }
	elseif class == "PRIEST" then
		return { "debuff-Magic", "debuff-Disease" }
	elseif class == "SHAMAN" then
		local result = { "debuff-Disease", "debuff-Poison" }
		if select(5, GetTalentInfo(3, 18)) > 0 then
			table.insert(result, "debuff-Curse")
		end
		return result
	end
end

local enabled
function Grid2Alert:OnEnable()
	if not enabled then
		for name, info in pairs(self.db.profile.alerts) do
			local statusList = self:GetStatusList(info.status)
			if statusList then
				for _, status in ipairs(statusList) do
					self:HookStatus(status, name, info.type)
				end
			end
		end
		enabled = true
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

function Grid2Alert:TriggerAlert(alert, unit)
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
			if message:find("%t", nil, true) then
				message = message:gsub("%%t", UnitName(unit))
			end
			self:Pour(message, 1, 0, 0)
		end
	end
end
