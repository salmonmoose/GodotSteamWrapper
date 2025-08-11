class_name ControllerData extends Resource

class Action:
	var held: bool = false
	var press_frame: int = -1
	var release_frame : int = -1

var action_states : Dictionary[StringName, Action] = {}
var action_sets :  Dictionary[StringName, int] = {}
var actions : Dictionary[StringName, int] = {}

var handle : int
var name : String : get = _get_name

func _init(_handle : int):
	handle = _handle

func _get_name() -> String:
	return SteamStrings.INPUT_TYPE[Steam.getInputTypeForHandle(handle)]
