class_name SteamLobbies extends Node

var lobby_id: int : get = _get_lobby_id, set = _set_lobby_id
var currentLobby : LobbyData
var lobby_members : Array[PlayerData] : get = _get_lobby_members
var _lobby_members : Array[PlayerData]

var lobby_list_dirty : bool = false
var lobby_list : Dictionary = {}
var lobbies : Dictionary : get = _get_lobbies
var is_host : bool : get = _get_is_host

var lobbyTypes : Dictionary = {

}

func _init() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_message.connect(_on_lobby_message)
	Steam.persona_state_change.connect(_on_persona_change)

func _get_lobby_id() -> int:
	if currentLobby:
		return currentLobby.id
	else:
		return 0

func _set_lobby_id(value: int) -> void:
	if currentLobby:
		currentLobby.id = value

func _get_lobbies() -> Dictionary:
	lobby_list_dirty = false
	return lobby_list

func _get_is_host() -> bool:
	if lobby_id > 0:
		var lobby_owner : int = Steam.getLobbyOwner(lobby_id)
		return lobby_owner == Mist.steam_id

	return false
func _get_lobby_members() -> Array[PlayerData]:
	_lobby_members.sort_custom(_compare_lobby_members)
	return _lobby_members

func _compare_lobby_members(a: PlayerData, b: PlayerData) -> bool:
	if a.id == Steam.getLobbyOwner(lobby_id):
		return true
	if b.id == Steam.getLobbyOwner(lobby_id):
		return false

	return a.id < b.id

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	var owner_name: String = Steam.getFriendPersonaName(friend_id)

	print("Joining %s's lobby..." % owner_name)

	join_lobby(this_lobby_id)

func _on_lobby_match_list(these_lobbies: Array) -> void:
	Console.print_line("Got new set of %s lobbies" % these_lobbies.size())
	lobby_list_dirty = true
	lobby_list.clear()
	for this_lobby : int in these_lobbies:
		var lobbyData : LobbyData = LobbyData.new()
		lobbyData.name = Steam.getLobbyData(this_lobby, "name")
		lobbyData.mode = Steam.getLobbyData(this_lobby, "mode")
		lobbyData.players = Steam.getNumLobbyMembers(this_lobby)
		lobbyData.id = this_lobby

		lobby_list[this_lobby] = lobbyData

func get_lobbies() -> void:
	Console.print_line("Getting Lobbies")
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_CLOSE)
	Steam.addRequestLobbyListResultCountFilter(5)
	#Steam.addRequestLobbyListStringFilter(hash, ProjectSettings.get_setting("application/config/version"), Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func send_lobby_chat_message(message: String) -> bool:
	if message.length() > 0:
		var was_sent: bool = Steam.sendLobbyChatMsg(lobby_id, message)

		if not was_sent:
			Console.print_line("ERROR: Chat message failed to sned")

		return was_sent
	return false

func join_lobby(this_lobby_id: int) -> void:
	Console.print_line("Attempting to join lobby %s" % lobby_id)

	_lobby_members.clear()

	Steam.joinLobby(this_lobby_id)

func create_lobby(lobby: LobbyData) -> void:
	if lobby_id == 0:
		currentLobby = lobby
		Steam.createLobby(lobby.lobbyType, lobby.players)

func exit_lobby() -> void:
	Console.print_line("Leaving lobby %s" % currentLobby.id)
	Steam.leaveLobby(currentLobby.id)
	currentLobby = null

func get_lobby_members() -> void:
	Console.print_line("Getting Members")
	_lobby_members = []

	var num_of_members : int = Steam.getNumLobbyMembers(lobby_id)
	for this_member : int in range(0, num_of_members):
		var member : PlayerData = PlayerData.new()
		member.id = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		member.name = Steam.getFriendPersonaName(member.id)
		Steam.getPlayerAvatar(2, member.id as int)

		Console.print_line("Found user %s" % [member.id, member.name])

		_lobby_members.append(member)

	Mist.lobby_members_update.emit()

func _on_lobby_created(connect_result: int, this_lobby_id: int) -> void:
	if connect_result == 1:
		lobby_id = this_lobby_id

		Console.print_line("Created a lobby: %s" % lobby_id)

		Steam.setLobbyJoinable(lobby_id, true)

		Steam.setLobbyData(lobby_id, "name", currentLobby.name)
		Steam.setLobbyData(lobby_id, Mist.game_hash, "%s" % ProjectSettings.get_setting("application/config/version"))

		var set_relay : bool = Steam.allowP2PPacketRelay(true)

		Console.print_line("Allowing Steam to be relay backup; %s" % set_relay)

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		Console.print_line("Joined lobby: %s" % this_lobby_id)

		currentLobby = LobbyData.new()
		currentLobby.id = this_lobby_id
		currentLobby.name = Steam.getLobbyData(this_lobby_id, "name")

		get_lobby_members()

		Mist.P2P.make_p2p_handshake()

		#(Interface as MainMenu).show_lobby()
		Mist.lobby_joined.emit()

	else:
		var fail_reason : String = SteamStrings.CHAT_ROOM[response]

		Console.print_line("Failed to join this chat room: %s" % fail_reason)

func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	if lobby_id > 0:
		var username : String = Steam.getFriendPersonaName(this_steam_id)
		Console.print_line("%s had information change, update the lobby list" % username)

		get_lobby_members()

func _on_lobby_chat_update(_this_lobby_id: int, steam_id: int, _making_change_id: int, chat_state: int) -> void:
	var changer_name : String = Steam.getFriendPersonaName(steam_id)
	var message : String = SteamStrings.CHAT_ROOM[chat_state]

	Mist.send_message.emit(message % changer_name, steam_id)

	get_lobby_members()

func _on_lobby_message(_result: int, steam_id: int, message: String, type: int) -> void:
	var _this_sender : String = Steam.getFriendPersonaName(steam_id)

	if type == 1:
		if message.begins_with('/'):
			#Parse chat commands
			if steam_id == Steam.getLobbyOwner(lobby_id):
				#Admin commands
				if message.begins_with("/kick"):
					pass
					## Get the user ID for kicking
					#var these_commands: PoolStringArray = message.split(":", true)
					## If this is your ID, leave the lobby
					#if Global.steam_id == int(these_commands[1]):
						#_on_leave_lobby_pressed()
			pass

		else:
			Mist.send_message.emit(message, steam_id)
