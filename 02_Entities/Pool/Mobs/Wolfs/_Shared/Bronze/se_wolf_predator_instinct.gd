class_name SE_WolfPredatorInstinct
extends SkillEffect

# Bronze partagé des loups "Instinct du Prédateur" : bonus de stats plats, choisis via
# l'export _bonuses (clé = stat, valeur = montant). Par défaut +20 de chance de crit.

@export var _bonuses: Dictionary[EntityStats.StatType, float] = {
	EntityStats.StatType.CRIT_CHANCE: 20.0,
}


func apply(ctx: SkillContext) -> void:
	var wolf: Entity = ctx.entity
	if wolf == null:
		Verbose.error("SE_WolfPredatorInstinct: null owner", Verbose.Category.ENTITY_MODULE)
		return
	WolfFlatStats.apply_bonuses(wolf, _bonuses, &"WolfPredatorInstinct")


func get_description() -> String:
	return "Gagne " + WolfFlatStats.describe_bonuses(_bonuses, _value) + "."
