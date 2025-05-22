class_name Module
extends Node

enum ModuleType {
	MOVEMENT,
	ACTION,
	INTERACT,
	AUTOATTACK,
	TARGET
}

@export var source: Entity # Owner of the module

func _ready() -> void:
	if source == null:
		printerr("Module: undef source [", get_path(), "]")
