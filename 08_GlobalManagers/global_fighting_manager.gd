extends Node

# ============================== Description ==============================
#
# -- GlobalFightingManager --
# Orchestre les phases globales pour N FightingManager(s) :
# UNDEF → POSITIONING → COUNTDOWN → NORMAL → SPECIAL → CELEBRATION → UNDEF.
# Avance globalement quand TOUS les FMs ont signalé la fin de la phase courante
# (POSITIONING/CELEBRATION) ou via timer (COUNTDOWN/NORMAL/SPECIAL).

#region ============================== Signals ==============================
signal all_fights_are_over()
signal fighting_phase_state_changed(new_fighting_phase_state: FightingPhaseState)
#endregion

#region ============================== Enum ==============================
enum FightingPhaseState {
	UNDEF,
	POSITIONING,
	COUNTDOWN,
	NORMAL,
	SPECIAL,
	CELEBRATION
}
#endregion

#region ============================== Constants ==============================
const TICKS_PER_SECOND: int = 60
#endregion

#region ============================== Private variables ==============================
var _fighting_managers: Array[FightingManager]
var _current_active_fighting_managers: Array[FightingManager]

# Trackers de fin de phase par FM. Reset à chaque entrée dans la phase concernée.
var _fms_positioning_done: Array[FightingManager]
var _fms_fight_done: Array[FightingManager]
var _fms_celebration_done: Array[FightingManager]

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
	for fm in _fighting_managers:
		_disconnect_fm_signals(fm)
	_fighting_managers.clear()
	_current_active_fighting_managers.clear()
	_fms_positioning_done.clear()
	_fms_fight_done.clear()
	_fms_celebration_done.clear()
	_players_running_playback.clear()
	_is_active = false
	_phase_ticks_remaining = 0
	_current_tick = 0
	fight_start_tick = 0
	# Backing var écrit directement : éviter d'émettre fighting_phase_state_changed
	# pendant le teardown (l'UI est en cours de libération). Sans ce reset, quitter
	# en phase POSITIONING laisse l'état figé → au run suivant start() repose
	# POSITIONING (valeur inchangée) → pas d'émission → AdvanceButton jamais affiché.
	__fighting_phase_state = FightingPhaseState.UNDEF
	set_physics_process(false)


