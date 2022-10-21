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

local function UpdateScale(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	SetScaleEffect( self, self.GetBlinkFrame(self,parent), status )
	self:OnUpdate(parent, unit, status)
end

-- glowing border effect
local LCG = LibStub("LibCustomGlow-1.0")

local function InitGlowPixelAnimation(indicator)
	local dbx = indicator.dbx
	local key = indicator.name
	local funcStart = LCG.PixelGlow_Start
	local funcStop  = LCG.PixelGlow_Stop
	local color = dbx.glow_color
	local linesCount = dbx.glow_linesCount or 8
	local frequency = dbx.glow_frequency or 0.25
	local thickness = dbx.glow_thickness or 2
	return function( frame, enabled )
		if enabled ~= frame.__glowEnabled then
			frame.__glowEnabled = enabled
			if enabled then
				funcStart( frame, color, linesCount, frequency, nil, thickness, 0, 0, false, key )
			else
				funcStop( frame, key )
			end
		end
	end
end

local function InitGlowAutoCastAnimation(indicator)
	local dbx = indicator.dbx
	local key = indicator.name
	local funcStart = LCG.AutoCastGlow_Start
	local funcStop  = LCG.AutoCastGlow_Stop
	local color = dbx.glow_color
	local particlesCount = dbx.glow_particlesCount or 4
	local frequency = dbx.glow_frequency or 0.12
	local particlesScale = dbx.glow_particlesScale or 1
	return function( frame, enabled )
		if enabled ~= frame.__glowEnabled then
			frame.__glowEnabled = enabled
			if enabled then
				funcStart( frame, color, particlesCount, frequency, particlesScale, 0 , 0, key )
			else
				funcStop( frame, key )
			end
		end
	end
end

local function InitGlowButtonAnimation(indicator)
	local dbx = indicator.dbx
	local key = indicator.name
	local funcStart = LCG.ButtonGlow_Start
	local funcStop  = LCG.ButtonGlow_Stop
	local color = dbx.glow_color
	local frequency = dbx.glow_frequency or 0.12
	return function( frame, enabled )
		if enabled ~= frame.__glowEnabled then
			frame.__glowEnabled = enabled
			if enabled then
				funcStart( frame, color, frequency )
			else
				funcStop( frame )
			end
		end
	end
end

local glowEffectsInit = { InitGlowPixelAnimation, InitGlowAutoCastAnimation, InitGlowButtonAnimation }

local function UpdateGlow(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	self.glowAnim( self.GetBlinkFrame(self,parent), state=="blink" )
	self:OnUpdate(parent, unit, status)
end

local function UpdateGlowScale(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	local frame = self.GetBlinkFrame(self,parent)
	self.glowAnim( frame, state=="blink" )
	SetScaleEffect( self, frame, status )
	self:OnUpdate(parent, unit, status)
end

-- Blink effect
local function CreateBlinkAnimation(frame, dbx)
	local anim  = frame:CreateAnimationGroup()
	local alpha = anim:CreateAnimation("Alpha")
	anim.settings = alpha
	anim:SetLooping("REPEAT")
	alpha:SetOrder(1)
	alpha:SetFromAlpha( 1 )
	alpha:SetToAlpha( 0.1 )
	alpha:SetDuration( 1 / (dbx.blink_frequency or 2) )
	frame.blinkAnim = anim
	return anim
end

local function SetBlinkEffect(indicator, frame, enabled)
	local anim = frame.blinkAnim
	if enabled then
		(anim or CreateBlinkAnimation(frame,indicator.dbx)):Play()
	elseif anim then
		anim:Stop()
	end
end

local function UpdateBlink(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	SetBlinkEffect( self, self.GetBlinkFrame(self,parent), state=="blink" )
	self:OnUpdate(parent, unit, status)
end

local function UpdateBlinkScale(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	local frame = self.GetBlinkFrame(self,parent)
	SetBlinkEffect( self, frame, state=="blink" )
	SetScaleEffect( self, frame, status )
	self:OnUpdate(parent, unit, status)
end

-- Public method (overwriting the original UpdateDB defined in GridIndicator.lua)
function indicatorPrototype:UpdateDB()
	if self.LoadDB then
		self:LoadDB()
	end
	if self.GetBlinkFrame then
		if Grid2Frame.db.shared.blinkType~="None" then -- now blinkType controls blink and glow effects
			local typ = self.dbx.highlightType
			if typ then -- border glow effects
				self.glowAnim = glowEffectsInit[ typ ]( self )
				self.Update = self.dbx.animEnabled and UpdateGlowScale or UpdateGlow
			else -- blink effect
				self.glowAnim = nil
				self.Update = self.dbx.animEnabled and UpdateBlinkScale or UpdateBlink
			end
		else
			self.Update = self.dbx.animEnabled and UpdateScale or indicatorPrototype.Update
		end
	elseif not rawget(self, "Update") then
		self.Update = indicatorPrototype.Update -- speed optimization
	end
end
