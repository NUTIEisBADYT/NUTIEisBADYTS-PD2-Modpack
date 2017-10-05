local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local max_players = tweak_data.max_players
function BaseNetworkSession:amount_of_alive_players()
	local count = 0

	local peers_all = self._peers_all
	for i = 1, max_players do
		local peer = peers_all[i]
		if peer and alive(peer:unit()) then
			count = count + 1
		end
	end

	return count
end

function BaseNetworkSession:peer_by_ip(ip)
	local peers_all = self._peers_all
	for i = 1, max_players do
		local peer = peers_all[i]
		if peer and peer:ip() == ip then
			return peer
		end
	end
end

function BaseNetworkSession:peer_by_user_id(user_id)
	local peers_all = self._peers_all
	for i = 1, max_players do
		local peer = peers_all[i]
		if peer and peer:user_id() == user_id then
			return peer
		end
	end
end
