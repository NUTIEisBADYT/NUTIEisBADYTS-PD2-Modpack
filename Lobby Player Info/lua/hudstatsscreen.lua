local lpi_original_hudstatsscreen_show = HUDStatsScreen.show
function HUDStatsScreen:show()
	lpi_original_hudstatsscreen_show(self)

	if LobbyPlayerInfo.settings.show_skills_in_stats_screen then
		local right_panel = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel:child('right_panel')
		if not right_panel then
			return
		end

		local dwp = right_panel:child('day_wrapper_panel')
		if not dwp then
			return
		end

		local dd = dwp:child('day_description')
		dd:set_font_size(12)
		local _, _, _, h = dd:text_rect()
		dd:set_h(h)
		local gt = dwp:child('ghostable_text')
		gt:set_font_size(14)
		gt:set_top(math.round(dd:bottom() + 10))

		local y = math.round(gt:bottom() + 20)
		for i = 1, 4 do
			local peer = managers.network:session() and managers.network:session():peer(i)
			local txt_name = 'lpi_team_text_name' .. tostring(i)
			local name_text = dwp:child(txt_name) or dwp:text({
				name = txt_name,
				text = 'A',
				align = 'left',
				vertical = 'top',
				blend_mode = 'add',
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.chat_colors[i],
				w = dwp:w(),
				x = 0,
				y = y
			})
			name_text:set_text(peer and peer:name() or '')

			txt_name = 'lpi_team_text_skills' .. tostring(i)
			local skill_text = dwp:child(txt_name) or dwp:text({
				name = txt_name,
				text = 'B',
				align = 'left',
				vertical = 'top',
				blend_mode = 'add',
				font_size = tweak_data.menu.pd2_small_font_size - 4,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text,
				x = 10,
				y = y + 20
			})

			local outfit = peer and peer:blackmarket_outfit()
			local skills = outfit and outfit.skills
			local perk = skills and skills.specializations
			skills = skills and skills.skills

			local skills_txt = ''
			if skills and #skills >= 15 then
				local ini_len = LobbyPlayerInfo._abbreviation_length_v
				skills_txt = string.format(LobbyPlayerInfo.skills_layouts[#LobbyPlayerInfo.skills_layouts],
					utf8.sub(managers.localization:text('st_menu_mastermind'),  1, ini_len), skills[1],  skills[2],  skills[3],
					utf8.sub(managers.localization:text('st_menu_enforcer'),    1, ini_len), skills[4],  skills[5],  skills[6],
					utf8.sub(managers.localization:text('st_menu_technician'),  1, ini_len), skills[7],  skills[8],  skills[9],
					utf8.sub(managers.localization:text('st_menu_ghost'),       1, ini_len), skills[10], skills[11], skills[12],
					utf8.sub(managers.localization:text('st_menu_hoxton_pack'), 1, ini_len), skills[13], skills[14], skills[15]
				)
			end
			skill_text:set_text(skills_txt)
			local _, _, skills_w, _ = skill_text:text_rect()
			skill_text:set_width(skills_w)

			txt_name = 'lpi_team_text_perk' .. tostring(i)
			local perk_text = dwp:child(txt_name) or dwp:text({
				name = txt_name,
				text = 'C',
				align = 'left',
				vertical = 'top',
				blend_mode = 'add',
				font_size = tweak_data.menu.pd2_small_font_size - 4,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text,
				w = dwp:w(),
				x = 10,
				y = y + 38
			})
			local perk_txt = ''
			if perk then
				if #perk == 2 then
					perk_txt = managers.localization:text('menu_st_spec_' .. perk[1]) .. ' (' .. perk[2] .. '/9)'
				else
					perk_txt = 'Unknown perk'
				end
			end
			perk_text:set_text(perk_txt)

			txt_name = 'lpi_team_text_ping' .. tostring(i)
			local ping_text = dwp:child(txt_name) or dwp:text({
				name = txt_name,
				text = '',
				align = 'right',
				vertical = 'top',
				blend_mode = 'add',
				font_size = tweak_data.menu.pd2_small_font_size - 4,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text,
				w = 50,
				y = y + 38
			})
			ping_text:set_right(skill_text:right())
			local ping_txt = ''
			if peer then
				local ping = math.ceil(peer:qos().ping)
				if ping > 0 then
					ping_txt = ping .. ' ms'
				end
			end
			ping_text:set_text(ping_txt)

			txt_name = 'lpi_team_text_ploss' .. tostring(i)
			local ploss_text = dwp:child(txt_name) or dwp:text({
				name = txt_name,
				text = '',
				align = 'right',
				vertical = 'top',
				blend_mode = 'add',
				font_size = tweak_data.menu.pd2_small_font_size - 4,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.chat_colors[i],
				w = 130,
				y = y + 38
			})
			ploss_text:set_right(ping_text:left())
			local ploss_txt = ''
			if peer then
				local loss_nr = peer:qos().packet_loss
				if loss_nr > 0 then
					ploss_txt = managers.localization:text('lpi_packet_loss') .. ' (' .. loss_nr .. ')'
				elseif NoMA then
					local hacc = NoMA.hit_accounting[i]
					if hacc and hacc.attacked_nr > 0 then
						ploss_txt = string.format('hit by %0.1f%% of %i shots', (hacc.health_hit_nr + hacc.armor_hit_nr) / hacc.attacked_nr * 100, hacc.attacked_nr)
					end
				end
			end
			ploss_text:set_text(ploss_txt)

			y = math.round(name_text:top() + 60)
		end
		dwp:set_h(y)
	end
end
