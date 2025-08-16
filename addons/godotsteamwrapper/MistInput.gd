class_name MistInput extends Object
var controllers : Dictionary[int, ControllerData] = {}

## A list of signals that this game is aware of
var input_signal : Array[StringName]

## Maintain a connection to the current player's handle
var player_handle : int = -1

var action_sets : Array[StringName] = [
	&"InGameControls",
	&"MenuControls",
]

#FIXME: We can find controllers in C:\Program Files(x86)\Steam\controller_base\templates

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
	Steam.runFrame()
	Steam.enableDeviceCallbacks()

func _exit() -> void:
	Steam.inputShutdown()

## Captures actions from Steam and emits as native Godot events.
func emit_input_signals() -> void:
	var window : Window = Mist.get_tree().root
	for action : StringName in input_signal:
		if is_action_just_pressed(player_handle, action):
			var event : InputEventAction = InputEventAction.new()
			event.action = action
			event.pressed = true
			window.push_input(event)

		if is_action_just_released(player_handle, action):
			var event : InputEventAction = InputEventAction.new()
			event.action = action
			event.pressed = false
			window.push_input(event)

## Sets the current action set
func _set_current_action_set(value: StringName) -> void:
	assert(controllers[player_handle].action_sets.has(value), "Missing action set %s")
	Steam.activateActionSet(player_handle, controllers[player_handle].action_sets[value])
	current_action_set = value


func _on_input_device_connected(_device_handle: int) -> void:
	Steam.runFrame()
	print("Device connected: %s" % str(SteamStrings.INPUT_TYPE[Steam.getInputTypeForHandle(_device_handle)]))

func _on_input_device_disconnected(_device_handle: int) -> void:
	if player_handle == _device_handle:
		player_handle = -1
	print("Device disconnected: %s" % str(SteamStrings.INPUT_TYPE[Steam.getInputTypeForHandle(_device_handle)]))

func _on_input_configuration_loaded(_app_id: int, _device_handle: int, _config: Dictionary) -> void:
	print("Steam Input Configuration Loaded")
	if !controllers.has(_device_handle):
		populate_controller(_device_handle)

	if player_handle < 0:
		player_handle = _device_handle

	print(action_sets)
	#_set_current_action_set("InGameControls")
	Steam.activateActionSet(player_handle, 1)
	Steam.activateActionSetLayer(player_handle, 1)
	Steam.runFrame()


func _on_input_gamepad_slot_change(
	_app_id: int,
	_device_handle: int,
	_device_type: int,
	_old_gamepad_slot: int,
	new_gamepad_slot: int
	) -> void:
	pass


## Populate a controller dataset with associations from Steam
func populate_controller(_device_handle: int) -> void:
	controllers[_device_handle] = ControllerData.new(_device_handle)

	for action_set: StringName in action_sets:
		var handle = Steam.getActionSetHandle(action_set)
		print("Registering action set %s handle %s on %s" % [action_set, handle, controllers[_device_handle].name])
		controllers[_device_handle].action_sets[action_set] = handle

	for action in InputMap.get_actions():
		for event : InputEvent in InputMap.action_get_events(action):
			if is_instance_of(event, InputEventJoypadMotion):
				var handle : int = Steam.getAnalogActionHandle(action)
				if handle:
					print("Registering analog %s handle %s on %s" % [action, handle, controllers[_device_handle].name])
					controllers[_device_handle].actions[action] = handle

			if is_instance_of(event, InputEventJoypadButton):
				var handle : int = Steam.getDigitalActionHandle(action)
				if handle:
					print("Registering digital %s handle %s on %s" % [action, handle, controllers[_device_handle].name])
					controllers[_device_handle].actions[action] = handle

func get_active_action_set_layers(handle: int) -> void:
	print("action set layers", Steam.getActiveActionSetLayers(handle))

func get_controllers() -> Array[int]:
	var _controllers: Array[int] = [-1]
	var steam_controllers : Array[int] = Steam.getConnectedControllers() as Array[int]
	if steam_controllers:
		_controllers.append_array(steam_controllers)
	return _controllers


