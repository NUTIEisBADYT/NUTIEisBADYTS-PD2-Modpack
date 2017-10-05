core:module("CoreEnvironmentEffectsManager")
core:import("CoreTable")

EnvironmentEffectsManager = EnvironmentEffectsManager or class()
function EnvironmentEffectsManager:init()
	self._effects = {}
	self._current_effects = {}
	self._mission_effects = {}
	self._repeat_mission_effects = {}
  

end
function EnvironmentEffectsManager:add_effect(name, effect)
	self._effects[name] = effect
	if effect:default() then
		self:use(name)
	end
end
function EnvironmentEffectsManager:effect(name)
	return self._effects[name]
end
function EnvironmentEffectsManager:effects()
	return self._effects
end
function EnvironmentEffectsManager:effects_names()
	local t = {}
	for name, effect in pairs(self._effects) do
		if not effect:default() then
			table.insert(t, name)
		end
	end
	table.sort(t)
	return t
end
function EnvironmentEffectsManager:use(effect)
	
end
function EnvironmentEffectsManager:load_effects(effect)
	if self._effects[effect] then
		self._effects[effect]:load_effects()
	end
end
function EnvironmentEffectsManager:stop(effect)
	if self._effects[effect] then
		self._effects[effect]:stop()
		table.delete(self._current_effects, self._effects[effect])
	end
end
function EnvironmentEffectsManager:stop_all()
	for _, effect in ipairs(self._current_effects) do
		effect:stop()
	end
	self._current_effects = {}
end
function EnvironmentEffectsManager:update(t, dt)
	
end
function EnvironmentEffectsManager:gravity_and_wind_dir()
	local wind_importance = 0.5
	return Vector3(0, 0, -982) + Wind:wind_at(Vector3()) * wind_importance
end
function EnvironmentEffectsManager:spawn_mission_effect(name, params)
	
end
function EnvironmentEffectsManager:kill_all_mission_effects()
	for _, params in pairs(self._repeat_mission_effects) do
		if params.effect_id then
			World:effect_manager():kill(params.effect_id)
		end
	end
	self._repeat_mission_effects = {}
	for _, effects in pairs(self._mission_effects) do
		for _, params in ipairs(effects) do
			World:effect_manager():kill(params.effect_id)
		end
	end
	self._mission_effects = {}
end
function EnvironmentEffectsManager:kill_mission_effect(name)
	self:_kill_mission_effect(name, "kill")
end
function EnvironmentEffectsManager:fade_kill_mission_effect(name)
	self:_kill_mission_effect(name, "fade_kill")
end
function EnvironmentEffectsManager:_kill_mission_effect(name, type)
	local kill = callback(World:effect_manager(), World:effect_manager(), type)
	local params = self._repeat_mission_effects[name]
	if params then
		if params.effect_id then
			kill(params.effect_id)
		end
		self._repeat_mission_effects[name] = nil
		return
	end
	local effects = self._mission_effects[name]
	if not effects then
		return
	end
	for _, params in ipairs(effects) do
		kill(params.effect_id)
	end
	self._mission_effects[name] = nil
end
function EnvironmentEffectsManager:save(data)
	local state = {
		mission_effects = {}
	}
	for name, effects in pairs(self._mission_effects) do
		state.mission_effects[name] = {}
		for _, params in pairs(effects) do
			if World:effect_manager():alive(params.effect_id) then
				table.insert(state.mission_effects[name], params)
			end
		end
	end
	data.EnvironmentEffectsManager = state
end
function EnvironmentEffectsManager:load(data)
	local state = data.EnvironmentEffectsManager
	for name, effects in pairs(state.mission_effects) do
		for _, params in ipairs(effects) do
			self:spawn_mission_effect(name, params)
		end
	end
end
EnvironmentEffect = EnvironmentEffect or class()
function EnvironmentEffect:init(default)
	self._default = default
end
function EnvironmentEffect:load_effects()
end
function EnvironmentEffect:update(t, dt)
end
function EnvironmentEffect:start()
end
function EnvironmentEffect:stop()
end
function EnvironmentEffect:default()
	return self._default
end