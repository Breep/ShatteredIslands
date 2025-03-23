class_name UIPlayerLife
extends Control

# ============================== Public variables ==============================

var player_health: int

# ============================== Private variables ==============================

var _player_max_life: int

# ============================== Local nodes ==============================

@onready var _health_progress_bar: TextureProgressBar = %HealthProgressBar
@onready var _health_value_label: Label = %HealthValueLabel

# ============================== Public functions ==============================

func update_player_life(new_player_current_health: int, new_player_max_health: int) -> void:
	_update_player_life(new_player_current_health, new_player_max_health)
	_player_max_life = new_player_max_health


func connect_to_player_health_signal(player_health_signal: Signal) -> void:
	player_health_signal.connect(_on_player_health_changed)


func connect_to_player_max_health_signal(player_max_health_signal: Signal) -> void:
	player_max_health_signal.connect(_on_player_max_health_changed)

# ============================== Private functions ==============================

func _update_player_life(new_player_current_health: int, new_player_max_health: int) -> void:
	_health_value_label.text = str(new_player_current_health)
	_health_progress_bar.max_value = new_player_max_health
	_health_progress_bar.value = new_player_current_health
	player_health = new_player_current_health
	_player_max_life = new_player_max_health

# ============================== Callbacks ==============================

func _on_player_health_changed(new_health) -> void:
	_update_player_life(new_health, _player_max_life)


func _on_player_max_health_changed(new_max_health) -> void:
	_update_player_life(player_health, new_max_health)
