// SETUP

/proc/TopicHandlers()
	. = list()
	var/list/all_handlers = subtypesof(/datum/world_topic)
	for(var/I in all_handlers)
		var/datum/world_topic/WT = I
		var/keyword = initial(WT.keyword)
		if(!keyword)
			continue
		var/existing_path = .[keyword]
		if(existing_path)
		else if(keyword == "key")
		else
			.[keyword] = WT

// DATUM

/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/require_comms_key = FALSE

/datum/world_topic/proc/TryRun(list/input)
	key_valid = config && (config.comms_key == input["key"])
	input -= "key"
	if(require_comms_key && !key_valid)
		. = "Bad Key"
		if (input["format"] == "json")
			. = list("error" = .)
	else
		. = Run(input)
	if (input["format"] == "json")
		. = json_encode(.)
	else if(islist(.))
		. = list2params(.)

/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")

// TOPICS

/datum/world_topic/ping
	keyword = "ping"
	log = FALSE

/datum/world_topic/ping/Run(list/input)
	. = 0
	for (var/client/C in clients)
		++.

/datum/world_topic/playing
	keyword = "playing"
	log = FALSE

/datum/world_topic/pr_announce
	keyword = "announce"
	require_comms_key = TRUE
	var/static/list/PRcounts = list() //PR id -> number of times announced this round

/datum/world_topic/ahelp_relay
	keyword = "Ahelp"
	require_comms_key = TRUE

/datum/world_topic/comms_console
	keyword = "Comms_Console"
	require_comms_key = TRUE

/datum/world_topic/comms_console/Run(list/input)
	// Reject comms messages from other servers that are not on our configured network,
	// if this has been configured. (See CROSS_COMMS_NETWORK in comms.txt)
	var/configured_network = config.cross_comms_network
	if (configured_network && configured_network != input["network"])
		return

	// for(var/obj/machinery/computer/communications/CM in machine_registry[MACHINES_COMMSCONSOLES])
	// 	CM.override_cooldown()

/datum/world_topic/news_report
	keyword = "News_Report"
	require_comms_key = TRUE

/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE

/datum/world_topic/namecheck
	keyword = "namecheck"
	require_comms_key = TRUE

/datum/world_topic/adminwho
	keyword = "adminwho"
	require_comms_key = TRUE

/datum/world_topic/status
	keyword = "status"

/datum/world_topic/whois
	keyword = "whoIs"

/datum/world_topic/whois/Run(list/input)
	. = list()
	.["players"] = clients

	return list2params(.)

/datum/world_topic/getadmins
	keyword = "getAdmins"

/datum/world_topic/status
	keyword = "status"

/datum/world_topic/status/Run(list/input)
	. = list()
	.["version"] = game_version
	.["mode"] = (ticker?.hide_mode) ? "secret" : master_mode
	.["respawn"] = config ? abandon_allowed : 0
	.["enter"] = enter_allowed
	.["ai"] = config.allow_ai
	.["host"] = host ? host : null
	.["players"] = list()
	.["revision"] = revdata.commit
	.["revision_date"] = revdata.date
	.["station_name"] = station_name
	var/shuttle
	if (emergency_shuttle)
		if (emergency_shuttle.location == SHUTTLE_LOC_STATION) shuttle = 0 - emergency_shuttle.timeleft()
		else shuttle = emergency_shuttle.timeleft()
	else shuttle = "welp"
	.["shuttle_time"] = shuttle
	var/elapsed
	if (current_state < GAME_STATE_FINISHED)
		if (current_state <= GAME_STATE_PREGAME) elapsed = "pre"
		else if (current_state > GAME_STATE_PREGAME) elapsed = round(ticker.round_elapsed_ticks / 10)
	else if (current_state == GAME_STATE_FINISHED) elapsed = "post"
	else elapsed = "welp"
	.["elapsed"] = elapsed
	var/n = 0
	for(var/client/C in clients)
		.["player[n]"] = "[(C.stealth || C.alt_key) ? C.fakekey : C.key]"
		n++
	.["players"] = n
	.["map_name"] = getMapNameFromID(map_setting)
