class_name JoystickData extends Resource

var action_states : Dictionary[StringName, ControllerData.Action] = {}
var action_sets :  Dictionary[StringName, int] = {}
var actions : Dictionary[StringName, int] = {}

var handle : int
var name : String : get = _get_name

func _init(_handle : int) -> void:
	handle = _handle
	print("Found a controller of type %s" % name)

func _get_name() -> String:
	return SteamStrings.INPUT_TYPE[Steam.getInputTypeForHandle(handle)]
