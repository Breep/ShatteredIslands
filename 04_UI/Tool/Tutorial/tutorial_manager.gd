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

## State-less sequence fired when the local hero first unlocks a talent tier
## (level-up). Once-per-session via _played_sequence_ids.
const _TALENT_CHOICE_PATH: String = "res://04_UI/Tool/Tutorial/Sequences/seq_talent_choice.tres"

## State-less sequence fired the first time the unit-placement UI opens (first
## combat positioning). Once-per-session via _played_sequence_ids.
const _UNIT_PLACEMENT_PATH: String = "res://04_UI/Tool/Tutorial/Sequences/seq_unit_placement.tres"
#endregion


#region ============================== Private variables ==============================
var _sequences_by_state: Dictionary = {}
var _played_sequence_ids: Dictionary = {}

var _active_sequence: TutorialSequence
var _step_index: int = -1
var _auto_advance_timer: Timer

var _overlay: TutorialOverlay
var _pending_sequence: TutorialSequence

var _talent_choice_sequence: TutorialSequence
var _unit_placement_sequence: TutorialSequence
var _hand_hidden_by_tutorial: bool = false
var _shop_locked_by_tutorial: bool = false
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_load_sequences()
	_load_talent_choice()
	_load_unit_placement()

	_auto_advance_timer = Timer.new()
	_auto_advance_timer.one_shot = true
	add_child(_auto_advance_timer)
	_auto_advance_timer.timeout.connect(_on_auto_advance_timeout)

	GameManager.game_state_changed.connect(_on_game_state_changed)
	Events.entity_clicked.connect(_on_entity_clicked)
	Events.furniture_clicked.connect(_on_furniture_clicked)
	Events.skill_selected.connect(_on_skill_selected)
	Events.card_bought.connect(_on_card_bought)
	Events.shop_refreshed.connect(_on_shop_refreshed)
	Events.shop_opened.connect(_on_shop_opened)
	Events.tavern_continue_pressed.connect(_on_tavern_continue_pressed)
	Events.tavern_phase_started.connect(_on_tavern_phase_started)
	Events.fighting_phase_started.connect(_on_fighting_phase_started)
	Events.hero_skill_unlocked.connect(_on_hero_skill_unlocked)
	Events.hero_skill_chosen.connect(_on_hero_skill_chosen)
	Events.unit_placement_started.connect(_on_unit_placement_started)
	Events.combat_started.connect(_on_combat_started)
	Events.entity_drag_started.connect(_on_entity_drag_started)
	Events.entity_drag_stopped.connect(_on_entity_drag_stopped)

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


func _load_talent_choice() -> void:
	if not ResourceLoader.exists(_TALENT_CHOICE_PATH):
		Verbose.warn("Talent choice sequence not found: " + _TALENT_CHOICE_PATH, Verbose.Category.TUTORIAL)
		return
	_talent_choice_sequence = load(_TALENT_CHOICE_PATH)


func _load_unit_placement() -> void:
	if not ResourceLoader.exists(_UNIT_PLACEMENT_PATH):
		Verbose.warn("Unit placement sequence not found: " + _UNIT_PLACEMENT_PATH, Verbose.Category.TUTORIAL)
		return
	_unit_placement_sequence = load(_UNIT_PLACEMENT_PATH)


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
	_apply_step_ui_side_effects(step)
	_overlay.present_step(step, is_last)
	if step.auto_advance_delay > 0.0:
		_auto_advance_timer.wait_time = step.auto_advance_delay
		_auto_advance_timer.start()
	else:
		_auto_advance_timer.stop()


