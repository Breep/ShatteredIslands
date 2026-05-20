class_name FightingFormation
extends Formation

@export var entity_specs: Array[EntitySpec]
@export var hero_spawn_specs: Array[HeroSpawnSpec]
@export var acolyte_spawn_specs: Array[AcolyteSpawnSpec]

# Legacy field for migration from old .tres. Empty after re-save via builders.
@export var spawn_point_specs: Array[SpawnPointSpec]


func mirrored() -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: EntitySpec in copy.entity_specs:
		entity_spec.free_position.x *= -1
		entity_spec.rotation_y *= -1
	for spawn_spec: HeroSpawnSpec in copy.hero_spawn_specs:
		spawn_spec.free_position.x *= -1
		spawn_spec.rotation_y *= -1
	for spawn_spec: AcolyteSpawnSpec in copy.acolyte_spawn_specs:
		spawn_spec.free_position.x *= -1
		spawn_spec.rotation_y *= -1
	return copy


func populate_with(hero_scenes: Array[PackedScene], acolyte_scenes: Array[PackedScene]) -> FightingFormation:
	var result: FightingFormation = duplicate(true)

	var placed_heroes: int = mini(hero_scenes.size(), result.hero_spawn_specs.size())
	for i in placed_heroes:
		if hero_scenes[i] == null: continue
		result.entity_specs.append(_make_hero_spec(hero_scenes[i], result.hero_spawn_specs[i], "Hero_" + str(i)))

	var placed_acolytes: int = mini(acolyte_scenes.size(), result.acolyte_spawn_specs.size())
	for i in placed_acolytes:
		if acolyte_scenes[i] == null: continue
		result.entity_specs.append(_make_acolyte_spec(acolyte_scenes[i], result.acolyte_spawn_specs[i], "Acolyte_" + str(i)))

	var dropped_heroes: int = maxi(0, hero_scenes.size() - result.hero_spawn_specs.size())
	var dropped_acolytes: int = maxi(0, acolyte_scenes.size() - result.acolyte_spawn_specs.size())
	if dropped_heroes > 0 or dropped_acolytes > 0:
		Verbose.warn(
			"populate_with: %d heroes / %d acolytes dropped (not enough spawn points)" % [dropped_heroes, dropped_acolytes],
			Verbose.Category.ENCOUNTER_RUNNER
		)
	return result


func add_hero(scene: PackedScene) -> HeroSpec:
	var spawn: SpawnSpec = _find_free_spawn(hero_spawn_specs)
	if spawn == null:
		Verbose.warn("add_hero: no free hero spawn point", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	var spec: HeroSpec = _make_hero_spec(scene, spawn, _default_label(scene))
	entity_specs.append(spec)
	return spec


func add_acolyte(scene: PackedScene) -> AcolyteSpec:
	var spawn: SpawnSpec = _find_free_spawn(acolyte_spawn_specs)
	if spawn == null:
		Verbose.warn("add_acolyte: no free acolyte spawn point", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	var spec: AcolyteSpec = _make_acolyte_spec(scene, spawn, _default_label(scene))
	entity_specs.append(spec)
	return spec


func add_building(scene: PackedScene, position: Vector3, rotation_y: float = 0.0) -> BuildingSpec:
	var spec: BuildingSpec = BuildingSpec.new()
	spec.scene = scene
	spec.display_label = _default_label(scene)
	spec.free_position = position
	spec.rotation_y = rotation_y
	entity_specs.append(spec)
	return spec


func remove_entity(spec: EntitySpec) -> bool:
	var idx: int = entity_specs.find(spec)
	if idx == -1:
		return false
	entity_specs.remove_at(idx)
	return true


func move_entity(spec: EntitySpec, new_position: Vector3, new_rotation_y: float = NAN) -> void:
	spec.free_position = new_position
	if not is_nan(new_rotation_y):
		spec.rotation_y = new_rotation_y


func _make_hero_spec(scene: PackedScene, spawn: SpawnSpec, label: String) -> HeroSpec:
	var spec: HeroSpec = HeroSpec.new()
	spec.scene = scene
	spec.display_label = label
	spec.transform = spawn.transform
	return spec


func _make_acolyte_spec(scene: PackedScene, spawn: SpawnSpec, label: String) -> AcolyteSpec:
	var spec: AcolyteSpec = AcolyteSpec.new()
	spec.scene = scene
	spec.display_label = label
	spec.transform = spawn.transform
	return spec


func _find_free_spawn(spawns: Array) -> SpawnSpec:
	for spawn: SpawnSpec in spawns:
		if not _is_position_occupied(spawn.free_position):
			return spawn
	return null


func _is_position_occupied(pos: Vector3) -> bool:
	for entity_spec: EntitySpec in entity_specs:
		if entity_spec.free_position == pos:
			return true
	return false


func _default_label(scene: PackedScene) -> String:
	if scene == null or scene.resource_path == "":
		return "Entity"
	return scene.resource_path.get_file().get_basename()
