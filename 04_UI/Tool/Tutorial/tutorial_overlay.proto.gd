extends Control

# Prototyping scene for TutorialOverlay. Bypasses TutorialManager (autoload, hard
# to fake) and drives the overlay directly. Lets you load any real .tres sequence
# from Sequences/ and step through it with a Force-Advance button (since
# validation_event-based steps need real game events the proto cannot emit).
# Also exposes one button per popup_mode for visual validation.

#region ============================== Constants ==============================
const _SEQUENCES: Array[String] = [
	"res://04_UI/Tool/Tutorial/Sequences/seq_hero_selection.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_buying_phase.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_fighting_phase.tres",
	"res://04_UI/Tool/Tutorial/Sequences/seq_end_of_round.tres",
]

const _DEMO_SHORT_TEXT: String = "Coucou ! Je suis ton tutoriel. Clique sur la cible orange pour avancer."

## Margins around the random-target placement so the bubble has room to fit on
## any side. Right-side margin matches the ControlPanel's footprint so the
## target never lands under it.
const _TARGET_MARGIN_LEFT: float = 80.0
const _TARGET_MARGIN_TOP: float = 80.0
const _TARGET_MARGIN_RIGHT: float = 320.0
const _TARGET_MARGIN_BOTTOM: float = 100.0
#endregion


#region ============================== Private variables ==============================
var _active_sequence: TutorialSequence
var _step_index: int = -1
#endregion


#region ============================== Local nodes ==============================
@onready var _overlay: TutorialOverlay = %TutorialOverlay

@onready var _target_card_shop: Button = %CardShop
@onready var _target_card_container: Button = %CardContainer
@onready var _target_card_button: Button = %CardButton
@onready var _target_player_gold: Button = %PlayerGoldHBox
@onready var _target_refresh: Button = %RefreshButton
@onready var _target_end_buying: Button = %EndBuyingPhaseButton
@onready var _target_generic: Button = %FakeTargetGeneric
@onready var _demo_target: Button = %DemoTarget

@onready var _btn_play_hero: Button = %BtnPlaySeqHero
@onready var _btn_play_buying: Button = %BtnPlaySeqBuying
@onready var _btn_play_fighting: Button = %BtnPlaySeqFighting
@onready var _btn_play_end: Button = %BtnPlaySeqEnd

@onready var _btn_show_passive: Button = %BtnShowPassive
@onready var _btn_show_blocking: Button = %BtnShowBlocking
@onready var _btn_show_modal: Button = %BtnShowModal
@onready var _btn_randomize: Button = %BtnRandomize

@onready var _btn_force_advance: Button = %BtnForceAdvance
@onready var _btn_clear: Button = %BtnClear

@onready var _status_label: Label = %StatusLabel
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	_overlay.step_completed.connect(_on_overlay_step_completed)

	_btn_play_hero.pressed.connect(func(): _play_sequence(_SEQUENCES[0]))
	_btn_play_buying.pressed.connect(func(): _play_sequence(_SEQUENCES[1]))
	_btn_play_fighting.pressed.connect(func(): _play_sequence(_SEQUENCES[2]))
	_btn_play_end.pressed.connect(func(): _play_sequence(_SEQUENCES[3]))

	_btn_show_passive.pressed.connect(func(): _show_demo_step(TutorialStep.PopupMode.PASSIVE))
	_btn_show_blocking.pressed.connect(func(): _show_demo_step(TutorialStep.PopupMode.BLOCKING))
	_btn_show_modal.pressed.connect(func(): _show_demo_step(TutorialStep.PopupMode.MODAL_DIMMED))
	_btn_randomize.pressed.connect(_randomize_demo_target)

	_btn_force_advance.pressed.connect(_force_advance)
	_btn_clear.pressed.connect(_clear_all)

	_target_card_shop.pressed.connect(func(): _log_target_click("CardShop"))
	_target_card_container.pressed.connect(func(): _log_target_click("CardContainer"))
	_target_card_button.pressed.connect(func(): _log_target_click("CardButton"))
	_target_player_gold.pressed.connect(func(): _log_target_click("PlayerGoldHBox"))
	_target_refresh.pressed.connect(func(): _log_target_click("RefreshButton"))
	_target_end_buying.pressed.connect(func(): _log_target_click("EndBuyingPhaseButton"))
	_target_generic.pressed.connect(func(): _log_target_click("Generic"))
	_demo_target.pressed.connect(func(): _log_target_click("DemoTarget"))

	_set_status("Idle")
#endregion


#region ============================== Private functions ==============================
func _play_sequence(path: String) -> void:
	_clear_all()
	if not ResourceLoader.exists(path):
		_set_status("Sequence not found: " + path)
		return
	var seq: TutorialSequence = load(path)
	if seq == null or seq.steps.is_empty():
		_set_status("Sequence empty or invalid: " + path)
		return
	_active_sequence = seq
	_step_index = -1
	_advance_step()


func _advance_step() -> void:
	if _active_sequence == null: return
	_step_index += 1
	if _step_index >= _active_sequence.steps.size():
		_set_status("Sequence finished: " + String(_active_sequence.id))
		_active_sequence = null
		_step_index = -1
		return
	var step: TutorialStep = _active_sequence.steps[_step_index]
	var is_last: bool = _step_index == _active_sequence.steps.size() - 1
	_set_status("Playing %s — step %d/%d (%s)" % [String(_active_sequence.id), _step_index + 1, _active_sequence.steps.size(), String(step.id)])
	_overlay.present_step(step, is_last)


func _show_demo_step(mode: int) -> void:
	_clear_all()
	_randomize_demo_target()
	var step: TutorialStep = TutorialStep.new()
	step.id = &"proto_demo"
	step.text = _DEMO_SHORT_TEXT
	step.target_unique_name = &"DemoTarget"
	step.popup_mode = mode
	step.auto_advance_delay = 0.0
	_set_status("Demo at (%d, %d) — mode=%s" % [int(_demo_target.position.x), int(_demo_target.position.y), TutorialStep.PopupMode.keys()[mode]])
	_overlay.present_step(step, true)


## Moves DemoTarget to a random position inside the safe zone (no overlap with
## the ControlPanel) so the bubble can demonstrate all four arrow sides.
func _randomize_demo_target() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var target_size: Vector2 = _demo_target.size
	if target_size == Vector2.ZERO:
		target_size = _demo_target.custom_minimum_size

	var min_x: float = _TARGET_MARGIN_LEFT
	var max_x: float = viewport_size.x - _TARGET_MARGIN_RIGHT - target_size.x
	var min_y: float = _TARGET_MARGIN_TOP
	var max_y: float = viewport_size.y - _TARGET_MARGIN_BOTTOM - target_size.y

	if max_x <= min_x: max_x = min_x + 1.0
	if max_y <= min_y: max_y = min_y + 1.0

	_demo_target.position = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))


func _force_advance() -> void:
	if not _overlay.has_active_step():
		_set_status("No active step")
		return
	_overlay.complete_current_step()


func _clear_all() -> void:
	_active_sequence = null
	_step_index = -1
	_overlay.clear()
	_set_status("Cleared")


func _set_status(text: String) -> void:
	if _status_label != null:
		_status_label.text = text
	Verbose.debug("[Proto] " + text, Verbose.Category.TUTORIAL)


func _log_target_click(target_name: String) -> void:
	_set_status("Target clicked: " + target_name)
#endregion


#region ============================== Callbacks ==============================
func _on_overlay_step_completed(_step: TutorialStep) -> void:
	if _active_sequence != null:
		_advance_step()
	else:
		_set_status("Step completed (demo)")
#endregion
