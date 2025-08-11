@tool
class_name MistMain extends Node

var is_running : bool : get = _is_steam_running
var steam_id : int : get = _get_steam_id
var steam_name : String : get = _get_steam_name
var is_owned: bool : get = _get_is_owned
var is_online : bool : get = _is_online
var is_on_steam_deck : bool : get = _is_on_steam_deck
var steam_avatar : Image : set = _set_steam_avatar
static var app_id : int : get = _get_app_id

var steam_icon = preload("uid://cphqhxb1xs8cl")

var auth_ticket: Dictionary
var client_auth_tickets: Array

var Leaderboards : MistLeaderboards
var Achievements : MistAchievements
var Lobby : MistLobbies
var Authentication : MistAuthentication
var P2P : MistP2P
var Controller : MistInput
var HTTP : MistHTTP
var Config : MistConfig
var Stats : MistStats

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

func _enter_tree() -> void:
	var steam_init_response: Dictionary = Steam.steamInitEx(app_id, true)
	print("Initializing Steam APP_ID %s: %s" % [app_id, SteamStrings.AUTH[steam_init_response.status]])

	HTTP = MistHTTP.new()
	Config = MistConfig.new()
	Leaderboards = MistLeaderboards.new()
	Stats = MistStats.new()
	Controller = MistInput.new()
	#Achievements = MistAchievements.new()
	#Lobby = MistLobbies.new()
	#Authentication = MistAuthentication.new()
	#P2P = MistP2P.new()



	if not is_owned:
		if OS.is_debug_build():
			push_warning("Game not owned on Steam")
		else:
			get_tree().quit()

	#SettingsGlobal.player.name = steam_name

	#Steam.avatar_loaded.connect(_avatar_loaded)
#
	#Steam.network_messages_session_request.connect(_on_network_messages_session_request)
	#Steam.network_messages_session_failed.connect(_on_network_messages_session_failed)

	#Steam.getPlayerAvatar()
#
	#auth_ticket = Steam.getAuthSessionTicket()

func _exit_tree() -> void:
	if Controller:
		Controller._exit()
	Steam.steamShutdown()

static func _get_app_id() -> int:
	return int(get_setting(SteamLoader.APP_ID))

func _process(_delta: float) -> void:
	Steam.runFrame()
	if Steam.newDataAvailable():
		Controller.emit_input_signals()
	Steam.run_callbacks()

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

# Grabs a setting from the project, or returns the plugin's default if it does not exist.
static func get_setting(setting: StringName) -> Variant:
	if ProjectSettings.has_setting(setting):
		return ProjectSettings.get_setting(setting)
	else:
		push_warning("Did not find a setting for %s" % setting)
		return SteamLoader.SETTINGS[setting]['default']

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
