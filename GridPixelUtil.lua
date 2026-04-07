---------------------------------------------------
-- Pixel perfect calculation functions
---------------------------------------------------

local Round = Round
local min = math.min
local max = math.max

local PixelUtil, scaleFactor = {}

---------------------------------------------------
-- Shared
---------------------------------------------------

function PixelUtil.GetScaleFactor()
	local physicalWidth, physicalHeight = GetPhysicalScreenSize()
	return 768.0 / physicalHeight
end

---------------------------------------------------
-- Non pixel perfect
---------------------------------------------------

function PixelUtil.GetSizeForScale(size, scale)
	return size * scale
end

function PixelUtil.GetSizeForRegion(size, region)
	return size
end

function PixelUtil.SetWidth(region, width)
	region:SetWidth(width)
end

function PixelUtil.SetHeight(region, height)
	region:SetWidth(height)
end

function PixelUtil.SetSize(region, width, height)
	region:SetSize(width, height)
end

function PixelUtil.SetPoint(region, point, relativeTo, relPoint, offX, offY, minX, minY)
	region:SetPoint(point, relativeTo, relPoint, offX, offY)
end

---------------------------------------------------
-- Pixel perfect
---------------------------------------------------

local function GetSizeForScale(size, scale, minPixels)
	local pixels =  Round( (size * scale) / scaleFactor )
	if minPixels then
		pixels = size<0.0 and max( pixels, -minPixels ) or min( pixels, minPixels )
	end
	return pixels * scaleFactor / scale
end

local function GetSizeForRegion(size, region)
	return GetSizeForScale( size, region:GetEffectiveScale() )
end

local function SetWidth(region, width, minPixels)
	region:SetWidth( GetSizeForScale(width, region:GetEffectiveScale(), minPixels) )
end

local function SetHeight(region, height, minPixels)
	region:SetHeight( GetSizeForScale(height, region:GetEffectiveScale(), minPixels) )
end

local function SetSize(region, width, height, minWidth, minHeight)
	local scale = region:GetEffectiveScale()
	region:SetSize( GetSizeForScale(width, scale, minWidth), GetSizeForScale(height, scale, minHeight) )
end

local function SetPoint(region, point, relativeTo, relPoint, offX, offY, minX, minY)
	local scale = region:GetEffectiveScale()
	region:SetPoint(point, relativeTo, relPoint, GetSizeForScale(offX, scale, minX), GetSizeForScale(offX, scale, minY) )
end

function PixelUtil.PixelPerfectEnable()
	scaleFactor = PixelUtil.GetScaleFactor()
	PixelUtil.GetSizeForScale = GetSizeForScale
	PixelUtil.GetSizeForRegion = GetSizeForRegion
	PixelUtil.SetWidth = SetWidth
	PixelUtil.SetHeight = SetHeight
	PixelUtil.SetSize = SetSize
	PixelUtil.SetPoint = SetPoint
end

---------------------------------------------------
--
---------------------------------------------------

Grid2.PixelUtil = PixelUtil
