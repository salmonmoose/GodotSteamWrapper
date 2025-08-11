@tool
class_name MistLeaderboards extends Node

signal on_fetch_leaderboards
signal on_get_leaderboard_entries

enum WEB_CALL {
	GetLeaderboardsForGame,
	FindOrCreateLeaderboard,
	UploadLeaderboardScore,
	GetLeaderboardEntries,
	SetLeaderboardScore,
	DeleteLeaderboard,
}

var WEB_CALL_DEFINITION : Dictionary = {
		WEB_CALL.DeleteLeaderboard: {
			&"method": HTTPClient.METHOD_POST,
			&"url": MistHTTP.WEB_API % ["ISteamLeaderboards", "DeleteLeaderboard", "1"],
			&"data": {
				&"key": MistHTTP.web_api_key,
				&"appid": str(Mist.app_id),
			}
		},
		WEB_CALL.GetLeaderboardsForGame: {
			&"method": HTTPClient.METHOD_GET,
			&"url": MistHTTP.WEB_API % ["ISteamLeaderboards", "GetLeaderboardsForGame", "1"],
			&"data": {
				&"key": MistHTTP.web_api_key,
				&"appid": str(Mist.app_id),
			}
		},
		WEB_CALL.FindOrCreateLeaderboard: {
			&"method": HTTPClient.METHOD_POST,
			&"url": MistHTTP.WEB_API % ["ISteamLeaderboards", "FindOrCreateLeaderboard", "2"],
			&"data": {
				&"key": MistHTTP.web_api_key,
				&"appid": str(Mist.app_id),
			}
		},
		WEB_CALL.UploadLeaderboardScore: {
			&"method": HTTPClient.METHOD_POST,
			&"url": MistHTTP.WEB_API % ["ISteamLeaderboards", "UploadLeaderboardScore", "1"],
		},
		WEB_CALL.GetLeaderboardEntries: {
			&"method": HTTPClient.METHOD_GET,
			&"url": MistHTTP.WEB_API % ["ISteamLeaderboards", "GetLeaderboardEntries", "1"],
			&"data": {
				&"key": MistHTTP.web_api_key,
				&"appid": str(Mist.app_id),
			}
		},
		WEB_CALL.SetLeaderboardScore: {
			&"method": HTTPClient.METHOD_POST,
			&"url": MistHTTP.WEB_API % ["ISteamLeaderboards", "SetLeaderboardScore", "1"],
			&"data": {
				&"key": MistHTTP.web_api_key,
				&"appid": str(Mist.app_id),
			}
		}
	}

enum SortMethod {
	Ascending,
	Descending,
}

enum DisplayType {
	Numeric,
	Seconds,
	MilliSeconds,
}

enum ScoreMethod {
	KeepBest,
	ForceUpdate,
}

enum RequestType {
	RequestGlobal,
	RequestAroundUser,
	RequestFriends,
}

var leaderboards : Dictionary[StringName, LeaderboardData]

var leaderboard_handle : int

var last_leaderboard_id : int = 0
var entry_page_size : int = 20
var last_leaderboard_range_start : int = 0

func _init() -> void:
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

func find_leaderboard(leaderboard_name: String) -> void:
	## Godot Steam wants us to call steam for this
	## Getting this from the local DB is faster
	Steam.findLeaderboard(leaderboard_name)

func find_by_id(leaderboard: int) -> LeaderboardData:
	for leaderboard_key in Mist.Config.data.Leaderboards:
		if Mist.Config.data.Leaderboards[leaderboard_key].id == leaderboard:
			return Mist.Config.data.Leaderboards[leaderboard_key]

	return null

func set_score(leaderboard: int, score: int, details: Array[int] = [], keep_best: bool = true) -> void:
	print("Setting score for %s" % leaderboard)
	print("score: %s, keep_best: %s, details: %s" % [score, keep_best, details])
	Steam.uploadLeaderboardScore(score, keep_best, PackedInt32Array(details), leaderboard)
	await Steam.leaderboard_score_uploaded

func get_scores(leaderboard: int, place_start: int = 1, place_end: int = 10, leaderboard_data : Steam.LeaderboardDataRequest = Steam.LEADERBOARD_DATA_REQUEST_GLOBAL) -> void:
	Steam.downloadLeaderboardEntries(place_start, place_end, leaderboard_data, leaderboard)

func get_user_scores(leaderboard: int, users : Array[int])  -> void:
	Steam.downloadLeaderboardEntriesForUsers(users, leaderboard)


