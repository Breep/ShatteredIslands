class_name AutoAttackModifier
extends Resource

# ============================== Enum ==============================

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

enum VarType { # Variable types of the callbacks dictionary
	SOURCE,
	TARGET,
	POSITION,
	DAMAGE,
	DAMAGE_ADD,
	DAMAGE_MUL,
	PROJECTILE
}

# ============================== Public variables ==============================

var id: StringName
var add: float # Flat damage add
var mul: float # % damage mult
var tags: Array[TagType]
var is_one_time_effect: bool = true

var damage_modifier_callback := Callable()
var additional_effect_callback := Callable() # var: Dictionary
