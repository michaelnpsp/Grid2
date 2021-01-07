-- Misc functions

local media = LibStub("LibSharedMedia-3.0", true)
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")
local Grid2 = Grid2
local select = select
local strtrim  = strtrim
local type = type
local pairs = pairs
local tonumber = tonumber
local tremove = table.remove

-- Dummy function
function Grid2.Dummy()
end

-- Fetch LibSharedMedia resources
function Grid2:MediaFetch(mediatype, key, def)
	return (key and media:Fetch(mediatype, key)) or (def and media:Fetch(mediatype, def))
end

-- Default Colors
do
	local defaultColors = {
		TRANSPARENT = {r=0,g=0,b=0,a=0},
		BLACK       = {r=0,g=0,b=0,a=1},
		WHITE       = {r=1,g=1,b=1,a=1},
	}
	function Grid2:MakeColor(color, default)
		return color or defaultColors[default or "TRANSPARENT"]
	end
	Grid2.defaultColors = defaultColors
end

-- Repeating Timer Management
do
	local frame = CreateFrame("Frame")
	local timers = {}
	local function SetDuration(self, duration)
		self.animation:SetDuration(duration)
	end
	-- Grid2:CreateTimer(func, duration, play)
	-- play=true|nil => timer running; play=false => timer paused
	-- timer methods: timer:Play() timer:Stop() timer:SetDuration()
	function Grid2:CreateTimer( func, duration, play )
		local timer = tremove(timers)
		if not timer then
			timer = frame:CreateAnimationGroup()
			timer.animation = timer:CreateAnimation()
			timer.SetDuration = SetDuration
			timer:SetLooping("REPEAT")
		end
		timer:SetScript("OnLoop", func)
		if duration then
			timer:SetDuration(duration)
			if play~=false then timer:Play() end
		end
		return timer
	end
	-- Grid2:CancelTimer(timer)
	function Grid2:CancelTimer( timer )
		if timer then
			timer:Stop()
			timers[#timers+1] = timer
		end
	end
end

-- UTF8 string truncate
do
	local strbyte = string.byte
	function Grid2.strcututf8(s, c)
		local l, i = #s, 1
		while c>0 and i<=l do
			local b = strbyte(s, i)
			if     b < 192 then	i = i + 1
			elseif b < 224 then i = i + 2
			elseif b < 240 then	i = i + 3
			else				i = i + 4
			end
			c = c - 1
		end
		return s:sub(1, i-1)
	end
end

-- Table Deep Copy used by GridDefaults.lua
function Grid2.CopyTable(src, dst)
	if type(dst)~="table" then dst = {} end
	for k,v in pairs(src) do
		if type(v)=="table" then
			dst[k] = Grid2.CopyTable(v,dst[k])
		elseif dst[k]==nil then
			dst[k] = v
		end
	end
	return dst
end

-- Remove item by value in a ipairs table
function Grid2.TableRemoveByValue(t,v)
	for i=#t,1,-1 do
		if t[i]==v then
			tremove(t, i)
			return
		end
	end
end

-- Creates a location table, used by GridDefaults.lua
function Grid2.CreateLocation(a,b,c,d)
    local p = a or "TOPLEFT"
	if type(b)=="string" then
		return { relPoint = p, point = b, x = c or 0, y = d or 0 }
	else
		return { relPoint = p, point = p, x = b or 0, y = c or 0 }
	end
end

-- Common methods repository for statuses
Grid2.statusLibrary = {
	IsActive = function()
		return true
	end,
	GetColor = function(self)
		local c = self.dbx.color1
		return c.r, c.g, c.b, c.a
	end,
	GetPercent = function(self)
		return self.dbx.color1.a
	end,
	UpdateAllUnits = function(self)
		for unit in Grid2:IterateRosterUnits() do
			self:UpdateIndicators(unit)
		end
	end,
}

-- Used by bar indicators
Grid2.AlignPoints= {
	HORIZONTAL = {
		[true]  = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" },    -- normal Fill
		[false] = { "BOTTOMRIGHT",  "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"  },  -- reverse Fill
	},
	VERTICAL   = {
		[true]  = { "BOTTOMLEFT","TOPLEFT","BOTTOMRIGHT","TOPRIGHT" }, -- normal Fill
		[false] = { "TOPRIGHT", "BOTTOMRIGHT","TOPLEFT","BOTTOMLEFT" }, -- reverse Fill
	}
}

-- Create/Manage/Sets frame backdrops
do
	local format = string.format
	local tostring = tostring
	local backdrops = {}
	-- Generates a backdrop table, reuses tables avoiding to create duplicates
	function Grid2:GetBackdropTable(edgeFile, edgeSize, bgFile, tile, tileSize, inset)
		inset = inset or edgeSize
		local key = format("%s;%s;%d;%s;%d;%d", bgFile or "", edgeFile or "", edgeSize or -1, tostring(tile), tileSize or -1, inset or -1)
		local backdrop = backdrops[key]
		if not backdrop then
			backdrop = {
				bgFile = bgFile,
				tile = tile,
				tileSize = tileSize,
				edgeFile = edgeFile,
				edgeSize = edgeSize,
				insets = { left = inset, right = inset, top = inset, bottom = inset },
			}
			backdrops[key] = backdrop
		end
		return backdrop
	end
	-- Sets a backdrop only if necessary to alleviate game freezes, see ticket #640
	function Grid2:SetFrameBackdrop(frame, backdrop)
		if backdrop~=frame.currentBackdrop then
			frame:SetBackdrop(backdrop)
			frame.currentBackdrop = backdrop
		end
	end
end

-- Grid2:RunSecure(priority, object, method, arg)
-- Queue some methods to be executed when out of combat, if we are not in combat do nothing.
-- Methods with lower priority value override the execution of methods with higher priority value.
-- Methods executed (in order of priority): ReloadProfile(1), ReloadTheme(2), ReloadLayout(3), ReloadFilter(4), FixRoster(5), UpdateSize(6), UpdateVisibility(7)
do
	local sec_priority, sec_object, sec_method, sec_arg
	function Grid2:PLAYER_REGEN_ENABLED()
		if sec_priority then
			sec_priority = nil
			sec_object[sec_method](sec_object, sec_arg)
		end
	end
	function Grid2:RunSecure(priority, object, method, arg)
		if InCombatLockdown() then
			if not sec_priority or priority<sec_priority then
				sec_priority, sec_object, sec_method, sec_arg = priority, object, method, arg
			end
			return true
		end
	end
end

-- Grid2:RunThrottled(object or arg1, method or func, delay)
-- Delays and throttles the execution of a method or function
do
	local counts = {}
	function Grid2:RunThrottled(object, method, delay)
		local func  = object[method] or method
		local count = counts[func]
		counts[func] = (count or 0) + 1
		if not count then
			local callback
			callback = function()
				if counts[func]>0 then
					counts[func] = 0
					func(object)
					C_Timer.After(delay or 0.1, callback)
				else
					counts[func] = nil
				end
			end
			C_Timer.After(delay or 0.1, callback)
		end
	end
end

-- Useful to change theme from external sources (macros, wa2,etc)
-- theme = number(theme index starting in 0) or string(theme name)
function Grid2:SetDefaultTheme(theme)
	local themes = self.db.profile.themes
	if type(theme)~='number' then
		for index,name in pairs(themes.names) do
			if theme==name then	theme = index; break; end
		end
		if type(theme)~='number' and (theme=='Default' or theme==L['Default']) then
			theme = 0
		end
	end
	if theme==0 or themes.names[theme] then
		themes.enabled.default = theme
		self:ReloadTheme()
		return true
	end
end

-- dispellable by player spells types tracking
do
	local class, dispel, func  = Grid2.playerClass, {}, nil
	if Grid2.isClassic then
		if class == 'DRUID' then
			func = function()
				dispel.Poison = IsPlayerSpell(2893) or IsPlayerSpell(8946)
				dispel.Curse  = IsPlayerSpell(2782)
			end
		elseif class == 'PALADIN' then
			func = function()
				dispel.Poison  = IsPlayerSpell(4987) or IsPlayerSpell(1152)
				dispel.Disease = IsPlayerSpell(4987) or IsPlayerSpell(1152)
				dispel.Magic   = IsPlayerSpell(4987)
			end
		elseif class == 'PRIEST' then
			func = function()
				dispel.Magic   = IsPlayerSpell(527)
				dispel.Disease = IsPlayerSpell(552) or IsPlayerSpell(528)
			end
		elseif class == 'SHAMAN' then
			func = function()
				dispel.Disease = IsPlayerSpell(2870)
				dispel.Poison  = IsPlayerSpell(526)
			end
		elseif class == 'MAGE' then
			func = function()
				dispel.Curse = IsPlayerSpell(475)
			end
		elseif class == 'WARLOCK' then
			func = function()
				dispel.Magic = IsPlayerSpell(19505)
			end
		end
	else -- retail
		if class == 'DRUID' then
			func = function()
				dispel.Magic  = IsPlayerSpell(88423)
				dispel.Curse  = IsPlayerSpell(88423) or IsPlayerSpell(2782)
				dispel.Poison = IsPlayerSpell(88423) or IsPlayerSpell(2782)
			end
		elseif class == 'PALADIN' then
			func = function()
				dispel.Magic   = IsPlayerSpell(4987)
				dispel.Disease = IsPlayerSpell(4987) or IsPlayerSpell(213644)
				dispel.Poison  = IsPlayerSpell(4987) or IsPlayerSpell(213644)
			end
		elseif class == 'PRIEST' then
			func = function()
				dispel.Magic   = IsPlayerSpell(527)
				dispel.Disease = IsPlayerSpell(527) or IsPlayerSpell(213634)
			end
		elseif class == 'SHAMAN' then
			func = function(self, event)
				dispel.Magic = IsPlayerSpell(77130)
				dispel.Curse = IsPlayerSpell(77130) or IsPlayerSpell(51886)
			end
		elseif class == 'MAGE' then
			func = function()
				dispel.Curse = IsPlayerSpell(475)
			end
		elseif class == 'WARLOCK' then
			func = function()
				dispel.Magic = IsPlayerSpell(115276) or IsPlayerSpell(89808)
			end
		elseif class == 'MONK' then
			func = function()
				dispel.Magic   = IsPlayerSpell(115450)
				dispel.Disease = IsPlayerSpell(115450) or IsPlayerSpell(218164)
				dispel.Poison  = IsPlayerSpell(115450) or IsPlayerSpell(218164)
			end
		end
	end
	-- publish usefull tables and methods
	Grid2.debuffPlayerDispelTypes = dispel
	Grid2.UpdatePlayerDispelTypes = func
end

-- Process command line order
do
	local display = {  never = 'Never', always = 'Always', grouped = 'Grouped', raid = 'Raid', toggle = false }
	function Grid2:ProcessCommandLine(input)
		local command, param = strsplit(" ", input or "", 2)
		local c, p = strlower(command), strlower(param or "")
		if c=='lock' then -- lock toggle
			Grid2Layout:FrameLock( p~='toggle' or nil )
		elseif c=='unlock' then
			Grid2Layout:FrameLock(false)
		elseif c=='show' and display[p]~=nil then
			Grid2Layout:FrameVisibility( display[p] )
		elseif c=='theme' and param and not InCombatLockdown() then
			if not self:SetDefaultTheme( tonumber(param) or strtrim(param,'" ') ) then
				self:Print("Specified theme does not exist.")
			end
		elseif c=='profile' and param and not InCombatLockdown() then
			param = strtrim(param,'" ')
			for _,name in ipairs(self.db:GetProfiles()) do
				if param == name and name~=self.db:GetCurrentProfile() then
					self.db:SetProfile(name)
					return
				end
			end
			self:Print("Specified profile does not exist.")
		elseif c=='help' then
			self:Print("commands (/grid2, /gr2)")
			print("    /grid2")
			print("    /grid2 options")
			print("    /grid2 help")
			print("    /grid2 unlock")
			print("    /grid2 lock")
			print("    /grid2 lock toggle")
			print("    /grid2 profile name")
			print("    /grid2 theme name || index")
			print("    /grid2 show never || always || grouped || raid || toggle\n")
		end
	end
end
