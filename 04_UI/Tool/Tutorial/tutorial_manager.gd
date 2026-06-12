extends Node

# Orchestrates tutorial sequences across the game lifecycle. Listens to game
# state transitions and gameplay events; drives a TutorialOverlay (resolved
# from the running UI tree) to show one TutorialStep at a time.
#
# Race-condition note: this is an autoload, so it boots before any scene. The
# TutorialOverlay lives inside UIPersistant which loads later. If a game state
# change happens before UIPersistant is ready (typical for the very first
# sequence on STARTING), we queue the sequence in _pending_sequence and retry
# resolving the overlay each frame until it appears.

#region ============================== Constants ==============================
const _SEQUENCE_PATHS: Array[String] = [
	"res://04_UI/Tool/Tutorial/Sequences/seq_hero_selection.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_buying_phase.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_fighting_phase.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_end_of_round.tres",
]

## The fight prompt is a state-less sequence: we fire it manually when the
## local player runs out of gold OR when the BUYING phase has been going for
## _FIGHT_PROMPT_DELAY seconds, whichever comes first. Once-per-session via
## the standard _played_sequence_ids dedup.
const _FIGHT_PROMPT_PATH: String = "res://04_UI/Tool/Tutorial/Sequences/seq_fight_prompt.tres"
const _FIGHT_PROMPT_DELAY: float = 60.0
#endregion


#region ============================== Private variables ==============================
var _sequences_by_state: Dictionary = {}
var _played_sequence_ids: Dictionary = {}

var _active_sequence: TutorialSequence
var _step_index: int = -1
var _auto_advance_timer: Timer

var _overlay: TutorialOverlay
var _pending_sequence: TutorialSequence

var _fight_prompt_sequence: TutorialSequence
var _fight_prompt_timer: Timer
var _local_player_connected: Player
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_load_sequences()
	_load_fight_prompt()

	_auto_advance_timer = Timer.new()
	_auto_advance_timer.one_shot = true
	add_child(_auto_advance_timer)
	_auto_advance_timer.timeout.connect(_on_auto_advance_timeout)

	_fight_prompt_timer = Timer.new()
	_fight_prompt_timer.one_shot = true
	add_child(_fight_prompt_timer)
	_fight_prompt_timer.timeout.connect(_on_fight_prompt_timer_timeout)

	GameManager.game_state_changed.connect(_on_game_state_changed)
	Events.entity_clicked.connect(_on_entity_clicked)
	Events.furniture_clicked.connect(_on_furniture_clicked)
	Events.ui_skill_picked.connect(_on_ui_skill_picked)
	Events.card_bought.connect(_on_card_bought)
	Events.shop_refreshed.connect(_on_shop_refreshed)
	Events.shop_opened.connect(_on_shop_opened)
	Events.tavern_continue_pressed.connect(_on_tavern_continue_pressed)
	Events.tavern_phase_started.connect(_on_tavern_phase_started)
	Events.fighting_phase_started.connect(_on_fighting_phase_started)

	set_process(false)

	Verbose.debug("TutorialManager ready (" + str(_sequences_by_state.size()) + " sequences loaded)", Verbose.Category.TUTORIAL)


func _process(_delta: float) -> void:
	if _pending_sequence == null:
		set_process(false)
		return
	if _try_resolve_overlay():
		var seq: TutorialSequence = _pending_sequence
		_pending_sequence = null
		set_process(false)
		_play_sequence(seq)
#endregion


#region ============================== Private functions ==============================
func _load_sequences() -> void:
	for path in _SEQUENCE_PATHS:
		if not ResourceLoader.exists(path):
			Verbose.warn("Tutorial sequence not found: " + path, Verbose.Category.TUTORIAL)
			continue
		var seq: TutorialSequence = load(path)
		if seq == null:
			Verbose.warn("Failed to load tutorial sequence: " + path, Verbose.Category.TUTORIAL)
			continue
		_sequences_by_state[seq.trigger_state] = seq


