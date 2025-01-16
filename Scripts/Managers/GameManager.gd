extends Node2D
# class_name GameManager
# Singleton

enum GameState {
	Starting,
	Buying,
	Fighting
}

# ============================== Public ==============================

var players: Array[Player]
var shopDeck: ShopDeck

# ============================== Public function ==============================

func gameSwitchTo(newGameState: GameState) -> void:
	if newGameState != _gameState:
		_gameState = newGameState
		_gameSwitchTo(_gameState)
	else:
		printerr("Game is already on ", _gameState, " state !")

# ============================== Private ==============================

var _gameState: GameState = GameState.Starting

var _buyingArea: PackedScene = preload("res://Scenes/Maps/BuyingArea.tscn")
var _fightingArea: PackedScene = preload("res://Scenes/Maps/FightingArea.tscn")

var _families: Array[Family]
var _rules: CardRules

# ============================== Node base functions ==============================

func _ready() -> void:
	print("GameManager ready !")
	players.append(Player.new())
	players[0].name = "Breep"
	players[0].deck = PlayerDeck.new()
	players[0].health = 30
	players[0].id = 0
	players[0].hero = load("res://Resources/Heros/JohnnyDefault/JohnnyDefault.tres").duplicate(true)
	players[0].gold = 10000
	
	_rules = load("res://Resources/RulesGame/NormalGameCardRules.tres")
	_families.append(load("res://Resources/Families/Attack/Attack.tres"))
	
	shopDeck = ShopDeck.new()
	shopDeck.construct_shopDeck(_families, _rules)
	shopDeck.shuffle()
	pass

# ============================== Private function ==============================

func _gameSwitchTo(newGameState: GameState) -> void:
	var newScene: PackedScene
	if newGameState == GameState.Buying:
		newScene = _buyingArea
	elif newGameState == GameState.Fighting:
		newScene = _fightingArea
	else:
		printerr("Unknown game state !")
		return
	
	get_tree().change_scene_to_packed(newScene)
