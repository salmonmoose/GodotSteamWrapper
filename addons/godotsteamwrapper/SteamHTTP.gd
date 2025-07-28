class_name SteamHTTP extends Node

#Grants access to functions available here: https://partner.steamgames.com/doc/webapi_overview

const HTTP_ERRORS : Dictionary = {
	OK: "OK",
	ERR_UNCONFIGURED: "Unconfigured",
	ERR_BUSY: "Busy",
	ERR_INVALID_PARAMETER: "Invalid Parameter",
	ERR_CANT_CONNECT: "Can't Connect",
}

enum INTERFACES {
	IBroadcastService,
	ICheatReportingService,
	ICloudService,
	IEconMarketService,
	IEconService,
	IGameInventory,
	IGameNotificationsService,
	IGameServersService,
	IInventoryService,
	ILobbyMatchmakingService,
	IPlayerService,
	IPublishedFileService,
	ISiteLicenseService,
	ISteamApps,
	ISteamAppTicket,
	ISteamClient,
	ISteamCommunity,
	ISteamController,
	ISteamEconomy,
	ISteamFriends,
	ISteamGameCoordinator,
	ISteamGameServer,
	ISteamGameServerStats,
	ISteamHTMLSurface,
	ISteamHTTP,
	ISteamInput,
	ISteamInventory,
	ISteamLeaderboards,
	ISteamMatchmaking,
	ISteamMatchmakingServers,
	ISteamMicroTxn,
	ISteamMicroTxnSandbox,
	ISteamMusic,
	ISteamMusicRemote,
	ISteamNetworking,
	ISteamNetworkingSockets,
	ISteamNetworkingUtils,
	ISteamNews,
	ISteamPublishedItemSearch,
	ISteamPublishedItemVoting,
	ISteamRemotePlay,
	ISteamRemoteStorag,
	ISteamRemoteStorage,
	ISteamScreenshots,
	ISteamTimeline,
	ISteamUGC,
	ISteamUser,
	ISteamUserAuth,
	ISteamUserStats,
	ISteamUtils,
	ISteamVideo,
	ISteamWebAPIUtil,
	IWorkshopService,
	steam_api,
	steam_gameserver,
	SteamEncryptedAppTicket,
}

const API : String = "https://api.steampowered.com/%s/%s/v%s/"
const WEB_API: String = "https://partner.steam-api.com/%s/%s/v%s/"

static var web_api_key: String : get = _get_web_api_key

func _init() -> void:
	pass

static func _get_web_api_key() -> String:
	return SteamGlobal.get_setting(SteamLoader.WEB_API_KEY)

static func make_request(data : Dictionary, callback : Callable = Callable()):
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data.data)

	var query : Array[String]
	for key in data.data:
		query.push_back("%s=%s" % [key, data.data[key]])

	var HTTP = HTTPRequest.new()
	Mist.add_child(HTTP)

	if callback:
		print("found a callback", callback)
		HTTP.request_completed.connect(callback)
	else:
		HTTP.request_completed.connect(func(data): print(data))

	var error = HTTP.request(
		"%s?%s" % [data.url, "&".join(query)],
		headers,
		HTTPClient.METHOD_GET,
		json
	)

	if error != OK:
		push_error("An error occurred in the http request: %s" % HTTP_ERRORS[error])
