#define TGS_STATUS_THROTTLE 5

/datum/tgs_chat_command/tgscheck
	name = "check"
	help_text = "Показывает количество игроков, игровой режим и адрес сервера."

/datum/tgs_chat_command/tgscheck/proc/pad_time(num)
	var/str = "[num]"
	if(length(str) < 2)
		// single digits
		str = "0[str]"
	return str

/datum/tgs_chat_command/tgscheck/Run(datum/tgs_chat_user/sender, params)
	var/elapsed
	if (current_state < GAME_STATE_FINISHED)
		if (current_state <= GAME_STATE_PREGAME)
			elapsed = "НАЧИНАЕТСЯ"
		else if (current_state > GAME_STATE_PREGAME)
			var/temp = round(ticker.round_elapsed_ticks / 10)
			var/hours = round(temp / 3600)

			temp -= hours * 3600
			var/minutes = round(temp / 60)
			temp -= minutes * 60
			var/seconds = temp
			elapsed = "Прошло [pad_time(hours)]:[pad_time(minutes)]:[pad_time(seconds)]"
	else if (current_state == GAME_STATE_FINISHED)
		elapsed = "ЗАКАНЧИВАЕТСЯ"
	return "[config.server_name] ([station_name]); Игроков: [clients.len]; Карта: [getMapNameFromID(map_setting)] Режим: [(ticker?.hide_mode) ? "secret" : master_mode]; [elapsed] -- <[config.server_address]>"

