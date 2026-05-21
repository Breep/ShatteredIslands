class_name UIFightingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _ui_dps_meter: UIDPSMeter = %UiDpsMeter
@onready var _advance_button: Button = %AdvanceButton

# ============================== Private variables ==============================

var _is_active: bool = false
var _fighting_area: FightingArea = null

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	_advance_button.pressed.connect(_on_advance_button_pressed)
	_advance_button.hide()
	hide()

# ============================== Public functions ==============================

func update_content(fighting_area: FightingArea) -> void:
	_fighting_area = fighting_area
	var heroes: Array[Entity] = fighting_area.get_fighting_heroes()
	_ui_dps_meter.set_heroes(heroes)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

# ============================== Callbacks ==============================

func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.POSITIONING:
			_advance_button.text = "READY"
			_advance_button.show()
		GlobalFightingManager.FightingPhaseState.COUNTDOWN:
			_advance_button.hide()
			_ui_countdown.start(int(GameManager.game_rules.duration_fighting_countdown), "FIGHT")
		GlobalFightingManager.FightingPhaseState.CELEBRATION:
			_advance_button.text = "NEXT"
			_advance_button.show()
		_:
			_advance_button.hide()


func _on_advance_button_pressed() -> void:
	if _fighting_area == null or _fighting_area.fighting_manager == null:
		Verbose.warn("UIFightingArea.AdvanceButton pressed but no FightingArea bound", Verbose.Category.FIGHTING_AREA)
		return
	_advance_button.hide()
	_fighting_area.fighting_manager.request_phase_advance()
