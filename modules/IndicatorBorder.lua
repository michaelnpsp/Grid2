--[[ Created by Grid2 original authors, modified by Michael ]]--

local Border = Grid2.indicatorPrototype:new("border")

local cr, cg, cb, ca = 0, 0, 0, 0

Border.Create = Grid2.Dummy
Border.Layout = Grid2.Dummy

function Border:GetFrame(parent)
	return parent
end

function Border:OnUpdate(parent, unit, status)
	if status then
		parent:SetBackdropBorderColor(status:GetColor(unit))
	else
		parent:SetBackdropBorderColor(cr, cg, cb, ca)
	end
end

function Border:Disable(parent)
	parent:SetBackdropBorderColor(0,0,0,0)
end

function Border:UpdateDB()
	local c = Grid2:MakeColor(Grid2Frame.db.profile.frameBorderColor, 'TRANSPARENT')
	cr, cg, cb, ca = c.r, c.g, c.b, c.a
end

local function Create(indicatorKey, dbx)
	Border.dbx = dbx
	Grid2:RegisterIndicator(Border, { "color" })
	return Border
end

Grid2.setupFunc["border"] = Create
