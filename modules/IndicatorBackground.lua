
local Background = Grid2.indicatorPrototype:new("background")

local Grid2Frame = Grid2Frame

Background.Create = Grid2.Dummy
Background.Layout = Grid2.Dummy

function Background:Disable(parent)
	parent.container:SetVertexColor(0,0,0,0)
end

function Background:OnUpdate(parent, unit, status)
	if status then
		parent.container:SetVertexColor(status:GetColor(unit))
	else
		local c = Grid2Frame.db.profile.frameContentColor
		parent.container:SetVertexColor(c.r, c.g, c.b, c.a)
	end
end

local function Create(indicatorKey, dbx)
	Background.dbx = dbx
	Grid2:RegisterIndicator(Background, { "color" })
	return Background
end

Grid2.setupFunc["background"] = Create