func _load_fight_prompt() -> void:
	if not ResourceLoader.exists(_FIGHT_PROMPT_PATH):
		Verbose.warn("Fight prompt sequence not found: " + _FIGHT_PROMPT_PATH, Verbose.Category.TUTORIAL)
		return
	_fight_prompt_sequence = load(_FIGHT_PROMPT_PATH)


func _try_resolve_overlay() -> bool:
	if _overlay != null and is_instance_valid(_overlay):
		return true
	var nodes: Array[Node] = get_tree().get_nodes_in_group("tutorial_overlay")
	if nodes.is_empty():
		return false
	_overlay = nodes[0] as TutorialOverlay
	if _overlay == null:
		return false
	_overlay.step_completed.connect(_on_step_completed)
	return true


func _start_sequence(sequence: TutorialSequence) -> void:
	if sequence == null: return
	if _played_sequence_ids.has(sequence.id):
		return
	if not _try_resolve_overlay():
		Verbose.debug("Tutorial overlay not yet available — queuing sequence " + String(sequence.id), Verbose.Category.TUTORIAL)
		_pending_sequence = sequence
		set_process(true)
		return
	_play_sequence(sequence)


func _play_sequence(sequence: TutorialSequence) -> void:
	_played_sequence_ids[sequence.id] = true
	_active_sequence = sequence
	_step_index = -1
	Verbose.debug("Starting sequence: " + String(sequence.id), Verbose.Category.TUTORIAL)
	_advance_step()


func _advance_step() -> void:
	if _active_sequence == null: return
	_step_index += 1
	if _step_index >= _active_sequence.steps.size():
		_finish_sequence()
		return
	var step: TutorialStep = _active_sequence.steps[_step_index]
	var is_last: bool = _step_index == _active_sequence.steps.size() - 1
	Verbose.debug("Step " + str(_step_index) + ": " + String(step.id) + (" (last)" if is_last else ""), Verbose.Category.TUTORIAL)
	_overlay.present_step(step, is_last)
	if step.auto_advance_delay > 0.0:
		_auto_advance_timer.wait_time = step.auto_advance_delay
		_auto_advance_timer.start()
	else:
		_auto_advance_timer.stop()


func _finish_sequence() -> void:
	Verbose.debug("Sequence finished: " + String(_active_sequence.id), Verbose.Category.TUTORIAL)
	_active_sequence = null
	_step_index = -1
	_auto_advance_timer.stop()


func _abort_active_sequence() -> void:
	_pending_sequence = null
	_stop_fight_prompt_watch()
	if _active_sequence == null: return
	Verbose.debug("Aborting active sequence: " + String(_active_sequence.id), Verbose.Category.TUTORIAL)
	_active_sequence = null
	_step_index = -1
	_auto_advance_timer.stop()
	if _overlay != null and is_instance_valid(_overlay):
		_overlay.clear()


## Starts watching for the two fight-prompt triggers (gold reaches 0, or 30s
## elapsed). Called when entering the BUYING state. Bails out if the prompt
## has already played this session, since it's a once-per-session reminder.
func _start_fight_prompt_watch() -> void:
	if _fight_prompt_sequence == null: return
	if _played_sequence_ids.has(_fight_prompt_sequence.id): return

	_fight_prompt_timer.wait_time = _FIGHT_PROMPT_DELAY
	_fight_prompt_timer.start()

	var local: Player = PlayerManager.get_local_player()
	if local == null: return
	if not local.gold_changed.is_connected(_on_local_gold_changed):
		local.gold_changed.connect(_on_local_gold_changed)
	_local_player_connected = local


func _stop_fight_prompt_watch() -> void:
	_fight_prompt_timer.stop()
	if _local_player_connected != null and is_instance_valid(_local_player_connected):
		if _local_player_connected.gold_changed.is_connected(_on_local_gold_changed):
			_local_player_connected.gold_changed.disconnect(_on_local_gold_changed)
	_local_player_connected = null


