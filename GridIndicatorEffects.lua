-- Implements blink and zoom in/out effects for indicators.

local indicatorPrototype = Grid2.indicatorPrototype

-- Zoom in/out effect, not using animation BOUNCE looping method because is bugged (generate glitches)
local function CreateScaleAnimation(frame, dbx)
	local scale  = dbx.animScale or 1.5
	local durat  = (dbx.animDuration or 0.7) / 2
	local origin = dbx.animOrigin or 'CENTER'
	local group  = frame:CreateAnimationGroup()
	local grow   = group:CreateAnimation("Scale")
	local shrink = group:CreateAnimation("Scale")
	grow:SetOrder(1)
	grow:SetOrigin(origin,0,0)
	grow:SetScale(scale,scale)
	grow:SetDuration(durat)
	shrink:SetOrder(2)
	shrink:SetOrigin(origin,0,0)
	shrink:SetScale(1/scale,1/scale)
	shrink:SetDuration(durat)
	frame.scaleAnim, group.grow, group.shrink = group, grow, shrink
	return group
end

local function SetScaleEffect(indicator, frame, status)
	local anim = frame.scaleAnim
	if status then
		if not (anim and anim:IsPlaying()) and not (indicator.dbx.animOnEnabled and frame:IsVisible()) then
			(anim or CreateScaleAnimation(frame, indicator.dbx)):Play()
		end
	elseif anim then
		anim:Stop()
	end
end

-- Blink effect
local function CreateBlinkAnimation(frame, dbx)
	local anim  = frame:CreateAnimationGroup()
	local alpha = anim:CreateAnimation("Alpha")
	anim:SetLooping("REPEAT")
	alpha:SetOrder(1)
	alpha:SetFromAlpha(1)
	alpha:SetToAlpha(0.1)
	alpha:SetDuration(1/dbx.blinkFrequency)
	frame.blinkAnim = anim
	return anim
end

local function SetBlinkEffect(indicator, frame, enabled)
	local anim = frame.blinkAnim
	if enabled then
		(anim or CreateBlinkAnimation(frame,Grid2Frame.db.shared)):Play()
	elseif anim then
		anim:Stop()
	end
end

-- Indicator Update functions
local function UpdateBlinkScale(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	local frame = self.GetBlinkFrame(self,parent)
	SetBlinkEffect( self, frame, state=="blink" )
	SetScaleEffect( self, frame, status )
	self:OnUpdate(parent, unit, status)
end

local function UpdateScale(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	SetScaleEffect( self, self.GetBlinkFrame(self,parent), status )
	self:OnUpdate(parent, unit, status)
end

local function UpdateBlink(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	SetBlinkEffect( self, self.GetBlinkFrame(self,parent), state=="blink" )
	self:OnUpdate(parent, unit, status)
end

-- Public method (overwriting the original UpdateDB defined in GridIndicator.lua)
function indicatorPrototype:UpdateDB()
	if self.LoadDB then
		self:LoadDB()
	end
	if self.GetBlinkFrame then
		if Grid2Frame.db.shared.blinkType~="None" then
			self.Update = self.dbx.animEnabled and UpdateBlinkScale or UpdateBlink
		else
			self.Update = self.dbx.animEnabled and UpdateScale or indicatorPrototype.Update
		end
	elseif not rawget(self, "Update") then
		self.Update = indicatorPrototype.Update -- speed optimization
	end
end
