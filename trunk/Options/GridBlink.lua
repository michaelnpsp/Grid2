--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

function Grid2Options:MakeMiscOptions()
	self:MakeFormattingOptions()
	self:MakeBlinkOptions()
	self:MakeBRFOptions()
end

-- Blink module options

function Grid2Options:MakeBlinkOptions()

	local Grid2Blink = Grid2:GetModule("Grid2Blink")

	Grid2Options:AddModuleOptions( "Misc", "blink", {
		effect = {
			type = "select",
			name = L["Blink effect"],
			desc = L["Select the type of Blink effect used by Grid2."],
			order = 10,
			get = function ()
				return Grid2Blink.db.profile.type
			end,
			set = function (_, v)
				local f= Grid2Blink.db.profile.type=="None" or v=="None"
				Grid2Blink.db.profile.type = v
				Grid2Blink:Update()
				if f then
					Grid2Options:MakeStatusOptions(true)
				end			
			end,
			values= {["None"] = L["None"], ["Blink"] = L["Blink"], ["Flash"] = L["Flash"]},
		},
		frequency = {
			type = "range",
			name = L["Blink Frequency"],
			desc = L["Adjust the frequency of the Blink effect."],
			disabled = function () return Grid2Blink.db.profile.type == "None" end,
			min = 1,
			max = 10,
			step = .5,
			get = function ()
				return Grid2Blink.db.profile.frequency / 2
			end,
			set = function (_, v)
				Grid2Blink.db.profile.frequency = v * 2
				Grid2Blink:Update()
			end,
		},
	})
	
end

-- Hide raid frames options

function Grid2Options:MakeBRFOptions()
local textStore
	Grid2Options:AddModuleOptions( "Misc", "Blizzard Raid Frames", {
		hideBlizzardRaidFrames = {
			type = "toggle",
			name = L["Hide Blizzard Raid Frames on Startup"],
			desc = L["Hide Blizzard Raid Frames on Startup"],
			width = "full",
			order = 120,
			get = function () return Grid2.db.profile.hideBlizzardRaidFrames end,
			set = function (_, v)
				Grid2.db.profile.hideBlizzardRaidFrames = v or nil
				if v then Grid2:HideBlizzardRaidFrames() end
			end,
		},
	})

end

-- Text formating options

local function ConvertToUserFormat(s)
	return s:gsub("%%d","%%s"):gsub("%%.0f","%%d"):gsub("%%.1f","%%d")
end

local function ConvertDuration(s, tenths)
	local short = tenths==2 and "%%.1f" or "%%.0f"
	local long  = tenths==1 and "%%.0f" or "%%.1f"
	return s:gsub( "%%d", short), s:gsub( "%%d", long)
end

local function ConvertDurationStack(s, tenths)
	local i1 = s:find("%%d")
	local i2 = s:find("%%s")
	if i1 and i2 then
		local short, long = ConvertDuration(s, tenths)
		short = short:gsub("%%s","%%d")
		long  = long:gsub("%%s","%%d")
		return short, long, i1>i2
	end	
end

local function GetTenthsValue(s,l)
	if l:find("%%.0f") then
		return 1
	elseif s:find("%%.1f") then
		return 2
	else	
		return 3
	end
end

local function SaveDecimalFormat( mask, tenths)
	local short,long = ConvertDuration( mask, tenths)
	if short then
		-- sanity sheck, string.format will crash if format is wrong, and nothing is saved
		string.format(short, 1); string.format(long , 1) 
		local dbx = Grid2.db.profile.formatting
		dbx.shortDecimalFormat = short
		dbx.longDecimalFormat  = long
		Grid2:UpdateTextFormating()
		return true
	end
end

local function SaveDurationStackFormat( mask, tenths)
	local short, long, inverted = ConvertDurationStack( mask, tenths)
	if short then
		-- sanity sheck, string.format will crash if format is wrong, and nothing is saved
		string.format(short, 1, 1);	string.format(long , 1, 1)
		local dbx = Grid2.db.profile.formatting
		dbx.shortDurationStackFormat = short
		dbx.longDurationStackFormat  = long
		dbx.invertDurationStack      = inverted
		Grid2:UpdateTextFormating()
		return true
	end
end

function Grid2Options:MakeFormattingOptions()

	local dbx      = Grid2.db.profile.formatting
	local dFormat  = ConvertToUserFormat(dbx.longDecimalFormat)
	local dTenths  = GetTenthsValue(dbx.shortDecimalFormat, dbx.longDecimalFormat)
	local dsFormat = ConvertToUserFormat(dbx.longDurationStackFormat)
	local dsTenths = GetTenthsValue(dbx.shortDurationStackFormat, dbx.longDurationStackFormat)
	
	Grid2Options:AddModuleOptions( "Misc", "Text Formatting", {
		durationFormat = {
			type = "input",
			order = 1,
			name = L["Duration Format"],
			desc = L["Examples:\n(%d)\n%d seconds"],
			get = function()  return dFormat end,
			set = function(_,v)	
				if SaveDecimalFormat(v, dTenths) then 
					dFormat = v 
				end
			end,
		},
		durationDecimals = {
			type = "select",
			order = 2,
			name = L["Display tenths of a second"],
			desc = L["Display tenths of a second"],
			get = function () return dTenths end,
			set = function (_, v) 
				if SaveDecimalFormat(dFormat, v) then 
					dTenths = v 
				end
			end,
			values = { L["Never"], L["Always"], L["When duration<1sec"] }
		},
		formatSeparator = {
		  type = "description",
		  name = "",
		  order = 3,
		},
		durationStackFormat = {
			type = "input",
			order = 4,
			name = L["Duration+Stacks Format"],
			desc = L["Examples:\n%d/%s\n%s(%d)"],
			get = function() return dsFormat end,
			set = function(_,v)	
				if SaveDurationStackFormat(v, dsTenths) then 
					dsFormat = v 
				end
			end,
		},
		durationStackDecimals = {
			type = "select",
			order = 5,
			name = L["Display tenths of a second"],
			desc = L["Display tenths of a second"],
			get = function ()  return dsTenths end,
			set = function (_, v) 
				if SaveDurationStackFormat(dsFormat,v) then	
					dsTenths = v 
				end
			end,
			values = { L["Never"], L["Always"] , L["When duration<1sec"] }
		},
	})

end