func get_axis(_device_handle: int, negative_action: StringName, positive_action: StringName) -> float:
	if _device_handle >= 0:
		if not got_handles: return 0

		var negative : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[negative_action])
		var positive : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[positive_action])
		return positive.x - negative.x
	return Input.get_axis(negative_action, positive_action)

func get_vector(_device_handle: int, negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	if _device_handle >= 0:
		if not got_handles: return Vector2.ZERO
		var negative_x_val : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[negative_x])
		var positive_x_val : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[positive_x])
		var negative_y_val : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[negative_y])
		var positive_y_val : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[positive_y])
		return Vector2((positive_x_val.x as float) - (negative_x_val.x as float), -((positive_y_val.y as float) - (negative_y_val.y as float))).normalized()
	return Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone)


func get_move_input(_device_handle: int) -> Vector2:
	if _device_handle >= 0:
		var action_data : Dictionary = Steam.getAnalogActionData(_device_handle, controllers[_device_handle].actions[&"Move"])
		return Vector2(action_data.x as float, -action_data.y as float).normalized()
	return Vector2(Input.get_axis(&"Left", &"Right"), Input.get_axis(&"Up", &"Down")).normalized()


func get_action_state(_device_handle: int, action: StringName) -> ControllerData.Action:
	if not controllers[_device_handle].action_states.has(action):
		controllers[_device_handle].action_states[action] = ControllerData.Action.new()

	return controllers[_device_handle].action_states[action]


## Set action state for a device
func set_action_state(_device_handle: int, action: StringName, currently_held: bool, current_frame: int) -> ControllerData.Action:
	var previous_action_state : ControllerData.Action = get_action_state(_device_handle, action)

	if currently_held and not previous_action_state.held:
		controllers[_device_handle].action_states[action].held = true
		controllers[_device_handle].action_states[action].press_frame = current_frame

	elif not currently_held and previous_action_state.held:
		controllers[_device_handle].action_states[action].held = false
		controllers[_device_handle].action_states[action].release_frame = current_frame

	return controllers[_device_handle].action_states[action]


## Returns true if an action is currently pressed
func is_action_pressed(_device_handle: int, action: StringName, exact_match: bool = false) -> bool:
	if _device_handle >= 0:
		assert(controllers[_device_handle].actions.has(action), "Actions does not contain %s" % [action])

		var current_frame : int = Engine.get_process_frames()
		var currently_held : bool = Steam.getDigitalActionData(_device_handle, controllers[_device_handle].actions[action]).state

		set_action_state(_device_handle, action, currently_held, current_frame)

		return currently_held

	return Input.is_action_pressed(action, exact_match)


## Returns a true if an action has been pressed this frame
func is_action_just_pressed(_device_handle: int, action: StringName, exact_match: bool = false) -> bool:
	if _device_handle >= 0:
		assert(controllers[_device_handle].actions.has(action), "Actions does not contain %s" % [action])

		var current_frame : int = Engine.get_process_frames()
		var currently_held : bool = Steam.getDigitalActionData(_device_handle, controllers[_device_handle].actions[action]).state
		var action_state : ControllerData.Action = set_action_state(_device_handle, action, currently_held, current_frame)

		return currently_held and action_state.press_frame == current_frame

	return Input.is_action_just_pressed(action, exact_match)


## Returns a true if an action has been release this frame
func is_action_just_released(_device_handle: int, action: StringName, exact_match: bool = false) -> bool:
	if _device_handle >= 0:
		assert(controllers[_device_handle].actions.has(action), "Actions does not contain %s" % [action])

		var current_frame : int = Engine.get_process_frames()
		var currently_held : int = Steam.getDigitalActionData(_device_handle, controllers[_device_handle].actions[action]).state
		var action_state : ControllerData.Action = set_action_state(_device_handle, action, currently_held, current_frame)

		return not currently_held and action_state.release_frame == current_frame

	return Input.is_action_just_released(action, exact_match)
