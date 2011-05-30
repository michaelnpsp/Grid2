--- (C) 2011 Michael
--- zlib/libpng License
--- Simple utf8 manipulation functions

local strbyte= string.byte

if not string.lenutf8 then
	string.lenutf8 = strlenutf8  -- Provided by blizzard api
end

local function posutf8(s, pos)
	local l = #s
	local i = 1
	local c = pos-1
	while c>0 and i<=l do
		local b = strbyte(s, i)
		if     b < 192 then	i = i + 1
		elseif b < 224 then i = i + 2
		elseif b < 240 then	i = i + 3
		else				i = i + 4
		end
		c = c - 1
	end
	return i
end
if not string.posutf8 then
	string.posutf8 = posutf8
end

local function subutf8(s, from, to)
	local l = #s
	local c = to and to-from+1 or l
	local j = from>1 and posutf8(s, from) or 1
	local i = j
	while c>0 and i<=l do
		local b = strbyte(s, i)
		if     b < 192 then	i = i + 1
		elseif b < 224 then i = i + 2
		elseif b < 240 then	i = i + 3
		else				i = i + 4
		end
		c = c - 1
	end
	return s:sub(j, i-1)
end
if not string.subutf8 then
	string.subutf8 = subutf8
end

