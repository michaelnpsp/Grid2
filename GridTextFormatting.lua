local Grid2 = Grid2

local strfind = strfind

Grid2.defaults.profile.formatting = {
	longDecimalFormat        = "%.1f",
	shortDecimalFormat       = "%.0f",
	minutesDecimalFormat     = "%.0fm",
	hoursDecimalFormat       = "%.0fh",
	longDurationStackFormat  = "%.1f:%d",
	shortDurationStackFormat = "%.0f:%d",
	invertDurationStack      = false,
	secondsElapsedFormat     = "%ds",
	minutesElapsedFormat     = "%dm",
	percentFormat            = "%.0f%%",
	numbersUseGameFormat     = nil,
}

local formatter = C_StringUtil.CreateNumericRuleFormatter()

local breakpoints = {}

function Grid2:GetGeneralElapsedTimeFormatter()
	return formatter
end

function Grid2:UpdateGeneralTextFormatting()
	local fmt = Grid2.db.profile.formatting
	wipe(breakpoints)
	if fmt.longDecimalFormat==fmt.shortDecimalFormat then
		local step = strfind(fmt.longDecimalFormat,"%%.1f") and 0.1 or 1
		breakpoints[#breakpoints+1] = { threshold = 0, format = fmt.longDecimalFormat, step = step }
	else
		breakpoints[#breakpoints+1] = { threshold = 0, format = fmt.longDecimalFormat, step = .1 }
		breakpoints[#breakpoints+1] = { threshold = 1, format = fmt.shortDecimalFormat, step = 1 }
	end
	breakpoints[#breakpoints+1]	= { threshold = 60, format = fmt.minutesDecimalFormat, step = 1, components = {{div = 60}} }
	breakpoints[#breakpoints+1]	= {	threshold = 3600, format = fmt.hoursDecimalFormat,	step = 1, components = {{div = 3600}} }
	formatter:SetBreakpoints(breakpoints)
end
