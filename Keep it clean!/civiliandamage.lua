if Network:is_server() then
	local kic_civilians_killed = KeepItClean.civilians_killed

	local kic_original_civiliandamage_ondamagereceived = CivilianDamage._on_damage_received
	function CivilianDamage:_on_damage_received(damage_info)
		kic_original_civiliandamage_ondamagereceived(self, damage_info)

		if damage_info.result.type == "death" then
			local attacker_unit = damage_info and damage_info.attacker_unit
			if alive(attacker_unit) and attacker_unit:base() then
				if attacker_unit:base().thrower_unit then
					attacker_unit = attacker_unit:base():thrower_unit()
				elseif attacker_unit:base().sentry_gun then
					attacker_unit = attacker_unit:base():get_owner()
				end
			end
			if attacker_unit then
				local peer = managers.network:session():peer_by_unit(attacker_unit)
				if peer then
					local steam_id = peer:user_id()
					local ck_nr = kic_civilians_killed[steam_id] or 0
					kic_civilians_killed[steam_id] = ck_nr + 1
				end
			end
		end
	end
end
