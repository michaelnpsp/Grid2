--[[ Created by Grid2 original authors, modified by Michael ]]--

local Border = Grid2.indicatorPrototype:new("border")

local cr, cg, cb, ca = 0, 0, 0, 0

Border.Create = Grid2.Dummy

-- aura containers management

function Border:OnUnitChanged(parent, unit)
	local auraContainer = parent._borderAuraContainer
	if auraContainer then
		unit = unit or 'none'
		if unit~=auraContainer:GetUnit() then
			local enabled = unit~="none"
			auraContainer:SetUnit(unit)
			auraContainer:SetShown(enabled)
			auraContainer:SetEnabled(enabled)
		else
			auraContainer:UpdateAllAuras()
		end
	end
end

function Border:ReleaseAuraContainer(parent)
	local auraContainer = parent._borderAuraContainer
	if auraContainer then
		auraContainer:SetShown(false)
		auraContainer:SetEnabled(false)
		auraContainer:SetParent(nil)
		parent._borderAuraContainer = nil
	end
end

function Border:AcquireAuraContainerSlot(parent, initFunc, filter)
	local auraContainer = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
	parent._borderAuraContainer = auraContainer
	auraContainer:AddAuraSlot( "1", filter.filter, {
		sortMethod = filter.sortRule or 0,
		sortDirection = filter.sortDir or 0,
		candidateFilters = filter.candidateFilters,
		initializeFrame = initFunc,
	} )
	auraContainer:Show()
end

function Border:Layout(parent)
	self:ReleaseAuraContainer(parent)
	if self.auraMode then
		local filter = self:GetStatusAurasFilter()
		self:AcquireAuraContainerSlot(parent, function(button)
			local borderSize = Grid2Frame.db.profile.frameBorder
			button:SetAllPoints(parent)
			button:SetFrameLevel(parent:GetFrameLevel())
			local tex = button:CreateTexture(nil, "OVERLAY", nil, 7)
			tex:SetTexture( Grid2:GetSliceBorderTexture(borderSize) )
			tex:SetTextureSliceMargins(borderSize, borderSize, borderSize, borderSize)
			tex:SetTextureSliceMode(1)
			tex:SetAllPoints()
			tex:SetVertexColor(1, 1, 1, 1)
			button:SetAuraBorder(tex, filter.borderOptions)
		end, filter)
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
