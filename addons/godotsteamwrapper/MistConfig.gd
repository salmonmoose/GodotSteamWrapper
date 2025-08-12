@tool
class_name MistConfig extends Node

signal data_updated
var data : MistData

var test_data : Dictionary[StringName, Variant] = {
	&"controller_data" : {
		&"version": "3",
		&"revision": "23",
		&"title": "XBox One",
		&"actions": {
			&"InGameControls" : {
				&"title": "#Set_Ingame",
				&"legacy_set": "0",
				&"Button" : {
					&"Action" : "#Action_Action",
					&"Up" : "#Action_Up",
					&"Down" : "#Action_Down",
					&"Left" : "#Action_Left",
					&"Right" : "#Action_Right",
					&"Pause" : "#Action_Menu",
				}
			}
		}
	}
}

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

func vdf_parse(vdf_data: String) -> Dictionary[StringName, Variant]:
	var _result : Dictionary[StringName, Variant]
	var regex = RegEx.new()

	regex.compile("\"((?:\\\"|.)*?)\"\\s*\"((?:\\\"|.)*?)\"|\"((?:\\\"|.)*?)\"\\s*{([^}]*)(?!})")
	var matches = regex.search_all(vdf_data)

	for _match in matches:
		if _match.get_string(3) and _match.get_string(4):
			_result[_match.get_string(3)] = vdf_parse(_match.get_string(4))

		elif _match.get_string(1) and _match.get_string(2):
			_result[_match.get_string(1)] = _match.get_string(2)

		else:
			push_error("Error parsing vdf string: %s" % [_match.get_string(0)])

	return _result

func vdf_stringify(source_data : Dictionary, depth : int = 0) -> String:
	var _result : String
	var tab_stop : String = "\t".repeat(depth)

	for key in source_data:
		if source_data[key] is Dictionary:
			_result += "%s\"%s\"\n%s{\n%s%s}\n" % [
				tab_stop,
				key,
				tab_stop,
				vdf_stringify(source_data[key], depth + 1),
				tab_stop,
			]

		else:
			_result += "%s\"%s\"\t\t\"%s\"\n" % [
				tab_stop,
				key,
				source_data[key]
			]

	return _result
