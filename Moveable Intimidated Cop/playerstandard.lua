local mic_original_playerstandard_getintimidationaction = PlayerStandard._get_intimidation_action
function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only, secondary)
	if prime_target and prime_target.unit and prime_target.unit:base() and prime_target.unit:base().mic_is_being_moved then
		if self._unit == prime_target.unit:base().mic_is_being_moved then
			local wp = managers.hud and managers.hud._hud and managers.hud._hud.waypoints["CustomWaypoint_localplayer"]
			local wp_position = wp and mvector3.copy(wp.position) or nil
			local old_dst = prime_target.unit:base().mic_destination
			local same_dst = wp_position and old_dst and mvector3.equal(wp_position, old_dst)

			prime_target.unit:brain():on_intimidated(0, self._unit)
			prime_target.unit:base().mic_destination = wp_position

			if same_dst then
				local t = TimerManager:game():time()
				if not self._intimidate_t or t - self._intimidate_t > tweak_data.player.movement_state.interaction_delay then
					self._intimidate_t = t
					self:say_line("g18", managers.groupai:state():whisper_mode())
					if not self:_is_using_bipod() then
						self:_play_distance_interact_redirect(t, "cmd_gogo")
					end
				end
				return "mic_boost", false, prime_target -- will do nothing
			elseif wp_position then
				return "stop", false, prime_target
			end
		end
		return "come", false, prime_target
	end

	return mic_original_playerstandard_getintimidationaction(self, prime_target, char_table, amount, primary_only, detect_only, secondary)
end
