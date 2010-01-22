local media = LibStub("LibSharedMedia-3.0", true)

if not media then return end

local registeredMedia = {}
local dummy_info = {}

media.RegisterCallback(Grid2Options, "LibSharedMedia_Registered", function (_, type, name)
	local t = registeredMedia[type]
	if not t then return end
	local list = media:List(type)
	for _, option in ipairs(t) do
		dummy_info.option = option
		option.values = list
		if option.get(dummy_info) == name then
			option.set(dummy_info, name)
		end
	end
end)
media.RegisterCallback(Grid2Options, "LibSharedMedia_SetGlobal", function (_, type)
	local t = registeredMedia[type]
	if not t then return end
	for _, option in ipairs(t) do
		dummy_info.option = option
		option.set(dummy_info, option.get(dummy_info))
	end
end)

function Grid2Options:AddMediaOption(type, option)
	option.values = media:List(type)
	local t = registeredMedia[type]
	if not t then
		t = {}
		registeredMedia[type] = t
	end
	t[#t + 1] = option
end
