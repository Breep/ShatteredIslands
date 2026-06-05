class_name SE_NoyauRenforce
extends SkillEffect

# Talent "Noyau renforcé": tant que la Tour est vivante, les bâtiments alliés dans un rayon
# _radius gagnent +_defense Defense. Appliqué au début du combat, retiré si la Tour meurt.

@export var _radius: float = 10.0
@export var _defense: float = 15.0


func apply(ctx: SkillContext) -> void:
	var tower: AegisTower = ctx.entity as AegisTower
	if tower == null:
		Verbose.error("SE_NoyauRenforce: owner is not an AegisTower", Verbose.Category.ENTITY_MODULE)
		return

	var buffed: Array[Entity] = []
	tower.battle_callback_registry.register_battle_start(&"NoyauRenforce", func() -> void:
		for ally: Entity in tower.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius):
			if is_instance_valid(ally) and ally.category == Entity.Category.BUILDING:
				ally.alterations.add_stack(Alteration.Type.DEFENSE, _defense, tower, &"Noyau renforcé")
				buffed.append(ally)
	)
	# À la mort de la Tour : on annule le buff en ajoutant autant de Vulnerability
	# (opposée de Defense → se compense, et passe en négatif si besoin).
	tower.died.connect(func(_self_ref: Entity) -> void:
		for ally: Entity in buffed:
			if is_instance_valid(ally):
				ally.alterations.add_stack(Alteration.Type.VULNERABILITY, _defense, tower, &"Noyau renforcé")
	)
