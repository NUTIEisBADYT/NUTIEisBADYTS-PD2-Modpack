local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if FullSpeedSwarm.settings.optimized_inputs then

	local fs_original_playerdriving_init = PlayerDriving.init
	function PlayerDriving:init(...)
		fs_original_playerdriving_init(self, ...)

		self.wanted_pressed = clone(self.wanted_pressed)
		self.wanted_pressed.vehicle_change_camera = "btn_vehicle_change_camera"
		self.wanted_pressed.vehicle_rear_camera = "btn_vehicle_rear_camera_press"
		self.wanted_pressed.vehicle_shooting_stance = "btn_vehicle_shooting_stance"
		self.wanted_pressed.vehicle_exit = "btn_vehicle_exit_press"

		self.wanted_released = clone(self.wanted_released)
		self.wanted_released.vehicle_rear_camera = "btn_vehicle_rear_camera_release"
		self.wanted_released.vehicle_exit = "btn_vehicle_exit_release"
	end

	function PlayerDriving:_get_input(t, dt)
		return PlayerDriving.super._get_input(self, t, dt)
	end

end