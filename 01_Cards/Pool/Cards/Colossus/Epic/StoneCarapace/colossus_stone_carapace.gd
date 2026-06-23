class_name ColossusStoneCarapace
extends CardEffect

## Colossus — quand le héros subit des dégâts, une chance d'étourdir l'attaquant.

const DAMAGE_TYPES: Array[Utils.ActionType] = [
	Utils.ActionType.DAMAGE_PHYSICAL,
	Utils.ActionType.DAMAGE_MAGICAL,
	Utils.ActionType.DAMAGE_POISON,
	Utils.ActionType.DAMAGE_PURE,
]

@export var _chance: Array[float]
@export var _stun_duration: Array[float]

var _on_received: Callable

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance[card_lvl - 1]
	var stun_duration: float = _stun_duration[card_lvl - 1]

	_on_received = func(source: Entity, action_type: Utils.ActionType, _action_id: StringName, _value: float, _is_critical: bool) -> void:
		if not is_instance_valid(source) or source == owner: return
		if action_type not in DAMAGE_TYPES: return
		if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return
		owner.alterations.direct_status(source, Alteration.Type.STUN, stun_duration, card_name)
	owner.action_received.connect(_on_received)


func revert(ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if _on_received.is_valid() and owner.action_received.is_connected(_on_received):
		owner.action_received.disconnect(_on_received)


func get_description(card_lvl: int) -> String:
	return "Touché : " + _value(_chance[card_lvl - 1]) \
		+ "% d'appliquer [[STUN]] " + _value(_stun_duration[card_lvl - 1]) + "s à l'attaquant."
