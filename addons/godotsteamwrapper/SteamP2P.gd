class_name SteamP2P extends Object

const PACKET_READ_LIMIT: int = 32



func _init() -> void:
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)

func make_p2p_handshake() -> void:
	Console.print_line("Sending P2P handshake to the lobby")

	send_p2p_packet(0, {"message": "handshake", "from": Mist.steam_id})

func _on_p2p_session_request(remote_id: int) -> void:
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	print("%s is requesting a P2P session" % this_requester)

	if not Steam.acceptP2PSessionWithUser(remote_id):
		print("Failed to accept P2P session from %s (%s)" % [this_requester, remote_id])

	make_p2p_handshake()

func _on_p2p_session_connect_fail(steam_id: int, session_error: int) -> void:
	print("%s %s" % [SteamStrings.P2P_SESSION[session_error], steam_id])

func read_all_p2p_packets(read_count: int = 0) -> void:
	if read_count >= PACKET_READ_LIMIT:
		return

	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)

	if packet_size > 0:
		var this_packet : Dictionary = Steam.readP2PPacket(packet_size, 0)

		if this_packet.is_empty() or this_packet == null:
			print("WARNING: read an empty packet with non-zero size!")

		var _packet_sender : int = this_packet['remote_steam_id']

		var packet_code : PackedByteArray = this_packet['data']

		var readable_data: Dictionary = bytes_to_var(packet_code.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))

		print("Packet: %s" % readable_data)

func send_p2p_packet(this_target: int, packet_data: Dictionary) -> void:
	var send_type: int = Steam.P2P_SEND_RELIABLE
	var channel: int = 0

	var this_data: PackedByteArray
	var compressed_data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)

	this_data.append_array(var_to_bytes(compressed_data))

	if this_target == 0:
		if Mist.Lobby.lobby_members.size() > 1:
			for this_member : PlayerData in Mist.Lobby.lobby_members:
				if this_member['steam_id'] != Mist.steam_id:
					Steam.sendP2PPacket(this_member['steam_id'] as int, this_data, send_type, channel)

	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, channel)
