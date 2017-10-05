
function GamePlayCentralManager:init()
	self._bullet_hits = {}
	self._play_effects = {}
	self._play_sounds = {}
	self._footsteps = {}
	self._queue_fire_raycast = {}
	self._projectile_trails = {}
	self._effect_manager = World:effect_manager()
	self._slotmask_flesh = managers.slot:get_mask("flesh")
	self._slotmask_world_geometry = managers.slot:get_mask("world_geometry")
	self._slotmask_physics_push = managers.slot:get_mask("bullet_physics_push")
	self._slotmask_footstep = managers.slot:get_mask("footstep")
	self._slotmask_bullet_impact_targets = managers.slot:get_mask("bullet_impact_targets")
	self:_init_impact_sources()
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	self._flashlights_on = lvl_tweak_data and lvl_tweak_data.flashlights_on
	self._dropped_weapons = {
		index = 1,
		units = {}
	}
	self._flashlights_on_player_on = false
	if lvl_tweak_data and lvl_tweak_data.environment_effects then
		for _, effect in ipairs(lvl_tweak_data.environment_effects) do
			managers.environment_effects:use(effect)
		end
	end
	self._mission_disabled_units = {}
	self._heist_timer = {start_time = 0, running = false}
  local is_Win32 = SystemInfo:platform() == Idstring("WIN32")
	local is_ps3 = SystemInfo:platform() == Idstring("PS3")
	local is_x360 = SystemInfo:platform() == Idstring("X360")
	self._block_bullet_decals = is_ps3 or is_x360 or is_Win32
	self._block_blood_decals = is_x360 or is_Win32
  
end