local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if core then
	core:module("CoreEvent")
end

local math_floor = math.floor
local table_insert = table.insert
function CallbackHandler:__insert_sorted(cb)
	local cb_next = cb.next
	local t = self._sorted
	local iStart, iEnd, iMid, iState = 1, #t, 1, 0
	-- thanks to http://lua-users.org/wiki/BinaryInsert
	while iStart <= iEnd do
		iMid = math_floor((iStart + iEnd) * 0.5)
		local i = iMid
		local mid_next = t[iMid].next
		while not mid_next do
			if iMid == iStart then
				while true do
					i = i + 1
					local item = t[i]
					if not (item and (item.next == nil or cb_next > item.next)) then
						table_insert(t, i, cb)
						return
					end
				end
			end
			iMid = iMid - 1
			mid_next = t[iMid].next
		end
		if cb_next == mid_next then
			break
		elseif cb_next < mid_next then
			iEnd, iState = iMid - 1, 0
		else
			iStart, iState = iMid + 1, 1
		end
	end
	table_insert(t, iMid + iState, cb)
end
