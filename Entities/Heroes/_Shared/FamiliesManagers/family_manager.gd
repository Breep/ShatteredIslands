class_name FamilyManager
extends Node

var _owner: Hero # Ref to Hero owner

var _player: Player # TODO Check how to get this

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

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
