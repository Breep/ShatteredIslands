class_name SE_AshBrood
extends SkillEffect

# Gold "Couvée de cendres": on takeoff (Vol fracassant passive), summon two Molten
# Golems in opposite arena corners (top-left + bottom-right), each heralded by a
# fire-twist VFX at its spawn point.

const _SPAWN_VFX: PackedScene = preload("res://02_Entities/Pool/Mobs/SkeletonDragon/VFX/VFX_FireTwist_Q1.tscn")

# (x_sign, z_sign) of each golem's arena corner — opposite corners of one diagonal.
const _CORNERS: Array[Vector2] = [Vector2(-1.0, 1.0), Vector2(1.0, -1.0)]

## Distance pulled inward from the arena edge so golems never spawn on/over the boundary.
@export var _corner_inset: float = 2.0

func apply(ctx: SkillContext) -> void:
	var dragon: SkeletonDragon = ctx.entity as SkeletonDragon
	if dragon == null:
		Verbose.error("SE_AshBrood: owner is not a SkeletonDragon", Verbose.Category.ENTITY_MODULE)
		return
	var ability: ShatteringFlightAbility = dragon.get_flight_ability()
	if ability == null:
		Verbose.error("SE_AshBrood: dragon has no flight ability", Verbose.Category.ENTITY_MODULE)
		return

	ability.flight_started.connect(func() -> void: _spawn_golems(dragon))


func _spawn_golems(dragon: SkeletonDragon) -> void:
	var context: EntityContext = dragon.get_context()
	if context.spawn_manager == null or context.arena_zone_manager == null:
		Verbose.warn("SE_AshBrood: missing spawn/arena manager", Verbose.Category.ENTITY_MODULE)
		return

	# spawn_entity emits entity_spawned synchronously, so capturing around the calls below
	# collects exactly the golems this brood spawned (used to know when it is wiped out).
	var golems: Array[Entity] = []
	var capture: Callable = func(e: Entity) -> void: golems.append(e)
	context.spawn_manager.entity_spawned.connect(capture)
	for corner: Vector2 in _CORNERS:
		var pos: Vector3 = context.arena_zone_manager.get_arena_corner(corner.x, corner.y, _corner_inset)
		context.spawn_manager.spawn_vfx(_SPAWN_VFX, pos)
		dragon.summon.summon_entity(Entity.EntityType.MOLTEN_GOLEM, SpawnLocationConfig.create_exact(pos), {})
	context.spawn_manager.entity_spawned.disconnect(capture)

	_match_golem_levels(dragon, golems)

	# Keep the dragon sweeping (Vol fracassant) until this brood is wiped out. The flight
	# ability polls the list each tick, so a golem freed without a death signal still releases it.
	var ability: ShatteringFlightAbility = dragon.get_flight_ability()
	if ability != null:
		ability.hold_flight_for(golems)


# Bring each golem up to the dragon's level (setting progression.level recomputes its base stats).
func _match_golem_levels(dragon: SkeletonDragon, golems: Array[Entity]) -> void:
	var dragon_level: int = dragon.progression.level if dragon.progression != null else dragon.level
	for golem: Entity in golems:
		if not is_instance_valid(golem):
			continue
		if golem.progression != null:
			golem.progression.level = dragon_level
		else:
			golem.level = dragon_level
