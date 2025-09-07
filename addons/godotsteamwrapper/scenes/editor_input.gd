@tool
extends Control

@onready var action_set_list : GridContainer = %ActionSetList
const DEFAULT_TEXT : StringName = &"Action Set"
const INDEX : StringName = &"_INDEX_"

var action_set_root : TreeItem

func _ready() -> void:
	_populate_action_sets()
	
func _populate_action_sets() -> void:
	for n in action_set_list.get_children():
		n.queue_free()
		
	
	for index in Mist.Config.Controller.action_sets.size():
		var node : LineEdit = LineEdit.new()
		node.text = Mist.Config.Controller.action_sets[index]
		node.set_meta(INDEX, index)
		action_set_list.add_child(node)
		

func _on_add_action_set_pressed() -> void:
	var node : LineEdit = LineEdit.new()
	node.text = DEFAULT_TEXT
	node.editing_toggled.connect(_on_action_set_editing_toggled.bind(node))
	action_set_list.add_child(node)

func _on_action_set_editing_toggled(editing : bool, node: LineEdit) -> void:
	#If we're going into editing, we don't care.
	if editing:
		return
		
	var value : StringName = node.text
		
	#If we've moved out, and it's still a default, we don't care
	if value == DEFAULT_TEXT:
		return 

	#If we already have this value, we don't care, it's either a duplicate or an existing value
	if (Mist.Config.data.Controller.action_sets.has(value)):
		return
		
	#If the node already has a value, it has an index, so update that value
	if node.has_meta(INDEX):
		Mist.Config.data.Controller.action_sets[node.get_meta(INDEX)]
	# Otherwise, create a new value
	else:
		Mist.Config.data.Controller.action_sets.push_back((node.text as StringName))
		node.set_meta(INDEX, Mist.Config.data.Controller.action_sets.find((node.text as StringName)))
	
	Mist.Config.save_data()
	
