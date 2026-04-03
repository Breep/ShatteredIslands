class_name UIPersistant
extends Control

# ============================== Local nodes ==============================

@onready var _game_state_viewer: UIGameStateViewer = %GameStateViewer
@onready var _ui_player_info: UIPlayerInfo = %UIPlayerInfo
@onready var _ui_all_player_portraits: UIAllPlayersPortrait = %AllPlayersPortrait
@onready var _ui_all_families_portraits: UIAllFamiliesPortrait = %UIAllFamiliesPortrait
@onready var _ui_family_viewer: UIFamilyViewer = %UiFamilyViewer

@onready var _end_buying_phase_button: Button = %EndBuyingPhaseButton

@export var _blink_wait_period: float = 10.0
@export var _blink_interval: float = 0.1
@export var _blink_duration: float = 0.15
@export var _blink_count: int = 5
@export var _urgent_threshold: float = 30.0

@onready var _blink_timer := Timer.new()
@onready var _urgent_timer := Timer.new()

@onready var _main_timer: Timer = %Timer

# ============================== Node base functions ==============================

func _ready() -> void:
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	_game_state_viewer.connect_timer(_main_timer)
	_ui_player_info.connect_to_player(PlayerManager.get_local_player())
	_ui_all_families_portraits.update_content(PlayerManager.get_local_player())
	_original_scale = _end_buying_phase_button.scale

	add_child(_blink_timer)
	_blink_timer.wait_time = _blink_wait_period
	_blink_timer.one_shot = false
	_blink_timer.timeout.connect(_play_blink)

	add_child(_urgent_timer)
	_urgent_timer.wait_time = _urgent_threshold
	_urgent_timer.one_shot = true
	_urgent_timer.timeout.connect(_on_urgent_timeout)

	_blink_timer.start()
	_urgent_timer.start()
	
	# TODO: J'aime pas comment c'est fait mais tout droit pour le moment
	Events.ui_family_portrait_requested.connect(_on_events_ui_family_portrait_requested)
	Events.ui_family_portrait_unselected.connect(_on_events_ui_family_portrait_unselected)

var _blink_tween: Tween
var _is_urgent: bool = false
var _original_scale: Vector2

# ============================== Private functions ==============================

func _play_blink() -> void:
	if _blink_tween and _blink_tween.is_running():
		return
	_blink_tween = create_tween()
	if _is_urgent:
		_blink_tween.set_loops()
	for i in _blink_count:
		_blink_tween.tween_property(_end_buying_phase_button, "modulate", Color.YELLOW, _blink_duration)
		_blink_tween.tween_property(_end_buying_phase_button, "modulate", Color.WHITE, _blink_duration)
		if i < _blink_count - 1:
			_blink_tween.tween_interval(_blink_interval)


func _enter_urgent_mode() -> void:
	_is_urgent = true
	_blink_timer.stop()
	if _blink_tween and _blink_tween.is_running():
		_blink_tween.kill()
	var scale_tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	scale_tween.tween_property(_end_buying_phase_button, "scale", _original_scale * 2.0, 0.3)
	_play_blink()


func _exit_urgent_mode() -> void:
	_is_urgent = false
	_urgent_timer.stop()
	_blink_timer.stop()
	if _blink_tween and _blink_tween.is_running():
		_blink_tween.kill()
	_end_buying_phase_button.modulate = Color.WHITE
	_end_buying_phase_button.scale = _original_scale


# ============================== Callbacks ==============================

func _on_round_manager_current_round_changed(round_number: int) -> void:
	_game_state_viewer.update_round_value(round_number)


func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	_game_state_viewer.update_game_state(game_state)
	_ui_family_viewer.hide()
	match game_state:
		GameManager.GameState.BUYING:
			_end_buying_phase_button.show()
			_ui_all_player_portraits.show()
			_ui_player_info.show()
			_blink_timer.start()
			_urgent_timer.start()
			_main_timer.wait_time = GameManager.game_rules.duration_buying_phase
		GameManager.GameState.FIGHTING:
			_end_buying_phase_button.hide()
			_ui_player_info.hide()
			_exit_urgent_mode()
			_main_timer.wait_time = GameManager.game_rules.duration_fighting_countdown + GameManager.game_rules.duration_fighting_normal \
				+ GameManager.game_rules.duration_fighting_special
	_main_timer.start()


func _on_urgent_timeout() -> void:
	_enter_urgent_mode()


func _on_end_buying_phase_button_pressed() -> void:
	GameManager.request_state_transition(GameManager.GameState.FIGHTING)


func _on_events_ui_family_portrait_requested(player: Player, family: Family) -> void:
	_ui_family_viewer.display_family(player, family)
	_ui_family_viewer.show()


func _on_events_ui_family_portrait_unselected() -> void:
	_ui_family_viewer.hide()















 
