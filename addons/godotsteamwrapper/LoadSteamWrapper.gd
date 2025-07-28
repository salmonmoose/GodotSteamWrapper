@tool
class_name SteamLoader extends EditorPlugin

const APP_ID = &"mist/appID"

## Project settings
const SETTINGS : Dictionary[StringName, Dictionary] = {
	APP_ID : {
		"name": APP_ID,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,infinity,1,or_greater,hide_slider",
		"default": 480,
	}
}

func _enter_tree() -> void:
	for setting : StringName in SETTINGS:
		add_setting(setting, SETTINGS[setting], SETTINGS[setting].default)

	add_autoload_singleton("Mist", "res://addons/godotsteamwrapper/SteamGlobal.gd")

## Add a setting for the project - mostly a wrapper for ease
func add_setting(setting_name: String, property_info: Dictionary, default: Variant) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default)

	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value(setting_name, default)
	ProjectSettings.set_as_basic(setting_name, true)
