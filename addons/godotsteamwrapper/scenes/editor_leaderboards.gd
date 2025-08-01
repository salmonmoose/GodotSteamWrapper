@tool
extends VBoxContainer

var both : Color = Color.GREEN
var local : Color = Color.YELLOW
var steam : Color = Color.BLUE

@onready var leaderboard_tree : Tree = %LeaderboardList
var root : TreeItem

var leaves : Dictionary[StringName, TreeItem]

func _ready() -> void:
	Mist.Leaderboards.on_fetch_leaderboards.connect(_populate_leaderboards)

	leaderboard_tree.hide_root = true
	leaderboard_tree.cell_selected.connect(_tree_clicked)
	for title : StringName in Mist.Leaderboards.DisplayType.keys():
		%display_type_edit.add_item(str(title))

	for title : StringName in Mist.Leaderboards.SortMethod.keys():
		%sort_method_edit.add_item(str(title))

func _populate_leaderboards() -> void:
	leaderboard_tree.clear()
	root = leaderboard_tree.create_item()
	for leaderboard : StringName in Mist.Leaderboards.leaderboards:
		var leaf = leaderboard_tree.create_item(root)
		leaves[leaderboard] = leaf

		leaf.set_text(0, leaderboard)

		configure_node(leaderboard)

func _tree_clicked() -> void:
	var leaderboard_key : StringName = leaderboard_tree.get_selected().get_text(0)
	var leaderboard : MistLeaderboards.Leaderboard = Mist.Leaderboards.leaderboards[leaderboard_key]

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
	var leaderboard = Mist.Leaderboards.leaderboards[name]
	if leaderboard.on_local and leaderboard.on_steam:
		leaves[name].set_custom_color(0, both)
	elif leaderboard.on_local:
		leaves[name].set_custom_color(0, local)
	elif leaderboard.on_steam:
		leaves[name].set_custom_color(0, steam)

func _on_fetch_leaderboards_button_pressed() -> void:
	Mist.Leaderboards.fetch_leaderboards()
