--- (C) 2011 Michael
--- zlib/libpng License
--- Simple utf8 manipulation functions

local function utf8len(s)
	local l = #s
	local i = 1
	local c = 0
	while i<=l do
		local b = string.byte(s, i)
		if     b < 192 then	i = i + 1
		elseif b < 224 then i = i + 2
		elseif b < 240 then	i = i + 3
		else				i = i + 4
		end
		c = c + 1
	end
	return c
end
if not string.utf8len then
	string.utf8len = utf8len
end

local function utf8pos(s, pos)
	local l = #s
	local i = 1
	local c = pos-1
	while c>0 and i<=l do
		local b = string.byte(s, i)
		if     b < 192 then	i = i + 1
		elseif b < 224 then i = i + 2
		elseif b < 240 then	i = i + 3
		else				i = i + 4
		end
		c = c - 1
	end
	return i
end
if not string.utf8pos then
	string.utf8pos = utf8pos
end

local function utf8sub(s, from, to)
	local l = #s
	local c = to and to-from+1 or l
	local j = from>1 and utf8pos(s, from) or 1
	local i = j
	while c>0 and i<=l do
		local b = string.byte(s, i)
		if     b < 192 then	i = i + 1
		elseif b < 224 then i = i + 2
		elseif b < 240 then	i = i + 3
		else				i = i + 4
		end
		c = c - 1
	end
	return s:sub(j, i-1)
end
if not string.utf8sub then
	string.utf8sub = utf8sub
end

