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
	print(load_vdf("res://addons/godotsteamwrapper/data_types/controller_templates/controller_generic_gamepad_joystick.vdf"))

func load_data() -> void:
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

func load_vdf(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file == null:
		push_error(FileAccess.get_open_error())
		return

	var definition = vdf_parse(file.get_as_text())

	print(vdf_stringify(definition))


## Parse a vdf file - takes the string from a vdf file and parses it into a dictionary
func vdf_parse(vdf_data: String, key='') -> Dictionary[StringName, Variant]:
	vdf_data = vdf_data.replace('\r\n', '\n')
	vdf_data = vdf_data.replace('\r', '\n')
	var _result : Dictionary[StringName, Variant]
	var regex = RegEx.new()
	var collecting = false
	var bracket_count = 0
	var collect_key = ''
	var collection = []

	regex.compile("\"((?:\\\"|.)*?)\"\\s*\"((?:\\\"|.)*?)\"|\"((?:\\\"|.)*?)\"|({)|(})")

	var lines = vdf_data.split('\n')

	for line in lines:
		var matches = regex.search(line)

		if not matches:
			break

		if bracket_count > 0:
			if matches.strings[5]:
				bracket_count -= 1
				if bracket_count == 0:
					#print(collection)
					collecting = false
					var str = '\n'.join(collection)

					var vdf = vdf_parse(str, collect_key)

					if _result.has(collect_key) and _result[collect_key] is Dictionary:
						_result[collect_key] = [_result[collect_key]]
						_result[collect_key].push_back(vdf)
					else:
						_result[collect_key] = vdf
				else:
					collection.push_back(line)
			else:
				collection.push_back(line)

		else:
			if matches.strings[1] and matches.strings[2]:
				_result[matches.strings[1]] = matches.strings[2]

			if matches.strings[3]:
				collecting = true
				collection = []
				collect_key = matches.strings[3]

		#count LHS brackets
		if matches.strings[4]:
			bracket_count += 1

	return _result


## Takes a basic dictionary and converts it into a vdf files - only works with nested [String, String] dictionaries.
func vdf_stringify(source_data : Dictionary, depth : int = 0) -> String:
	var _result : String
	var tab_stop : String = "\t".repeat(depth)

	for key in source_data:
		if source_data[key] is Dictionary:
			_result += "%s\"%s\"\r%s{\r%s%s}\r" % [
				tab_stop,
				key,
				tab_stop,
				vdf_stringify(source_data[key], depth + 1),
				tab_stop,
			]

		elif source_data[key] is Array:
			for value in source_data[key]:
				if value is Dictionary:
					_result += "%s\"%s\"\r%s{\r%s%s}\r" % [
						tab_stop,
						key,
						tab_stop,
						vdf_stringify(value, depth + 1),
						tab_stop,
					]

		else:
			_result += "%s\"%s\"\t\t\"%s\"\r" % [
				tab_stop,
				key,
				source_data[key]
			]

	return _result
