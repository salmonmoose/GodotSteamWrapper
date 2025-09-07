@tool
class_name ControllerData extends Resource

class Action:
	var held: bool = false
	var press_frame: int = -1
	var release_frame : int = -1

@export var action_sets :  Array[StringName] = []
