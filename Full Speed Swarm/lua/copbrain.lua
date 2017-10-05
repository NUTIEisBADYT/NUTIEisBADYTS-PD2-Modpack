local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local REACT_IDLE = AIAttentionObject.REACT_IDLE

local fs_original_copbrain_clbkdeath = CopBrain.clbk_death
function CopBrain:clbk_death(my_unit, damage_info)
	local gstate = managers.groupai:state()
	if gstate:whisper_mode() then
		fs_original_copbrain_clbkdeath(self, my_unit, damage_info)
	else
		local my_unit_key = my_unit:key()
		for u_key, unit in pairs(gstate._converted_police) do
			if u_key == my_unit_key then
				for _, cop_unit in pairs(managers.enemy:all_enemies()) do
					local attention_info = cop_unit.brain and cop_unit:brain()._logic_data.detected_attention_objects[my_unit_key]
					if attention_info then
						attention_info.previous_reaction = REACT_IDLE
					end
				end
			else
				local attention_info = unit:brain()._logic_data.detected_attention_objects[my_unit_key]
				if attention_info then
					attention_info.previous_reaction = REACT_IDLE
				end
			end
		end
		fs_original_copbrain_clbkdeath(self, my_unit, damage_info)
		gstate:unregister_AI_attention_object(my_unit_key)
	end
end

local fs_original_copbrain_converttocriminal = CopBrain.convert_to_criminal
function CopBrain:convert_to_criminal(mastermind_criminal)
	fs_original_copbrain_converttocriminal(self, mastermind_criminal)
	self._unit:movement().fs_do_track = nil
end

local fs_original_copbrain_oncriminalneutralized = CopBrain.on_criminal_neutralized
function CopBrain:on_criminal_neutralized(criminal_key)
	fs_original_copbrain_oncriminalneutralized(self, criminal_key)
	local attention_info = self._logic_data.detected_attention_objects[criminal_key]
	if attention_info then
		attention_info.previous_reaction = nil
	end
end

function CopBrain:action_complete_clbk(action)
	if action.chk_block and not action.itr_fake_complete then
		local u_mov = self._unit:movement()
		u_mov.fs_blockers_nr = u_mov.fs_blockers_nr - 1
	end
	self._current_logic.action_complete_clbk(self._logic_data, action)
end

local fs_original_copbrain_resetlogicdata = CopBrain._reset_logic_data
function CopBrain:_reset_logic_data()
	fs_original_copbrain_resetlogicdata(self)
	self._logic_data._tweak_table = self._unit:base()._tweak_table
end
