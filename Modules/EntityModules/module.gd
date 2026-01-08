class_name Module
extends Node

enum ModuleType {
	MOVEMENT,
	ACTION,
	INTERACT,
	AUTOATTACK,
	TARGET
}

@export var _owner: Entity # Owner of the module

func init(entity_owner: Entity) -> Module:
	_owner = entity_owner
	return self

func _ready() -> void:
	if _owner == null:
		printerr("Module: undef source [", get_path(), "]")
