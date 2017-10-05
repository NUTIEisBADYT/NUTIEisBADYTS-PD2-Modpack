
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_set_l = mvector3.set_length
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_dis = mvector3.distance
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()



function CopActionHurt:_start_enemy_fire_effect_on_death(death_variant)

	local enemy_effect_name = ""
	local anim_duration = 0
	if death_variant == 1 then
		anim_duration = 0
	elseif death_variant == 2 then
		anim_duration = 0
	elseif death_variant == 3 then
		anim_duration = 0
	elseif death_variant == 4 then
		anim_duration = 0
	elseif death_variant == 5 then
        anim_duration = 0
	else
        anim_duration = 0
	end
	managers.fire:start_burn_body_sound({
		enemy_unit = self._unit
	}, anim_duration)


end


function CopActionHurt:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_inventory = common_data.ext_inventory
	self._ext_anim = common_data.ext_anim
	self._body_part = action_desc.body_part
	self._unit = common_data.unit
	self._machine = common_data.machine
	self._attention = common_data.attention
	self._action_desc = action_desc
	local t = TimerManager:game():time()
	local tweak_table = self._unit:base()._tweak_table
	local is_civilian = CopDamage.is_civilian(tweak_table)
	local is_female = (self._machine:get_global("female") or 0) == 1
	local crouching = not self._unit:anim_data().crouch and self._unit:anim_data().hurt and 0 < self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "crh")
	local redir_res
	local action_type = action_desc.hurt_type
	local ignite_character = false
	local start_dot_dance_antimation = action_desc.fire_dot_data and action_desc.fire_dot_data.start_dot_dance_antimation
	if action_type == "fatal" then
		redir_res = self._ext_movement:play_redirect("fatal")
		if not redir_res then
			debug_pause("[CopActionHurt:init] fatal redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		managers.hud:set_mugshot_downed(self._unit:unit_data().mugshot_id)
	elseif action_desc.variant == "tase" then
		redir_res = self._ext_movement:play_redirect("tased")
		if not redir_res then
			debug_pause("[CopActionHurt:init] tased redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		managers.hud:set_mugshot_tased(self._unit:unit_data().mugshot_id)
	elseif action_type == "fire_hurt" or action_type == "light_hurt" and action_desc.variant == "fire" then
		local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
		local use_animation_on_fire_damage
		if char_tweak.use_animation_on_fire_damage == nil then
			use_animation_on_fire_damage = false
		else
			use_animation_on_fire_damage = false
		end
		if start_dot_dance_antimation then
			if ignite_character == "dragonsbreath" then

			end
			if self._unit:character_damage() ~= nil and self._unit:character_damage().get_last_time_unit_got_fire_damage ~= nil then
				local last_fire_recieved = self._unit:character_damage():get_last_time_unit_got_fire_damage()
				if last_fire_recieved == nil or t - last_fire_recieved > 1 then
					if use_animation_on_fire_damage then
						redir_res = self._ext_movement:play_redirect("fire_hurt")
						local dir_str
						local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)
						if fwd_dot < 0 then
							local hit_pos = action_desc.hit_pos
							local hit_vec = hit_pos - common_data.pos:with_z(0):normalized()
							if 0 < mvector3.dot(hit_vec, common_data.right) then
								dir_str = "r"
							else
								dir_str = "l"
							end
						else
							dir_str = "bwd"
						end
						self._machine:set_parameter(redir_res, dir_str, 1)
					end
					self._unit:character_damage():set_last_time_unit_got_fire_damage(t)
				end
			end
		end
	elseif action_type == "taser_tased" then
		local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
		if (char_tweak.can_be_tased == nil or char_tweak.can_be_tased) and self._unit:brain() and self._unit:brain()._current_logic_name ~= "intimidated" then
			redir_res = self._ext_movement:play_redirect("taser")
			local variant = math.random(4)
			local dir_str
			if variant == 1 then
				dir_str = "var1"
			elseif variant == 2 then
				dir_str = "var2"
			elseif variant == 3 then
				dir_str = "var3"
			elseif variant == 4 then
				dir_str = "var4"
			else
				dir_str = "fwd"
			end
			self._machine:set_parameter(redir_res, dir_str, 1)
		end
	elseif action_type == "light_hurt" then
		if not self._ext_anim.upper_body_active or self._ext_anim.upper_body_empty or self._ext_anim.recoil then
			redir_res = self._ext_movement:play_redirect(action_type)
			if not redir_res then
				debug_pause("[CopActionHurt:init] light_hurt redirect failed in", self._machine:segment_state(Idstring("upper_body")))
				return
			end
			local dir_str
			local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)
			if fwd_dot < 0 then
				local hit_pos = action_desc.hit_pos
				local hit_vec = hit_pos - common_data.pos:with_z(0):normalized()
				if 0 < mvector3.dot(hit_vec, common_data.right) then
					dir_str = "r"
				else
					dir_str = "l"
				end
			else
				dir_str = "bwd"
			end
			self._machine:set_parameter(redir_res, dir_str, 1)
			local height_str = action_desc.hit_pos.z > self._ext_movement:m_com().z and "high" or "low"
			self._machine:set_parameter(redir_res, height_str, 1)
		end
		self._expired = true
		return true
	elseif action_type == "hurt_sick" then
		local ecm_hurts_table = self._common_data.char_tweak.ecm_hurts
		if not ecm_hurts_table then
			debug_pause_unit(self._unit, "[CopActionHurt:init] Unit missing ecm_hurts in Character Tweak Data", self._unit)
			return
		end
		redir_res = self._ext_movement:play_redirect("hurt_sick")
		if not redir_res then
			debug_pause("[CopActionHurt:init] hurt_sick redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		local is_cop = true
		if is_civilian then
			is_cop = true
		end
		local sick_variants = {}
		for i, d in pairs(ecm_hurts_table) do
			table.insert(sick_variants, i)
		end
		local variant = sick_variants[math.random(#sick_variants)]
		local duration = math.random(ecm_hurts_table[variant].min_duration, ecm_hurts_table[variant].max_duration)
		for _, hurt_sick in ipairs(sick_variants) do
			self._machine:set_global(hurt_sick, hurt_sick == variant and 1 or 0)
		end
		self._sick_time = t + duration
	elseif action_type == "poison_hurt" then
		redir_res = self._ext_movement:play_redirect("hurt_poison")
		if not redir_res then
			debug_pause("[CopActionHurt:init] hurt_sick redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		self._sick_time = t + 2
	elseif action_type == "bleedout" then
		redir_res = self._ext_movement:play_redirect("bleedout")
		if not redir_res then
			debug_pause("[CopActionHurt:init] bleedout redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
	elseif action_type == "death" and action_desc.variant == "fire" then
		redir_res = self._ext_movement:play_redirect("death_fire")
		if not redir_res then
			debug_pause("[CopActionHurt:init] death_fire redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		local variant_count = #CopActionHurt.fire_death_anim_variants_length or 5
		local variant = 1
		if variant_count > 1 then
			variant = math.random(variant_count)
		end
		for i = 1, variant_count do
			local state_value = 0
			if i == variant then
				state_value = 1
			end
			self._machine:set_parameter(redir_res, "var" .. tostring(i), state_value)
		end

		managers.fire:check_achievemnts(self._unit, t)
	elseif action_type == "death" and action_desc.variant == "poison" then
		self:force_ragdoll()
	elseif action_type == "death" and (self._ext_anim.run and self._ext_anim.move_fwd or self._ext_anim.sprint) and not common_data.char_tweak.no_run_death_anim then
		redir_res = self._ext_movement:play_redirect("death_run")
		if not redir_res then
			debug_pause("[CopActionHurt:init] death_run redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		local variant = self.running_death_anim_variants[is_female and "female" or "male"] or 1
		if variant > 1 then
			variant = math.random(variant)
		end
		self._machine:set_parameter(redir_res, "var" .. tostring(variant), 1)
	elseif action_type == "death" and (self._ext_anim.run or self._ext_anim.ragdoll) and self:_start_ragdoll() then
		self.update = self._upd_ragdolled
	elseif action_type == "heavy_hurt" and (self._ext_anim.run or self._ext_anim.sprint) and not common_data.is_suppressed and not crouching then
		redir_res = self._ext_movement:play_redirect("heavy_run")
		if not redir_res then
			debug_pause("[CopActionHurt:init] heavy_run redirect failed in", self._machine:segment_state(Idstring("base")))
			return
		end
		local variant = self.running_hurt_anim_variants.fwd or 1
		if variant > 1 then
			variant = math.random(variant)
		end
		self._machine:set_parameter(redir_res, "var" .. tostring(variant), 1)
	else
		local variant, height, old_variant, old_info
		if (action_type == "hurt" or action_type == "heavy_hurt") and self._ext_anim.hurt then
			for i = 1, self.hurt_anim_variants_highest_num do
				if self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "var" .. i) then
					old_variant = i
					break
				end
			end
			if old_variant ~= nil then
				old_info = {
					fwd = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "fwd"),
					bwd = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "bwd"),
					l = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "l"),
					r = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "r"),
					high = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "high"),
					low = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "low"),
					crh = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "crh"),
					mod = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "mod"),
					hvy = self._machine:get_parameter(self._machine:segment_state(Idstring("base")), "hvy")
				}
			end
		end
		redir_res = self._ext_movement:play_redirect(action_type)
		if not redir_res then
			debug_pause_unit(self._unit, "[CopActionHurt:init]", action_type, "redirect failed in", self._machine:segment_state(Idstring("base")), self._unit)
			return
		end
		if action_desc.variant == "bleeding" then
		else
			local nr_variants = self._ext_anim.base_nr_variants
			local death_type
			if nr_variants then
				variant = math.random(nr_variants)
			else
				local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)
				local right_dot = action_desc.direction_vec:dot(common_data.right)
				local dir_str
				if math.abs(fwd_dot) > math.abs(right_dot) then
					if fwd_dot < 0 then
						dir_str = "fwd"
					else
						dir_str = "bwd"
					end
				elseif right_dot > 0 then
					dir_str = "l"
				else
					dir_str = "r"
				end
				self._machine:set_parameter(redir_res, dir_str, 1)
				local hit_z = action_desc.hit_pos.z
				height = hit_z > self._ext_movement:m_com().z and "high" or "low"
				if action_type == "death" then
					death_type = is_civilian and "normal" or action_desc.death_type
					if is_female then
						variant = self.death_anim_fe_variants[death_type][crouching and "crouching" or "not_crouching"][dir_str][height]
					else
						variant = self.death_anim_variants[death_type][crouching and "crouching" or "not_crouching"][dir_str][height]
					end
					if variant > 1 then
						variant = math.random(variant)
					end
				elseif action_type ~= "shield_knock" and action_type ~= "counter_tased" and action_type ~= "taser_tased" then
					if old_variant and (old_info[dir_str] == 1 and old_info[height] == 1 and old_info.mod == 1 and action_type == "hurt" or old_info.hvy == 1 and action_type == "heavy_hurt") then
						variant = old_variant
					end
					if not variant then
						if action_type == "expl_hurt" then
							variant = self.hurt_anim_variants[action_type][dir_str]
						else
							variant = self.hurt_anim_variants[action_type].not_crouching[dir_str][height]
						end
						if variant > 1 then
							variant = math.random(variant)
						end
					end
				end
			end
			variant = variant or 1
			if variant then
				self._machine:set_parameter(redir_res, "var" .. tostring(variant), 1)
			end
			if height then
				self._machine:set_parameter(redir_res, height, 1)
			end
			if crouching then
				self._machine:set_parameter(redir_res, "crh", 1)
			end
			if action_type == "hurt" then
				self._machine:set_parameter(redir_res, "mod", 1)
			elseif action_type == "heavy_hurt" then
				self._machine:set_parameter(redir_res, "hvy", 1)
			elseif action_type == "death" then
				if (death_type or action_desc.death_type) == "heavy" and not is_civilian then
					self._machine:set_parameter(redir_res, "heavy", 1)
				end
			elseif action_type == "expl_hurt" then
				self._machine:set_parameter(redir_res, "expl", 1)
			end
		end
	end
	if self._ext_anim.upper_body_active and not self._ragdolled then
		self._ext_movement:play_redirect("up_idle")
	end
	self._last_vel_z = 0
	self._hurt_type = action_type
	self._variant = action_desc.variant
	self._body_part = action_desc.body_part
	if action_type == "bleedout" then
		self.update = self._upd_bleedout
		self._shoot_t = t + 1
		if Network:is_server() then
			self._ext_inventory:equip_selection(1, true)
		end
		local weapon_unit = self._ext_inventory:equipped_unit()
		self._weapon_base = weapon_unit:base()
		local weap_tweak = weapon_unit:base():weapon_tweak_data()
		local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]
		self._weapon_unit = weapon_unit
		self._weap_tweak = weap_tweak
		self._w_usage_tweak = weapon_usage_tweak
		self._reload_speed = weapon_usage_tweak.RELOAD_SPEED
		self._spread = weapon_usage_tweak.spread
		self._falloff = weapon_usage_tweak.FALLOFF
		self._head_modifier_name = Idstring("look_head")
		self._arm_modifier_name = Idstring("aim_r_arm")
		self._head_modifier = self._machine:get_modifier(self._head_modifier_name)
		self._arm_modifier = self._machine:get_modifier(self._arm_modifier_name)
		self._aim_vec = mvector3.copy(common_data.fwd)
		self._anim = redir_res
		if not self._shoot_history then
			self._shoot_history = {
				focus_error_roll = math.random(360),
				focus_start_t = t,
				focus_delay = weapon_usage_tweak.focus_delay,
				m_last_pos = common_data.pos + common_data.fwd * 500
			}
		end
	elseif action_type == "hurt_sick" or action_type == "poison_hurt" then
		self.update = self._upd_sick
	elseif action_desc.variant == "tase" then
	elseif self._ragdolled then
	elseif self._unit:anim_data().skip_force_to_graph then
		self.update = self._upd_empty
	else
		self.update = self._upd_hurt
	end
	local shoot_chance
	if self._ext_inventory and not self._weapon_dropped and common_data.char_tweak.shooting_death and not self._ext_movement:cool() and 3 < t - self._ext_movement:not_cool_t() then
		local weapon_unit = self._ext_inventory:equipped_unit()
		if weapon_unit then
			if action_type == "counter_tased" or action_type == "taser_tased" then
				weapon_unit:base():on_reload()
				shoot_chance = 1
			elseif action_type == "death" or action_type == "hurt" or action_type == "heavy_hurt" then
				shoot_chance = 0.1
			end
		end
	end
	if shoot_chance then
		local equipped_weapon = self._ext_inventory:equipped_unit()
		if equipped_weapon and (not equipped_weapon:base().clip_empty or not equipped_weapon:base():clip_empty()) and shoot_chance > math.random() then
			self._weapon_unit = equipped_weapon
			self._unit:movement():set_friendly_fire(true)
			self._friendly_fire = true
			if equipped_weapon:base():weapon_tweak_data().auto then
				equipped_weapon:base():start_autofire()
				self._shooting_hurt = true
			else
				self._delayed_shooting_hurt_clbk_id = "shooting_hurt" .. tostring(self._unit:key())
				managers.enemy:add_delayed_clbk(self._delayed_shooting_hurt_clbk_id, callback(self, self, "clbk_shooting_hurt"), TimerManager:game():time() + math.lerp(0.2, 0.4, math.random()))
			end
		end
	end
	if not self._unit:base().nick_name then
		if action_desc.variant == "fire" then
			if tweak_table ~= "tank" and tweak_table ~= "tank_hw" and tweak_table ~= "shield" then
				if action_desc.hurt_type == "fire_hurt" and tweak_table ~= "spooc" then
					self._unit:sound():say("burnhurt")
				elseif action_desc.hurt_type == "death" then
					self._unit:sound():say("burndeath")
				end
			end
		elseif action_type == "death" then
			self._unit:sound():say("x02a_any_3p")
		elseif action_type == "counter_tased" or action_type == "taser_tased" then
			self._unit:sound():say("tasered")
		else
			self._unit:sound():say("x01a_any_3p")
		end
		if (tweak_table == "tank" or tweak_table == "tank_hw") and action_type == "death" then
			local unit_id = self._unit:id()
			managers.fire:remove_dead_dozer_from_overgrill(unit_id)
		end
		if Network:is_server() then
			local radius, filter_name
			local default_radius = managers.groupai:state():whisper_mode() and tweak_data.upgrades.cop_hurt_alert_radius_whisper or tweak_data.upgrades.cop_hurt_alert_radius
			if action_desc.attacker_unit and action_desc.attacker_unit:base().upgrade_value then
				radius = action_desc.attacker_unit:base():upgrade_value("player", "silent_kill") or default_radius
			elseif action_desc.attacker_unit and action_desc.attacker_unit:base().is_local_player then
				radius = managers.player:upgrade_value("player", "silent_kill", default_radius)
			end
			local new_alert = {
				"vo_distress",
				common_data.ext_movement:m_head_pos(),
				radius or default_radius,
				self._unit:brain():SO_access(),
				self._unit
			}
			managers.groupai:state():propagate_alert(new_alert)
		end
	end
	if action_type == "death" or action_type == "bleedout" or action_desc.variant == "tased" or action_type == "fatal" then
		self._floor_normal = self:_get_floor_normal(common_data.pos, common_data.fwd, common_data.right)
	end
	CopActionAct._create_blocks_table(self, action_desc.blocks)
	self._ext_movement:enable_update()
	if (self._body_part == 1 or self._body_part == 2) and Network:is_server() then
		local stand_rsrv = self._unit:brain():get_pos_rsrv("stand")
		if not stand_rsrv or mvector3.distance_sq(stand_rsrv.position, common_data.pos) > 400 then
			self._unit:brain():add_pos_rsrv("stand", {
				position = mvector3.copy(common_data.pos),
				radius = 30
			})
		end
	end
	return true
