--[[
	Layouts test mode
--]]

local Grid2Layout = Grid2:GetModule("Grid2Layout")
local Grid2Frame = Grid2:GetModule("Grid2Frame")
local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L
local LG = Grid2Options.LG
local theme = Grid2Options.editedTheme

local colCount
local rowCount
local colColors
local layoutName
local layoutFrame
local layoutFrameWidth
local layoutFrameHeight
local frames = {}

local layoutBackdrop = {
	 bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	 tile = false, tileSize = 16, edgeSize = 16,
	 insets = {left = 4, right = 4, top = 4, bottom = 4},
}

local frameBackdrop = {
	bgFile = nil, tile = false, tileSize = 0,
	edgeFile = "Interface\\Addons\\Grid2\\media\\white16x16", edgeSize = 1,
	insets = {left = 1, right = 1, top = 1, bottom = 1},
}

local colorsTable= { pet= { r=0,g=1,b=0, a=0.35 }, spacer = { r=0,g=0,b=0, a=0 } }

local vectors= {
	TOPLEFT     = { 1,0, 0, 1, 0, 0},
	TOPRIGHT    = {-1,0, 0, 1, 1, 0},
	BOTTOMLEFT  = { 1,0, 0,-1, 0, 1},
	BOTTOMRIGHT = {-1,0, 0,-1, 1, 1},
}

local function SavePosition()
	local f = layoutFrame
	if f:GetLeft() and f:GetWidth() then
		local a = theme.layout.anchor
		local s = f:GetEffectiveScale()
		local t = UIParent:GetEffectiveScale()
		local x = (a:find("LEFT")  and f:GetLeft()*s) or
				  (a:find("RIGHT") and f:GetRight()*s-UIParent:GetWidth()*t) or
				  (f:GetLeft()+f:GetWidth()/2)*s-UIParent:GetWidth()/2*t
		local y = (a:find("BOTTOM") and f:GetBottom()*s) or
				  (a:find("TOP")    and f:GetTop()*s-UIParent:GetHeight()*t) or
				  (f:GetTop()-f:GetHeight()/2)*s-UIParent:GetHeight()/2*t
		theme.layout.PosX, theme.layout.PosY = x, y
	end
end

local function RestorePosition()
	local s = layoutFrame:GetEffectiveScale()
	local x = theme.layout.PosX / s
	local y = theme.layout.PosY / s
	local a = theme.layout.anchor
	layoutFrame:ClearAllPoints()
	layoutFrame:SetPoint(a, x, y)
end

local function LayoutMouseDown(_, button)
	if button == "LeftButton" then
		layoutFrame:StartMoving()
		layoutFrame.isMoving = true
	end
end

local function LayoutMouseUp()
	if layoutFrame.isMoving then
		layoutFrame.isMoving = false
		layoutFrame:StopMovingOrSizing()
		SavePosition()
		RestorePosition()
	end
end

local function LayoutGetTestFrame(i)
	local f = frames[i] or CreateFrame("Frame", nil, layoutFrame) 
	f:SetBackdrop(frameBackdrop)
	frames[i]= f
	return f
end

local function LayoutGetVectors(anchor, horizontal, ox,oy, w,h, cols, rows)
	local ux,uy,vx,vy,px,py= unpack(vectors[anchor])
	if horizontal then
		return vx*w,vy*h,ux*w,uy*h,px*(rows-1)*w+ox,py*(cols-1)*h+oy,rows,cols
	else
		return ux*w,uy*h,vx*w,vy*h,px*(cols-1)*w+ox,py*(rows-1)*h+oy,cols,rows
	end
end

