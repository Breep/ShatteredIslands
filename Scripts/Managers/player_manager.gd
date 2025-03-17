extends Node

const MAX_PLAYERS: int = 8

var players: Dictionary # { player_id : Player }

# Add a player to the list of players
# If this is called on the server, the server will transmit this to every other players
@rpc("any_peer", "call_remote")
func add_player(player_name: String, id: int) -> void:
	print("[id:", multiplayer.get_unique_id(),"] Adding player: ", player_name, " of multiplayer id:", id, " in my players list")
	
	if players.has(id):
		return
	
	if players.size() >= MAX_PLAYERS:
		printerr("[id:", multiplayer.get_unique_id(),"] Too many players")
		return
	
	var new_player := Player.new()
	new_player.deck = PlayerDeck.new()
	new_player.name = player_name
	new_player.id = id
	new_player.ready = false
	
	# TMP
	new_player.hero = Shared.HEROES[Hero.HeroType.ANCIENT_TREE]
	new_player.gold = 500
	new_player.health = 30
	
	players[id] = new_player
	
	if multiplayer.is_server():
		for player in players.values():
			add_player.rpc(player.name, player.id)



@rpc("any_peer", "call_local")
func set_ready(peer_id: int , is_ready: bool) -> void:
	print("[id:", multiplayer.get_unique_id(),"] player ", peer_id, " is telling me that he is ready ? ", is_ready)
	players[peer_id].ready = is_ready


func get_local_player() -> Player:
	if not players.has(multiplayer.get_unique_id()):
		printerr(" No local player for player_id=", multiplayer.get_unique_id())
		return null
	return players[multiplayer.get_unique_id()]


func get_alive_players() -> Dictionary:
	var alive_players: Dictionary
	for player in players.values():
		if player.health > 0:
			alive_players[player.id] = player
	return alive_players


func all_players_are_ready() -> bool:
	for player in players.values():
		if player.ready == false:
			return false
	return true
