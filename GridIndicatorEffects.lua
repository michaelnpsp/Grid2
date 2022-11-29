-- Implements glow, blink and zoom in effects for indicators.

local indicatorPrototype = Grid2.indicatorPrototype

-- Glowing border effects
local LCG = LibStub("LibCustomGlow-1.0")

local function GetUpdate_GlowPixel(indicator)
	local funcStatus = indicator.GetCurrentStatus
	local funcFrame  = indicator.GetBlinkFrame
	local funcUpdate = indicator.OnUpdate
	local funcStart  = LCG.PixelGlow_Start
	local funcStop   = LCG.PixelGlow_Stop
	local dbx = indicator.dbx
	local color = dbx.glow_color
	local linesCount = dbx.glow_linesCount or 8
	local frequency = dbx.glow_frequency or 0.25
	local thickness = dbx.glow_thickness or 2
	local always = not not dbx.highlightAlways
	return function(self, parent, unit)
		local status, state = funcStatus(self, unit)
		local frame = funcFrame(self, parent)
		if frame then
			local enabled = status and (always or state=="blink")
			if enabled ~= frame.__glowEnabled then
				frame.__glowEnabled = enabled
				if enabled then
					funcStart( frame, color, linesCount, frequency, nil, thickness, 0, 0, false )
				else
					funcStop( frame )
				end
			end
			funcUpdate(self, parent, unit, status)
		end
	end
end

local function GetUpdate_GlowAutoCast(indicator)
	local funcStatus = indicator.GetCurrentStatus
	local funcFrame  = indicator.GetBlinkFrame
	local funcUpdate = indicator.OnUpdate
	local funcStart  = LCG.AutoCastGlow_Start
	local funcStop   = LCG.AutoCastGlow_Stop
	local dbx = indicator.dbx
	local color = dbx.glow_color
	local particlesCount = dbx.glow_particlesCount or 4
	local frequency = dbx.glow_frequency or 0.12
	local particlesScale = dbx.glow_particlesScale or 1
	local always = not not dbx.highlightAlways
	return function(self, parent, unit)
		local status, state = funcStatus(self, unit)
		local frame = funcFrame(self, parent)
		if frame then
			local enabled = status and (always or state=="blink")
			if enabled ~= frame.__glowEnabled then
				frame.__glowEnabled = enabled
				if enabled then
					funcStart( frame, color, particlesCount, frequency, particlesScale, 0 , 0 )
				else
					funcStop( frame )
				end
			end
			funcUpdate(self, parent, unit, status)
		end
	end
end

local function GetUpdate_GlowButton(indicator)
	local funcStatus = indicator.GetCurrentStatus
	local funcFrame  = indicator.GetBlinkFrame
	local funcUpdate = indicator.OnUpdate
	local funcStart  = LCG.ButtonGlow_Start
	local funcStop   = LCG.ButtonGlow_Stop
	local dbx = indicator.dbx
	local color = dbx.glow_color
	local frequency = dbx.glow_frequency or 0.12
	local always = not not dbx.highlightAlways
	return function(self, parent, unit)
		local status, state = funcStatus(self, unit)
		local frame = funcFrame(self, parent)
		if frame then
			local enabled = status and (always or state=="blink")
			if enabled ~= frame.__glowEnabled then
				frame.__glowEnabled = enabled
				if enabled then
					funcStart( frame, color, frequency )
				else
					funcStop( frame )
				end
			end
			funcUpdate(self, parent, unit, status)
		end
	end
end

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

local function GetUpdate_Scale(indicator)
	local funcStatus = indicator.GetCurrentStatus
	local funcFrame  = indicator.GetBlinkFrame
	local funcUpdate = indicator.OnUpdate
	local animOnEnabled = indicator.dbx.animOnEnabled
	return function(self, parent, unit)
		local status, state = funcStatus(self, unit)
		local frame = funcFrame(self, parent)
		if frame then
			local anim = frame.scaleAnim
			if status then
				if not (anim and anim:IsPlaying()) and not (animOnEnabled and frame:IsVisible()) then
					(anim or CreateScaleAnimation(frame, self.dbx)):Play()
				end
			elseif anim then
				anim:Stop()
			end
			funcUpdate(self, parent, unit, status)
		end
	end
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

local function GetUpdate_Blink(indicator)
	local funcStatus = indicator.GetCurrentStatus
	local funcFrame  = indicator.GetBlinkFrame
	local funcUpdate = indicator.OnUpdate
	local always = not not indicator.dbx.highlightAlways
	return function(self, parent, unit)
		local status, state = funcStatus(self, unit)
		local frame = funcFrame(self, parent)
		if frame then
			local anim = frame.blinkAnim
			if status and (always or state=="blink") then
				(anim or CreateBlinkAnimation(frame,self.dbx)):Play()
			elseif anim then
				anim:Stop()
			end
			funcUpdate(self, parent, unit, status)
		end
	end
end

local function GetUpdate_Original(indicator)
	return indicator.UpdateF or indicatorPrototype.Update
end

do
	local updateFunctions = {
		[-2] = GetUpdate_Blink,
		[-1] = GetUpdate_Scale,
		[ 0] = GetUpdate_Original,
		[ 1] = GetUpdate_GlowPixel,
		[ 2] = GetUpdate_GlowAutoCast,
		[ 3] = GetUpdate_GlowButton,
	}
	-- Called from indicator:RegisterStatus() inside GridIndicator.lua
	-- Warning indicators that replace the Update method (like icons or multibar) cannot use these effects
	-- so never add a GetBlinkFrame method to an indicator that overrides the default Update method.
	function indicatorPrototype:UpdateHighlight(status)
		if self.GetBlinkFrame and (status==nil or ( self.highlightType==nil and (self.dbx.highlightAlways or (status.dbx and status.dbx.blinkThreshold)) ) ) then
			local typ = self.dbx.highlightType or -2 -- blink by default
			self.highlightType = typ
			self.Update = updateFunctions[typ](self)
		end
	end
end
