extends Node

# TODO Move this to card shop ? Rename this into xp_shop ?

# ============================== Constants ==============================

const SERVER_ID = 1

# ============================== Public variables ==============================

enum ServerResponse {
	OK,                # No error
	NOT_ENOUGHT_MONEY, # Client doesn't have enought money to buy xp
	XP_ALREADY_MAX,    # Client try to buy xp but it is already max
}
var _server_response: ServerResponse

# ============================== Public functions ==============================

func try_buy_xp(player: Player) -> bool:
	Verbose.trace("try_buy_xp() | " + player.player_name, Verbose.Category.ORACLE_SHOP)
	if multiplayer.is_server():
		return _server_try_buy_xp(player)
	else:
		return await _client_try_buy_xp()

# ============================== Private functions ==============================

func _server_try_buy_xp(player: Player) -> bool:
	Verbose.trace("_server_try_buy_xp() | " + player.player_name, Verbose.Category.ORACLE_SHOP)
	if player.gold < GameManager.game_rules.buy_xp_price:
		Verbose.warn("Player:" + player.player_name + " is not rich enough (" + str(player.gold) + "<" + str(GameManager.game_rules.buy_xp_price), Verbose.Category.ORACLE_SHOP)
		return false
	
	if player.lvl == 10:
		Verbose.warn("Player: " + player.player_name + " has already max xp", Verbose.Category.ORACLE_SHOP)
		return false
	
	player.xp += GameManager.game_rules.xp_per_oracle_buy
	player.gold -= GameManager.game_rules.buy_xp_price
	return true


signal _answer_buy_xp_received()
func _client_try_buy_xp() -> bool:
	Verbose.trace("_client_try_buy_xp()", Verbose.Category.ORACLE_SHOP)
	_ask_buy_xp.rpc_id(SERVER_ID)
	await _answer_buy_xp_received
	
	match _server_response:
		ServerResponse.OK: return true
		ServerResponse.NOT_ENOUGHT_MONEY:
			Verbose.warn("Not enought money", Verbose.Category.ORACLE_SHOP)
			return false
		ServerResponse.XP_ALREADY_MAX:
			Verbose.warn("Player XP is already max", Verbose.Category.ORACLE_SHOP)
			return false
	
	# Unreachable
	return false


@rpc("any_peer", "call_remote", "reliable")
func _ask_buy_xp() -> void:
	Verbose.trace("_ask_buy_xp()", Verbose.Category.ORACLE_SHOP)
	if not multiplayer.is_server(): return
	var peer_id: int = multiplayer.get_remote_sender_id()
	var player: Player = PlayerManager.players[peer_id]
	
	if player.gold < GameManager.game_rules.buy_xp_price:
		Verbose.warn("Peer." + str(peer_id) + " is not rich enough (" + str(player.gold) + "<" + str(GameManager.game_rules.buy_xp_price), Verbose.Category.ORACLE_SHOP)
		_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.NOT_ENOUGHT_MONEY)
		return
	
	if player.lvl == 10:
		Verbose.warn("Peer." + str(peer_id) + " has already max xp")
		_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.XP_ALREADY_MAX)
		return
	
	player.xp += GameManager.game_rules.xp_per_oracle_buy
	player.gold -= GameManager.game_rules.buy_xp_price
	_answer_buy_card_from_player_shop.rpc_id(peer_id, ServerResponse.OK)


@rpc("authority", "call_remote", "reliable")
func _answer_buy_card_from_player_shop(server_response: ServerResponse) -> void:
	_server_response = server_response
	_answer_buy_xp_received.emit()
