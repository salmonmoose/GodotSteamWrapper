class_name SteamAchievements extends Node



#
#
#func _init() -> void:
	#Steam.current_stats_received.connect(_on_steam_stats_ready)
	#Mist.set_float_stat.connect(_set_float_stat)
	#Mist.set_int_stat.connect(_set_int_stat)
	#Mist.fire_achievement.connect(_fire_steam_achievement)
#
#func _on_steam_stats_ready(_game: int, _result: int, _user: int) -> void:
	#for achievment : String in achievements:
		#get_achievement(achievment)
#
#func get_achievement(value: String) -> void:
	#var this_achievement: Dictionary = Steam.getAchievement(value)
#
	#if this_achievement['ret']:
#
		#if this_achievement['achieved']:
			#achievements[value] = true
#
		#else:
			#achievements[value] = false
#
	#else:
		#achievements[value] = false
#
#func _fire_steam_achievement(value: String) -> void:
	#achievements[value] = true
#
	#Steam.setAchievement(value)
	#Steam.storeStats()
#
#func _set_int_stat(stat_name: String, value: int) -> void:
	#Steam.setStatInt(stat_name, value)
	#Steam.storeStats()
#
#func _set_float_stat(stat_name: String, value: float) -> void:
	#Steam.setStatFloat(stat_name, value)
	#Steam.storeStats()
