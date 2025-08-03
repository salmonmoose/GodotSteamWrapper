@tool
extends VBoxContainer

var both : Color = Color.GREEN
var local : Color = Color.YELLOW
var steam : Color = Color.BLUE

@onready var leaderboard_tree : Tree = %LeaderboardList
var root : TreeItem

var leaves : Dictionary[String, TreeItem]
var leaderboard : LeaderboardData : get = _get_leaderboard
var leaderboard_key : StringName : get = _get_leaderboard_key

func _enter_tree() -> void:
	%display_type_edit.clear()
	for title : StringName in Mist.Leaderboards.DisplayType.keys():
		%display_type_edit.add_item(str(title))

	%sort_method_edit.clear()
	for title : StringName in Mist.Leaderboards.SortMethod.keys():
		%sort_method_edit.add_item(str(title))


func _ready() -> void:
	Mist.Leaderboards.on_fetch_leaderboards.connect(_populate_leaderboards)
	Mist.Config.data_updated.connect(_populate_leaderboards)
	leaderboard_tree.cell_selected.connect(_tree_clicked)
	leaderboard_tree.hide_root = true
	_populate_leaderboards()


func _populate_leaderboards() -> void:
	print("Populating Leaderboards")
	leaderboard_tree.clear()
	leaves.clear()
	root = leaderboard_tree.create_item()
	for leaderboard : StringName in Mist.Config.data.Leaderboards:
		var leaf : TreeItem

		if leaves.has(leaderboard):
			leaf = leaves[leaderboard]
		else:
			leaf = leaderboard_tree.create_item(root)
			leaves[leaderboard] = leaf
		leaf.set_text(0, leaderboard)

		configure_node(leaderboard)


func _get_leaderboard_key() -> StringName:
	return leaderboard_tree.get_selected().get_text(0)


func _get_leaderboard() -> LeaderboardData:
	return Mist.Config.data.Leaderboards[leaderboard_key]


func _tree_clicked() -> void:
	%name_edit.text = str(leaderboard_key)
	%entries_data.text = str(leaderboard.entries)
	%id_edit.text = str(leaderboard.id)
	%display_type_edit.selected = leaderboard.display_type
	%sort_method_edit.selected = leaderboard.sort_method
	%only_trusted_writes_edit.button_pressed = leaderboard.only_trusted_writes
	%only_friends_reads_edit.button_pressed = leaderboard.only_friends_reads
	%only_users_in_same_party_edit.button_pressed = leaderboard.only_users_in_same_party
	%limit_global_top_entries_edit.value = leaderboard.limit_global_top_entries
	%limit_range_around_user_edit.value = leaderboard.limit_range_around_user

func configure_node(name: StringName) -> void:
	var leaderboard = Mist.Config.data.Leaderboards[name]
	if leaderboard.on_local and leaderboard.on_steam:
		leaves[name].set_custom_color(0, both)
	elif leaderboard.on_local:
		leaves[name].set_custom_color(0, local)
	elif leaderboard.on_steam:
		leaves[name].set_custom_color(0, steam)

func _on_fetch_leaderboards_button_pressed() -> void:
	Mist.Leaderboards.fetch_leaderboards()


func _on_push_to_steam_pressed() -> void:
	var leaderboard_key : StringName = leaderboard_tree.get_selected().get_text(0)
	var leaderboard : LeaderboardData = Mist.Config.data.Leaderboards[leaderboard_key]
	Mist.Leaderboards.find_or_create_leaderboards(leaderboard)


func _on_delete_leaderboard_pressed() -> void:
	pass # Replace with function body.


func _on_get_scores_pressed() -> void:
	pass # Replace with function body.


func _on_reset_scores_pressed() -> void:
	pass # Replace with function body.
