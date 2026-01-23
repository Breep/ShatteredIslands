class_name StackModifier
extends Node

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

enum VarType {
	STACK_VALUE,
	STACK_TYPE,
	SOURCE,
	TARGET,
	DAMAGE_TYPE
}

enum ModifierType {
	ARMOR_REDUCTION, # Modifies how armor reduces damage
	ARMOR_CONSUMPTION, # Modifies if armor is consumed
	POISON_BLOCKING, # Allows armor to block poison
	STACK_GAIN, # Modifies stack gain amount
	STACK_LOSS # Modifies stack loss amount
}

var id: StringName
var modifier_type: ModifierType
var tags: Array[TagType]
var is_one_time_effect: bool = true
var auto_cleanup: bool = true

# Callbacks for different stages
var before_stack_logic_callback := Callable() # var: Dictionary
var after_stack_logic_callback := Callable() # var: Dictionary
