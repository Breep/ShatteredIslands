# Carte de prototypage : ×4 la taille des AoE émises par le héros porteur.
# Valide la nouvelle stat EntityStats.AOE_SIZE à travers le pipeline StatModifier
# (registry du héros) : MULT puis remove en miroir.
class_name CardPrototypingAoeSize
extends CardEffect

# 3.0 car la stat finale = (base + ΣADD) × (1 + ΣMULT) : 1 × (1 + 3) = ×4.
const AOE_SIZE_MULT: float = 3.0


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.AOE_SIZE
	mod.calc_type = StatModifier.CalcType.MULT
	mod.value = AOE_SIZE_MULT
	ctx.entity_owner.stat_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AOE_SIZE, card_name)


func get_description(_card_lvl: int) -> String:
	return "×4 la taille des zones d'effet (AoE)."