func _try_fire_fight_prompt() -> void:
	if _fight_prompt_sequence == null: return
	if _played_sequence_ids.has(_fight_prompt_sequence.id): return
	# Never interrupt a running sequence (e.g. the forced buying onboarding, which
	# spends the player's gold down to 0 and would otherwise trigger this prompt).
	if _active_sequence != null: return
	_stop_fight_prompt_watch()
	_start_sequence(_fight_prompt_sequence)


func _current_step() -> TutorialStep:
	if _active_sequence == null: return null
	if _step_index < 0 or _step_index >= _active_sequence.steps.size(): return null
	return _active_sequence.steps[_step_index]


func _validate_and_advance(event: TutorialStep.ValidationEvent, filter: StringName = &"") -> void:
	var step: TutorialStep = _current_step()
	if step == null: return
	if step.validation_event != event: return
	if step.validation_filter != &"" and step.validation_filter != filter: return
	_auto_advance_timer.stop()
	_overlay.complete_current_step()
#endregion


#region ============================== Callbacks ==============================
func _on_game_state_changed(new_state: int) -> void:
	if not Settings.is_tutorial_enabled():
		_abort_active_sequence()
		return
	match new_state:
		GameManager.GameState.BUYING:
			_start_fight_prompt_watch()
		GameManager.GameState.FIGHTING:
			_stop_fight_prompt_watch()
			_validate_and_advance(TutorialStep.ValidationEvent.GAME_STATE_FIGHTING)
		GameManager.GameState.ENDING_ROUND:
			_stop_fight_prompt_watch()
			_validate_and_advance(TutorialStep.ValidationEvent.GAME_STATE_ENDING_ROUND)

	if _sequences_by_state.has(new_state):
		_start_sequence(_sequences_by_state[new_state])


func _on_local_gold_changed(_self_ref, new_gold: int) -> void:
	if not Settings.is_tutorial_enabled(): return
	if new_gold > 0: return
	_try_fire_fight_prompt()


func _on_fight_prompt_timer_timeout() -> void:
	if not Settings.is_tutorial_enabled(): return
	_try_fire_fight_prompt()


func _on_entity_clicked(_entity) -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.ENTITY_CLICKED)


func _on_furniture_clicked(furniture) -> void:
	if not Settings.is_tutorial_enabled(): return
	var filter := &""
	if furniture != null and furniture.has_method("get_id"):
		filter = StringName(furniture.get_id())
	elif furniture != null:
		filter = StringName(furniture.name)
	_validate_and_advance(TutorialStep.ValidationEvent.FURNITURE_CLICKED, filter)


func _on_ui_skill_picked(_skill_id) -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.UI_SKILL_PICKED)


func _on_card_bought(_card) -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.CARD_BOUGHT)


func _on_shop_refreshed() -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.SHOP_REFRESHED)


func _on_shop_opened() -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.OPEN_SHOP)


func _on_tavern_continue_pressed() -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.END_BUYING_PRESSED)


## Roguelite flow entry points. The run is driven by RunRoot/EncounterRunner,
## which never fire GameManager.game_state_changed — so we trigger the buying and
## fighting sequences from these global phase events instead. Sequences are still
## looked up in _sequences_by_state by their GameState trigger int.
func _on_tavern_phase_started() -> void:
	if not Settings.is_tutorial_enabled(): return
	_start_fight_prompt_watch()
	if _sequences_by_state.has(GameManager.GameState.BUYING):
		_start_sequence(_sequences_by_state[GameManager.GameState.BUYING])


func _on_fighting_phase_started() -> void:
	if not Settings.is_tutorial_enabled(): return
	_stop_fight_prompt_watch()
	_validate_and_advance(TutorialStep.ValidationEvent.GAME_STATE_FIGHTING)
	if _sequences_by_state.has(GameManager.GameState.FIGHTING):
		_start_sequence(_sequences_by_state[GameManager.GameState.FIGHTING])


func _on_step_completed(_step: TutorialStep) -> void:
	_advance_step()


func _on_auto_advance_timeout() -> void:
	if _overlay == null or not _overlay.has_active_step(): return
	_overlay.complete_current_step()
#endregion
