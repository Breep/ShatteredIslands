class_name SE_AshBrood
extends SkillEffect

# Gold "Couvée de cendres": on each landing (Vol fracassant passive), summon
# _golem_count Molten Golems — each heralded by a meteor that falls on a random
# arena spot and spawns the golem on impact (the golem plays its JumpEnd landing).

#const _METEOR_SCENE: PackedScene = preload("res://03_SpellsAndProjectiles/Spells/Meteor/meteor.tscn")

@export var _golem_count: int = 2

func apply(ctx: SkillContext) -> void:
	var dragon: SkeletonDragon = ctx.entity as SkeletonDragon
	if dragon == null:
		Verbose.error("SE_AshBrood: owner is not a SkeletonDragon", Verbose.Category.ENTITY_MODULE)
		return
	var ability: ShatteringFlightAbility = dragon.get_flight_ability()
	if ability == null:
		Verbose.error("SE_AshBrood: dragon has no flight ability", Verbose.Category.ENTITY_MODULE)
		return

	ability.flight_landing_impact.connect(func() -> void: _drop_golems(dragon))


func _drop_golems(dragon: SkeletonDragon) -> void:
	var context: EntityContext = dragon.get_context()
	if context.spawn_manager == null or context.arena_zone_manager == null:
		Verbose.warn("SE_AshBrood: missing spawn/arena manager", Verbose.Category.ENTITY_MODULE)
		return

	for i in _golem_count:
		var pos: Vector3 = context.arena_zone_manager.get_random_position_in_arena()
		# The meteor herald (0 damage); its on-hit callback summons the golem at impact.
		var spawn_golem: Callable = func(_data: Dictionary) -> void:
			dragon.summon.summon_entity(Entity.EntityType.MOLTEN_GOLEM, SpawnLocationConfig.create_exact(pos), {})

		#var meteor: Meteor = _METEOR_SCENE.instantiate()
		#meteor.init_at_position(pos, 0.0, 0.0, 1.0, [spawn_golem], dragon)
		#context.spawn_manager.spawn_spell(meteor)
