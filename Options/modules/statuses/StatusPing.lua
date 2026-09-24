-- Pings Received

local L = Grid2Options.L

local function make_color_option(status, options, key, order)
	if order then
		options[key] = {
			type = "color",
			hasAlpha = true,
			width = "full",
			order = order,
			name = L[key],
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
	make_color_option(status, options, "Attack",  1)
	make_color_option(status, options, "Warning", 2)
	make_color_option(status, options, "Assist",  3)
	make_color_option(status, options, "OnMyWay", 4)
end, {
	title = L["Communication Pings"],
	titleIcon = "Interface/Cursor/UIPingCursor2x",
	titleIconCoords = { 0.767578125, 0.861328125, 0.00390625, 0.19140625},
})
