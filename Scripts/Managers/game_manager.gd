extends Node2D
# Global Singleton

# =============================================================
# =============================================================
# ====================                     ====================
# ====================     GameManager     ====================
# ====================                     ====================
# =============================================================
# =============================================================

# ============================== Enum ==============================

enum GameState {
	Starting,
	Buying,
	Fighting
}

# ============================== Private variables ==============================

var _game_scene: PackedScene = preload("res://Scenes/Game/game.tscn")

var _families_ref: Dictionary # Reference Dictionary to all families
var _active_families: Array[Family] # Array of all families activated for this game only
var _rules: GameRules

#[Server only]
var _game_heroes_ready: bool = false
signal _heroes_choosen()

# [Client only] Is emit when server has answered the local client request
signal _server_answered()

var _random_heroes_ref: Array[Hero.HeroType]

# ============================== Node base functions ==============================

func _ready() -> void:
	_rules = load("res://Resources/GameRules/NormalGameRules.tres")
	_init_families_ref()
	_active_families.append(get_family_from_type(Family.FamilyType.Serenity))
	#_active_families.append(get_family_from_type(Family.FamilyType.Life))
	_active_families.append(get_family_from_type(Family.FamilyType.Fire))

# ============================== Public function ==============================

func get_n_random_heroes(heroes_number: int) -> Array[Hero]:
	if multiplayer.is_server():
		_init_current_current_game_heroes(heroes_number)
	else:
		_ask_get_n_random_heroes.rpc_id(1, multiplayer.get_unique_id(), heroes_number)
		await _server_answered
	
	var random_heroes: Array[Hero]
	for hero_ref in _random_heroes_ref:
		random_heroes.append(Shared.HEROES[hero_ref])
	
	return random_heroes


@rpc("any_peer", "call_local")
func start_game() -> void:
	if not PlayerManager.all_players_are_ready():
		printerr("[id:", multiplayer.get_unique_id(),"] Not all player are ready !")
		return
	
	MultiplayerDeckManager.init_cards_ref(_active_families, _rules)
	if multiplayer.is_server():
		MultiplayerDeckManager.construct_shop_deck(_active_families, _rules)
	
	get_tree().change_scene_to_packed(_game_scene)


func get_family_from_type(family_type: Family.FamilyType) -> Family:
	return _families_ref[family_type]




# ============================== Private function ==============================

func _init_families_ref() -> void:
	_families_ref[Family.FamilyType.Attack] = load("res://Resources/Families/attack_family.tres") as Family
	_families_ref[Family.FamilyType.Defense] = load("res://Resources/Families/defense_family.tres") as Family
	_families_ref[Family.FamilyType.Fire] = load("res://Resources/Families/fire_family.tres") as Family
	_families_ref[Family.FamilyType.Storm] = load("res://Resources/Families/storm_family.tres") as Family
	_families_ref[Family.FamilyType.Serenity] = load("res://Resources/Families/heal_family.tres") as Family
	_families_ref[Family.FamilyType.Life] = load("res://Resources/Families/hp_family.tres") as Family
	_families_ref[Family.FamilyType.Poison] = load("res://Resources/Families/poison_family.tres") as Family
	_families_ref[Family.FamilyType.Shadow] = load("res://Resources/Families/shadow_family.tres") as Family

# ============================== RPC - Ask/Answer current round battle ==============================

@rpc("any_peer", "call_remote")
func _ask_get_n_random_heroes(peer_id: int, heroes_number: int) -> void:
	if not multiplayer.is_server():
		printerr("Only server should be asked for random heroes")
		return
	
	if not _game_heroes_ready:
		await _heroes_choosen
	
	_answer_get_n_random_heroes.rpc_id(peer_id, _random_heroes_ref)


@rpc("authority", "call_remote")
func _answer_get_n_random_heroes(heroes_ref: Array[Hero.HeroType]) -> void:
	_random_heroes_ref = heroes_ref
	_server_answered.emit()
	pass

# ============================== Private functions ==============================

func _init_current_current_game_heroes(heroes_number: int) -> void:
	if heroes_number <= 0 or heroes_number > Shared.HEROES.size():
		printerr("Hero: Wrong heroes_number: ", heroes_number)
		return
	
	var heroes_ref: Array[Hero.HeroType]
	for hero_ref in Shared.HEROES.keys():
		heroes_ref.append(hero_ref)
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in heroes_number:
		var random_index: int = rng.randi_range(0, heroes_ref.size() - 1)
		_random_heroes_ref.append(heroes_ref.get(random_index))
		heroes_ref.remove_at(random_index)
	
	_heroes_choosen.emit()
	_game_heroes_ready = true

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
