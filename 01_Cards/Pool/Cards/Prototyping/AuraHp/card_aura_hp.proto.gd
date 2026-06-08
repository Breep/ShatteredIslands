# Carte de prototypage : aura de vie. Le héros porteur distribue +X PV max à TOUS
# ses alliés (présents et futurs) via son AuraComponent. Valide la propagation push
# de l'aura : add au apply, remove en miroir au revert, révocation auto à la mort.
class_name CardPrototypingAuraHp
extends CardEffect

const AURA_HP_BONUS: float = 500.0


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var mod := StatModifier.new()
	mod.id = card_name
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = AURA_HP_BONUS
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	owner.aura.add_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.aura.remove_modifier(card_name)


func get_description(_card_lvl: int) -> String:
	return "Aura : tous les alliés gagnent +%d PV max." % int(AURA_HP_BONUS)
