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

# ============================== Private ==============================

var _game_state: GameState = GameState.Starting

var _buying_area: PackedScene = preload("res://Scenes/Maps/buying_area.tscn")
var _fighting_area: PackedScene = preload("res://Scenes/Maps/fighting_area.tscn")

var _families_ref: Dictionary # Reference Dictionary to all families
var _active_families: Array[Family] # Array of all families activated for this game only
var _rules: GameRules

# ============================== Node base functions ==============================

func _ready() -> void:
	_rules = load("res://Resources/GameRules/NormalGameRules.tres")
	_init_families_ref()
	_active_families.append(get_family_from_type(Family.FamilyType.Attack))

# ============================== Public function ==============================

@rpc("any_peer", "call_local")
func game_switch_to(new_game_state: GameState) -> void:
	if new_game_state != _game_state:
		_game_state = new_game_state
		_game_switch_to(_game_state)
	else:
		printerr("Game is already on ", _game_state, " state !")


@rpc("any_peer", "call_remote")
func add_player(player_name: String, id: int) -> void:
	print("[id:", multiplayer.get_unique_id(),"] Adding player: ", player_name, " of multiplayer id:", id, " in my players list")
	
	if _is_player_registered(id):
		printerr("Player already registered")
		return
	
	if players.size() >= MAX_PLAYERS:
		printerr("Too many players")
		return
	
	var new_player := Player.new()
	new_player.deck = PlayerDeck.new()
	new_player.name = player_name
	new_player.id = id
	new_player.ready = false
	
	# TMP
	new_player.hero = load("res://Resources/Heros/JohnnyDefault/johnny_default.tres").duplicate(true)
	new_player.gold = 10000
	new_player.health = 30
	
	players.append(new_player)
	
	if multiplayer.is_server():
		for player in players:
			add_player.rpc(player.name, player.id)


@rpc("any_peer", "call_local")
func set_ready(peer_id: int , is_ready: bool) -> void:
	print("[id:", multiplayer.get_unique_id(),"] player ", peer_id, " is telling me that he is ready ? ", is_ready)
	for player in players:
		if player.id == peer_id:
			player.ready = is_ready


func get_local_player() -> Player:
	for player in players:
		if player.id == multiplayer.get_unique_id():
			return player
	
	printerr("No local player registered in the GameManager !")
	return null


@rpc("any_peer", "call_local")
func start_game() -> void:
	if not _all_player_are_ready():
		printerr("Not all player are ready !")
		return
	
	MultiplayerDeckManager.init_cards_ref(_active_families, _rules)
	if multiplayer.is_server():
		MultiplayerDeckManager.construct_shop_deck(_active_families, _rules)
	
	game_switch_to(GameState.Buying)


func get_family_from_type(family_type: Family.FamilyType) -> Family:
	return _families_ref[family_type]

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


func _all_player_are_ready() -> bool:
	for player in players:
		if player.ready == false:
			return false

	return true


func _init_families_ref() -> void:
	_families_ref[Family.FamilyType.Attack] = load("res://Resources/Families/Attack/attack_family.tres") as Family
	_families_ref[Family.FamilyType.Rock] = load("res://Resources/Families/Defense/defense_family.tres") as Family
	_families_ref[Family.FamilyType.Fire] = load("res://Resources/Families/Fire/fire_family.tres") as Family
	_families_ref[Family.FamilyType.Storm] = load("res://Resources/Families/Storm/storm_family.tres") as Family
	_families_ref[Family.FamilyType.Serinity] = load("res://Resources/Families/Heal/heal_family.tres") as Family
	_families_ref[Family.FamilyType.Life] = load("res://Resources/Families/Hp/hp_family.tres") as Family
	_families_ref[Family.FamilyType.Poison] = load("res://Resources/Families/Poison/poison_family.tres") as Family
	_families_ref[Family.FamilyType.Shadow] = load("res://Resources/Families/Shadow/shadow_family.tres") as Family
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
