@tool
class_name MistConfig extends Node

signal data_updated
var data : MistData

var Leaderboards : Dictionary[StringName, LeaderboardData] :
	get:
		return data.Leaderboards

var Achievements : Dictionary[StringName, AchievementData] :
	get:
		return data.Achievements

var Stats : Dictionary[StringName, StatData] :
	get:
		return data.Stats

const FILENAME : StringName = &"mist_data.tres"

func _init() -> void:
	load_data()

func load_data() -> void:
	print("loading data")
	if ResourceLoader.exists(FILENAME):
		data = ResourceLoader.load(FILENAME)
		data_updated.emit()
	else:
		data = MistData.new()

func save_data() -> void:
	var err = ResourceSaver.save(data, FILENAME)
	if err != OK:
		push_error(err)
	data_updated.emit()
