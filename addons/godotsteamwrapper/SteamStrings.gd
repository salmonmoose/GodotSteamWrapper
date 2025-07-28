class_name SteamStrings extends Node

const AUTH : Dictionary[int, String] = {
	Steam.AUTH_SESSION_RESPONSE_OK : "Authentication Successful",
	Steam.AUTH_SESSION_RESPONSE_USER_NOT_CONNECTED_TO_STEAM: "User not connected to Steam",
	Steam.AUTH_SESSION_RESPONSE_NO_LICENSE_OR_EXPIRED: "No License",
	Steam.AUTH_SESSION_RESPONSE_VAC_BANNED: "Banned",
	Steam.AUTH_SESSION_RESPONSE_LOGGED_IN_ELSEWHERE: "Logged in elsewhere",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_CANCELED: "Ticket cancelled",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID_ALREADY_USED: "Ticket already used",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID: "Ticked invalid",
	Steam.AUTH_SESSION_RESPONSE_PUBLISHER_ISSUED_BAN: "Banned by publisher",
	Steam.AUTH_SESSION_RESPONSE_VAC_CHECK_TIMED_OUT: "VAC has been unable to perform anti-cheat checks on this user.",
	Steam.AUTH_SESSION_RESPONSE_AUTH_TICKET_NETWORK_IDENTITY_FAILURE: "AUTH_SESSION_RESPONSE_AUTH_TICKET_NETWORK_IDENTITY_FAILURE",
}

const LOBBY : Dictionary[int, String] = {
	Steam.LOBBY_TYPE_PRIVATE : 'Private',
	Steam.LOBBY_TYPE_FRIENDS_ONLY : 'Friends Only',
	Steam.LOBBY_TYPE_PUBLIC : 'Public',
	Steam.LOBBY_TYPE_INVISIBLE : 'Invisible',
}

const CHAT_ROOM : Dictionary[int, String] = {
	Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST : "This lobby no longer exists.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED : "You don't have permission to join this lobby.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_FULL : "The lobby is now full.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR : "Uh... something unexpected happened!",
	Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED : "You are banned from this lobby.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED : "You cannot join due to having a limited account.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED : "This lobby is locked or disabled.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN : "This lobby is community locked.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU : "A user in the lobby has blocked you from joining.",
	Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER : "A user you have blocked is in the lobby.",
}

const CHAT_MEMBER : Dictionary[int, String] = {
	Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED: "%s has joined the lobby.",
	Steam.CHAT_MEMBER_STATE_CHANGE_LEFT: "%s has left the lobby.",
	Steam.CHAT_MEMBER_STATE_CHANGE_KICKED: "%s has been kicked from the lobby.",
	Steam.CHAT_MEMBER_STATE_CHANGE_BANNED: "%s has been banned from the lobby.",
}

const P2P_SESSION : Dictionary[int, String] = {
	Steam.P2P_SESSION_ERROR_NONE : "Session failure with no error given",
	Steam.P2P_SESSION_ERROR_NOT_RUNNING_APP: "Session failure: target user not running the same game",
	Steam.P2P_SESSION_ERROR_NO_RIGHTS_TO_APP: "Session failure: local user doesn't own app / game",
	Steam.P2P_SESSION_ERROR_DESTINATION_NOT_LOGGED_ON: "Session failure: target user isn't connected to Steam",
	Steam.P2P_SESSION_ERROR_TIMEOUT: "Session failure: connection timed out",
	Steam.P2P_SESSION_ERROR_MAX : "Session failure: unused",
}

const INPUT_TYPE : Dictionary[int, String] = {
	Steam.INPUT_TYPE_UNKNOWN: "Unknown",
	Steam.INPUT_TYPE_STEAM_CONTROLLER: "Steam Controller",
	Steam.INPUT_TYPE_XBOX360_CONTROLLER: "XBox 360 Controller",
	Steam.INPUT_TYPE_XBOXONE_CONTROLLER: "XBox One Controller",
	Steam.INPUT_TYPE_GENERIC_XINPUT: "Generic X-Input",
	Steam.INPUT_TYPE_PS4_CONTROLLER: "PS4 Controller",
	Steam.INPUT_TYPE_APPLE_MFI_CONTROLLER: "Apple MFI Controller",
	Steam.INPUT_TYPE_ANDROID_CONTROLLER: "Android Controller",
	Steam.INPUT_TYPE_SWITCH_JOYCON_PAIR: "Switch Joycon Pair",
	Steam.INPUT_TYPE_SWITCH_JOYCON_SINGLE: "Switch Joycon Single",
	Steam.INPUT_TYPE_SWITCH_PRO_CONTROLLER: "Switch Pro Controller",
	Steam.INPUT_TYPE_MOBILE_TOUCH: "Mobile Touch",
	Steam.INPUT_TYPE_PS3_CONTROLLER: "PS3 Controller",
	Steam.INPUT_TYPE_PS5_CONTROLLER: "PS5 Controller",
	Steam.INPUT_TYPE_STEAM_DECK_CONTROLLER: "Steam Deck",
	Steam.INPUT_TYPE_COUNT: "Controller Count",
	Steam.INPUT_TYPE_MAXIMUM_POSSIBLE_VALUE: "Maximum Controllers",
}