# Guarantees the game UI is in the state the step needs (shop open/closed, hand
# hidden) before its bubble points at anything. Hand visibility is auto-restored
# on the first step that doesn't ask to hide it, and on sequence end/abort.
func _apply_step_ui_side_effects(step: TutorialStep) -> void:
	if step.ensure_shop_open:
		Events.tutorial_set_shop_open.emit(true)
	elif step.ensure_shop_closed:
		Events.tutorial_set_shop_open.emit(false)

	if step.hide_hand:
		Events.tutorial_set_hand_visible.emit(false)
		_hand_hidden_by_tutorial = true
	elif _hand_hidden_by_tutorial:
		Events.tutorial_set_hand_visible.emit(true)
		_hand_hidden_by_tutorial = false

	# Shop buying is locked on block_interaction steps (the shop is on a CanvasLayer
	# above the blocker, so it must be gated at the shop level).
	if step.block_interaction:
		Events.tutorial_set_shop_interactable.emit(false)
		_shop_locked_by_tutorial = true
	elif _shop_locked_by_tutorial:
		Events.tutorial_set_shop_interactable.emit(true)
		_shop_locked_by_tutorial = false


func _restore_ui_if_overridden() -> void:
	if _hand_hidden_by_tutorial:
		Events.tutorial_set_hand_visible.emit(true)
		_hand_hidden_by_tutorial = false
	if _shop_locked_by_tutorial:
		Events.tutorial_set_shop_interactable.emit(true)
		_shop_locked_by_tutorial = false


func _finish_sequence() -> void:
	Verbose.debug("Sequence finished: " + String(_active_sequence.id), Verbose.Category.TUTORIAL)
	_restore_ui_if_overridden()
	_active_sequence = null
	_step_index = -1
	_auto_advance_timer.stop()


func _abort_active_sequence() -> void:
	_pending_sequence = null
	_restore_ui_if_overridden()
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


func _on_skill_selected(_skill: Skill) -> void:
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
	if _sequences_by_state.has(GameManager.GameState.BUYING):
		_start_sequence(_sequences_by_state[GameManager.GameState.BUYING])


func _on_fighting_phase_started() -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.GAME_STATE_FIGHTING)


## The combat-info sequence is deferred to the actual fight start (countdown) so it
## doesn't clash with the unit-placement help shown during positioning.
func _on_combat_started() -> void:
	if not Settings.is_tutorial_enabled(): return
	if _sequences_by_state.has(GameManager.GameState.FIGHTING):
		_start_sequence(_sequences_by_state[GameManager.GameState.FIGHTING])


## Talent onboarding: when the local hero unlocks its first talent tier (level-up),
## present the talent-choice sequence highlighting the two choices. Once-per-session
## via _played_sequence_ids, so it only fires on the very first unlock.
func _on_hero_skill_unlocked(component, _skill_type) -> void:
	if not Settings.is_tutorial_enabled(): return
	if not _is_local_hero_skill(component): return
	_start_sequence(_talent_choice_sequence)


func _on_hero_skill_chosen(_component, _skill_id) -> void:
	if not Settings.is_tutorial_enabled(): return
	_validate_and_advance(TutorialStep.ValidationEvent.HERO_SKILL_CHOSEN)


## First combat: the placement UI just opened — show how to drag units onto the field.
func _on_unit_placement_started() -> void:
	if not Settings.is_tutorial_enabled(): return
	_start_sequence(_unit_placement_sequence)


func _on_entity_drag_started(_entity) -> void:
	var step: TutorialStep = _current_step()
	if step != null and step.dim_off_while_dragging and _overlay != null:
		_overlay.set_highlight_visible(false)


func _on_entity_drag_stopped(_entity) -> void:
	var step: TutorialStep = _current_step()
	if step != null and step.dim_off_while_dragging and _overlay != null:
		_overlay.set_highlight_visible(true)


func _is_local_hero_skill(component) -> bool:
	var local: Player = PlayerManager.get_local_player()
	if local == null or not is_instance_valid(local.hero):
		return false
	return local.hero.skill == component


func _on_step_completed(_step: TutorialStep) -> void:
	_advance_step()


func _on_auto_advance_timeout() -> void:
	if _overlay == null or not _overlay.has_active_step(): return
	_overlay.complete_current_step()
#endregion
