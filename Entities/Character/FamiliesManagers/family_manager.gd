class_name FamilyManager
extends Node

var source: Character # Ref to character owner

@export var _action_module: ActionModule

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

func _ready() -> void:
	if source == null:
		printerr("FamilyManager: Need a character_owner [", get_path(), "]")
	
	if _action_module == null:
		printerr("FamilyManager: Need a ref to the character owner ActionModule [", get_path(), "]")
	
	_optional_spells.clear()
	_optional_timers.clear()


func init() -> void:
	_specific_init()


func _specific_init() -> void:
	pass