end


function CopActionHurt:_dragons_breath_sparks()


end


function CopDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable then
		return
	end
	local result
	local damage = attack_data.damage
	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(damage)
		damage = crit_damage
		if attack_data.weapon_unit and attack_data.variant ~= "stun" and not attack_data.is_fire_dot_damage then
			if critical_hit then
				managers.hud:on_crit_confirmed()
			else
				managers.hud:on_hit_confirmed()
			end
		end
	end
	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)
	if damage >= self._health then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}
		self:die(attack_data)
		self:chk_killshot(attack_data.attacker_unit, "fire")
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "fire")
		result = {
			type = result_type,
			variant = attack_data.variant
		}
		self:_apply_damage_to_health(damage)
	end
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local headshot_multiplier = 1
	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(damage)
		if critical_hit then
			damage = crit_damage
		end
		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)
		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
		if head then
			managers.player:on_headshot_dealt()
		end
	end
	if self._damage_reduction_multiplier then
		damage = damage * self._damage_reduction_multiplier
	elseif head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end
	if self._head_body_name and attack_data.variant ~= "stun" then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)
	end
	local attacker = attack_data.attacker_unit
	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end
	local attacker_unit = attack_data.attacker_unit
	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}
		if not attack_data.is_fire_dot_damage then
			managers.statistics:killed_by_anyone(data)
		end
		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end
		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit:base()._tweak_table)
			end
			self:_show_death_hint(self._unit:base()._tweak_table)
			if not attack_data.is_fire_dot_damage then
				managers.statistics:killed(data)
			end
			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end
			self:_check_damage_achievements(attack_data, false)
		end
	end
	if alive(attacker) and attacker:base() and attacker:base().add_damage_result then
		attacker:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end
	if not attack_data.is_fire_dot_damage then
		local fire_dot_data = attack_data.fire_dot_data
		local flammable
		local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
		if char_tweak.flammable == nil then
			flammable = true
		else
			flammable = char_tweak.flammable
		end
		local distance = 1000
		local hit_loc = attack_data.col_ray.hit_position
		if hit_loc and attacker_unit and attacker_unit.position then
			distance = mvector3.distance(hit_loc, attacker_unit:position())
		end
		local fire_dot_max_distance = 3000
		local fire_dot_trigger_chance = 30
		if fire_dot_data then
			fire_dot_max_distance = tonumber(fire_dot_data.dot_trigger_max_distance)
			fire_dot_trigger_chance = tonumber(fire_dot_data.dot_trigger_chance)
		end
		local start_dot_damage_roll = math.random(1, 100)
		local start_dot_dance_antimation = false
		if flammable and not attack_data.is_fire_dot_damage and distance < fire_dot_max_distance and fire_dot_trigger_chance >= start_dot_damage_roll then

			start_dot_dance_antimation = false
		end
		if fire_dot_data then
			fire_dot_data.start_dot_dance_antimation = false
			attack_data.fire_dot_data = fire_dot_data
		end
	else
	end
	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.is_fire_dot_damage, attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
end