## Fetch the currently known leaderboard from Steam
func fetch_leaderboards() -> void:
	Mist.HTTP.make_request(
		WEB_CALL_DEFINITION[WEB_CALL.GetLeaderboardsForGame],
		_parse_leaderboards
		)

func find_or_create_leaderboard(leaderboard : LeaderboardData) -> void:
	var call = WEB_CALL_DEFINITION[WEB_CALL.FindOrCreateLeaderboard]
	call.data[&"name"] = leaderboard.name
	call.data[&"sortmethod"] = leaderboard.sort_method_string
	call.data[&"displaytype"] = leaderboard.display_type_string
	call.data[&"onlytrustedwrites"] = leaderboard.only_trusted_writes
	call.data[&"onlyfriendsreads"] = leaderboard.only_friends_reads

	Mist.HTTP.make_request(
		call,
		_on_find_or_create_leaderboard
		)

func delete_leaderboard(leaderboard : LeaderboardData) -> void:
	var call = WEB_CALL_DEFINITION[WEB_CALL.DeleteLeaderboard]
	call.data[&"name"] = leaderboard.name

	Mist.HTTP.make_request(
		call,
		_on_delete_leaderboard
	)

	Mist.Config.data.Leaderboards.erase(leaderboard.name)

func get_leaderboard_entires(leaderboard : LeaderboardData, datarequest : RequestType, steamid: int = 0) -> void:
	var call = WEB_CALL_DEFINITION[WEB_CALL.GetLeaderboardEntries]

	call.data[&"leaderboardid"] = leaderboard.id
	call.data[&"datarequest"] = datarequest

	if steamid:
		call.data[&"steamid"] = steamid

	if last_leaderboard_id != leaderboard.id:
		last_leaderboard_range_start = 0
		last_leaderboard_id = leaderboard.id

	call.data[&"rangestart"] = last_leaderboard_range_start
	call.data[&"rangeend"] = last_leaderboard_range_start + entry_page_size

	Mist.HTTP.make_request(
		call,
		_on_get_leaderboard_entries
	)


## Convert the Steam data into local copies of the leaderboards
func _parse_leaderboards(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()['leaderBoards']

	for leaderboard in Mist.Config.data.Leaderboards:
		Mist.Config.data.Leaderboards[leaderboard].on_steam = false

	for key in data:
		if key != "leaderBoardCount":
			if not Mist.Config.data.Leaderboards.has(key):
				Mist.Config.data.Leaderboards[key] = LeaderboardData.new()

			Mist.Config.data.Leaderboards[key].parse(data[key])
			Mist.Config.data.Leaderboards[key].name = key
			Mist.Config.data.Leaderboards[key].on_steam = true
			Mist.Config.save_data()

	on_fetch_leaderboards.emit()

func _on_leaderboard_find_result(handle: int, found: int) -> void:
	if found == 1:
		leaderboard_handle = handle
		print("Leaderboard handle found: %s" % leaderboard_handle)

	else:
		print("No handle found")

func _on_find_or_create_leaderboard(result, response_code, headers, body) -> void:
	print(result, response_code, headers, body.get_string_from_utf8())
	fetch_leaderboards()

func _on_delete_leaderboard(result, response_code, headers, body) -> void:
	fetch_leaderboards()

func _on_get_leaderboard_entries(result, response_code, headers, body) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()['leaderboardEntryInformation']

	for entryData in data.leaderboardEntries:
		var entry = LeaderboardEntryData.new(data.leaderboardID)
		entry.parse(entryData)
		print(entry)

	#print(result, response_code, headers, body.get_string_from_utf8())
	on_get_leaderboard_entries.emit()

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	print("leaderboard uploaded %s, %s, %s" % [success, this_handle, this_score])
	if success == 1:
		print("Leaderboard uploaded ok", this_handle, this_score)

	else:
		push_warning("Failed to upload scores for %s with code: %s" % [this_handle, success])

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	print("Scores downloaded message: %s %s" % [message, this_leaderboard_handle])

	for this_result : int in result:
		print(result)

## Register a leaderboard string
## Registered Leaderboards are marked as local and can be pushed to steam to assure matching
## Leaderboard pairs
func register(name : StringName) -> void:
	if not Mist.Config.data.Leaderboards[name]:
		print("Registering new leaderboard: %s" % name)
		var leaderboard : LeaderboardData = LeaderboardData.new()
		leaderboard.name = name
		Mist.Config.data.Leaderboards[name] = leaderboard

	if Mist.Config.data.Leaderboards[name].on_local:
		return

	Mist.Config.data.Leaderboards[name].on_local = true

	Mist.Config.save_data()
