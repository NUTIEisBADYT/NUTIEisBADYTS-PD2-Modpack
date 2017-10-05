local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local function project_instigators_player()
	local instigators = { managers.player:player_unit() }
	return instigators
end

local function project_instigators_vehicle()
	local instigators = {}
	local instigators_nr = 1
	local vehicles = managers.vehicle:get_all_vehicles()
	for _, v in ipairs(vehicles) do
		if not v:npc_vehicle_driving() then
			instigators[instigators_nr] = v
			instigators_nr = instigators_nr + 1
		end
	end
	return instigators
end

local function project_instigators_npc_vehicle()
	local instigators = {}
	local instigators_nr = 1
	local vehicles = managers.vehicle:get_all_vehicles()
	for _, v in ipairs(vehicles) do
		if v:npc_vehicle_driving() then
			instigators[instigators_nr] = v
			instigators_nr = instigators_nr + 1
		end
	end
	return instigators
end

local function project_instigators_vehicle_with_players()
	local instigators = {}
	local instigators_nr = 1
	local vehicles = managers.vehicle:get_all_vehicles()
	for _, v in ipairs(vehicles) do
		instigators[instigators_nr] = v
		instigators_nr = instigators_nr + 1
	end
	return instigators
end

local _units_per_navseg = FullSpeedSwarm.units_per_navseg
local function project_instigators_enemies(self)
	local instigators = {}
	local gstate = managers.groupai:state()

	local navseg = self and self._values.restrict_to_navseg
	local all_enemies
	if navseg then
		all_enemies = _units_per_navseg[navseg] or {}
	else
		all_enemies =  managers.enemy:all_enemies()
	end

	local instigators_nr = 1
	if gstate:police_hostage_count() <= 0 and gstate:get_amount_enemies_converted_to_criminals() <= 0 then
		for _, data in pairs(all_enemies) do
			instigators[instigators_nr] = data.unit
			instigators_nr = instigators_nr + 1
		end
	else
		for _, data in pairs(all_enemies) do
			if not data.is_converted and not data.unit:anim_data().surrender then
				instigators[instigators_nr] = data.unit
				instigators_nr = instigators_nr + 1
			end
		end
	end

	return instigators
end

