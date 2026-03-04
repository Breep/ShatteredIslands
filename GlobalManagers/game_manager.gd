extends Node

# ============================== Signals ==============================

# ============================== Enum ==============================

enum GameType { # Hello captain Hook
	UNDEF,
	SOLO,
	MULTIPLAYER
}

enum GameState {
	UNDEF,
	STARTING,
	INIT_ROUND,
	BUYING,
	FIGHTING,
	ENDING_ROUND,
	FINISHED,
}

# ============================== Constants ==============================

const HEROES_NUMBER: int = 8

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

signal game_state_changed(new_game_state: GameState)
var __game_state := GameState.UNDEF
var _game_state: GameState:
	get: return __game_state
	set(value):
		if __game_state == value: return
		__game_state = value
		_sync_game_state.rpc(__game_state)
		game_state_changed.emit(__game_state)
var game_state: GameState:
	get: return __game_state

# ============================== Private variables ==============================

var _game_scene: PackedScene = load("res://Game/game.tscn")

var _FAMILIES_REF: Dictionary[Family.Type, Family] = {
}

#[Server only]
var _game_heroes_ready: bool = false
signal _heroes_choosen()

# [Client only] Is emit when server has answered the local client request
signal _server_answered()

var _random_heroes_ref: Array[HeroDesc.HeroId]

# ============================== Node base functions ==============================

func _init() -> void:
	Verbose.debug("GAME MANAGER INIT", Verbose.Category.DEFAULT)
	_FAMILIES_REF[Family.Type.WARRIOR] = load("res://Card/Descriptions/Families/warrior_family.tres") as Family
	_FAMILIES_REF[Family.Type.ENGINEER] = load("res://Card/Descriptions/Families/engineer_family.tres") as Family
	_FAMILIES_REF[Family.Type.ARDENT_CELESTIAL] = load("res://Card/Descriptions/Families/ardent_celestial_family.tres") as Family
	_FAMILIES_REF[Family.Type.POISON] = load("res://Card/Descriptions/Families/poison_family.tres") as Family
	_FAMILIES_REF[Family.Type.STORM_CALLER] = load("res://Card/Descriptions/Families/storm_caller_family.tres") as Family
	_FAMILIES_REF[Family.Type.LIGHT] = load("res://Card/Descriptions/Families/light_family.tres") as Family
	_FAMILIES_REF[Family.Type.COLOSSUS] = load("res://Card/Descriptions/Families/colossus_family.tres") as Family
	_FAMILIES_REF[Family.Type.CHICKEN_LORD] = load("res://Card/Descriptions/Families/chicken_lord_family.tres") as Family
	_FAMILIES_REF[Family.Type.NECROSIS] = load("res://Card/Descriptions/Families/necro_family.tres") as Family
	Verbose.debug("GAME MANAGER INIT", Verbose.Category.DEFAULT)

func _ready() -> void:
	_game_state_timer = Timer.new()
	_game_state_timer.autostart = false
	_game_state_timer.one_shot = true
	add_child(_game_state_timer)
	game_state_changed.connect(_on_game_state_changed)
	_game_state_timer.timeout.connect(_on_game_state_timer_timeout)
	GlobalFightingManager.all_fights_are_over.connect(_on_gfm_all_fights_are_over)

# ============================== Public function ==============================

## Request a game state transition. Only the server can change state.
## Game.gd and other scenes should call this instead of setting game_state directly.
func request_state_transition(new_state: GameState) -> void:
	if not multiplayer.is_server(): return
	_game_state = new_state


func clear() -> void:
	_game_type = GameType.UNDEF
	_active_families.clear()
	_random_heroes_ref.clear()
	CardShopManager.clear()

	# Reset complete du state
	__game_state = GameState.UNDEF
	if _game_state_timer != null:
		_game_state_timer.stop()


func init() -> void:
	_game_rules = load("res://Game/GameRules/normal_game_rules.tres")
	_active_families.append(_FAMILIES_REF[Family.Type.ENGINEER])
	_active_families.append(_FAMILIES_REF[Family.Type.POISON])
	_active_families.append(_FAMILIES_REF[Family.Type.ARDENT_CELESTIAL])
	_active_families.append(_FAMILIES_REF[Family.Type.WARRIOR])
	_active_families.append(_FAMILIES_REF[Family.Type.LIGHT])
	_active_families.append(_FAMILIES_REF[Family.Type.CHICKEN_LORD])
	_active_families.append(_FAMILIES_REF[Family.Type.COLOSSUS])
	_active_families.append(_FAMILIES_REF[Family.Type.NECROSIS])


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


func get_current_game_heroes() -> Array[HeroDesc]:
	if multiplayer.is_server():
		_init_current_current_game_heroes(HEROES_NUMBER)
	else:
		_ask_get_n_random_heroes.rpc_id(1, multiplayer.get_unique_id())
		await _server_answered
	
	var random_heroes: Array[HeroDesc]
	for hero_ref in _random_heroes_ref:
		random_heroes.append(Shared.HEROES[hero_ref])
	
	return random_heroes


