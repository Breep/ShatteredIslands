class_name UIPlayerInfo
extends Control

# ============================== Local nodes ==============================

@onready var _ui_player_life: UIPlayerLife = %UIPlayerLife
@onready var _ui_player_gold_label: Label = %PlayerGoldLabel

# ============================== Private variables ==============================

var _player: Player

# ============================== Public functions ==============================

func connect_to_player(new_player: Player) -> void:
	if new_player == null:
		printerr("UIPlayerInfo: Trying to connect to a <null> hero")
		return
	
	_player = new_player
	_ui_player_life.connect_to_player_health_signal(_player.health_changed)
	_ui_player_life.connect_to_player_max_health_signal(_player.max_health_changed)
	_ui_player_life.update_player_life(_player.health, _player.max_health)
	_player.gold_changed.connect(_on_player_gold_changed)
	_ui_player_gold_label.text = str(_player.gold)

# ============================== Callbacks ==============================

func _on_player_gold_changed(_player_ref: Player, new_gold: int) -> void:
	_ui_player_gold_label.text = str(new_gold)
