local Border = Grid2.indicatorPrototype:new("border")

function Border:Create(parent)
end

function Border:Layout(parent)
end

function Border:OnUpdate(parent, unit, status)
	if status then
		parent:SetBackdropBorderColor(status:GetColor(unit))
	else
		parent:SetBackdropBorderColor(0, 0, 0, 1)
	end
end

local function Create(indicatorKey, dbx)
	Border.dbx = dbx
	Grid2:RegisterIndicator(Border, { "color" })
	return Border
end

Grid2.setupFunc["border"] = Create
