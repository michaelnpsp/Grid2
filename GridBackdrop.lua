local BORDER_SETTINGS = {
	showIcon = true,
	showWhenHarmful = true,
	showWhenHelpful = true,
	style = 1 -- Atlas = 0, Color = 1
}

Grid2BackdropTemplateMixin = {}

for k,v in pairs(BackdropTemplateMixin) do
   Grid2BackdropTemplateMixin[k] = v
end

function Grid2BackdropTemplateMixin:SetAuraBackdropBorder()
	self:ClearDispelTypeTextures()
	self:AddDispelTypeTexture(self.TopLeftCorner, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.TopRightCorner, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.BottomLeftCorner, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.BottomRightCorner, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.TopEdge, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.BottomEdge, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.LeftEdge, BORDER_SETTINGS)
	self:AddDispelTypeTexture(self.RightEdge, BORDER_SETTINGS)
end

function Grid2BackdropTemplateMixin:ClearAuraBackdropBorder()
	self:ClearDispelTypeTextures()
end
