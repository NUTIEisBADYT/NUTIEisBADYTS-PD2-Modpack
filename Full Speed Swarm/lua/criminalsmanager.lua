local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local fs_original_criminalsmanager_addcharacter = CriminalsManager.add_character
function CriminalsManager:add_character(name, unit, peer_id, ...)
	managers.player:reset_cached_hostage_bonus_multiplier()
	if peer_id == managers.network:session():local_peer():id() then
		BlackMarketManager.equipped_grenade = BlackMarketManager.cached_equipped_grenade
		if not managers.groupai:state():whisper_mode() then
			managers.groupai:state():fs_load_loud_optims()
		end
	end
	return fs_original_criminalsmanager_addcharacter(self, name, unit, peer_id, ...)
end

local fs_original_criminalsmanager_remove = CriminalsManager._remove
function CriminalsManager:_remove(id)
	managers.player:reset_cached_hostage_bonus_multiplier()
	return fs_original_criminalsmanager_remove(self, id)
end
