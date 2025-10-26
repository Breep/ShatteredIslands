class_name UIPersistant
extends Control

# ============================== Local nodes ==============================

@onready var _round_label: Label = %RoundLabel
@onready var _game_state_viewer: UIGameStateViewer = %GameStateViewer

# ============================== Node base functions ==============================

func _ready() -> void:
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	_game_state_viewer.connect_timer(GameManager.game_state_timer)

# ============================== Public functions ==============================



# ============================== Callbacks ==============================

func _on_round_manager_current_round_changed(round_number: int) -> void:
	_round_label.text = str("ROUND ") + str(round_number)

func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	_game_state_viewer.update_content(game_state)
	
