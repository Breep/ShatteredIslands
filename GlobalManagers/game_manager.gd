extends Node

# ============================== Signals ==============================

# ============================== Enum ==============================

enum GameType {
	UNDEF,
	SOLO,
	MULTIPLAYER
}

# ============================== Constants ==============================

const HEROES_NUMBER: int = 8
const ACCELERATED_FIGHT_TIME_SCALE = 2.0

# ============================== Public variables ==============================

var _game_rules: GameRules
var game_rules: GameRules:
	get: return _game_rules

var _game_type: GameType
var game_type: GameType:
	get: return _game_type

var _active_families: Array[Family] # Array of all families activated for this game only
var active_families: Array[Family]:
	get: return _active_families

var _game_state_timer: Timer
var game_state_timer: Timer:
	get: return _game_state_timer

signal game_state_changed(game_state: Game.GameState)
var _game_state: Game.GameState
var game_state: Game.GameState:
	get: return _game_state
	set(value):
		if _game_state == value: return
		_game_state = value
		game_state_changed.emit(_game_state)

# ============================== Private variables ==============================

var __prototyping: bool = false

var _game_scene: PackedScene = load("res://Game/game.tscn")

var _FAMILIES_REF: Dictionary[Family.FamilyType, Family] = {
	Family.FamilyType.ATTACK: load("res://Card/Descriptions/Families/attack_family.tres") as Family,
	Family.FamilyType.DEFENSE: load("res://Card/Descriptions/Families/defense_family.tres") as Family,
	Family.FamilyType.FIRE: load("res://Card/Descriptions/Families/fire_family.tres") as Family,
	Family.FamilyType.POISON: load("res://Card/Descriptions/Families/poison_family.tres") as Family,
	Family.FamilyType.STORM: load("res://Card/Descriptions/Families/storm_family.tres") as Family,
	Family.FamilyType.SERENITY: load("res://Card/Descriptions/Families/serenity_family.tres") as Family,
	Family.FamilyType.LIFE: load("res://Card/Descriptions/Families/life_family.tres") as Family,
	Family.FamilyType.MANA: load("res://Card/Descriptions/Families/mana_family.tres") as Family,
	Family.FamilyType.CHICKEN: load("res://Card/Descriptions/Families/chickenlord_family.tres") as Family,
	Family.FamilyType.LIGHTNING: load("res://Card/Descriptions/Families/lightning_family.tres") as Family,
	Family.FamilyType.NECROSIS: load("res://Card/Descriptions/Families/necro_family.tres") as Family,
	Family.FamilyType.SHADOW: load("res://Card/Descriptions/Families/shadow_family.tres") as Family,
}

#[Server only]
var _game_heroes_ready: bool = false
signal _heroes_choosen()

# [Client only] Is emit when server has answered the local client request
signal _server_answered()

var _random_heroes_ref: Array[Hero.HeroId]

# ============================== Node base functions ==============================

func _ready() -> void:
	_game_state_timer = Timer.new()
	_game_state_timer.autostart = false
	_game_state_timer.one_shot = true
	add_child(_game_state_timer)
	game_state_changed.connect(_on_game_state_changed)
	_game_state_timer.timeout.connect(_on_game_state_timer_timeout)

# ============================== Public function ==============================




func clear() -> void:
	_game_type = GameType.UNDEF
	_active_families.clear()
	_random_heroes_ref.clear()
	ServerCardShop.clear()


func init() -> void:
	_game_rules = load("res://Game/GameRules/normal_game_rules.tres")
	_active_families.append(_FAMILIES_REF[Family.FamilyType.DEFENSE])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.POISON])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.FIRE])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.ATTACK])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.SERENITY])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.LIGHTNING])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.MANA])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.LIFE])
	_active_families.append(_FAMILIES_REF[Family.FamilyType.NECROSIS])


#TODO Move into round manager ?
func is_end_of_game() -> bool:
	if PlayerManager.get_local_player() in PlayerManager.dead_players.values():
		Events.signal_local_player_is_dead()
	return PlayerManager.get_alive_players().size() == 1


func start_solo_game() -> void:
	_game_type = GameType.SOLO
	for i in 7: # TODO Avoir un nombre max de joueur qui dépend du mode ?
		PlayerManager.add_bot()
	PlayerManager.join_game(1, "Breepsolo")
	start_game()


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


func get_active_families() -> Array[Family]:
	return _active_families


@rpc("any_peer", "call_local")
func start_game() -> void:
	ServerCardShop.init(_active_families, _game_rules)
	get_tree().change_scene_to_packed(_game_scene)

