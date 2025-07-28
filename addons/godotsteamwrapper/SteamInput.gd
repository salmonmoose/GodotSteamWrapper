class_name SteamInput extends Object
var device_handle : int
var device_type : int

var devices : Dictionary[int, int]

class Action:
	var held: bool = false
	var press_frame: int = -1
	var release_frame : int = -1

class Controller:
	var actions : Dictionary[String, int] = {}
	var action_sets :  Dictionary[String, int] = {}

var controllers : Dictionary[int, Controller] = {}

var actions : Dictionary[String, int] = {}
var action_states : Dictionary[int, Dictionary] = {}

## A list of signals that this game is aware of
var input_signal : Array[StringName]

var action_sets : Dictionary[String, int] = {
	&"InGameControls": 0,
	&"MenuControls": 0,
}

var current_action_set : String = &"MenuControls" : set = _set_current_action_set

var got_handles : bool = false

var game_action_set : int

func _init() -> void:
	Steam.input_device_connected.connect(_on_input_device_connected)
	Steam.input_device_disconnected.connect(_on_input_device_disconnected)
	Steam.input_configuration_loaded.connect(_on_input_configuration_loaded)
	Steam.input_gamepad_slot_change.connect(_on_input_gamepad_slot_change)
	print("Initializing Steam Input")
	Steam.inputInit(true)
	Steam.enableDeviceCallbacks()

func _exit() -> void:
	Steam.inputShutdown()

func emit_input_signals() -> void:
	var window : Window = GameGlobal.get_tree().root
	for action : StringName in input_signal:
		if is_action_just_pressed(PlayerGlobal.controller_handle, action):
			var event : InputEventAction = InputEventAction.new()
			event.action = action
			event.pressed = true
			window.push_input(event)

		if is_action_just_released(PlayerGlobal.controller_handle, action):
			var event : InputEventAction = InputEventAction.new()
			event.action = action
			event.pressed = false
			window.push_input(event)

func _set_current_action_set(value: String) -> void:
	assert(action_sets.has(value), "Missing action set %s")
	Steam.activateActionSet(PlayerGlobal.controller_handle, action_sets[value])
	current_action_set = value

func _on_input_device_connected(_device_handle: int) -> void:
	Steam.runFrame()
	print("Device connected: %s" % str(SteamStrings.INPUT_TYPE[Steam.getInputTypeForHandle(_device_handle)]))

func _on_input_device_disconnected(_device_handle: int) -> void:
	if PlayerGlobal.controller_handle == _device_handle:
		PlayerGlobal.controller_handle = -1
	print("Device disconnected: %s" % str(SteamStrings.INPUT_TYPE[Steam.getInputTypeForHandle(_device_handle)]))

func _on_input_configuration_loaded(_app_id: int, _device_handle: int, _config: Dictionary) -> void:
	print("Steam Input Configuration Loaded")
	if !controllers.has(_device_handle):
		print("Handle does not yet exist")
		populate_controller(_device_handle)

	if not got_handles:
		get_handles()

	if PlayerGlobal.controller_handle < 0:
		PlayerGlobal.controller_handle = _device_handle

	Steam.activateActionSet(PlayerGlobal.controller_handle, action_sets[current_action_set])

func _on_input_gamepad_slot_change(
	_app_id: int,
	_device_handle: int,
	_device_type: int,
	_old_gamepad_slot: int,
	new_gamepad_slot: int
	) -> void:
		device_handle = _device_handle
		device_type = _device_type

		if new_gamepad_slot >= 0:
			devices[device_handle] = new_gamepad_slot
		else:
			devices.erase(device_handle)

func populate_controller(_device_handle: int) -> void:
	controllers[_device_handle] = Controller.new()

	for action_set: String in action_sets.keys() as Array[String]:
		controllers[_device_handle].action_sets[action_set] = Steam.getActionSetHandle(action_set)

	for action in InputMap.get_actions():
		for event : InputEvent in InputMap.action_get_events(action):
			if is_instance_of(event, InputEventJoypadMotion):
				var handle : int = Steam.getAnalogActionHandle(action)
				if handle:
					controllers[_device_handle].actions[action] = handle
					print(controllers[_device_handle].actions[action])

			if is_instance_of(event, InputEventJoypadButton):
				var handle : int = Steam.getDigitalActionHandle(action)
				if handle:
					controllers[_device_handle].actions[action] = handle
					print(controllers[_device_handle].actions[action])

func get_handles() -> void:
	got_handles = true

	get_action_sets()
	get_action_handles()

## Loops through defined action sets, and loops through them to get the steam ID
func get_action_sets() -> void:
	for action_set : String in action_sets.keys() as Array[String]:
		action_sets[action_set] = Steam.getActionSetHandle(action_set)

