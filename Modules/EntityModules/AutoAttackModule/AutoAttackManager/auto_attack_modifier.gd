class_name AutoAttackModifier
extends Resource

# ============================== Enum ==============================

enum TagType {
	CARD,
	HERO,
	QUEST,
	EVENT
}

# ============================== Public variables ==============================

var id: StringName
var damage_flat: float
var damage_mult: float
var tags: Array[TagType]
var is_one_time_effect: bool = true

var on_attack_logic_callable: Callable
var on_attack_visual_callable: Callable
var on_hit_logic_callable: Callable
var on_hit_visual_callable: Callable
