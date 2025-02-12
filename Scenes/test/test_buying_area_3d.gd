extends Node3D


func _on_timer_timeout() -> void:
	GameManager.game_switch_to(GameManager.GameState.Fighting)
