class_name AutoAttackModifier
extends Resource

# ============================== Enum ==============================

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

enum VarType {
	VISUAL_POS,
	PHYSICAL_DAMAGE
}

# ============================== Public variables ==============================

var id: StringName
var damage_flat: float
var damage_mult: float
var tags: Array[TagType]
var is_one_time_effect: bool = true

var on_attack_logic_callback := Callable() # var: Dictionary
var on_attack_visual_callback := Callable() # var: Dictionary
var on_hit_logic_callback := Callable() # var: Dictionary
var on_hit_visual_callback := Callable() # var: Dictionary