func start() -> void:
	Verbose.debug("START", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	_current_tick = 0
	if multiplayer.is_server():
		_players_running_playback = PlayerManager.get_human_players().values().duplicate()
	_fighting_phase_state = FightingPhaseState.POSITIONING


# === Register/Unregister FightingManager
func register_fighting_manager(fighting_manager: FightingManager):
	Verbose.trace("register_fighting_manager() | " + str(fighting_manager.get_path()), Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if _fighting_managers.has(fighting_manager):
		Verbose.error("FightingManager[" + str(fighting_manager) + "] already registered !", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return

	_fighting_managers.append(fighting_manager)
	fighting_manager.fight_is_ready_to_be_started.connect(_on_fighting_manager_fight_is_ready_to_be_started)
	fighting_manager.positioning_done.connect(_on_fm_positioning_done)
	fighting_manager.fight_done.connect(_on_fm_fight_done)
	fighting_manager.celebration_done.connect(_on_fm_celebration_done)


func unregister_fighting_manager(fighting_manager: FightingManager):
	Verbose.trace("unregister_fighting_manager() | " + str(fighting_manager.get_path()), Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if not _fighting_managers.has(fighting_manager):
		Verbose.error("FightingManager[" + str(fighting_manager) + "] is not registered !", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return

	_fighting_managers.erase(fighting_manager)
	_current_active_fighting_managers.erase(fighting_manager)
	_disconnect_fm_signals(fighting_manager)
#endregion

#region ============================== State machine ==============================
# Timer-driven transitions only. POSITIONING → COUNTDOWN et CELEBRATION → UNDEF
# sont signal-driven (voir _on_fm_*_done).
func _advance_phase() -> void:
	match __fighting_phase_state:
		FightingPhaseState.COUNTDOWN: _fighting_phase_state = FightingPhaseState.NORMAL
		FightingPhaseState.NORMAL: _fighting_phase_state = FightingPhaseState.SPECIAL
		FightingPhaseState.SPECIAL:
			Verbose.debug("Fights are taking too long => Forcing CELEBRATION phase", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			_fighting_phase_state = FightingPhaseState.CELEBRATION
		_: pass


func _on_fighting_phase_state_changed(new_fighting_phase_state: FightingPhaseState) -> void:
	var duration: float = 0.0
	var use_timer: bool = true

	match new_fighting_phase_state:
		FightingPhaseState.POSITIONING:
			Verbose.debug("[State=POSITIONING] (waiting for all FMs)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			_fms_positioning_done.clear()
			_fms_fight_done.clear()
			_fms_celebration_done.clear()
			for fighting_manager in _current_active_fighting_managers:
				if not is_instance_valid(fighting_manager): continue
				fighting_manager.start_positioning()
			use_timer = false  # avance via _on_fm_positioning_done

		FightingPhaseState.COUNTDOWN:
			duration = GameManager.game_rules.duration_fighting_countdown
			Verbose.debug("[State=COUNTDOWN] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)

		FightingPhaseState.NORMAL:
			duration = GameManager.game_rules.duration_fighting_normal
			Verbose.debug("[State=NORMAL] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			for fighting_manager in _current_active_fighting_managers:
				if not is_instance_valid(fighting_manager): continue
				fighting_manager.start_fighting()

		FightingPhaseState.SPECIAL:
			duration = GameManager.game_rules.duration_fighting_special
			Verbose.debug("[State=SPECIAL] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)

		FightingPhaseState.CELEBRATION:
			Verbose.debug("[State=CELEBRATION] (waiting for all FMs)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			for fighting_manager in _current_active_fighting_managers:
				if not is_instance_valid(fighting_manager): continue
				fighting_manager.start_celebration()
			use_timer = false  # avance via _on_fm_celebration_done

		_:
			Verbose.trace("[State=UNDEF]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
			_is_active = false
			set_physics_process(false)
			return

	if use_timer:
		_phase_ticks_remaining = int(duration * TICKS_PER_SECOND)
		_is_active = true
		set_physics_process(true)
		if _phase_ticks_remaining == 0:
			_advance_phase()
	else:
		_is_active = false
		set_physics_process(false)
#endregion

func _on_game_manager_game_state_changed(new_game_state: GameManager.GameState) -> void:
	match new_game_state:
		GameManager.GameState.ENDING_ROUND:
			pass # TODO handle the GameManager watchdog
		_: pass

#region ============================== FightingManager callbacks ==============================
func _on_fighting_manager_fight_is_ready_to_be_started(fighting_manager: FightingManager) -> void:
	if _current_active_fighting_managers.has(fighting_manager):
		Verbose.error("A fight is starting more than once at the same time on the same FightingArea [" + str(fighting_manager.get_path()) + "]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	_current_active_fighting_managers.append(fighting_manager)


func _on_fm_positioning_done(fm: FightingManager) -> void:
	if not _current_active_fighting_managers.has(fm): return
	if fm in _fms_positioning_done: return
	_fms_positioning_done.append(fm)
	if _all_active_fms_in(_fms_positioning_done):
		Verbose.debug("All FMs positioning done => COUNTDOWN", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		_fighting_phase_state = FightingPhaseState.COUNTDOWN


func _on_fm_fight_done(fm: FightingManager, _winner_teams_order: Array[int]) -> void:
	if not _current_active_fighting_managers.has(fm): return
	if fm in _fms_fight_done: return
	_fms_fight_done.append(fm)
	# Si tous les FMs ont fini le combat avant le timer SPECIAL, on force le passage
	# direct à CELEBRATION (skip SPECIAL).
	if _all_active_fms_in(_fms_fight_done) and __fighting_phase_state < FightingPhaseState.CELEBRATION:
		Verbose.debug("All FMs fight done => CELEBRATION", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		_fighting_phase_state = FightingPhaseState.CELEBRATION


func _on_fm_celebration_done(fm: FightingManager) -> void:
	if not _current_active_fighting_managers.has(fm): return
	if fm in _fms_celebration_done: return
	_fms_celebration_done.append(fm)
	if _all_active_fms_in(_fms_celebration_done):
		Verbose.debug("All FMs celebration done => UNDEF + all_fights_are_over", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		_current_active_fighting_managers.clear()
		_fighting_phase_state = FightingPhaseState.UNDEF
		all_fights_are_over.emit()
#endregion

#region ============================== Private helpers ==============================
func _all_active_fms_in(tracker: Array[FightingManager]) -> bool:
	if _current_active_fighting_managers.is_empty(): return false
	for fm in _current_active_fighting_managers:
		if not fm in tracker:
			return false
	return true


func _disconnect_fm_signals(fm: FightingManager) -> void:
	if fm.fight_is_ready_to_be_started.is_connected(_on_fighting_manager_fight_is_ready_to_be_started):
		fm.fight_is_ready_to_be_started.disconnect(_on_fighting_manager_fight_is_ready_to_be_started)
	if fm.positioning_done.is_connected(_on_fm_positioning_done):
		fm.positioning_done.disconnect(_on_fm_positioning_done)
	if fm.fight_done.is_connected(_on_fm_fight_done):
		fm.fight_done.disconnect(_on_fm_fight_done)
	if fm.celebration_done.is_connected(_on_fm_celebration_done):
		fm.celebration_done.disconnect(_on_fm_celebration_done)
#endregion
