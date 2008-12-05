local media = LibStub("LibSharedMedia-3.0", true)

if not media then return end

local registeredMedia = {}

media.RegisterCallback(Grid2Options, "LibSharedMedia_Registered", function (_, type, name)
	local t = registeredMedia[type]
	if not t then return end
	local list = media:List(type)
	for _, option in ipairs(t) do
		if option:get() == name then
			option:set(name)
		end
		option.values = list
	end
end)
media.RegisterCallback(Grid2Options, "LibSharedMedia_SetGlobal", function (_, type)
	local t = registeredMedia[type]
	if not t then return end
	for _, option in ipairs(t) do
		option:set(option:get())
	end
end)

function Grid2Options:AddMediaOption(type, option)
	local t = registeredMedia[type]
	if not t then
		t = {}
		registeredMedia[type] = t
	end
	t[#t + 1] = option
	option.values = media:List(type)
end
