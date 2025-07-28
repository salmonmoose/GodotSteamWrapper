class_name SteamGlobal extends Node

var is_running : bool : get = _is_steam_running
var steam_id : int : get = _get_steam_id
var steam_name : String : get = _get_steam_name
var is_owned: bool : get = _get_is_owned
var is_online : bool : get = _is_online
var is_on_steam_deck : bool : get = _is_on_steam_deck
var steam_avatar : Image : set = _set_steam_avatar

var number_of_friends : int : get = _number_of_friends

var auth_ticket: Dictionary
var client_auth_tickets: Array

var Leaderboard : SteamLeaderboards
var Achievement : SteamAchievements
var Lobby : SteamLobbies
var Authentication : SteamAuthentication
var P2P : SteamP2P
var Controller : SteamInput

enum {
	HOST,
	CLIENT,
	VOICE,
}

var game_hash : String = "9fa47249_DELVE"

signal lobby_joined
signal send_message
signal lobby_members_update
signal fire_achievement(achievment_name: String)
signal set_int_stat(stat_name: String, value: int)
signal set_float_stat(stat_name: String, value: float)

var AuthSessionResponse : Dictionary = {
	Steam.AUTH_SESSION_RESPONSE_OK : "Authentication Successful",
	Steam.AUTH_SESSION_RESPONSE_USER_NOT_CONNECTED_TO_STEAM: "User not connected to Steam",
	Steam.AUTH_SESSION_RESPONSE_NO_LICENSE_OR_EXPIRED: "No License",
	Steam.AUTH_SESSION_RESPONSE_VAC_BANNED: "Banned",
	Steam.AUTH_SESSION_RESPONSE_LOGGED_IN_ELSEWHERE: "Logged in elsewhere",
#	Steam.AUTH_SESSION_RESPONSE_VAC_CHECK_TIMEDOUT: "Timed out",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_CANCELED: "Ticket cancelled",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID_ALREADY_USED: "Ticket already used",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID: "Ticked invalid",
	Steam.AUTH_SESSION_RESPONSE_PUBLISHER_ISSUED_BAN: "Banned by publisher",
}

func _enter_tree() -> void:
	#var _steam_init_response : Dictionary = Steam.steamInitEx(true, 480) #SpaceWar
	var steam_init_response: Dictionary = Steam.steamInitEx(486390, true) #Delve

	Console.print_info("Initializing Steam: %s" % (AuthSessionResponse[steam_init_response.status]))

	Leaderboard = SteamLeaderboards.new()
	Achievement = SteamAchievements.new()
	Lobby = SteamLobbies.new()
	Authentication = SteamAuthentication.new()
	P2P = SteamP2P.new()
	Controller = SteamInput.new()

	if not is_owned:
		if OS.is_debug_build():
			Console.print_warning("Game not owned on Steam")
		else:
			get_tree().quit()

	SettingsGlobal.player.name = steam_name

	Steam.avatar_loaded.connect(_avatar_loaded)

	Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	Steam.network_messages_session_failed.connect(_on_network_messages_session_failed)

	Steam.getPlayerAvatar()

	auth_ticket = Steam.getAuthSessionTicket()

func _exit_tree() -> void:
	Controller._exit()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	if (Controller):
		Controller.emit_input_signals()
	if Lobby.currentLobby and Lobby.currentLobby.id > 0:
		P2P.read_all_p2p_packets()

func _on_network_messages_session_request(this_identity: String) -> void:
	var this_id: String = this_identity.split(':', true)[1]

	if int(this_id) != steam_id:
		pass

func _on_network_messages_session_failed() -> void:
	pass

func _player_index(_steam_id: int) -> int:
	for index : int in range(Lobby.lobby_members.size()):
		if (Lobby.lobby_members[index] as PlayerData).id == _steam_id:
			return index

	return -1

func _set_steam_avatar(texture: Image) -> void:
	steam_avatar = texture
	SettingsGlobal.player.avatar = texture

func _get_is_owned() -> bool:
	return Steam.isSubscribed()

func _is_online() -> bool:
	return Steam.loggedOn()

func _number_of_friends() -> int:
	return Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)

func _is_on_steam_deck() -> bool:
	return Steam.isSteamRunningOnSteamDeck()

func _is_steam_running() -> bool:
	return Steam.isSteamRunning()

func _get_steam_id() -> int:
	return Steam.getSteamID()

func _get_steam_name() -> String:
	return Steam.getPersonaName()

func _avatar_loaded(id:int, size:int, buffer:PackedByteArray) -> void:
	if id == steam_id:
		steam_avatar = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)

	for lobby_member : PlayerData in Lobby.lobby_members:
		if lobby_member.id == id:
			lobby_member.avatar = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)



func get_friends() -> Array[PlayerData]:
	var _friends : Array[PlayerData] = []

	for i : int in range(0, Steam.getFriendCount()):
		var friend_id : int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var online : int = Steam.getFriendPersonaState(friend_id)
		var friend : PlayerData = PlayerData.new()

		friend.online = true if online == 1 else false
		#friend.game = Steam.getFriendGamePlayed(friend_id)
		friend.name = Steam.getFriendPersonaName(friend_id)
		friend.id = friend_id

		_friends.push_back(friend)

	return _friends
