@tool
class_name MistLeaderboards extends Node

signal on_fetch_leaderboards

enum WEB_CALL {
	GetLeaderboardsForGame,
	FindOrCreateLeaderboard,
	UploadLeaderboardScore,
	GetLeaderboardEntries,
	SetLeaderboardScore,
}

var WEB_CALL_DEFINITION : Dictionary = {
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

var leaderboards : Dictionary[StringName, LeaderboardData]

var leaderboard_handle : int

func _init() -> void:
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

func get_leaderboard(leaderboard_name: StringName) -> int:
	print("Leaderboard name %s" % leaderboard_name)
	print(Mist.Config.data.Leaderboards[leaderboard_name])
	return Mist.Config.data.Leaderboards[leaderboard_name].id

func find_leaderboard(leaderboard_name: String) -> void:
	## Godot Steam wants us to call steam for this
	Steam.findLeaderboard(leaderboard_name)

func set_score(leaderboard: int, score: int, details: Array[int] = [], keep_best: bool = true) -> void:
	print("Setting score for %s" % leaderboard)
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

func find_or_create_leaderboards(leaderboard : LeaderboardData) -> void:
	var call = WEB_CALL_DEFINITION[WEB_CALL.FindOrCreateLeaderboard]
	call.data[&"name"] = leaderboard.name
	call.data[&"sortmethod"] = leaderboard.sort_method_string
	call.data[&"displaytype"] = leaderboard.display_type_string
	call.data[&"onlytrustedwrites"] = leaderboard.only_trusted_writes
	call.data[&"onlyfriendsreads"] = leaderboard.only_friends_reads

	Mist.HTTP.make_request(
		call,
		_on_find_or_create_leaderboards
		)

## Convert the Steam data into local copies of the leaderboards
func _parse_leaderboards(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()['leaderBoards']

	for key in data:
		if key != "leaderBoardCount":
			if not Mist.Config.data.Leaderboards.has(key):
				Mist.Config.data.Leaderboards[key] = LeaderboardData.new()

			Mist.Config.data.Leaderboards[key].set_data(data)
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

func _on_find_or_create_leaderboards(result, response_code, headers, body):
	print(result, response_code, headers, body.get_string_from_utf8())
	fetch_leaderboards()

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if success == 1:
		print("Leaderboard uploaded ok", this_handle, this_score)

	else:
		print("Failed to upload scores for %s" % this_handle)

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	print("Scores downloaded message: %s %s" % [message, this_leaderboard_handle])

	for this_result : int in result:
		print(result)

## Register a leaderboard string
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
