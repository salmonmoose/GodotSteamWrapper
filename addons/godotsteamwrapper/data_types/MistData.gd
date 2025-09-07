class_name MistData extends Resource

@export var Leaderboards : Dictionary[StringName, LeaderboardData]
@export var Achievements : Dictionary[StringName, AchievementData]
@export var Stats : Dictionary[StringName, StatData]
@export var Controller : ControllerData = ControllerData.new()

func _init() -> void:
	pass
	#if not Controller:
		#Controller = ControllerData.new()
