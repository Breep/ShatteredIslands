class_name FamilyManager
extends Node

var source: Character # Ref to character owner

@export var _action_module: ActionModule

var _optional_timers: Array[Timer]
var _optional_spells: Array[Node]

func init() -> void:
	_specific_init()


func connect_external_signal(external_signal: Signal) -> void:
	pass


func _specific_init() -> void:
	pass
