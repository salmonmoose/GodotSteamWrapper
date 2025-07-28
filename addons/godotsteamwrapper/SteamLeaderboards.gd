@tool
class_name SteamLeaderboards extends Object

enum WEB_CALL {
	GetLeaderboardsForGame,
	FindOrCreateLeaderboard,
	UploadLeaderboardScore,
	GetLeaderboardEntries,
}

var WEB_CALL_DEFINITION : Dictionary = {
		WEB_CALL.GetLeaderboardsForGame: {
			&"method": HTTPClient.METHOD_GET,
			&"url": SteamHTTP.WEB_API % ["ISteamLeaderboards", "GetLeaderboardsForGame", "1"],
			&"data": {
				&"key": SteamHTTP.web_api_key,
				&"appid": SteamGlobal.app_id,
			}
		},
		WEB_CALL.FindOrCreateLeaderboard: {
			&"method": HTTPClient.METHOD_POST,
			&"url": SteamHTTP.WEB_API % ["ISteamLeaderboards", "FindOrCreateLeaderboard", "1"],
		},
		WEB_CALL.UploadLeaderboardScore: {
			&"method": HTTPClient.METHOD_POST,
			&"url": SteamHTTP.WEB_API % ["ISteamLeaderboards", "UploadLeaderboardScore", "1"],
		},
		WEB_CALL.GetLeaderboardEntries: {
			&"method": HTTPClient.METHOD_GET,
			&"url": SteamHTTP.WEB_API % ["ISteamLeaderboards", "GetLeaderboardEntries", "1"],
		}
	}

enum SortMethod {
	Ascending,
	Descending,
}

enum DisplayType {
	Numeric,
	MilliSeconds,
}

class Leaderboard:
	var id : int
	var entries : int
	var sort_method : SortMethod
	var display_type : DisplayType
	var only_trusted_writes : bool
	var only_friends_reads : bool
	var only_users_in_same_party : bool
	var limit_range_around_user : float
	var limit_global_top_entries : float

var leaderboards : Dictionary[StringName, Leaderboard]

var leaderboard_handle : int

func _init() -> void:
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
	get_leaderboards()

func find_leaderboard(level_name: String) -> void:
	Steam.findLeaderboard(level_name)

func set_score(leaderboard: int, score: int, details: Array[int] = [], keep_best: bool = true) -> void:
	Steam.uploadLeaderboardScore(score, keep_best, PackedInt32Array(details), leaderboard)

func get_scores(leaderboard: int, place_start: int = 1, place_end: int = 10, leaderboard_data : Steam.LeaderboardDataRequest = Steam.LEADERBOARD_DATA_REQUEST_GLOBAL) -> void:
	Steam.downloadLeaderboardEntries(place_start, place_end, leaderboard_data, leaderboard)

func get_user_scores(leaderboard: int, users : Array[int])  -> void:
	Steam.downloadLeaderboardEntriesForUsers(users, leaderboard)

func get_leaderboards() -> void:
	SteamHTTP.make_request(
		WEB_CALL_DEFINITION[WEB_CALL.GetLeaderboardsForGame],
		_parse_leaderboards
		)

func _parse_leaderboards(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	#data = data[data.keys()[0]] # get the first element
	var data = json.get_data()['leaderBoards']
	for key in data:
		if key != "leaderBoardCount":
			var leaderboard : SteamLeaderboards.Leaderboard = SteamLeaderboards.Leaderboard.new()

			leaderboard.id = data[key].leaderBoardID
			leaderboard.entries = data[key].leaderBoardEntries
			leaderboard.sort_method = data[key].leaderBoardSortMethod
			leaderboard.display_type = data[key].leaderBoardDisplayType
			leaderboard.only_trusted_writes = data[key].onlytrustedwrites
			leaderboard.only_friends_reads = data[key].onlyfriendsreads
			leaderboard.only_users_in_same_party = data[key].onlyusersinsameparty
			leaderboard.limit_range_around_user = data[key].limitrangearounduser
			leaderboard.limit_global_top_entries = data[key].limitglobaltopentries

			leaderboards[key] = leaderboard

func _on_leaderboard_find_result(handle: int, found: int) -> void:
	if found == 1:
		leaderboard_handle = handle
		print("Leaderboard handle found: %s" % leaderboard_handle)

	else:
		print("No handle found")

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if success == 1:
		print(this_handle, this_score)

	else:
		print("Failed to upload scores!")

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	print("Scores downloaded message: %s %s" % [message, this_leaderboard_handle])

	for this_result : int in result:
		print(result)

## Register a leaderboard string
static func register(name : StringName) -> void:
	var leaderboards : PackedStringArray
	if ProjectSettings.has_setting(SteamLoader.LEADERBOARDS):
		leaderboards = ProjectSettings.get_setting(SteamLoader.LEADERBOARDS)
	else:
		leaderboards = SteamLoader.SETTINGS[SteamLoader.LEADERBOARDS].default
	ProjectSettings.set_setting(SteamLoader.LEADERBOARDS, leaderboards)

	ProjectSettings.save()
