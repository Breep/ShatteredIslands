class_name AttackWarBanner
extends CardEffect

## Warrior — aura : augmente la vitesse d'attaque de toute l'équipe.

@export var _as_percent: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.aura == null: return
	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.AS
	mod.calc_type = StatModifier.CalcType.MULT
	mod.value = _as_percent[card_lvl - 1] / 100.0
	mod.tags = [StatModifier.TagType.CARD]
	owner.aura.add_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.aura != null:
		owner.aura.remove_modifier(card_name)


func get_description(card_lvl: int) -> String:
	return "Aura : +" + str(_as_percent[card_lvl - 1]) + "% de vitesse d'attaque pour l'équipe."
