@tool
class_name MistStats extends Node

enum WEB_CALL {
	GetSchemaForGame
}

var WEB_CALL_DEFINITION : Dictionary = {
		WEB_CALL.GetSchemaForGame: {
			&"method": HTTPClient.METHOD_GET,
			&"url": MistHTTP.WEB_API % ["ISteamUserStats", "GetSchemaForGame", "2"],
			&"data": {
				&"key": MistHTTP.web_api_key,
				&"appid": str(Mist.app_id),
			}
		},
	}

func _init() -> void:
	Steam.user_stats_received.connect(_on_user_stats_received)
	get_schema_for_game()
	Steam.requestUserStats(Mist.steam_id)

func _exit_tree() -> void:
	store_stats()

## Fetch the current layout of Steam Stats
func get_schema_for_game() -> void:
	print("getting schema")
	Mist.HTTP.make_request(
		WEB_CALL_DEFINITION[WEB_CALL.GetSchemaForGame],
		_on_get_schema_for_game
		)

func set_stat(_name: StringName, _value: int) -> void:
	Steam.setStatInt(_name, _value)

func get_stat(_name: StringName) -> int:
	return Steam.getStatInt(_name)

func increment_stat(_name: StringName, _value) -> void:
	var current_count = get_stat(_name)
	set_stat(_name, current_count + _value)

func store_stats() -> void:
	Steam.storeStats()

func _on_user_stats_received(game_id, results, user) -> void:
	print("user stats: %s %s %s" % [game_id, results, user])

func _on_get_schema_for_game(result, response_code, headers, body) -> void:
	if result == OK:
		var data : Dictionary = JSON.parse_string(body.get_string_from_utf8())

		if data.game.availableGameStats.has('achievements'):
			_on_get_game_achievements(data.game.availableGameStats.achievements)

		if data.game.availableGameStats.has('stats'):
			_on_get_game_stats(data.game.availableGameStats.stats)

func _on_get_game_achievements(data: Array) -> void:
	for achievement_data in data:
		var achievement = AchievementData.new()

		achievement.name = achievement_data[&'name']
		achievement.default_value = achievement_data[&'defaultvalue']
		achievement.display_name = achievement_data[&'displayName']
		achievement.hidden = true if achievement_data[&'hidden'] > 0 else false
		achievement.description = achievement_data[&'description']
		achievement.icon = achievement_data[&'icon']
		achievement.icon_gray = achievement_data[&'icongray']

		Mist.Config.Achievements[achievement_data[&'name']] = achievement
		Mist.Config.save_data()

func _on_get_game_stats(data: Array) -> void:
	for stat_data in data:
		var stat = StatData.new()

		stat.name = stat_data[&'name']
		stat.default_value = stat_data[&'defaultvalue']
		stat.display_name = stat_data[&'displayName']

		Mist.Config.Stats[stat_data[&'name']] = stat
		Mist.Config.save_data()