# TODO: Move all 4 bellow functions into HeroSelector
#region HERO PICKUP ORDER
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
#endregion

#region [RPC] Ask/Answer GET N RANDOM HEROES
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
#endregion

# ============================== Private functions ==============================

func _init_current_current_game_heroes(_heroes_number: int) -> void:
	# TODO Disabled for the moment
	#if heroes_number <= 0 or heroes_number > Shared.HEROES.size():
		#printerr("Hero: Wrong heroes_number: ", heroes_number)
		#return
	
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


func _player_health_compare(player_a: Player, player_b: Player) -> bool:
	return player_a.health >= player_b.health


#region GAME STATE
@rpc("authority", "call_remote")
func _sync_state(server_game_state: Game.GameState) -> void:
	game_state = server_game_state


func update_game_state(new_game_state: Game.GameState, need_to_sync: bool = false) -> void:
	game_state = new_game_state
	if need_to_sync:
		_sync_state(game_state)


func _on_game_state_timer_timeout() -> void:
	match game_state:
		Game.GameState.BUYING:
			await PlayerManager.sync_point(PlayerManager.SyncID.BUYING_PHASE)
			game_state = Game.GameState.FIGHTING_POSITIONING
		Game.GameState.FIGHTING_POSITIONING: # End of POSITIONING State
			if __prototyping or game_type == GameType.SOLO:
				game_state = Game.GameState.FIGHTING_COUNTDOWN # Trigger COUNTDOWN STATE for prototyping map
			else:
				game_state = Game.GameState.FIGHTING_NORMAL # Trigger FIGHT directly on server
		
		Game.GameState.FIGHTING_COUNTDOWN: game_state = Game.GameState.FIGHTING_NORMAL
		Game.GameState.FIGHTING_NORMAL: game_state = Game.GameState.FIGHTING_ACCELERATED
		Game.GameState.FIGHTING_ACCELERATED: game_state = Game.GameState.FIGHTING_CELEBRATING
		Game.GameState.FIGHTING_CELEBRATING: game_state = Game.GameState.FIGHTING_FINISHED
		Game.GameState.FIGHTING_FINISHED: game_state = Game.GameState.INITIATING_NEW_ROUND


# Start Timers
func _on_game_state_changed(new_state) -> void:
	_game_state_timer.stop()
	match new_state:
		Game.GameState.BUYING:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=BUYING] (", _game_rules.duration_buying_phase, "s)")
			_game_state_timer.wait_time = _game_rules.duration_buying_phase
			_game_state_timer.start()
		
		Game.GameState.FIGHTING_POSITIONING:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FIGHTING_POSITIONING] (", _game_rules.duration_fighting_positioning, "s)")
			_game_state_timer.wait_time = _game_rules.duration_fighting_positioning
			_game_state_timer.start()
		
		Game.GameState.FIGHTING_COUNTDOWN:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FIGHTING_COUNTDOWN] (", _game_rules.duration_fighting_countdown, "s)")
			_game_state_timer.wait_time = _game_rules.duration_fighting_countdown
			_game_state_timer.start()
		
		Game.GameState.FIGHTING_NORMAL:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FIGHTING_NORMAL] (", _game_rules.duration_fighting_normal, "s)")
			_game_state_timer.wait_time = _game_rules.duration_fighting_normal
			_game_state_timer.start()
		
		Game.GameState.FIGHTING_ACCELERATED:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FIGHTING_ACCELERATED] (", _game_rules.duration_fighting_accelerated, "s)")
			Engine.time_scale = ACCELERATED_FIGHT_TIME_SCALE
			_game_state_timer.wait_time = _game_rules.duration_fighting_accelerated
			_game_state_timer.start()
		
		Game.GameState.FIGHTING_CELEBRATING:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FIGHTING_CELEBRATING] (", _game_rules.duration_fighting_celebrating, "s)")
			Engine.time_scale = 1.0
			_game_state_timer.wait_time = _game_rules.duration_fighting_celebrating
			_game_state_timer.start()
		
		Game.GameState.FIGHTING_FINISHED:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FIGHTING_FINISHED]")
			_game_state_timer.wait_time = _game_rules.duration_fighting_finished
			_game_state_timer.start()
		
		Game.GameState.STARTING:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=STARTING]")
		Game.GameState.INITIATING_NEW_ROUND:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=INITIATING_NEW_ROUND]")
		Game.GameState.FINISHED:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=FINISHED]")
		Game.GameState.UNDEF:
			print("[", multiplayer.get_unique_id(), "] GameManager: [State=UNDEF]")
#endregion
	
	
	
	
	
	
	
	
	
	
	
	
	
	
