extends Node

# Orchestrates tutorial sequences across the game lifecycle. Listens to game
# state transitions and gameplay events; drives a TutorialOverlay (resolved
# from the running UI tree) to show one TutorialStep at a time.

#region ============================== Constants ==============================
const _SEQUENCES_DIR: String = "res://04_UI/Tool/Tutorial/Sequences/"

const _SEQUENCE_PATHS: Array[String] = [
	"res://04_UI/Tool/Tutorial/Sequences/seq_hero_selection.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_buying_phase.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_fighting_phase.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_end_of_round.tres",
]
#endregion


#region ============================== Private variables ==============================
var _sequences_by_state: Dictionary = {}
var _played_sequence_ids: Dictionary = {}

var _active_sequence: TutorialSequence
var _step_index: int = -1
var _auto_advance_timer: Timer

var _overlay: TutorialOverlay
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_load_sequences()

	_auto_advance_timer = Timer.new()
	_auto_advance_timer.one_shot = true
	add_child(_auto_advance_timer)
	_auto_advance_timer.timeout.connect(_on_auto_advance_timeout)

	GameManager.game_state_changed.connect(_on_game_state_changed)
	Events.entity_clicked.connect(_on_entity_clicked)
	Events.furniture_clicked.connect(_on_furniture_clicked)
	Events.ui_skill_picked.connect(_on_ui_skill_picked)

	Verbose.debug("TutorialManager ready (" + str(_sequences_by_state.size()) + " sequences loaded)", Verbose.Category.TUTORIAL)
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
	_overlay.step_skipped.connect(_on_step_skipped)
	return true


func _start_sequence(sequence: TutorialSequence) -> void:
	if sequence == null: return
	if _played_sequence_ids.has(sequence.id):
		return
	if not _try_resolve_overlay():
		Verbose.warn("Tutorial overlay not yet available — skipping sequence " + String(sequence.id), Verbose.Category.TUTORIAL)
		return
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
	Verbose.debug("Step " + str(_step_index) + ": " + String(step.id), Verbose.Category.TUTORIAL)
	_overlay.present_step(step)
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
	if _active_sequence == null: return
	Verbose.debug("Aborting active sequence: " + String(_active_sequence.id), Verbose.Category.TUTORIAL)
	_active_sequence = null
	_step_index = -1
	_auto_advance_timer.stop()
	if _overlay != null and is_instance_valid(_overlay):
		_overlay.clear()


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
		GameManager.GameState.FIGHTING:
			_validate_and_advance(TutorialStep.ValidationEvent.GAME_STATE_FIGHTING)
		GameManager.GameState.ENDING_ROUND:
			_validate_and_advance(TutorialStep.ValidationEvent.GAME_STATE_ENDING_ROUND)

	if _sequences_by_state.has(new_state):
		_start_sequence(_sequences_by_state[new_state])


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


func _on_step_completed(_step: TutorialStep) -> void:
	_advance_step()


func _on_step_skipped(_step: TutorialStep) -> void:
	_finish_sequence()


func _on_auto_advance_timeout() -> void:
	if _overlay == null or not _overlay.has_active_step(): return
	_overlay.complete_current_step()
#endregion
