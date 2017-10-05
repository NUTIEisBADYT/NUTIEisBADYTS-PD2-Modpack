local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local fs_groupaistatebase_converthostagetocriminal = GroupAIStateBase.convert_hostage_to_criminal
function GroupAIStateBase:convert_hostage_to_criminal(unit, ...)
	local ret = fs_groupaistatebase_converthostagetocriminal(self, unit, ...)
	self:on_AI_attention_changed(unit:key())
	return ret
end

local loud_optims_loaded = false
function GroupAIStateBase:fs_load_loud_optims()
	if loud_optims_loaded then
		return
	end
	loud_optims_loaded = true

	for k, v in pairs(self._attention_objects) do
		if k ~= 'all' then
			self._attention_objects[k] = nil
		end
	end

	if FullSpeedSwarm.settings.character_positioning_quality == 1 then
		CopMovement.upd_ground_ray = CopMovement.upd_ground_ray_1
	elseif FullSpeedSwarm.settings.character_positioning_quality == 2 then
		CopMovement.upd_ground_ray = CopMovement.upd_ground_ray_2
	end

	for _, fct in pairs(FullSpeedSwarm.call_on_loud) do
		fct()
	end
end

local fs_original_groupaistatebase_onenemyweaponshot = GroupAIStateBase.on_enemy_weapons_hot
function GroupAIStateBase:on_enemy_weapons_hot(...)
	self:fs_load_loud_optims()
	return fs_original_groupaistatebase_onenemyweaponshot(self, ...)
end

local function _is_civ(ctg)
	return ctg and ctg:sub(1, 3) == 'civ'
end

local _cop_ctgs = {
	city_swat = true,
	cop = true,
	cop_female = true,
	cop_scared = true,
	fbi = true,
	fbi_heavy_swat = true,
	fbi_swat = true,
	gensec = true,
	heavy_swat = true,
	medic = true,
	murky = true,
	phalanx_minion = true,
	phalanx_vip = true,
	security = true,
	shield = true,
	sniper = true,
	spooc = true,
	swat = true,
	tank = true,
	tank_hw = true,
	tank_medic = true,
	tank_mini = true,
	taser = true,
}
local function _is_cop(ctg)
	return _cop_ctgs[ctg]
end

local function _cop_is_ignorable(ctg, unit)
	if _is_cop(ctg) then
		local brain = unit:brain()
		if brain and brain._logic_data then
			return not brain._logic_data.is_converted
		end
	end
	return false
end

local _mask_enemies
DelayedCalls:Add('DelayedModFSS_groupaistatebase_maskenemies', 0, function()
	_mask_enemies = managers.slot:get_mask('enemies')
end)

local function _requires_attention(cat_filter, att_info)
	if not (att_info and att_info.nav_tracker) then
		return false
	end

	local aiub = att_info and att_info.unit and att_info.unit:base()
	if not aiub then
		return false
	end

	if cat_filter == 'teamAI1' then
		if _is_civ(aiub._tweak_table) then
			return false
		elseif aiub.is_local_player then
			return att_info.unit:character_damage():need_revive()
		elseif aiub.is_husk_player then
			return att_info.unit:movement():need_revive()
		end
		return att_info.unit:in_slot(_mask_enemies)
	end

	return not (_is_cop(cat_filter) and (_cop_is_ignorable(aiub._tweak_table, att_info.unit) or _is_civ(aiub._tweak_table)))
end

local _is_loud
local function SetLoud()
	_is_loud = true
end
table.insert(FullSpeedSwarm.call_on_loud, SetLoud)

local _cf = {}
function GroupAIStateBase:on_AI_attention_changed(unit_key)
	local att_info = self._attention_objects.all[unit_key]
	if att_info then
		att_info.handler.rel_cache = {}
	end

	local navigation = managers.navigation
	for cat_filter, list in pairs(self._attention_objects) do
		if cat_filter ~= 'all' then
			_cf[1] = cat_filter
			local cat_filter_num = navigation:convert_access_filter_to_number(_cf)
			if not att_info or att_info.handler:get_attention(cat_filter_num) then
				if _is_loud and not _requires_attention(cat_filter, att_info) then
					list[unit_key] = nil
				else
					list[unit_key] = att_info
				end
			else
				list[unit_key] = nil
			end
		end
	end
end

function GroupAIStateBase:get_AI_attention_objects_by_filter(filter, team)
	local real_filter = team and team.id == 'converted_enemy' and 'teamAI1' or filter

	local result = self._attention_objects[real_filter]
	if not result then
		_cf[1] = real_filter
		local filter_num = managers.navigation:convert_access_filter_to_number(_cf)
		result = {}
		for u_key, attention_info in pairs(self._attention_objects.all) do
			if attention_info.handler:get_attention(filter_num) then
				if not _is_loud or _requires_attention(real_filter, attention_info) then
					result[u_key] = attention_info
				end
			end
		end
		self._attention_objects[real_filter] = result
	end

	return result
