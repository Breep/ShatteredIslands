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
	print("GameManager ready !")
	players.append(Player.new())
	players[0].name = "Breep"
	players[0].deck = PlayerDeck.new()
	players[0].health = 30
	players[0].id = 0
	players[0].hero = load("res://Resources/Heros/JohnnyDefault/johnny_default.tres").duplicate(true)
	players[0].gold = 10000
	
	_rules = load("res://Resources/GameRules/NormalGameRules.tres")
	_families.append(load("res://Resources/Families/Attack/attack_family.tres"))
	
	shop_deck = ShopDeck.new()
	shop_deck.construct_shop_deck(_families, _rules)
	shop_deck.shuffle()
	pass

# ============================== Public function ==============================

func game_switch_to(new_game_state: GameState) -> void:
	if new_game_state != _game_state:
		_game_state = new_game_state
		_game_switch_to(_game_state)
	else:
		printerr("Game is already on ", _game_state, " state !")

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