func get_active_families() -> Array[Family]:
	return _active_families


@rpc("any_peer", "call_local")
func start_game() -> void:
	CardShopManager.init(_active_families, _game_rules)
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
		Verbose.error("Only the server can choose the hero pickup order", Verbose.Category.GLOBAL_MANAGER)
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
		Verbose.error("Only server should be asked for random heroes", Verbose.Category.GLOBAL_MANAGER)
		return
	
	if not _game_heroes_ready:
		await _heroes_choosen
	
	_answer_get_n_random_heroes.rpc_id(peer_id, _random_heroes_ref)


@rpc("authority", "call_remote")
func _answer_get_n_random_heroes(heroes_ref: Array[HeroDesc.HeroId]) -> void:
	_random_heroes_ref = heroes_ref
	_server_answered.emit()
#endregion

# ============================== Private functions ==============================

func _init_current_current_game_heroes(_heroes_number: int) -> void:
	# TODO Disabled for the moment
	#if heroes_number <= 0 or heroes_number > Shared.HEROES.size():
		#printerr("HeroDesc: Wrong heroes_number: ", heroes_number)
		#return
	
	#var heroes_ref: Array[HeroDesc.HeroId]
	#for hero_ref in Shared.HEROES.keys():
		#heroes_ref.append(hero_ref)
	#
	#var rng := RandomNumberGenerator.new()
	#rng.randomize()
	#for i in heroes_number:
		#var random_index: int = rng.randi_range(0, heroes_ref.size() - 1)
		#_random_heroes_ref.append(heroes_ref.get(random_index))
		#heroes_ref.remove_at(random_index)
	
	_random_heroes_ref.append(HeroDesc.HeroId.DARK_KNIGHT)
	_heroes_choosen.emit()
	_game_heroes_ready = true


#region GAME STATE
@rpc("authority", "call_remote", "reliable")
func _sync_game_state(server_game_state: GameState) -> void:
	Verbose.debug("Sync game state | " + str(GameState.keys()[server_game_state]), Verbose.Category.GLOBAL_MANAGER)
	_game_state = server_game_state


func _on_game_state_timer_timeout() -> void:
	match _game_state:
		GameState.BUYING:
			await PlayerManager.sync_point(PlayerManager.SyncID.BUYING_PHASE)
			_game_state = GameState.FIGHTING
		GameState.FIGHTING:
			Verbose.warn("Fighting phase watchdog triggered", Verbose.Category.GLOBAL_MANAGER)
			_game_state = GameState.ENDING_ROUND


func _on_game_state_changed(new_state) -> void:
	_game_state_timer.stop()
	match new_state:
		GameState.UNDEF:
			Verbose.debug("[State=UNDEF]", Verbose.Category.GLOBAL_MANAGER)
		GameState.STARTING:
			Verbose.debug("[State=STARTING]", Verbose.Category.GLOBAL_MANAGER)
		GameState.INIT_ROUND:
			Verbose.debug("[State=INIT_ROUND]", Verbose.Category.GLOBAL_MANAGER)
		GameState.BUYING:
			Verbose.debug("[State=BUYING] (" + str(_game_rules.duration_buying_phase) + "s)", Verbose.Category.GLOBAL_MANAGER)
			_game_state_timer.wait_time = _game_rules.duration_buying_phase
			_game_state_timer.start()
		GameState.FIGHTING:
			Verbose.debug("[State=FIGHTING]", Verbose.Category.GLOBAL_MANAGER)
			var watchdog_time: float = _game_rules.duration_fighting_countdown + _game_rules.duration_fighting_normal
			watchdog_time += _game_rules.duration_fighting_special + _game_rules.duration_fighting_celebration + _game_rules.duration_fighting_finished
			watchdog_time += 10 # MAGIC NUMBER => TODO define it ?
			_game_state_timer.wait_time = watchdog_time
			_game_state_timer.start()
		GameState.ENDING_ROUND:
			Verbose.debug("[State=ENDING_ROUND]", Verbose.Category.GLOBAL_MANAGER)
			await PlayerManager.sync_point(PlayerManager.SyncID.FIGHTING_PHASE)
			await RoundManager.ending_round_player_changes()
			_game_state = GameState.INIT_ROUND
		GameState.FINISHED:
			Verbose.debug("[State=FINISHED]", Verbose.Category.GLOBAL_MANAGER)


func _on_gfm_all_fights_are_over() -> void:
	Verbose.trace("GFM signals that all fights are over")
	if _game_state != GameState.FIGHTING:
		Verbose.error("GFM signals that all fights are over but the GameManager state isn't on FIGHTING", Verbose.Category.GLOBAL_MANAGER)
		return
	_game_state_timer.stop()
	_game_state = GameState.ENDING_ROUND
#endregion
	
	
	
	
	
	
	
