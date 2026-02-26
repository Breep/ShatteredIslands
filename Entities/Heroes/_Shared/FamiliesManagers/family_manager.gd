class_name FamilyManager
extends Node

var _owner: Hero # Ref to Hero owner
var level: int = 0 # Family level (0-4), computed from deck or overridden via prototyping

func _ready() -> void:
	if _owner == null:
		printerr("FamilyManager: Need a hero owner [", get_path(), "]")
		queue_free()


func init(hero_owner: Hero) -> FamilyManager:
	_owner = hero_owner
	return self


func start() -> void:
	printerr("FamilyManager: virtual start() called [", get_path(), "]")


func stop() -> void:
	printerr("FamilyManager: virtual stop() called [", get_path(), "]")


func pause() -> void:
	pass


func resume() -> void:
	pass
