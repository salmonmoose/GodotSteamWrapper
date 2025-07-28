@tool
extends EditorPlugin

## Project settings
const CONSOLE_THEME : String = &"steam/steamID"

func _enter_tree() -> void:
	add_autoload_singleton("Mist", "res://addons/godotsteamwrapper/SteamGlobal.gd")


## Add a setting for the project - mostly a wrapper for ease
func add_setting(setting_name: String, property_info: Dictionary, default: Variant) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default)

	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value(setting_name, default)
	ProjectSettings.set_as_basic(setting_name, true)
