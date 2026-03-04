extends Node

# ============================== Description ==============================
#
# -- GlobalFightingManager --
# Handle the differents fighting phases (COUNTDOWN/NORMAL/SPECIAL/CELEBRATION/FINISHED) for every other FightingManager

#region ============================== Signals ==============================
signal all_fights_are_over()
signal fighting_phase_state_changed(new_fighting_phase_state: FightingPhaseState)
#endregion

#region ============================== Enum ==============================
enum FightingPhaseState {
	UNDEF,
	COUNTDOWN,
	NORMAL,
	SPECIAL,
	CELEBRATION,
	FINISHED,
}
#endregion

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
#endregion

#region ============================== Private variables ==============================
var _fighting_managers: Array[FightingManager]
var _current_active_fighting_managers: Array[FightingManager]

# Tick at which NORMAL phase started (t=0 reference)
var fight_start_tick: int = 0

# /!\ _fighting_phase_state is NOT sync, the server is ahead of time /!\
var __fighting_phase_state := FightingPhaseState.UNDEF
var _fighting_phase_state: FightingPhaseState:
	get: return __fighting_phase_state
	set(value):
		if __fighting_phase_state == value: return
		__fighting_phase_state = value
		if value == FightingPhaseState.NORMAL:
			fight_start_tick = _current_tick
		fighting_phase_state_changed.emit(__fighting_phase_state)

var __prototyping = false
var _is_active: bool = false
var _phase_ticks_remaining: int = 0
var _current_tick: int = 0

# ====== SERVER ONLY
var _players_running_playback: Array[Player]
#endregion

#region ============================== Node base functions ==============================
func _init() -> void:
	Verbose.debug("GLOBAL FIGHTING MANAGER INIT", Verbose.Category.DEFAULT)

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	fighting_phase_state_changed.connect(_on_fighting_phase_state_changed)
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not _is_active: return
	_current_tick += 1
	_phase_ticks_remaining -= 1
	if _phase_ticks_remaining <= 0:
		_advance_phase()
#endregion

#region ============================== Public functions ==============================
func clear() -> void:
	_fighting_managers.clear()
	_current_active_fighting_managers.clear()
	_players_running_playback.clear()
	_is_active = false
	_phase_ticks_remaining = 0
	_current_tick = 0
	set_physics_process(false)


