class_name HeroUpgrade
extends Resource

enum VarType {
	HERO_OWNER,
	ACTION_MODIFIERS_MANAGER,
	AUTO_ATTACK_MODIFIERS_MANAGER,
	STAT_MODIFIERS_MANAGER,
	FAMILIES_STATS,
}

func apply(_stats: FamiliesStats, _cardLvl: int) -> void:
	push_warning("[HeroUpgrade] call virtual apply()")
	pass


func get_description(_cardlvl: int) -> String:
	push_warning("[HeroUpgrade] call virtual get_description()")
	return ""


var action_modifiers: Array[ActionModifier]

var auto_attack_modifiers: Array[AutoAttackModifier]

var on_battle_start: Callable

var on_battle_end: Callable

var on_purchase: Callable

var periodic_callback: Callable
var periodic_callback_wait_time: float
