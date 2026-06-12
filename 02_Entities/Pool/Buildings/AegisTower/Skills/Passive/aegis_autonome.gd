class_name SE_AegisAutonome
extends SkillEffect

# Passif "Aegis autonome" (Rush): au début du combat, invoque 1 Aegis Blade liée à la Tour.
# La blade hérite du niveau de la Tour et meurt si la Tour meurt.

@export var _spawn_distance: float = 2.0


func apply(ctx: SkillContext) -> void:
	var tower: AegisTower = ctx.entity as AegisTower
	if tower == null:
		Verbose.error("SE_AegisAutonome: owner is not an AegisTower", Verbose.Category.ENTITY_MODULE)
		return
	tower.battle_callback_registry.register_battle_start(&"AegisAutonome", func() -> void:
		_summon_linked_blade(tower)
	)


func get_description() -> String:
	return "Au début du combat, invoque une Aegis Blade liée à la Tour (à son niveau, " \
		+ "elle meurt si la Tour meurt)."


func _summon_linked_blade(tower: AegisTower) -> void:
	if tower.summon == null:
		return
	var spawn_cfg := SpawnLocationConfig.create_entity_relative(tower, _spawn_distance)
	var spawn_manager: SpawnManager = tower.get_context().spawn_manager
	if spawn_manager == null:
		tower.summon.summon_entity(Entity.EntityType.AEGIS_BLADE, spawn_cfg, {})
		return

	var spawned: Array[Entity] = []
	var capture := func(entity: Entity) -> void: spawned.append(entity)
	spawn_manager.entity_spawned.connect(capture)
	tower.summon.summon_entity(Entity.EntityType.AEGIS_BLADE, spawn_cfg, {})
	spawn_manager.entity_spawned.disconnect(capture)

	for blade: Entity in spawned:
		if not is_instance_valid(blade):
			continue
		# Niveau hérité de la Tour.
		if blade.progression != null and tower.progression != null:
			blade.progression.level = tower.progression.level
		# Lien de mort : la blade meurt avec la Tour.
		tower.died.connect(func(_self_ref: Entity) -> void:
			if is_instance_valid(blade) and blade.is_alive():
				blade.stats.health = 0
		)
