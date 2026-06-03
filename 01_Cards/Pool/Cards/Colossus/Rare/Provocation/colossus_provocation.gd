class_name ColossusProvocation
extends CardEffect

## Colossus — provoque les ennemis (taunt permanent) et augmente la défense.

@export var _defense: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.alterations == null: return
	owner.alterations.add_stack(Alteration.Type.DEFENSE, _defense[card_lvl - 1])
	owner.alterations.inflict_status(owner, Alteration.Type.TAUNT, -1, card_name)


func revert(ctx: CardContext, _card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.alterations == null: return
	owner.alterations.cancel_state(Alteration.Type.TAUNT)
	owner.alterations.remove_stack(Alteration.Type.DEFENSE, _defense[card_lvl - 1])


func get_description(card_lvl: int) -> String:
	return "Provoque les ennemis ([[TAUNT]]) et augmente la [[DEFENCE]] de " \
		+ str(_defense[card_lvl - 1]) + "."
