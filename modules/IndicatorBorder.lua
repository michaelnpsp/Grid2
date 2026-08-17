--[[ Created by Grid2 original authors, modified by Michael ]]--

local Border = Grid2.indicatorPrototype:new("border")

local cr, cg, cb, ca = 0, 0, 0, 0

Border.Create = Grid2.Dummy

-- aura containers management

function Border:Layout(parent)
	if self.auraMode then
		self:AcquireAuraSlotButton(parent, nil, function(_, _, button, filter)
			local borderSize = math.ceil(Grid2Frame.db.profile.frameBorder)
			button:SetAllPoints(parent)
			button:SetFrameLevel(parent:GetFrameLevel())
			local tex = button.__texture or button:CreateTexture(nil, "OVERLAY", nil, 7)
			tex:SetTexture( Grid2:GetSliceBorderTexture(borderSize) )
			tex:SetTextureSliceMargins(borderSize, borderSize, borderSize, borderSize)
			tex:SetTextureSliceMode(1)
			tex:SetAllPoints()
			tex:SetVertexColor(1, 1, 1, 1)
			button:SetAuraBorder(tex, filter.borderOptions)
			button.__texture = tex
		end)
	else
		self:ReleaseAuraSlotButton(parent)
	end
end

-- standard indicators

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
	local c = Grid2.MakeColor(Grid2Frame.db.profile.frameBorderColor, 'TRANSPARENT')
	cr, cg, cb, ca = c.r, c.g, c.b, c.a
end

local function Create(indicatorKey, dbx)
	Border.dbx = dbx
	Grid2:RegisterIndicator(Border, { "color" })
	return Border
end

Grid2.setupFunc["border"] = Create
