function CopActionHurt:_start_enemy_fire_effect_on_death(death_variant)
	local enemy_effect_name = ""
	local anim_duration = 3
	if death_variant == 1 then

		anim_duration = 9
	elseif death_variant == 2 then

		anim_duration = 5
	elseif death_variant == 3 then

		anim_duration = 5
	elseif death_variant == 4 then

		anim_duration = 7
	elseif death_variant == 5 then

	else

	end
	managers.fire:start_burn_body_sound({
		enemy_unit = self._unit
	}, anim_duration)

end
