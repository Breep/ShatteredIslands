class_name FamilyManager
extends Node

var _source: Character # Ref to character owner

var _action_module: ActionModule

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

func init(source: Character) -> void:
	if source == null:
		printerr("FamilyManager: source undef")
		return
	
	var action_modules = source.find_children("", "ActionModule", true, false)
	if action_modules.is_empty():
		printerr("FamilyManager: An ActionModule is mandatory on the owner")
		return
	
	_action_module = action_modules[0]
	_source = source
	_specific_init()


func _specific_init() -> void:
	pass
