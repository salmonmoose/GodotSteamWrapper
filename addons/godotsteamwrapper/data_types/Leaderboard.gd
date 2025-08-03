@tool
class_name LeaderboardData extends Resource

@export var id : int
@export var name : StringName
@export var entries : int = 0# Don't save it, data is always live
@export var sort_method : MistLeaderboards.SortMethod
@export var display_type : MistLeaderboards.DisplayType
@export var only_trusted_writes : bool
@export var only_friends_reads : bool
@export var only_users_in_same_party : bool
@export var limit_range_around_user : int
@export var limit_global_top_entries : int
@export var on_steam : bool
@export var on_local : bool

@export var sort_method_string : StringName : get = _get_sort_method_string
@export var display_type_string : StringName : get = _get_display_type_string

static func parse(data : Dictionary) -> LeaderboardData:
	var leaderboard : LeaderboardData = LeaderboardData.new()

	leaderboard.set_data(data)

	return leaderboard

func set_data(data: Dictionary) -> void:
	id = data.leaderBoardID
	entries = data.leaderBoardEntries
	sort_method = MistLeaderboards.SortMethod.keys().find(data.leaderBoardSortMethod)
	display_type = MistLeaderboards.DisplayType.keys().find(data.leaderBoardDisplayType)
	only_trusted_writes = true if data.onlytrustedwrites else false
	only_friends_reads = true if data.onlyfriendsreads else false
	only_users_in_same_party = true if data.onlyusersinsameparty else false
	limit_range_around_user = int(data.limitrangearounduser)
	limit_global_top_entries = int(data.limitglobaltopentries)

func _get_sort_method_string() -> StringName:
	return MistLeaderboards.SortMethod.keys()[sort_method]

func _get_display_type_string() -> StringName:
	return MistLeaderboards.DisplayType.keys()[display_type]

func _to_string() -> String:
	return "%s, %s, %s, %s, %s, %s, %s, %s, %s" % [
		id,
		entries,
		sort_method,
		display_type,
		only_trusted_writes,
		only_friends_reads,
		only_users_in_same_party,
		limit_range_around_user,
		limit_global_top_entries
	]
