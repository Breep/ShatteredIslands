class_name UIFightingArea
extends Control

# ============================== Local nodes ==============================

#region Layout 1v1
@onready var _layout_1v1: Control = %Layout_1v1
#endregion

#region Layout 2v2
@onready var _layout_2v2: Control = %Layout_2v2
#endregion

@onready var _ui_countdown: UICountdown = %Countdown

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	hide()

# ============================== Public functions ==============================

func update_content(fighting_area: FightingArea) -> void:
	var battle_type: Battle.BattleType = fighting_area.get_battle_type()
	var heroes: Array[Hero] = fighting_area.get_fighting_heroes()
	match battle_type:
		Battle.BattleType.VS_1: _set_layout_1v1(heroes)
		Battle.BattleType.VS_2: _set_layout_2v2(heroes)
		Battle.BattleType.FFA_SOLO_3: _set_layout_2v2(heroes)


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

func _set_layout_1v1(heroes: Array[Hero]) -> void:
	_layout_1v1.hide()
	_layout_2v2.hide() # TODO: Remove this
	return
	if heroes.is_empty():
		push_warning("UIFightingArea: There is no heroes in the 1v1 fighting area")
		return
	_layout_1v1.show()
	_layout_2v2.hide()


func _set_layout_2v2(heroes: Array[Hero]) -> void:
	_layout_1v1.hide()
	_layout_2v2.hide() # TODO: Remove this
	return
	if heroes.is_empty():
		push_warning("UIFightingArea: There is no heroes in the 2v2 fighting area")
		return
	_layout_2v2.show()
	_layout_1v1.hide()

# ============================== Callbacks ==============================

func _on_gfm_fighting_phase_state_changed(fighting_phase_state: GlobalFightingManager.FightingPhaseState) -> void:
	match fighting_phase_state:
		GlobalFightingManager.FightingPhaseState.COUNTDOWN:
			_ui_countdown.start(int(GameManager.game_rules.duration_fighting_countdown), "FIGHT")






 
