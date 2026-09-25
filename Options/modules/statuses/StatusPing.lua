-- Pings Received

local L = Grid2Options.L

local function make_color_option(status, options, key, order)
	if order then
		options[key] = {
			type = "color",
			hasAlpha = true,
			width = "full",
			order = order,
			name = L[key] .. ' ' .. CreateAtlasMarkup("Ping_Chat_"..key, 16, 16),
			get = function()
				local c = status.dbx.colors[key]
				return c.r, c.g, c.b, c.a
			end,
			set = function(info, r, g, b, a)
				local c = status.dbx.colors[key]
				c.r, c.g, c.b, c.a = r, g, b, a
				status:Refresh()
			end,
		}
	end
end

Grid2Options:RegisterStatusOptions("ping", "misc", function(self, status, options, optionParams)
	make_color_option(status, options, "NonThreat", 1)
	make_color_option(status, options, "Threat", 2)
	make_color_option(status, options, "Attack", 3)
	make_color_option(status, options, "Warning", 4)
	make_color_option(status, options, "Assist", 5)
	make_color_option(status, options, "OnMyWay", 6)
	options.resetcolors = {
		type = "execute",
		order = 10,
		name = L["Reset Colors"],
		desc = L["Reset status settings to the default values."],
		func = function ()
			wipe(status.dbx.colors)
			Grid2.CopyTable( Grid2.defaults.profile.statuses[status.name].colors, status.dbx.colors )
		end,
		confirm = true,
	}
end, {
	title = L["Communication Pings"],
	titleIcon = "Interface/ChatFrame/ChatFrame",
	titleIconCoords = { 0.14453125, 0.26171875, 0.2578125, 0.4921875},
})
