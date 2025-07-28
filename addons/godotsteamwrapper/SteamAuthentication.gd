class_name SteamAuthentication extends Object

func _init() -> void:
	Steam.get_auth_session_ticket_response.connect(_on_get_auth_session_ticket_response)
	Steam.validate_auth_ticket_response.connect(_on_validate_auth_ticket_response)

func _on_get_auth_session_ticket_response(this_auth_ticket: int, result: int) -> void:
	print("Auth session result: %s" % result)
	print("Auth session ticket handle: %s" % this_auth_ticket)

func _on_validate_auth_ticket_response(auth_id: int, response: int, owner_id: int) -> void:
	print("Ticket Owner: %s" % auth_id)

	# Make the response more verbose, highly unnecessary but good for this example
	var verbose_response: String = SteamStrings.AUTH[response]
	print("Auth response: %s" % verbose_response)
	print("Game owner ID: %s" % owner_id)
