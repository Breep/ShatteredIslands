class_name SE_ReacteurCapacitif
extends SkillEffect

# Talent "Réacteur capacitif": la Tour gagne +_regen_per_building Mana Regen par bâtiment
# allié dans un rayon _radius (compté au début du combat).

@export var _radius: float = 10.0
@export var _regen_per_building: float = 1.0


func apply(ctx: SkillContext) -> void:
	var tower: AegisTower = ctx.entity as AegisTower
	if tower == null:
		Verbose.error("SE_ReacteurCapacitif: owner is not an AegisTower", Verbose.Category.ENTITY_MODULE)
		return

	tower.battle_callback_registry.register_battle_start(&"ReacteurCapacitif", func() -> void:
		var building_count: int = 0
		for ally: Entity in tower.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius):
			if is_instance_valid(ally) and ally.category == Entity.Category.BUILDING:
				building_count += 1
		var modifier := StatModifier.new()
		modifier.id = &"ReacteurCapacitif"
		modifier.stat_type = EntityStats.StatType.MANA_REGEN
		modifier.value = building_count * _regen_per_building
		tower.stat_modifiers_registry.register_modifier(modifier)
	)
