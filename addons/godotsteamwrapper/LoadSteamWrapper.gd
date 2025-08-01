@tool
class_name SteamLoader extends EditorPlugin

const APP_ID = &"mist/appID"
const WEB_API_KEY = &"mist/WebAPI"
const ACHIEVEMENTS = &"mist/stats/achievments"
const LEADERBOARDS = &"mist/stats/leaderboards"

## Project settings
const SETTINGS : Dictionary[StringName, Dictionary] = {
	APP_ID : {
		"name": APP_ID,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,infinity,1,or_greater,hide_slider",
		"default": 480,
	},
	WEB_API_KEY : {
		"name": WEB_API_KEY,
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_RANGE,
		"default": "",
	},
	ACHIEVEMENTS : {
		"name": ACHIEVEMENTS,
		"type": TYPE_PACKED_STRING_ARRAY,
		"hint": PROPERTY_HINT_NONE,
		"default": [],
	},
	LEADERBOARDS : {
		"name": LEADERBOARDS,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_NONE,
		"default": [],
	}
}

var dock

func _enter_tree() -> void:
	for setting : StringName in SETTINGS:
		add_setting(setting, SETTINGS[setting], SETTINGS[setting].default)

	add_autoload_singleton("Mist", "res://addons/godotsteamwrapper/Mist.gd")

	dock = preload("uid://bvrfuplm0c3sq").instantiate()
	add_control_to_bottom_panel(dock, "Mist")

func _exit_tree() -> void:
	remove_autoload_singleton("Mist")
	remove_control_from_bottom_panel(dock)
	dock.free()


## Add a setting for the project - mostly a wrapper for ease
func add_setting(setting_name: String, property_info: Dictionary, default: Variant) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default)

	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value(setting_name, default)
	ProjectSettings.set_as_basic(setting_name, true)
