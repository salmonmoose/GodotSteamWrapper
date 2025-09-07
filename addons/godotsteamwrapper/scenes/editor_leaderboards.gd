@tool
extends Control

var both : Color = Color.GREEN
var local : Color = Color.YELLOW
var steam : Color = Color.BLUE
var none : Color = Color.RED

@onready var leaderboard_tree : Tree = %LeaderboardList
@onready var entry_tree : Tree = %EntryList
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
	Mist.Leaderboards.on_get_leaderboard_entries.connect(_populate_entries)
	Mist.Config.data_updated.connect(_populate_leaderboards)
	leaderboard_tree.item_selected.connect(_tree_clicked)
	leaderboard_tree.set_column_title(0, "Name")
	leaderboard_tree.set_column_title(1, "ID")
	leaderboard_tree.set_column_title(2, "Community Name")
	Mist.Leaderboards.fetch_leaderboards()
	_populate_leaderboards()


func _populate_leaderboards() -> void:
	leaderboard_tree.clear()
	leaves.clear()
	root = leaderboard_tree.create_item()
	for _leaderboard : StringName in Mist.Config.data.Leaderboards:
		var leaf : TreeItem

		if leaves.has(_leaderboard):
			leaf = leaves[_leaderboard]
		else:
			leaf = leaderboard_tree.create_item(root)
			leaves[_leaderboard] = leaf
		leaf.set_text(0, _leaderboard)

		configure_node(_leaderboard)

func _populate_entries() -> void:
	entry_tree.clear()
	var entry_root = entry_tree.create_item()

	for entry : LeaderboardEntryData in leaderboard.entries:
		var leaf : TreeItem = entry_tree.create_item(entry_root)
		leaf.set_text(0, str(entry.rank))
		leaf.set_text(1, str(entry.steam_id)) #FIXME Go fetch the actual player
		leaf.set_text(2, str(entry.score))


func _get_leaderboard_key() -> StringName:
	return leaderboard_tree.get_selected().get_text(0)


func _get_leaderboard() -> LeaderboardData:
	return Mist.Config.data.Leaderboards[leaderboard_key]


func _tree_clicked() -> void:
	%name_edit.text = str(leaderboard_key)
	%community_name_data.text = str(leaderboard.leaderBoardDisplayName)
	%entries_data.text = str(leaderboard.entries_count)
	%id_edit.text = str(leaderboard.id)
	%display_type_edit.selected = leaderboard.display_type
	%sort_method_edit.selected = leaderboard.sort_method
	%only_trusted_writes_edit.button_pressed = leaderboard.only_trusted_writes
	%only_friends_reads_edit.button_pressed = leaderboard.only_friends_reads
	%only_users_in_same_party_edit.button_pressed = leaderboard.only_users_in_same_party
	%limit_global_top_entries_edit.value = leaderboard.limit_global_top_entries
	%limit_range_around_user_edit.value = leaderboard.limit_range_around_user
	%push_to_steam.disabled = false
	%delete_leaderboard.disabled = false
	%get_scores.disabled = false
	%reset_scores.disabled = false
	_populate_entries()

func configure_node(name: StringName) -> void:
	var leaderboard = Mist.Config.data.Leaderboards[name]
	if leaderboard.on_local and leaderboard.on_steam:
		leaves[name].set_custom_color(0, both)
	elif leaderboard.on_local:
		leaves[name].set_custom_color(0, local)
	elif leaderboard.on_steam:
		leaves[name].set_custom_color(0, steam)
	else:
		leaves[name].set_custom_color(0, none)

	leaves[name].set_text(1, str(leaderboard.id))
	leaves[name].set_text(2, leaderboard.leaderBoardDisplayName)

func _on_fetch_leaderboards_button_pressed() -> void:
	Mist.Leaderboards.fetch_leaderboards()


func _on_push_to_steam_pressed() -> void:
	(%push_to_steam as Button).icon = Mist.steam_icon
	var leaderboard_key : StringName = leaderboard_tree.get_selected().get_text(0)
	var leaderboard : LeaderboardData = Mist.Config.data.Leaderboards[leaderboard_key]
	Mist.Leaderboards.find_or_create_leaderboard(leaderboard)


func _on_delete_leaderboard_pressed() -> void:
	(%delete_leaderboard as Button).icon = Mist.steam_icon
	Mist.Leaderboards.delete_leaderboard(leaderboard)


func _on_get_scores_pressed() -> void:
	(%get_scores as Button).icon = Mist.steam_icon
	Mist.Leaderboards.get_leaderboard_entires(leaderboard, Mist.Leaderboards.RequestType.RequestGlobal)


func _on_reset_scores_pressed() -> void:
	pass # Replace with function body.
