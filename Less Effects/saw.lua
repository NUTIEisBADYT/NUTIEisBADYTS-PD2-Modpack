function SawWeaponBase:_start_sawing_effect()
	if not self._active_effect then
		self:_play_sound_sawing()
		--self._active_effect = World:effect_manager():spawn(self._active_effect_table)

	end
end
