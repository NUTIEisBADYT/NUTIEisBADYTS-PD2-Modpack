Hooks:PostHook( HUDAssaultCorner, "init", "MoneyInHud", function(self, hud, full_hud, tweak_hud)
    self._money_panel_color = Color(255, 5, 165, 0) / 255

    local money_panel = self._hud_panel:panel({
		visible = true,
		name = "assault_panel",
		w = 400,
		h = 100,
		color = self._money_panel_color
	})

    self._money_panel_box = HUDBGBox_create(money_panel, {
		w = 242,
		h = 38,
		x = 0,
		y = 0
	}, {
		color = Color.white,
		visible = true,
		blend_mode = "add"
	})

	self.money_count = self._money_panel_box:text({
		name = "money_count",
		text = "TAKE    $ 0",
		valign = "center",
		align = "left",
		vertical = "center",
		w = self._money_panel_box:w(),
		h = self._money_panel_box:h(),
		layer = 1,
		x = 10,
		y = 0,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.numhostages_size
	})

    money_panel:set_top(self._hostages_bg_box:bottom() + 30)
    money_panel:set_left(self._hostages_bg_box:left() + 21)
end )