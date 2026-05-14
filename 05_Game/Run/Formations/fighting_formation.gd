class_name FightingFormation
extends Formation

@export var entity_specs: Array[FightingEntitySpec]
@export var spawn_point_specs: Array[SpawnPointSpec]


func mirrored() -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: FightingEntitySpec in copy.entity_specs:
		entity_spec.free_position.x *= -1
		entity_spec.rotation_y *= -1
	for spawn_spec: SpawnPointSpec in copy.spawn_point_specs:
		spawn_spec.free_position.x *= -1
		spawn_spec.rotation_y *= -1
	return copy


func populate_with(hero_scenes: Array[PackedScene], acolyte_scenes: Array[PackedScene]) -> FightingFormation:
	var result: FightingFormation = duplicate(true)
	var hero_idx: int = 0
	var acolyte_idx: int = 0
	for spawn_spec: SpawnPointSpec in result.spawn_point_specs:
		match spawn_spec.role:
			SpawnPointSpec.SpawnRole.HERO:
				if hero_idx < hero_scenes.size() and hero_scenes[hero_idx] != null:
					result.entity_specs.append(_make_spec_from_spawn(
						hero_scenes[hero_idx],
						FightingEntitySpec.FightingRole.HERO,
						spawn_spec,
						"Hero_" + str(hero_idx)
					))
					hero_idx += 1
			SpawnPointSpec.SpawnRole.ACOLYTE:
				if acolyte_idx < acolyte_scenes.size() and acolyte_scenes[acolyte_idx] != null:
					result.entity_specs.append(_make_spec_from_spawn(
						acolyte_scenes[acolyte_idx],
						FightingEntitySpec.FightingRole.ACOLYTE,
						spawn_spec,
						"Acolyte_" + str(acolyte_idx)
					))
					acolyte_idx += 1

	var dropped_heroes: int = hero_scenes.size() - hero_idx
	var dropped_acolytes: int = acolyte_scenes.size() - acolyte_idx
	if dropped_heroes > 0 or dropped_acolytes > 0:
		Verbose.warn(
			"populate_with: %d heroes / %d acolytes dropped (not enough spawn points)" % [dropped_heroes, dropped_acolytes],
			Verbose.Category.ENCOUNTER_RUNNER
		)
	return result


func add_entity(scene: PackedScene, role: FightingEntitySpec.FightingRole) -> FightingEntitySpec:
	if role == FightingEntitySpec.FightingRole.BUILDING:
		Verbose.warn("add_entity: BUILDING role not supported yet, TODO", Verbose.Category.ENCOUNTER_RUNNER)
		return null

	var spawn_role: int = _spawn_role_for_fighting_role(role)
	if spawn_role < 0:
		Verbose.warn("add_entity: no spawn role mapping for fighting role %d" % role, Verbose.Category.ENCOUNTER_RUNNER)
		return null

	for spawn_spec: SpawnPointSpec in spawn_point_specs:
		if spawn_spec.role != spawn_role: continue
		if _is_slot_occupied(spawn_spec): continue
		var spec: FightingEntitySpec = _make_spec_from_spawn(scene, role, spawn_spec, scene.resource_path.get_file().get_basename())
		entity_specs.append(spec)
		return spec

	Verbose.warn("add_entity: no free spawn point for role %d" % role, Verbose.Category.ENCOUNTER_RUNNER)
	return null


func remove_entity(spec: FightingEntitySpec) -> bool:
	var idx: int = entity_specs.find(spec)
	if idx == -1:
		return false
	entity_specs.remove_at(idx)
	return true


func move_entity(spec: FightingEntitySpec, new_position: Vector3, new_rotation_y: float = NAN) -> void:
	spec.free_position = new_position
	if not is_nan(new_rotation_y):
		spec.rotation_y = new_rotation_y


func _make_spec_from_spawn(scene: PackedScene, role: FightingEntitySpec.FightingRole, spawn_spec: SpawnPointSpec, label: String) -> FightingEntitySpec:
	var spec: FightingEntitySpec = FightingEntitySpec.new()
	spec.scene = scene
	spec.role = role
	spec.display_label = label
	spec.transform = spawn_spec.transform
	return spec


func _spawn_role_for_fighting_role(role: FightingEntitySpec.FightingRole) -> int:
	match role:
		FightingEntitySpec.FightingRole.HERO:    return SpawnPointSpec.SpawnRole.HERO
		FightingEntitySpec.FightingRole.ACOLYTE: return SpawnPointSpec.SpawnRole.ACOLYTE
		_:                                       return -1


func _is_slot_occupied(spawn_spec: SpawnPointSpec) -> bool:
	for entity_spec: FightingEntitySpec in entity_specs:
		if entity_spec.free_position == spawn_spec.free_position:
			return true
	return false
