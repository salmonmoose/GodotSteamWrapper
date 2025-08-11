@tool
class_name AchievementData extends Resource

@export var name : StringName
@export var default_value : int
@export var display_name : String
@export var hidden : bool
@export var description : String
@export var icon : String : set = _set_icon
@export var icon_gray : String : set = _set_icon_gray

func _set_icon(value : String) -> void:
	icon = value

func _set_icon_gray(value : String) -> void:
	icon_gray = value
