local Ping = Grid2.statusPrototype:new("ping")

--===============================================================

local _G = _G
local pcall = pcall
local hooksecurefunc = hooksecurefunc
local format = string.format
local canaccessvalue = Grid2.canaccessvalue

--===============================================================

local Ping_Enabled
local cache = {}
local textures = {}
do
	local function st(msg)
		local d = C_Texture.GetAtlasInfo("Ping_Wheel_Icon_"..msg)
		textures[msg] = { msg, d.file, d.leftTexCoord, d.rightTexCoord, d.topTexCoord, d.bottomTexCoord }
	end
	st("Warning"); st("Assist"); st("Attack"); st("OnMyWay")
end

local function ShowPingEvent(icon, msg)
	if Ping_Enabled then
		local parent = icon:GetParent()
		local unit = parent and parent.unit
		if unit and canaccessvalue(unit) then
			cache[unit] = textures[msg]
			Ping:UpdateIndicators(unit)
		end
	end
end

local function ClearPingEvent(icon)
	if Ping_Enabled then
		local parent = icon:GetParent()
		local unit = parent and parent.unit
		if unit and canaccessvalue(unit) then
			cache[unit] = nil
			Ping:UpdateIndicators(unit)
		end
	end
end

local function HookFrame(frame)
	if frame then
		local icon = frame.pingIconFrame
		if icon and not icon.__grid2Hooked then
			local ok, err = pcall(icon.IsForbidden, icon)
			if ok and not err then
				hooksecurefunc(icon, "ShowPing", ShowPingEvent)
				hooksecurefunc(icon, "ClearPing", ClearPingEvent)
				icon.__grid2Hooked = true
			end
		end
	end
end

--===============================================================

function Ping:OnEnable()
	if Ping_Enabled==nil then -- hook only on first enable
		for i=1,5 do HookFrame(_G["CompactPartyFrameMember"..i]) end
		for g=1,8 do for i=1,5 do HookFrame(_G[format("CompactRaidGroup%dMember%d",g,i)]) end; end
		hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", HookFrame)
	end
	Ping_Enabled = true
end

function Ping:OnDisable()
	wipe(cache)
	Ping_Enabled = false
end

function Ping:GetColor(unit)
	local msg = cache[unit][1]
	local c = self.dbx.colors[msg]
	return c.r, c.g, c.b, c.a
end

function Ping:GetTexCoord(unit)
	local info = cache[unit]
	return info[3], info[4], info[5], info[6]
end

function Ping:GetIcon(unit)
	return cache[unit][2]
end

function Ping:IsActive(unit)
	return cache[unit]~=nil
end

function Ping:UpdateDB()
end

Grid2.setupFunc["ping"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Ping, {"color", "icon"}, baseKey, dbx)
	return Ping
end

Grid2:DbSetStatusDefaultValue( "ping", {type = "ping", colors = {
	Warning = {r=1,g=0,b=0,a=1},
    Attack  = {r=1,g=1,b=0,a=1},
	Assist  = {r=0,g=1,b=0,a=1},
	OnMyWay = {r=0,g=0,b=1,a=1},
}})
