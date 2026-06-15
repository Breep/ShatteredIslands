class_name SE_WolfWarCry
extends SkillEffect

# Ultimate partagé des loups "Cri de Guerre" : au déclenchement, tous les alliés à moins
# de _radius m gagnent des bonus de stats plats pour le combat, choisis via l'export
# _bonuses (clé = stat, valeur = montant). Buff permanent (pas de retrait).

@export var _bonuses: Dictionary[EntityStats.StatType, float] = {
	EntityStats.StatType.CRIT_CHANCE: 15.0,
	EntityStats.StatType.ARMOR: 10.0,
}
@export var _radius: float = 5.0


func apply(ctx: SkillContext) -> void:
	var wolf: Entity = ctx.entity
	if wolf == null:
		Verbose.error("SE_WolfWarCry: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var allies: Array[Entity] = wolf.target.get_targets(
		TargetComponent.MultipleTargettingStrategy.ALLIES, _radius)
	for ally: Entity in allies:
		if is_instance_valid(ally):
			WolfFlatStats.apply_bonuses(ally, _bonuses, &"WolfWarCry")


func get_description() -> String:
	return "Pousse un cri de guerre : les alliés à moins de " + _value(_radius) + " m gagnent " \
		+ WolfFlatStats.describe_bonuses(_bonuses, _value) + "."