end

function GroupAIStateBase:on_unit_detection_updated()
end

function GroupAIStateBase:chk_enemy_calling_in_area(area, except_key)
	local area_nav_segs = area.nav_segs
	for unit_key, v in pairs(FullSpeedSwarm.in_arrest_logic) do
		if v and unit_key ~= except_key then
			local u_data = self._police[unit_key]
			if u_data and area_nav_segs[u_data.tracker:nav_segment()] then
				return true
			end
		end
	end
end

function GroupAIStateBase:criminal_spotted(unit)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]
	if u_sighting.det_t == self._t then
		return
	end
	local prev_seg = u_sighting.seg
	local prev_area = u_sighting.area
	local seg = u_sighting.tracker:nav_segment()
	u_sighting.undetected = nil
	u_sighting.seg = seg
	u_sighting.tracker:m_position(u_sighting.pos)
	u_sighting.det_t = self._t
	local area
	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end
	if prev_area ~= area then
		u_sighting.area = area
		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end
		area.criminal.units[u_key] = u_sighting
	end
	if area.is_safe then
		area.is_safe = nil
		self:_on_area_safety_status(area, {reason = 'criminal', record = u_sighting})
	end
end

local fs_original_groupaistatebase_creategroup = GroupAIStateBase._create_group
function GroupAIStateBase:_create_group(...)
	local result = fs_original_groupaistatebase_creategroup(self, ...)
	result.attention_obj_identified_t = {}
	return result
end

local table_insert = table.insert
function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	local max_nr_imp = self._nr_important_cops
	local imp_adj = 0
	local criminals = self._player_criminals

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_record = criminals[wgt_report[i_dis_rep]]
		local c_dis = wgt_report[i_dis_rep + 1]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		-- original function sorts the tables by distance but it does not seem to be useful anywhere
		local max_dis = -1
		local max_i = 1

		local imp_enemies_nr = #imp_enemies
		for i = 1, imp_enemies_nr do
			if imp_enemies[i] == u_key then
				imp_dis[i] = c_dis
				max_i = nil
				break
			else
				local imp_dis_i = imp_dis[i]
				if imp_dis_i > max_dis then
					max_dis = imp_dis_i
					max_i = i
				end
			end
		end

		if max_i then
			if imp_enemies_nr < max_nr_imp then
				table_insert(imp_enemies, u_key)
				table_insert(imp_dis, c_dis)
				imp_adj = imp_adj + 1
			elseif max_dis > c_dis then
				self:_adjust_cop_importance(imp_enemies[max_i], -1)
				imp_enemies[max_i] = u_key
				imp_dis[max_i] = c_dis
				imp_adj = imp_adj + 1
			end
		end
	end

	if imp_adj ~= 0 then
		self:_adjust_cop_importance(u_key, imp_adj)
	end
end

local _fs_cache_areas_from_nav_seg_id = {}

local fs_original_groupaistatebase_addarea = GroupAIStateBase.add_area
function GroupAIStateBase:add_area(...)
	_fs_cache_areas_from_nav_seg_id = {}
	return fs_original_groupaistatebase_addarea(self, ...)
end

local fs_original_groupaistatebase_getareasfromnavsegid = GroupAIStateBase.get_areas_from_nav_seg_id
function GroupAIStateBase:get_areas_from_nav_seg_id(nav_seg_id)
	local areas = _fs_cache_areas_from_nav_seg_id[nav_seg_id]

	if not areas then
		areas = fs_original_groupaistatebase_getareasfromnavsegid(self, nav_seg_id)
		_fs_cache_areas_from_nav_seg_id[nav_seg_id] = areas
	end

	return areas
end

local fs_original_groupaistatebase_onhostagestate = GroupAIStateBase.on_hostage_state
function GroupAIStateBase:on_hostage_state(state, key, ...)
	fs_original_groupaistatebase_onhostagestate(self, state, key, ...)

	local attention_data = self._attention_objects.all[key]
	local unit = attention_data and attention_data.unit
	if alive(unit) then
		unit:movement().move_speed_multiplier = state and tweak_data.character[unit:base()._tweak_table].hostage_move_speed or 1
		managers.network:session():send_to_peers_synched('sync_unit_event_id_16', unit, 'brain', state and 3 or 4)
	end
end

local fs_original_groupaistatebase_synchostageheadcount = GroupAIStateBase.sync_hostage_headcount
function GroupAIStateBase:sync_hostage_headcount(...)
	managers.player:reset_cached_hostage_bonus_multiplier()
	fs_original_groupaistatebase_synchostageheadcount(self, ...)
end
