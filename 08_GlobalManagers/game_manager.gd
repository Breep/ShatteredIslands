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

# ============================== Node base functions ==============================

func _init() -> void:
	Verbose.debug("GAME MANAGER INIT", Verbose.Category.DEFAULT)
	_FAMILIES_REF[Family.Type.WARRIOR] = load("res://Card/Descriptions/Families/warrior_family.tres") as Family
	_FAMILIES_REF[Family.Type.ENGINEER] = load("res://Card/Descriptions/Families/Engineer/engineer_family.tres") as Family
	_FAMILIES_REF[Family.Type.ARDENT_CELESTIAL] = load("res://Card/Descriptions/Families/ArdentCelestial/ardent_celestial_family.tres") as Family
	_FAMILIES_REF[Family.Type.POISON] = load("res://Card/Descriptions/Families/poison_family.tres") as Family
	_FAMILIES_REF[Family.Type.STORM_CALLER] = load("res://Card/Descriptions/Families/storm_caller_family.tres") as Family
	_FAMILIES_REF[Family.Type.LIGHT] = load("res://Card/Descriptions/Families/light_family.tres") as Family
	_FAMILIES_REF[Family.Type.COLOSSUS] = load("res://Card/Descriptions/Families/Colossus/colossus_family.tres") as Family
	_FAMILIES_REF[Family.Type.CHICKEN_LORD] = load("res://Card/Descriptions/Families/ChickenLord/chicken_lord_family.tres") as Family
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
	CardShopManager.clear()

	# Reset complete du state
	__game_state = GameState.UNDEF
	if _game_state_timer != null:
		_game_state_timer.stop()


func init() -> void:
	_game_rules = load("res://Game/GameRules/normal_game_rules.tres")
	_active_families.append(_FAMILIES_REF[Family.Type.ENGINEER])
	#_active_families.append(_FAMILIES_REF[Family.Type.POISON])
	_active_families.append(_FAMILIES_REF[Family.Type.ARDENT_CELESTIAL])
	#_active_families.append(_FAMILIES_REF[Family.Type.WARRIOR])
	#_active_families.append(_FAMILIES_REF[Family.Type.LIGHT])
	_active_families.append(_FAMILIES_REF[Family.Type.CHICKEN_LORD])
	_active_families.append(_FAMILIES_REF[Family.Type.COLOSSUS])
	#_active_families.append(_FAMILIES_REF[Family.Type.NECROSIS])


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


func get_active_families() -> Array[Family]:
	return _active_families


@rpc("any_peer", "call_local")
func start_game() -> void:
	CardShopManager.init(_active_families, _game_rules)
	get_tree().change_scene_to_packed(_game_scene)

# ============================== Private functions ==============================

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
		GameState.ENDING_ROUND:
			_game_state = GameState.INIT_ROUND


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
			watchdog_time += _game_rules.duration_fighting_special + _game_rules.duration_fighting_celebration
			watchdog_time += 10 # MAGIC NUMBER => TODO define it ?
			_game_state_timer.wait_time = watchdog_time
			_game_state_timer.start()
		GameState.ENDING_ROUND:
			Verbose.debug("[State=ENDING_ROUND]", Verbose.Category.GLOBAL_MANAGER)
			await get_tree().create_timer(0.1).timeout # Quick fix to avoid recursive signals
			await PlayerManager.sync_point(PlayerManager.SyncID.FIGHTING_PHASE)
			await RoundManager.ending_round_player_changes()
			_game_state_timer.wait_time = _game_rules.duration_fighting_finished
			_game_state_timer.start()
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
