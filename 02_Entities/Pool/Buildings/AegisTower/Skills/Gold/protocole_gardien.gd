class_name SE_ProtocoleGardien
extends SkillEffect

# Talent "Protocole gardien": la première fois qu'un héros allié passe sous _hp_threshold
# de ses PV, la Tour lui donne AP x _ap_ratio Shield (une seule fois par combat).

@export var _hp_threshold: float = 0.35
@export var _ap_ratio: float = 2.5


func apply(ctx: SkillContext) -> void:
	var tower: AegisTower = ctx.entity as AegisTower
	if tower == null:
		Verbose.error("SE_ProtocoleGardien: owner is not an AegisTower", Verbose.Category.ENTITY_MODULE)
		return

	var triggered: Array[bool] = [false]
	tower.battle_callback_registry.register_battle_start(&"ProtocoleGardien", func() -> void:
		for ally: Entity in tower.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
			if not is_instance_valid(ally) or ally.category != Entity.Category.HERO:
				continue
			ally.stats.health_changed.connect(func(new_health: float) -> void:
				if triggered[0] or ally.stats.health_max <= 0.0:
					return
				if new_health / ally.stats.health_max <= _hp_threshold:
					triggered[0] = true
					var shield: float = tower.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
					tower.alterations.inflict_condition_stacks(ally, shield, Alteration.Type.SHIELD, &"Protocole gardien")
			)
	)
