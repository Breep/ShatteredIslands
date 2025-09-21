class_name UIFightingArea
extends Control

# ============================== Local nodes ==============================

@onready var _continuous_timer: UIContinousTimer = %ContinousTimer
@onready var _countdown: UICountdown = %Countdown

@onready var _ui_own_entity_stats: UIEntityStats = %OwnEntityStats
@onready var _ui_selected_entity_stats: UIEntityStats = %SelectedEntityStats

# ============================== Private variables ==============================

var _battle_id: int
var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	hide()
	GlobalFightingManager.countdown_started.connect(_on_global_fighting_manager_countdown_started)
	_continuous_timer.connect_timer(GlobalFightingManager.timer)
	Events.entity_cliked.connect(_on_events_entity_clicked)

# ============================== Public functions ==============================

func start(battle_id: int) -> void:
	_battle_id = battle_id


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()
	if not multiplayer.is_server() or GameManager.game_type == GameManager.GameType.SOLO:
		_ui_own_entity_stats.connect_entity_stats(PlayerManager.get_local_player().character)


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	hide()

# ============================== Private functions ==============================

# ============================== Callbacks ==============================

func _on_global_fighting_manager_countdown_started(countdown_value: int, endword: String) -> void:
	_countdown.start(countdown_value, endword)


func _on_events_entity_clicked(entity: Entity) -> void:
	if not _is_active: return
	_ui_selected_entity_stats.connect_entity_stats(entity)








 
