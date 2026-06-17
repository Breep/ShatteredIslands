class_name ColossusBlastRadius
extends CardEffect

## Colossus — aura : augmente la taille des zones d'effet (AoE) de toute l'équipe.
## AOE_SIZE est une stat MULT (finale = base × (1 + ΣMULT)).

@export var _aoe_mult: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.aura == null: return
	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.AOE_SIZE
	mod.calc_type = StatModifier.CalcType.MULT
	mod.value = _aoe_mult[card_lvl - 1]
	mod.tags = [StatModifier.TagType.CARD]
	owner.aura.add_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.aura != null:
		owner.aura.remove_modifier(card_name)


func get_description(card_lvl: int) -> String:
	return "Aura : +" + _value(int(round(_aoe_mult[card_lvl - 1] * 100))) \
		+ "% de taille des zones d'effet (AoE) pour l'équipe."
