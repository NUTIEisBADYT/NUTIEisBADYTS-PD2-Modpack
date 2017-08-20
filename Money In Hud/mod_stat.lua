if managers.hud and managers.money and managers.loot then

	local mandatory_cash = managers.money:get_secured_mandatory_bags_money()
	local bonus_cash = managers.money:get_secured_bonus_bags_money()
	local instant_cash = managers.loot:get_real_total_small_loot_value()

	local total_cash = mandatory_cash + bonus_cash + instant_cash - managers.money.catch_reduction_to_persist

	local function format_int(number)

	  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

	  -- reverse the int-string and append a comma to all blocks of 3 digits
	  int = int:reverse():gsub("(%d%d%d)", "%1,")

	  -- reverse the int-string back remove an optional comma and put the 
	  -- optional minus and fractional part back
	  return minus .. int:reverse():gsub("^,", "") .. fraction
	end

	if Utils:IsInHeist() then
		if total_cash > 0 then
			managers.hud._hud_assault_corner.money_count:set_color(Color(255, 5, 165, 0) / 255)
			managers.hud._hud_assault_corner.money_count:set_text("TAKE    $ " .. format_int(total_cash))
		else
			managers.hud._hud_assault_corner.money_count:set_color(Color(255, 255, 0, 0) / 255)
			managers.hud._hud_assault_corner.money_count:set_text("TAKE    $" .. format_int(total_cash))
		end

		if managers.money.previous_stored_cash ~= total_cash then
			local bg = managers.hud._hud_assault_corner._money_panel_box:child("bg")
			bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
			--managers.hud._sound_source:post_event("stinger_objectivecomplete")
			
			managers.money.previous_stored_cash = total_cash
		end
	end
end