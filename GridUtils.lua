function Grid2.GetShortNumber(v, setPlusSign)
	local sign
	if v < 0 then
		sign = "-"
		v = -v
	else
		sign = setPlusSign and "+" or ""
	end
	if v >= 1000 then
		v = ("%.1fk"):format(v / 1000)
	end
	return sign..v
end
