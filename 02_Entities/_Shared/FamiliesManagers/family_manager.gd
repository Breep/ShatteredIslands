class_name FamilyManager
extends Node

var _owner: Entity # Ref to owner entity
var level: int = 0 # Family level (0-4), computed from hand or overridden via prototyping

func _ready() -> void:
	if _owner == null:
		printerr("FamilyManager: Need a hero owner [", get_path(), "]")
		queue_free()


func init(entity_owner: Entity) -> FamilyManager:
	_owner = entity_owner
	return self


func start() -> void:
	printerr("FamilyManager: virtual start() called [", get_path(), "]")


func stop() -> void:
	printerr("FamilyManager: virtual stop() called [", get_path(), "]")


func apply_passive() -> void:
	pass
