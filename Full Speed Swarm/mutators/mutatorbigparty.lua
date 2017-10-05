-- some of this comes from old GoonMod's mutator_insane_spawnrate.lua

MutatorBigParty = MutatorBigParty or class(BaseMutator)
MutatorBigParty._type = "MutatorBigParty"
MutatorBigParty.name_id = "fs_mutator_bigparty_name"
MutatorBigParty.desc_id = "fs_mutator_bigparty_desc"
MutatorBigParty.has_options = true
MutatorBigParty.reductions = {money = 0, exp = 0}
MutatorBigParty.categories = {"enemies"}
MutatorBigParty.icon_coords = {6, 1}

function MutatorBigParty:register_values(mutator_manager)
	self:register_value("insanity_level", 5, "il")
end

function MutatorBigParty:get_insanity_level()
	return self:value("insanity_level")
end

function MutatorBigParty:_min_insanity_level()
	return 2
end

function MutatorBigParty:_max_insanity_level()
	return 15
end

function MutatorBigParty:setup_options_gui(node)
	local params = {
		name = "insanity_level_slider",
		text_id = "fs_menu_mutator_insanity_level",
		callback = "_update_mutator_value",
		update_callback = callback(self, self, "_update_insanity_level")
	}
	local data_node = {
		type = "CoreMenuItemSlider.ItemSlider",
		show_value = true,
		min = self:_min_insanity_level(),
		max = self:_max_insanity_level(),
		step = 1,
		decimal_count = 0
	}
	local new_item = node:create_item(data_node, params)
	new_item:set_value(self:get_insanity_level())
	node:add_item(new_item)
	self._node = node
	return new_item
end

function MutatorBigParty:_update_insanity_level(item)
	self:set_value("insanity_level", item:value())
end

function MutatorBigParty:values()
	-- ugly way to send nothing to clients
	return {}
end

function MutatorBigParty:reset_to_default()
	self:clear_values()
	if self._node then
		local slider = self._node:item("insanity_level_slider")
		if slider then
			slider:set_value(self:get_insanity_level())
		end
	end
end

function MutatorBigParty:options_fill()
	return self:_get_percentage_fill(self:_min_insanity_level(), self:_max_insanity_level(), self:get_insanity_level())
end

function MutatorBigParty:setup()
	dofile(FullSpeedSwarm._path .. "mutators/old_goonmod_mutator_spawn_adjustments.lua")

	local group_ai = tweak_data.group_ai
	group_ai.special_unit_spawn_limits = {
		tank = 6,
		taser = 18,
		spooc = 12,
		shield = 32,
		medic = 18
	}

	local amount_multiplier = 10
	for id, group in pairs(group_ai.enemy_spawn_groups) do
		if id ~= "Phalanx" and not id:find("spooc") then
			if group.amount then
				for k, v in pairs(group.amount) do
					group.amount[k] = v * amount_multiplier
				end
			end
			for _, spawn in pairs(group.spawn or {}) do
				if spawn.amount_max then
					spawn.amount_max = spawn.amount_max * (amount_multiplier * ((spawn.unit:find("swat") or spawn.unit:find("heavy")) and 1 or 0.2))
				end
			end
		end
	end

	local besiege = group_ai.besiege
	local insanity_level = self:get_insanity_level()
	besiege.assault.force = {
		insanity_level,
		insanity_level,
		insanity_level
	}

	besiege.assault.force_pool = {
		300,
		600,
		1000
	}

	besiege.reenforce.interval = {
		1,
		2,
		3
	}

	besiege.assault.force_balance_mul = {
		20,
		24,
		28,
		32
	}
	besiege.assault.force_pool_balance_mul = {
		12,
		18,
		24,
		32
	}

	besiege.assault.delay = {
		15,
		10,
		5
	}

	besiege.assault.sustain_duration_min = {
		120,
		160,
		240
	}

	besiege.assault.sustain_duration_max = {
		240,
		320,
		480
	}

	besiege.assault.sustain_duration_balance_mul = {
		1.3,
		1.5,
		1.7,
		1.9
	}
end
