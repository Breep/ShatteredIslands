class_name ActionModifier
extends Node

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

enum VarType { # Variable types of the callbacks dictionary
	VISUAL_POS,
	PHYSICAL_DAMAGE,
	STACK_VALUE,
	STACK_TYPE,
	TARGET,
	DODGE_NUMBER,
	HEAL_AMOUNT,
	DURATION
}


var id: StringName
var action_type: Utils.ActionCategory
var tags: Array[TagType]
var is_one_time_effect: bool = true
var auto_cleanup: bool = true

var before_action_logic_callback := Callable() # var: Dictionary
var after_action_logic_callback := Callable() # var: Dictionary
var visual_callback := Callable() # var: Dictionary
