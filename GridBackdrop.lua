local BORDER_SETTINGS = {
	showIcon = true,
	showWhenHarmful = true,
	showWhenHelpful = true,
	style = 1 -- Atlas = 0, Color = 1
}

local Grid2BackdropTemplateMixin = {}

for k,v in pairs(BackdropTemplateMixin) do
   Grid2BackdropTemplateMixin[k] = v
end

function Grid2BackdropTemplateMixin:SetAuraBackdropBorder()
	self:SetAuraBorder(self.TopLeftCorner, BORDER_SETTINGS)
	self:SetAuraBorder(self.TopRightCorner, BORDER_SETTINGS)
	self:SetAuraBorder(self.BottomLeftCorner, BORDER_SETTINGS)
	self:SetAuraBorder(self.BottomRightCorner, BORDER_SETTINGS)
	self:SetAuraBorder(self.TopEdge, BORDER_SETTINGS)
	self:SetAuraBorder(self.BottomEdge, BORDER_SETTINGS)
	self:SetAuraBorder(self.LeftEdge, BORDER_SETTINGS)
	self:SetAuraBorder(self.RightEdge, BORDER_SETTINGS)
end

function Grid2BackdropTemplateMixin:ClearAuraBackdropBorder()
	self:ClearAuraBorder(self.TopLeftCorner)
	self:ClearAuraBorder(self.TopRightCorner)
	self:ClearAuraBorder(self.BottomLeftCorner)
	self:ClearAuraBorder(self.BottomRightCorner)
	self:ClearAuraBorder(self.TopEdge)
	self:ClearAuraBorder(self.BottomEdge)
	self:ClearAuraBorder(self.LeftEdge)
	self:ClearAuraBorder(self.RightEdge)
end

Grid2BackdropTemplateMixin = Grid2BackdropTemplateMixin
