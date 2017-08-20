Hooks:PostHook( PrePlanningTweakData, "init", "fixyfix_42120", function(self, tweak_data)
	self.locations.branchbank = {
		default_plans = {
			vault_plan = "branchbank_lance"
		},
		total_budget = 8,
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_branchbank",
		start_location = {
			group = "a",
			x = 512,
			y = 512,
			zoom = 1
		},
		{
			name_id = "menu_pp_branchbank_loc_a",
			texture = "guis/textures/pd2/pre_planning/branchbank_1",
			map_x = -0.6,
			map_y = 0,
			map_size = 1,
			x1 = -3500,
			y1 = -300,
			x2 = 500,
			y2 = 3700,
			rotation = 0,
			custom_points = {}
		},
		{
			name_id = "menu_pp_branchbank_loc_b",
			texture = "guis/textures/pd2/pre_planning/branchbank_2",
			map_x = 0.6,
			map_y = 0,
			map_size = 1,
			x1 = -5500,
			y1 = -3200,
			x2 = 2500,
			y2 = 4800,
			rotation = 0,
			custom_points = {}
		}
	}
	self.locations.firestarter_3 = {
		default_plans = {
			vault_plan = "branchbank_lance"
		},
		total_budget = 8,
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_branchbank",
		start_location = {
			group = "a",
			x = 512,
			y = 512,
			zoom = 1
		},
		{
			name_id = "menu_pp_branchbank_loc_a",
			texture = "guis/textures/pd2/pre_planning/branchbank_1",
			map_x = -0.6,
			map_y = 0,
			map_size = 1,
			x1 = -3500,
			y1 = -300,
			x2 = 500,
			y2 = 3700,
			rotation = 0,
			custom_points = {}
		},
		{
			name_id = "menu_pp_branchbank_loc_b",
			texture = "guis/textures/pd2/pre_planning/branchbank_2",
			map_x = 0.6,
			map_y = 0,
			map_size = 1,
			x1 = -5500,
			y1 = -3200,
			x2 = 2500,
			y2 = 4800,
			rotation = 0,
			custom_points = {}
		}
	}
end)