class_name SteamAuthentication extends Object

var AuthSessionResponse : Dictionary = {
		Steam.AUTH_SESSION_RESPONSE_OK: "Steam has verified the user is online, the ticket is valid and ticket has not been reused.",
		Steam.AUTH_SESSION_RESPONSE_USER_NOT_CONNECTED_TO_STEAM: "The user in question is not connected to Steam.",
		Steam.AUTH_SESSION_RESPONSE_NO_LICENSE_OR_EXPIRED: "The user doesn't have a license for this App ID or the ticket has expired.",
		Steam.AUTH_SESSION_RESPONSE_VAC_BANNED: "The user is VAC banned for this game.",
		Steam.AUTH_SESSION_RESPONSE_LOGGED_IN_ELSEWHERE: "The user account has logged in elsewhere and the session containing the game instance has been disconnected.",
		Steam.AUTH_SESSION_RESPONSE_VAC_CHECK_TIMED_OUT: "VAC has been unable to perform anti-cheat checks on this user.",
		Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_CANCELED: "The ticket has been canceled by the issuer.",
		Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID_ALREADY_USED: "This ticket has already been used, it is not valid.",
		Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID: "This ticket is not from a user instance currently connected to steam.",
		Steam.AUTH_SESSION_RESPONSE_PUBLISHER_ISSUED_BAN: "The user is banned for this game. The ban came via the Web API and not VAC.",
		Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_NETWORK_IDENTITY_FAILURE: "AUTH_SESSION_RESPONSE_AUTH_TICKET_NETWORK_IDENTITY_FAILURE",
}

func _init() -> void:
	Steam.get_auth_session_ticket_response.connect(_on_get_auth_session_ticket_response)
	Steam.validate_auth_ticket_response.connect(_on_validate_auth_ticket_response)

func _on_get_auth_session_ticket_response(this_auth_ticket: int, result: int) -> void:
	print("Auth session result: %s" % result)
	print("Auth session ticket handle: %s" % this_auth_ticket)

func _on_validate_auth_ticket_response(auth_id: int, response: int, owner_id: int) -> void:
	print("Ticket Owner: %s" % auth_id)

	# Make the response more verbose, highly unnecessary but good for this example
	var verbose_response: String = AuthSessionResponse[response]
	print("Auth response: %s" % verbose_response)
	print("Game owner ID: %s" % owner_id)
