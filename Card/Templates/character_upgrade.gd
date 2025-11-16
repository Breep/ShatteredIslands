class_name CharacterUpgrade
extends Resource

func apply(_stats: FamiliesStats, _cardLvl: int) -> void:
	push_warning("[CharacterUpgrade] call virtual apply()")
	pass


func get_description(_cardlvl: int) -> String:
	push_warning("[CharacterUpgrade] call virtual get_description()")
	return ""


var action_modifiers: Array[ActionModifier]
var auto_attack_modifiers: Array[AutoAttackModifier]
var on_battle_start: Callable
var on_battle_end: Callable
var on_buying_start: Callable
var on_buying_end: Callable
