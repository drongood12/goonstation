///// FOR EXPORTING DATA TO A SERVER /////

// Called in world.dm at new()
/proc/round_start_data()

	var/query[] = new()
	query["station_name"] = url_encode(station_name())
	query["round_status"] = "start"

	try
		apiHandler.queryAPI("round/save", query, 1)
	catch
		return 0

// Called in gameticker.dm at the end of the round.
/proc/round_end_data(var/reason)

	var/query[] = new()
	query["station_name"] = url_encode(station_name())
	query["round_status"] = "end"
	query["end_reason"] = reason
	query["game_type"] = ticker?.mode ? ticker.mode.name : "pre"

	try
		apiHandler.queryAPI("round/save", query, 1)
	catch
		return 0
