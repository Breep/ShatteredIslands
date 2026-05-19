class_name UIFightingArea
extends Control

# ============================== Local nodes ==============================

@onready var _ui_countdown: UICountdown = %Countdown
@onready var _ui_dps_meter: UIDPSMeter = %UiDpsMeter

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	hide()

# ============================== Public functions ==============================

func update_content(fighting_area: FightingArea) -> void:
	var heroes: Array[Hero] = fighting_area.get_fighting_heroes()
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
		GlobalFightingManager.FightingPhaseState.COUNTDOWN:
			_ui_countdown.start(int(GameManager.game_rules.duration_fighting_countdown), "FIGHT")






 
