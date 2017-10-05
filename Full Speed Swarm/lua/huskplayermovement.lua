local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

-- remove when http://steamcommunity.com/app/218620/discussions/14/144513248272843703/ gets integrated into base game
local fs_original_huskplayermovement_syncmovementstate = HuskPlayerMovement.sync_movement_state
function HuskPlayerMovement:sync_movement_state(state, down_time)
	if state == 'fatal' then
		self:sync_stop_auto_fire_sound()
	end
	fs_original_huskplayermovement_syncmovementstate(self, state, down_time)
end
