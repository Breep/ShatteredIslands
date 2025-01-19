extends Node2D
# Global Singleton

# =============================================================
# =============================================================
# ====================                     ====================
# ====================     GameManager     ====================
# ====================                     ====================
# =============================================================
# =============================================================

enum GameState {
	Starting,
	Buying,
	Fighting
}

# ============================== Constants ==============================

const MAX_PLAYERS: int = 8

# ============================== Public ==============================

var players: Array[Player]
var shop_deck: ShopDeck

# ============================== Private ==============================

var _game_state: GameState = GameState.Starting

var _buying_area: PackedScene = preload("res://Scenes/Maps/buying_area.tscn")
var _fighting_area: PackedScene = preload("res://Scenes/Maps/fighting_area.tscn")

var _families: Array[Family]
var _rules: GameRules

# ============================== Node base functions ==============================

func _ready() -> void:
	_rules = load("res://Resources/GameRules/NormalGameRules.tres")
	_families.append(load("res://Resources/Families/Attack/attack_family.tres"))
	
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(_families, _rules)
	shop_deck.shuffle()
	pass

# ============================== Public function ==============================

@rpc("any_peer", "call_local")
func game_switch_to(new_game_state: GameState) -> void:
	if new_game_state != _game_state:
		_game_state = new_game_state
		_game_switch_to(_game_state)
	else:
		printerr("Game is already on ", _game_state, " state !")


@rpc("any_peer", "call_remote")
func add_player(name: String, id: int) -> void:
	print("Adding player: ", name, " of multiplayer id:", id, " in my players list (I am player id ", multiplayer.get_unique_id(), ")")
	
	if _is_player_registered(id):
		printerr("Player already registered")
		return
	
	if players.size() >= MAX_PLAYERS:
		printerr("Too many players")
		return
	
	var new_player := Player.new()
	new_player.deck = PlayerDeck.new()
	new_player.name = name
	new_player.id = id
	
	# TMP
	new_player.hero = load("res://Resources/Heros/JohnnyDefault/johnny_default.tres").duplicate(true)
	new_player.gold = 10000
	new_player.health = 30
	
	players.append(new_player)
	
	if multiplayer.is_server():
		for player in players:
			add_player.rpc(player.name, player.id)


func get_local_player() -> Player:
	for player in players:
		if player.id == multiplayer.get_unique_id():
			return player

	printerr("No local player registered in the GameManager !")
	return null

# ============================== Private function ==============================

func _game_switch_to(new_game_state: GameState) -> void:
	var new_scene: PackedScene
	if new_game_state == GameState.Buying:
		new_scene = _buying_area
	elif new_game_state == GameState.Fighting:
		new_scene = _fighting_area
	else:
		printerr("Unknown game state !")
		return
	
	get_tree().change_scene_to_packed(new_scene)


func _is_player_registered(id: int) -> bool:
	if players == null:
		return false
	
	for player in players:
		if player.id == id:
			return true
	
	return false
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
