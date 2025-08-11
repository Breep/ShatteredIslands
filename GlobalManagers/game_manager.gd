extends Node2D
# Global Singleton

# =============================================================
# =============================================================
# ====================                     ====================
# ====================     GameManager     ====================
# ====================                     ====================
# =============================================================
# =============================================================

# ============================== Constants ==============================

const HEROES_NUMBER: int = 8

# ============================== Public variables ==============================

var game_rules: GameRules
var active_families_type: Array[Family.FamilyType]

# ============================== Private variables ==============================

var _game_scene: PackedScene = preload("res://Game/game.tscn")

var _families_ref: Dictionary # Reference Dictionary to all families
var _active_families: Array[Family] # Array of all families activated for this game only

#[Server only]
var _game_heroes_ready: bool = false
signal _heroes_choosen()

# [Client only] Is emit when server has answered the local client request
signal _server_answered()

var _random_heroes_ref: Array[Hero.HeroId]

# ============================== Node base functions ==============================

func _ready() -> void:
	game_rules = load("res://Game/GameRules/NormalGameRules.tres")
	_init_families_ref()
	_active_families.append(get_family_from_type(Family.FamilyType.DEFENSE))
	active_families_type.append(Family.FamilyType.DEFENSE)
	_active_families.append(get_family_from_type(Family.FamilyType.POISON))
	active_families_type.append(Family.FamilyType.POISON)
	_active_families.append(get_family_from_type(Family.FamilyType.FIRE))
	active_families_type.append(Family.FamilyType.FIRE)
	_active_families.append(get_family_from_type(Family.FamilyType.ATTACK))
	active_families_type.append(Family.FamilyType.ATTACK)

# ============================== Public function ==============================

func get_current_game_heroes() -> Array[Hero]:
	if multiplayer.is_server():
		_init_current_current_game_heroes(HEROES_NUMBER)
	else:
		_ask_get_n_random_heroes.rpc_id(1, multiplayer.get_unique_id())
		await _server_answered
	
	var random_heroes: Array[Hero]
	for hero_ref in _random_heroes_ref:
		random_heroes.append(Shared.HEROES[hero_ref])
	
	return random_heroes


@rpc("any_peer", "call_local")
func start_game() -> void:
	MultiplayerDeckManager.init_cards_ref(_active_families, game_rules)
	if multiplayer.is_server():
		MultiplayerDeckManager.construct_shop_deck(_active_families, game_rules)
	
	get_tree().change_scene_to_packed(_game_scene)


func get_family_from_type(family_type: Family.FamilyType) -> Family:
	return _families_ref[family_type]


# [Client only]
signal _server_hero_pickup_order_answered

# [Server only]
signal _hero_pickup_order_choosen
var _hero_pickup_order_ready: bool
var _hero_pickup_order_players: Array[Player]

func get_hero_pickup_order() -> Array[Player]:
	if multiplayer.is_server():
		_init_hero_pickup_order()
		return _hero_pickup_order_players
	else:
		_ask_hero_pickup_order.rpc_id(1, multiplayer.get_unique_id())
		await _server_hero_pickup_order_answered
		return _hero_pickup_order_players


func _init_hero_pickup_order() -> void:
	var players_dup := PlayerManager.players.duplicate()
	
	for i in players_dup.size():
		var random_player_id = players_dup.keys().pick_random()
		_hero_pickup_order_players.append(players_dup[random_player_id])
		players_dup.erase(random_player_id)
	
	_hero_pickup_order_ready = true
	_hero_pickup_order_choosen.emit()


@rpc("any_peer", "call_remote")
func _ask_hero_pickup_order(peer_id: int) -> void:
	if not multiplayer.is_server():
		printerr("GameManager: Only the server can choose the hero pickup order")
		return
	
	if not _hero_pickup_order_ready:
		await _hero_pickup_order_choosen
	
	var _hero_pickup_order_player_ids: Array[int]
	for player in _hero_pickup_order_players:
		_hero_pickup_order_player_ids.append(player.id)
	
	_answer_hero_pickup_order.rpc_id(peer_id, _hero_pickup_order_player_ids)


@rpc("authority", "call_remote")
func _answer_hero_pickup_order(hero_pickup_order_player_ids: Array[int]) -> void:
	for player_id in hero_pickup_order_player_ids:
		_hero_pickup_order_players.append(PlayerManager.players[player_id])
	_server_hero_pickup_order_answered.emit()


# ============================== Private function ==============================

func _init_families_ref() -> void:
	_families_ref[Family.FamilyType.ATTACK] = load("res://Card/Descriptions/Families/attack_family.tres") as Family
	_families_ref[Family.FamilyType.DEFENSE] = load("res://Card/Descriptions/Families/defense_family.tres") as Family
	_families_ref[Family.FamilyType.FIRE] = load("res://Card/Descriptions/Families/fire_family.tres") as Family
	#_families_ref[Family.FamilyType.STORM] = load("res://Resources/Families/storm_family.tres") as Family
	#_families_ref[Family.FamilyType.SERENITY] = load("res://Resources/Families/heal_family.tres") as Family
	#_families_ref[Family.FamilyType.Life] = load("res://Resources/Families/life_family.tres") as Family
	_families_ref[Family.FamilyType.POISON] = load("res://Card/Descriptions/Families/poison_family.tres") as Family

# ============================== RPC - Ask/Answer current round battle ==============================

@rpc("any_peer", "call_remote")
func _ask_get_n_random_heroes(peer_id: int) -> void:
	if not multiplayer.is_server():
		printerr("Only server should be asked for random heroes")
		return
	
	if not _game_heroes_ready:
		await _heroes_choosen
	
	_answer_get_n_random_heroes.rpc_id(peer_id, _random_heroes_ref)


@rpc("authority", "call_remote")
func _answer_get_n_random_heroes(heroes_ref: Array[Hero.HeroId]) -> void:
	_random_heroes_ref = heroes_ref
	_server_answered.emit()

# ============================== Private functions ==============================

func _init_current_current_game_heroes(heroes_number: int) -> void:
	if heroes_number <= 0 or heroes_number > Shared.HEROES.size():
		printerr("Hero: Wrong heroes_number: ", heroes_number)
		return
	
	# TODO Disabled for the moment
	#var heroes_ref: Array[Hero.HeroId]
	#for hero_ref in Shared.HEROES.keys():
		#heroes_ref.append(hero_ref)
	#
	#var rng := RandomNumberGenerator.new()
	#rng.randomize()
	#for i in heroes_number:
		#var random_index: int = rng.randi_range(0, heroes_ref.size() - 1)
		#_random_heroes_ref.append(heroes_ref.get(random_index))
		#heroes_ref.remove_at(random_index)
	
	_random_heroes_ref.append(Hero.HeroId.DARK_KNIGHT)
	_heroes_choosen.emit()
	_game_heroes_ready = true

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
