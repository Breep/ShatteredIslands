# Orchestrateur UI : conteneur des panneaux de phase (tavern / combat / result)
# et du HUD persistant. Piloté de l'extérieur par RunRoot via une API explicite —
# aucun couplage aux autoloads de gameplay.
class_name UIGame
extends Control

# ============================== Signals ==============================

signal result_leave_requested

# ============================== Local nodes ==============================

@onready var _ui_buying_area: UIBuyingArea = %BuyingArea
@onready var _ui_fighting_area: UIFightingArea = %FightingArea
@onready var _ui_result: UIResult = %Result
@onready var _ui_transition_screen: UITransitionScreen = %TransitionScreen
@onready var _ui_persistant: UIPersistant = %Persistant

# ============================== Node base functions ==============================

func _ready() -> void:
	_ui_buying_area.hide()
	_ui_persistant.hide()
	_ui_result.leave_requested.connect(func(): result_leave_requested.emit())

# ============================== Public functions ==============================

func bind_to_local_player(player: Player) -> void:
	_ui_persistant.bind_to_local_player(player)


func start_tavern_phase() -> void:
	_ui_persistant.show()
	_ui_persistant.show_hand()
	_ui_buying_area.set_active()


func end_tavern_phase() -> void:
	_ui_buying_area.set_inactive()


func start_fighting_phase(fighting_area: FightingArea) -> void:
	_ui_fighting_area.update_content(fighting_area)
	_ui_fighting_area.set_active()
	_ui_persistant.hide_hand()


func end_fighting_phase() -> void:
	_ui_fighting_area.set_inactive()


func play_transition(duration: float) -> void:
	_ui_transition_screen.start_transition(duration)


func show_run_result(player_place: int) -> void:
	_ui_result.show_result(player_place)
