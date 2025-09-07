extends Node

# All game manager
func reset_all_managers() -> void:
	_clear_all_managers()
	_init_all_managers()


func _clear_all_managers() -> void:
	GlobalFightingManager.clear()
	PlayerManager.clear()
	RoundManager.clear()
	GameManager.clear()


func _init_all_managers() -> void:
	GameManager.init()
