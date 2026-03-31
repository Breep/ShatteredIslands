class_name UIPersistant
extends Control

# ============================== Local nodes ==============================

@onready var _game_state_viewer: UIGameStateViewer = %GameStateViewer
@onready var _ui_player_info: UIPlayerInfo = %UIPlayerInfo
@onready var _ui_all_player_portraits: UIAllPlayersPortrait = %AllPlayersPortrait
@onready var _ui_all_families_portraits: UIAllFamiliesPortrait= %UIAllFamiliesPortrait

# ============================== Node base functions ==============================

func _ready() -> void:
	RoundManager.current_round_changed.connect(_on_round_manager_current_round_changed)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	_game_state_viewer.connect_timer(GameManager.game_state_timer)
	_ui_player_info.connect_to_player(PlayerManager.get_local_player())
	_ui_all_families_portraits.update_content(PlayerManager.get_local_player())

# ============================== Public functions ==============================



# ============================== Callbacks ==============================

func _on_round_manager_current_round_changed(round_number: int) -> void:
	_game_state_viewer.update_round_value(round_number)


func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	_game_state_viewer.update_game_state(game_state)
	match game_state:
		GameManager.GameState.BUYING:
			_ui_all_player_portraits.show()
			_ui_player_info.show()
		GameManager.GameState.FIGHTING:
			_ui_player_info.hide()
