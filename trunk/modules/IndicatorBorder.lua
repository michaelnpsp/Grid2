--[[ Created by Grid2 original authors, modified by Michael ]]--

local Border = Grid2.indicatorPrototype:new("border")

function Border:Create()
end

function Border:Layout()
end

function Border:OnUpdate(parent, unit, status)
	if status then
		parent:SetBackdropBorderColor(status:GetColor(unit))
	else
		local c= self.dbx.color1
		parent:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
	end
end

local function Create(indicatorKey, dbx)
	Border.dbx = dbx
	Grid2:RegisterIndicator(Border, { "color" })
	return Border
end

Grid2.setupFunc["border"] = Create
