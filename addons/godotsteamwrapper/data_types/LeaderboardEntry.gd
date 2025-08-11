@tool
class_name LeaderboardEntryData extends Resource

@export var steam_id : int
@export var _score : int
@export var rank : int
@export var ugc_id : int
@export var leaderboard_id : int

var score : String : get = _get_score

func _init(_leaderboard_id : int) -> void:
	leaderboard_id = _leaderboard_id
	var leaderboard : LeaderboardData = Mist.Leaderboards.find_by_id(_leaderboard_id)
	if leaderboard:
		leaderboard.entries.push_back(self)

func _get_score() -> String:
	var leaderboard : LeaderboardData = Mist.Leaderboards.find_by_id(leaderboard_id)
	if not leaderboard:
		return ""
	var score_type : MistLeaderboards.DisplayType = leaderboard.display_type

	match score_type:
		MistLeaderboards.DisplayType.Numeric:
			return "%s" % _score
		MistLeaderboards.DisplayType.Seconds:
			return "%s seconds" % _score
		MistLeaderboards.DisplayType.MilliSeconds:
			return "%s milliseconds" % (float(_score) / 1000)

	return ""

func parse(data: Dictionary) -> void:
	steam_id = int(data.steamID)
	_score = int(data.score)
	rank = data.rank
	ugc_id = int(data.ugcid)
