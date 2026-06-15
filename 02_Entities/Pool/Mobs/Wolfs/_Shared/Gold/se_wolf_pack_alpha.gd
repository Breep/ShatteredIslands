class_name SE_WolfPackAlpha
extends SkillEffect

# Gold partagé des loups "Alpha de la Meute" : bonus de stats plats, choisis via l'export
# _bonuses (clé = stat, valeur = montant). Par défaut deux bonus : crit et crit multiplier.

@export var _bonuses: Dictionary[EntityStats.StatType, float] = {
	EntityStats.StatType.CRIT_CHANCE: 20.0,
	EntityStats.StatType.CRIT_MULT: 20.0,
}


func apply(ctx: SkillContext) -> void:
	var wolf: Entity = ctx.entity
	if wolf == null:
		Verbose.error("SE_WolfPackAlpha: null owner", Verbose.Category.ENTITY_MODULE)
		return
	WolfFlatStats.apply_bonuses(wolf, _bonuses, &"WolfPackAlpha")


func get_description() -> String:
	return "Gagne " + WolfFlatStats.describe_bonuses(_bonuses, _value) + "."