local function project_instigators_civilians()
	local instigators = {}
	local instigators_nr = 1
	for _, data in pairs(managers.enemy:all_civilians()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	return instigators
end

local function project_instigators_escorts()
	local instigators = {}
	local instigators_nr = 1
	for _, data in pairs(managers.enemy:all_civilians()) do
		if tweak_data.character[data.unit:base()._tweak_table].is_escort then
			instigators[instigators_nr] = data.unit
			instigators_nr = instigators_nr + 1
		end
	end
	return instigators
end

local function project_instigators_hostages()
	local instigators = {}
	local instigators_nr = 1
	local enemies = managers.enemy:all_enemies()
	local civilians = managers.enemy:all_civilians()
	for _, u_key in pairs(managers.groupai:state():all_hostages()) do
		local data = enemies[u_key] or civilians[u_key]
		if data then
			instigators[instigators_nr] = data.unit
			instigators_nr = instigators_nr + 1
		end
	end
	return instigators
end

local function project_instigators_criminals()
	local instigators = {}
	local instigators_nr = 1
	for _, data in pairs(managers.groupai:state():all_char_criminals()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	return instigators
end

local function project_instigators_local_criminals()
	local instigators = { managers.player:player_unit() }
	local instigators_nr = 1
	for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	return instigators
end

local function project_instigators_persons()
	local instigators = { managers.player:player_unit() }
	local instigators_nr = 1
	for _, data in pairs(managers.groupai:state():all_char_criminals()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	for _, data in pairs(managers.enemy:all_civilians()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	for _, data in pairs(managers.enemy:all_enemies()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	return instigators
end

local function project_instigators_ai_teammates()
	local instigators = {}
	local instigators_nr = 1
	for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
		instigators[instigators_nr] = data.unit
		instigators_nr = instigators_nr + 1
	end
	return instigators
end

-- unless there is a good reason to,
-- ignoring absence of "winch_part_e3"
-- ignoring presence of "weapons"
local _carry_list = {}
for carry_id, data in pairs(tweak_data.carry) do
	if data.type and data.type ~= "being" and not data.is_vehicle then
		_carry_list[carry_id] = true
	end
end

local function project_instigators_loot()
	local instigators = {}
	local instigators_nr = 1
	local all_found = World:find_units_quick("all", 14)
	for _, unit in pairs(all_found) do
		local carry_data = unit:carry_data()
		if carry_data and _carry_list[carry_data:carry_id()] then
			instigators[instigators_nr] = unit
			instigators_nr = instigators_nr + 1
		end
	end
	return instigators
end

local function project_instigators_unique_loot()
	local instigators = {}
	local instigators_nr = 1
	local all_found = World:find_units_quick("all", 14)
	for _, unit in ipairs(all_found) do
		local carry_data = unit:carry_data()
		if carry_data and tweak_data.carry[carry_data:carry_id()].is_unique_loot then
			instigators[instigators_nr] = unit
			instigators_nr = instigators_nr + 1
		end
	end
	return instigators
end

local function project_instigators_equipment(self)
	local instigators = {}
	local instigator_name = self and self._values.instigator_name
	if instigator_name ~= nil then
		local all_found = World:find_units_quick("all", 14)
		local function filter_func(unit)
			if unit:base() and unit:base().get_name_id and unit:base():get_name_id() == instigator_name then
				return true
			end
		end
		local instigators_nr = 1
		for _, unit in ipairs(all_found) do
			if filter_func(unit) then
				instigators[instigators_nr] = unit
				instigators_nr = instigators_nr + 1
			end
		end
	end
	return instigators
end

local function project_instigators_intimidated_enemies()
	local instigators = {}
	local state = managers.groupai:state()
	if state:police_hostage_count() > 0 or 0 < state:get_amount_enemies_converted_to_criminals() then
		local instigators_nr = 1
		for _, data in pairs(managers.enemy:all_enemies()) do
			if data.unit:anim_data().surrender or data.is_converted then
				instigators[instigators_nr] = data.unit
				instigators_nr = instigators_nr + 1
			end
		end
	end
	return instigators
end

local _project_instigators_functions = {
	player = project_instigators_player,
	player_not_in_vehicle = project_instigators_player,
	vehicle = project_instigators_vehicle,
	npc_vehicle = project_instigators_npc_vehicle,
	vehicle_with_players = project_instigators_vehicle_with_players,
	enemies = project_instigators_enemies,
	civilians = project_instigators_civilians,
	escorts = project_instigators_escorts,
	hostages = project_instigators_hostages,
	criminals = project_instigators_criminals,
	local_criminals = project_instigators_local_criminals,
	persons = project_instigators_persons,
	ai_teammates = project_instigators_ai_teammates,
	loot = project_instigators_loot,
	unique_loot = project_instigators_unique_loot,
	equipment = project_instigators_equipment,
	intimidated_enemies = project_instigators_intimidated_enemies
}

function ElementAreaTrigger:project_instigators_server()
	return _project_instigators_functions[self._values.instigator](self)
end

function ElementAreaTrigger:project_instigators()
	local instigator = self._values.instigator

	if Network:is_client() then
		local instigators = {}
		if instigator == "player" or instigator == "local_criminals" or instigator == "persons" then
			instigators[1] = managers.player:player_unit()
		end
		return instigators
	end

	ElementAreaTrigger.project_instigators = ElementAreaTrigger.project_instigators_server
	return _project_instigators_functions[instigator]()
end

function ElementAreaTrigger:project_amount_all()
	local instigator = self._values.instigator
	if instigator == "criminals" or instigator == "local_criminals" then
		local i = 0
		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			i = i + 1
		end
		return i
	elseif instigator == "ai_teammates" then
		local i = 0
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			i = i + 1
		end
		return i
	end
	local session = managers.network:session()
	return session and session:amount_of_alive_players() or 0
end