local function LayoutLoad(name, maxPlayers)
	if not name then return layoutName end
	colColors= {}
	local layout = Grid2Layout.layoutSettings[name]
	if layout then
		layout = Grid2.CopyTable(layout)
		if not layout[1] then
			local m = math.ceil( (maxPlayers or 40)/5 )
			for i=1,m do layout[i]= {} end
		end
		local defaults = layout.defaults or {}
		colCount= 0
		rowCount= 0
		local col= 1
		for i, l in ipairs(layout) do
			local unitPerColumn, maxColumns
			if (l=="auto" or l.groupFilter=="auto") and maxPlayers then
				unitPerColumn = 5
				maxColumns    = math.ceil(maxPlayers/5)
			else
				unitPerColumn = l.unitsPerColumn or defaults.unitsPerColumn or 5
				maxColumns    = l.maxColumns or defaults.maxColumns or 1
				maxColumns    = maxColumns=="auto" and math.ceil((maxPlayers or 40)/5) or maxColumns
			end
			colCount = colCount + maxColumns
			rowCount = max(rowCount,unitPerColumn)
			local c = l.type and colorsTable[l.type] or RAID_CLASS_COLORS[ CLASS_SORT_ORDER[((i-1)%#CLASS_SORT_ORDER)+1] ]
			for j=1,maxColumns do
				colColors[col] = { c.r*0.5, c.g*0.5, c.b*0.5, c.a or 0.75}
				col = col + 1
			end
		end
		layoutName = name
		return true
	end
end

local function InitFrames()
	local p = theme.layout
	-- create layout frame
	if not layoutFrame then
		layoutFrame = CreateFrame('Frame', nil, UIParent)
		layoutFrame:SetScript("OnMouseUp", LayoutMouseUp)
		layoutFrame:SetScript("OnMouseDown", LayoutMouseDown)
		layoutFrame:SetMovable(true)
		layoutFrame:EnableMouse(true)	
		layoutFrame.Text = layoutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		layoutFrame.Text:SetPoint("BOTTOM", layoutFrame, "TOP", 0, -8)
		layoutFrame.Text:SetShadowOffset(1,-1)
		layoutFrame.Text:SetShadowColor(0,0,0, 1)		
		layoutFrame.Text:SetTextColor(1, 1, 1, 1)
		layoutFrame.Text:Show()
	end
	-- scale
	layoutFrame:SetScale( p.ScaleSize or 1 )
	-- position
	RestorePosition()
	-- background&border textures
	layoutBackdrop.bgFile = Grid2:MediaFetch("background", p.BackgroundTexture)
	layoutBackdrop.edgeFile = Grid2:MediaFetch("border", p.BorderTexture)
	layoutFrame:SetBackdrop( layoutBackdrop )
	-- create bg texture
	layoutFrame.texture = layoutFrame.texture or layoutFrame:CreateTexture(nil, "BORDER")
	layoutFrame.texture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	layoutFrame.texture:SetPoint("TOPLEFT", layoutFrame, "TOPLEFT", 4, -4)
	layoutFrame.texture:SetPoint("BOTTOMRIGHT", layoutFrame, "BOTTOMRIGHT", -4, 4)
	layoutFrame.texture:SetBlendMode("ADD")
	layoutFrame.texture:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .2, .2, .2, 0.5)
	-- update color
	layoutFrame.texture:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .2, .2, .2, p.BackgroundA/2 )
	layoutFrame:SetBackdropBorderColor(p.BorderR, p.BorderG, p.BorderB, p.BorderA)
	layoutFrame:SetBackdropColor(p.BackgroundR, p.BackgroundG, p.BackgroundB, p.BackgroundA)
	-- reset test unit frames
	frameBackdrop.bgFile = media:Fetch("statusbar", theme.frame.barTexture) or "Interface\\Addons\\Grid2\\media\\gradient32x32"
	for i=1,#frames do
		frames[i]:Hide()
	end
	-- hide real layout frame
    Grid2Layout.frame:Hide()
	-- show test layout frame
	layoutFrame:Show()
end

-- Published methods

function Grid2Options:LayoutTestRefresh(name, width, height, maxPlayers)

	if not LayoutLoad(name, maxPlayers) then return end

	InitFrames()

	layoutFrame.Text:SetText( string.format("|cFFfefe00%s:|r %s  |cFFfefe00%s:|r %s", L["Theme"], theme.db.names[theme.index] or L['Default'], L["Layout"], LG[layoutName]) )
	
	width  = width  or theme.frame.frameWidth
	height = height or theme.frame.frameHeight
	local settings = theme.layout
	local inset    = theme.frame.frameBorder
	local frameLevel = layoutFrame:GetFrameLevel() + 1
	local Spacing = settings.Spacing
	local Padding = settings.Padding
	local w = width - inset*2
	local h = height- inset*2
    local ux,uy,vx,vy,px,py,realCols,realRows = LayoutGetVectors( settings.groupAnchor, settings.horizontal, Spacing, Spacing, width+Padding, height+Padding, colCount, rowCount )
	px= px + inset
	py= py + inset
	local i= 1
	for nx=0,colCount-1 do
		local r,g,b,a= unpack(colColors[nx+1])
		for ny=0,rowCount-1 do
			local x= nx*ux + ny*vx + px
			local y= nx*uy + ny*vy + py
			local frame= LayoutGetTestFrame(i)
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", layoutFrame, "TOPLEFT", x, -y )
			frame:SetSize( w,h )
			frame:SetBackdropColor( r,g,b,a )
			frame:SetBackdropBorderColor(0,0,0,1)
			frame:SetFrameLevel(frameLevel)
			frame:Show()
			r,g,b= r*0.7, g*0.7, b*0.7
			i= i + 1
		end
	end
	local layWidth = Spacing*2 + realCols * (width+Padding) - Padding
	local layHeight= Spacing*2 + realRows * (height+Padding) - Padding
	layoutFrame:SetSize(layWidth,layHeight)
end

function Grid2Options:LayoutTestEnable(name, width, height, maxPlayers)
	if name and name ~= layoutName then
		self:LayoutTestRefresh(name, width, height, maxPlayers)
	elseif layoutName then
		layoutName= nil
		layoutFrame:Hide()
		Grid2Layout.frame:Show()
		Grid2Layout:RestorePosition()
		Grid2Layout:UpdateSize()
	end
end
