--[[ Created by Grid2 original authors, modified by Michael ]]--

local Border = Grid2.indicatorPrototype:new("border")

local Grid2Frame = Grid2Frame

Border.Create = Grid2.Dummy
Border.Layout = Grid2.Dummy

function Border:OnUpdate(parent, unit, status)
	if status then
		parent:SetBackdropBorderColor(status:GetColor(unit))
	else
		local c = Grid2Frame.db.profile.frameBorderColor
		if c then
			parent:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		else
			parent:SetBackdropBorderColor(0,0,0,0)
		end
	end
end

function Border:Disable(parent)
	parent:SetBackdropBorderColor(0,0,0,0)
end

local function Create(indicatorKey, dbx)
	Border.dbx = dbx
	Grid2:RegisterIndicator(Border, { "color" })
	return Border
end

Grid2.setupFunc["border"] = Create
