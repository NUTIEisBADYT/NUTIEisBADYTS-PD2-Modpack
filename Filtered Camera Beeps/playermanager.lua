local fcb_original_playermanager_serverdropcarry = PlayerManager.server_drop_carry
function PlayerManager:server_drop_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
	local unit = fcb_original_playermanager_serverdropcarry(self, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
	if unit and peer then
		unit:carry_data().fcb_last_carrier_id = peer:id()
	end
	return unit
end