# Runs through all the godot actions
# If they are joystick buttons or stick actions see if we can get a handle from Steam
func get_action_handles() -> void:
	for action in InputMap.get_actions():
		for event : InputEvent in InputMap.action_get_events(action):
			if is_instance_of(event, InputEventJoypadMotion):
				var handle : int = Steam.getAnalogActionHandle(action)
				if handle:
					actions[action] = handle

			if is_instance_of(event, InputEventJoypadButton):
				var handle : int = Steam.getDigitalActionHandle(action)
				if handle:
					actions[action] = handle

func get_action_set_handles() -> void:
	for action_set : String in action_sets.keys() as Array[String]:
		action_sets[action_set] = Steam.getActionSetHandle(action_set)

func get_controllers() -> Array[int]:
	var _controllers: Array[int] = [-1]
	var steam_controllers : Array[int] = Steam.getConnectedControllers() as Array[int]
	if steam_controllers:
		_controllers.append_array(steam_controllers)
	return _controllers

func get_action_strength(device: int, action: StringName, exact_match: bool = false) -> float:
	if device >= 0:
		if not got_handles: return 0

		var action_data : Dictionary = Steam.getAnalogActionData(device, actions[action])
		return action_data.x

	return Input.get_action_strength(action, exact_match)

func get_axis(device: int, negative_action: StringName, positive_action: StringName) -> float:
	if device >= 0:
		if not got_handles: return 0

		var negative : Dictionary = Steam.getAnalogActionData(device, actions[negative_action])
		var positive : Dictionary = Steam.getAnalogActionData(device, actions[positive_action])
		return positive.x - negative.x
	return Input.get_axis(negative_action, positive_action)

func get_vector(device: int, negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	if device >= 0:
		if not got_handles: return Vector2.ZERO
		var negative_x_val : Dictionary = Steam.getAnalogActionData(device, actions[negative_x])
		var positive_x_val : Dictionary = Steam.getAnalogActionData(device, actions[positive_x])
		var negative_y_val : Dictionary = Steam.getAnalogActionData(device, actions[negative_y])
		var positive_y_val : Dictionary = Steam.getAnalogActionData(device, actions[positive_y])
		return Vector2((positive_x_val.x as float) - (negative_x_val.x as float), -((positive_y_val.y as float) - (negative_y_val.y as float))).normalized()
	return Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone)

func get_move_input(device: int) -> Vector2:
	if device >= 0:
		if not got_handles: return Vector2.ZERO

		var action_data : Dictionary = Steam.getAnalogActionData(device, actions["Move"])
		return Vector2(action_data.x as float, -action_data.y as float).normalized()
	return Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()

func get_action_state(device: int, action: StringName) -> Action:
	if not action_states.get(device):
		action_states[device] = {}
	if not action_states[device].get(action):
		action_states[device][action] = Action.new()
	return action_states[device][action]

func set_action_state(device: int, action: StringName, currently_held: bool, current_frame: int) -> Action:
	var previous_action_state : Action = get_action_state(device, action)

	if currently_held and not previous_action_state.held:
		action_states[device][action].held = true
		action_states[device][action].press_frame = current_frame

	elif not currently_held and previous_action_state.held:
		action_states[device][action].held = false
		action_states[device][action].release_frame = current_frame

	return action_states[device][action]

func is_action_pressed(device: int, action: StringName, exact_match: bool = false) -> bool:
	if device >= 0:
		if not got_handles: return false
		var current_frame : int = Engine.get_process_frames()
		assert(actions.has(action), "Actions does not contain %s [%s]" % [action, actions])
		var currently_held : bool = Steam.getDigitalActionData(device, actions[action]).state

		set_action_state(device, action, currently_held, current_frame)
		return currently_held
	return Input.is_action_pressed(action, exact_match)

func is_action_just_pressed(device: int, action: StringName, exact_match: bool = false) -> bool:
	if device >= 0 and got_handles and actions.has(action):
		var current_frame : int = Engine.get_process_frames()
		var currently_held : bool = Steam.getDigitalActionData(device, actions[action]).state
		var action_state : Action = set_action_state(device, action, currently_held, current_frame)
		return currently_held and action_state.press_frame == current_frame

	return Input.is_action_just_pressed(action, exact_match)

func is_action_just_released(device: int, action: StringName, exact_match: bool = false) -> bool:
	if device >= 0:
		if not got_handles: return false
		var current_frame : int = Engine.get_process_frames()
		var currently_held : int = Steam.getDigitalActionData(device, actions[action]).state
		var action_state : Action = set_action_state(device, action, currently_held, current_frame)
		return not currently_held and action_state.release_frame == current_frame

	return Input.is_action_just_released(action, exact_match)
