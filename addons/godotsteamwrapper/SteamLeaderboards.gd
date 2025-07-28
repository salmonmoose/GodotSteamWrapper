class_name SteamLeaderboards extends Object

var leaderboard_handle : int

func _init() -> void:
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

func find_leaderboard(level_name: String) -> void:
	Steam.findLeaderboard(level_name)

func set_score(leaderboard: int, score: int, details: Array[int] = [], keep_best: bool = true) -> void:
	Steam.uploadLeaderboardScore(score, keep_best, PackedInt32Array(details), leaderboard)

func get_scores(leaderboard: int, place_start: int = 1, place_end: int = 10, leaderboard_data : Steam.LeaderboardDataRequest = Steam.LEADERBOARD_DATA_REQUEST_GLOBAL) -> void:
	Steam.downloadLeaderboardEntries(place_start, place_end, leaderboard_data, leaderboard)
	
func get_user_scores(leaderboard: int, users : Array[int])  -> void:
	Steam.downloadLeaderboardEntriesForUsers(users, leaderboard)
	
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
