class_name AllLevelsContainers
extends HBoxContainer

signal level_preview_changed(level: int)

@export var _level_containers: Array[LevelContainer]

func _ready() -> void:
	for level_container in _level_containers:
		level_container.activated.connect(_on_level_container_activated)


func _on_level_container_activated(level_container_activated: LevelContainer) -> void:
	for level_container in _level_containers:
		if level_container != level_container_activated:
			level_container.desactivate()
	
	print("HELLO ", level_container_activated.level)