func start() -> void:
	Verbose.debug("START", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	_current_tick = 0
	if multiplayer.is_server():
		_players_running_playback = PlayerManager.get_human_players().values().duplicate()
	_fighting_phase_state = FightingPhaseState.COUNTDOWN


# === Register/Unregister FightingManager
func register_fighting_manager(fighting_manager: FightingManager):
	Verbose.trace("register_fighting_manager() | " + str(fighting_manager.get_path()), Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if _fighting_managers.has(fighting_manager):
		Verbose.error("FightingManager[" + str(fighting_manager) + "] already registered !", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	
	_fighting_managers.append(fighting_manager)
	fighting_manager.fight_is_ready_to_be_started.connect(_on_fighting_manager_fight_is_ready_to_be_started)
	fighting_manager.fight_is_over.connect(_fighting_manager_fighting_is_over)


func unregister_fighting_manager(fighting_manager: FightingManager):
	Verbose.trace("unregister_fighting_manager() | " + str(fighting_manager.get_path()), Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if not _fighting_managers.has(fighting_manager):
		Verbose.error("FightingManager[" + str(fighting_manager) + "] is not registered !", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	
	_fighting_managers.erase(fighting_manager)
	fighting_manager.fight_is_over.disconnect(_fighting_manager_fighting_is_over)
#endregion

#region ============================== State machine ==============================
func _advance_phase() -> void:
	match __fighting_phase_state:
		FightingPhaseState.COUNTDOWN: _fighting_phase_state = FightingPhaseState.NORMAL
		FightingPhaseState.NORMAL: _fighting_phase_state = FightingPhaseState.SPECIAL
		FightingPhaseState.SPECIAL:
			Verbose.debug("Fights are taking too long => Forcing CELEBRATION phase", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			_fighting_phase_state = FightingPhaseState.CELEBRATION
		FightingPhaseState.CELEBRATION: _fighting_phase_state = FightingPhaseState.FINISHED
		FightingPhaseState.FINISHED: _fighting_phase_state = FightingPhaseState.UNDEF
		_: pass


func _on_fighting_phase_state_changed(new_fighting_phase_state: FightingPhaseState) -> void:
	var duration: float = 0.0
	match new_fighting_phase_state:
		FightingPhaseState.COUNTDOWN:
			duration = GameManager.game_rules.duration_fighting_countdown
			Verbose.debug("[State=COUNTDOWN] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)

		FightingPhaseState.NORMAL:
			duration = GameManager.game_rules.duration_fighting_normal
			Verbose.debug("[State=NORMAL] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			for fighting_manager in _current_active_fighting_managers:
				fighting_manager.start()

		FightingPhaseState.SPECIAL:
			duration = GameManager.game_rules.duration_fighting_special
			Verbose.debug("[State=SPECIAL] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)

		FightingPhaseState.CELEBRATION:
			duration = GameManager.game_rules.duration_fighting_celebration
			Verbose.debug("[State=CELEBRATION] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)

		FightingPhaseState.FINISHED:
			duration = GameManager.game_rules.duration_fighting_finished
			Verbose.debug("[State=FINISHED] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			if multiplayer.is_server(): _wait_for_all_players_to_finish_playback()
			else: _notice_playback_is_over.rpc_id(1)

		_:
			Verbose.trace("[State=UNDEF]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			_is_active = false
			set_physics_process(false)
			return

	_phase_ticks_remaining = int(duration * TICKS_PER_SECOND)
	_is_active = true
	set_physics_process(true)
	if _phase_ticks_remaining == 0:
		_advance_phase()
#endregion

func _on_game_manager_game_state_changed(new_game_state: GameManager.GameState) -> void:
	match new_game_state:
		GameManager.GameState.ENDING_ROUND:
			pass # TODO handle the GameManager watchdog
		_: pass

#region ============================== Net sync ==============================
signal _all_players_playback_finished()
func _wait_for_all_players_to_finish_playback() -> void:
	if not multiplayer.is_server(): return
	if GameManager.game_type != GameManager.GameType.SOLO and not _players_running_playback.is_empty():
		Verbose.debug("Waiting for clients to finish their playback", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		await _all_players_playback_finished
	_finish_all_fights.rpc()


@rpc("authority", "call_local")
func _finish_all_fights() -> void:
	all_fights_are_over.emit()
	Verbose.debug("Finishing GFM", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	_players_running_playback.clear()
	_is_active = false
	_phase_ticks_remaining = 0
	set_physics_process(false)


@rpc("any_peer", "call_remote")
func _notice_playback_is_over() -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	Verbose.debug("Player(" + str(peer_id) + ") finished its playback", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if _players_running_playback.has(PlayerManager.players[peer_id]):
		_players_running_playback.erase(PlayerManager.players[peer_id])
	else:
		Verbose.error("Player(" + str(peer_id) + ") notice playback is finished but is not listed", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	
	if _players_running_playback.is_empty():
		_all_players_playback_finished.emit()
#endregion

#region ============================== FightingManager callbacks ==============================
func _fighting_manager_fighting_is_over(fighting_manager: FightingManager, _winner_teams_order: Array[int]) -> void:
	if not _current_active_fighting_managers.has(fighting_manager):
		Verbose.error("An unexpected FightingArea signals a fight is over [" + str(fighting_manager.get_path()) + "]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	_current_active_fighting_managers.erase(fighting_manager)
	if _current_active_fighting_managers.is_empty() and _fighting_phase_state < FightingPhaseState.CELEBRATION:
		Verbose.debug("All fights are over => Going to CELEBRATION phase", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		_fighting_phase_state = FightingPhaseState.CELEBRATION


func _on_fighting_manager_fight_is_ready_to_be_started(fighting_manager: FightingManager) -> void:
	if _current_active_fighting_managers.has(fighting_manager):
		Verbose.error("A fight is starting more than once at the same time on the same FightingArea [" + str(fighting_manager.get_path()) + "]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	_current_active_fighting_managers.append(fighting_manager)
#endregion
