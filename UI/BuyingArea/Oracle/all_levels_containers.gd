class_name AllLevelsContainers
extends HBoxContainer

signal level_preview_changed(level: int)

@export var _level_containers: Array[UILevelContainer]

func _ready() -> void:
	for level_container in _level_containers:
		level_container.activated.connect(_on_level_container_activated)


func blink(player_level: int) -> void:
	_level_containers[player_level - 1].blink()


func update_player_xp(current_lvl: int, current_xp: int, max_xp: int) -> void:
	for i in current_lvl:
		_level_containers[i].unlock()
	
	if current_lvl < 10:
		_level_containers[current_lvl].set_xp_value(current_xp, max_xp)


func _on_level_container_activated(level_container_activated: UILevelContainer) -> void:
	for level_container in _level_containers:
		if level_container != level_container_activated:
			level_container.desactivate()
	level_preview_changed.emit(level_container_activated.level)
