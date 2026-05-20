@tool
class_name FightingFormationBuilder
extends FormationBuilder

@export_group("Local Nodes")
@export var _antagonists_node: Node3D
@export var _heroes_node: Node3D
@export var _acolytes_node: Node3D
@export var _buildings_node: Node3D
@export var _player_hero_spawns_node: Node3D
@export var _player_acolyte_spawns_node: Node3D

@export_group("Load")
@export var formation_to_load: FightingFormation
@warning_ignore("unused_private_class_variable")
@export_tool_button("Load") var _load_btn = _load

#region ============================== Buttons implementation (Public API) ==============================
func _save() -> void:
	if !_validate():
		return

	var formation: FightingFormation = _build()

	var path = output_dir.path_join(str(formation_id) + ".fighting.tres")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var err = ResourceSaver.save(formation, path)
	if err == OK:
		print_rich("[color=green]Formation saved: %s[/color]" % path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		print_rich("[color=red]Formation.save failed with code %d[/color]" % err)


func _build() -> FightingFormation:
	var formation := FightingFormation.new()
	formation.id = formation_id
	_collect_entities_into(formation, _antagonists_node, AntagonistSpec)
	_collect_entities_into(formation, _heroes_node, HeroSpec)
	_collect_entities_into(formation, _acolytes_node, AcolyteSpec)
	_collect_entities_into(formation, _buildings_node, BuildingSpec)
	_collect_spawns_into(formation.hero_spawn_specs, _player_hero_spawns_node, HeroSpawnSpec, HeroSpawnPoint)
	_collect_spawns_into(formation.acolyte_spawn_specs, _player_acolyte_spawns_node, AcolyteSpawnSpec, AcolyteSpawnPoint)
	return formation


func _load() -> void:
	if formation_to_load == null:
		print_rich("[color=red]Nothing to load[/color]")
		return

	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0

	for spec: EntitySpec in formation_to_load.entity_specs:
		var container: Node3D = _container_for_entity_spec(spec)
		if container == null:
			print_rich("[color=red]No container for entity '%s', skipping[/color]" % spec.display_label)
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1

	for spec: HeroSpawnSpec in formation_to_load.hero_spawn_specs:
		if _instantiate_spec_into(spec, _player_hero_spawns_node, edited_root): loaded += 1
		else: skipped += 1

	for spec: AcolyteSpawnSpec in formation_to_load.acolyte_spawn_specs:
		if _instantiate_spec_into(spec, _player_acolyte_spawns_node, edited_root): loaded += 1
		else: skipped += 1

	# Legacy compat: old .tres still using SpawnPointSpec with SpawnRole enum
	for spec: SpawnPointSpec in formation_to_load.spawn_point_specs:
		var container: Node3D = _container_for_legacy_spawn_role(spec.role)
		if container == null:
			print_rich("[color=red]No container for legacy spawn role %s, skipping '%s'[/color]" % [SpawnPointSpec.SpawnRole.keys()[spec.role], spec.display_label])
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1

	print("Loaded %d specs (%d skipped) from '%s'." % [loaded, skipped, formation_to_load.id])


func _cleanup() -> void:
	var removed := 0
	for container in _get_all_containers():
		if container == null: continue
		for child in container.get_children():
			child.queue_free()
			removed += 1
	print("Removed %d entities from the scene." % removed)


func _validate() -> bool:
	print_rich("[color=gray]Not implemented yet.[/color]")
	return true
#endregion

#region ============================== Private API ==============================
func _collect_entities_into(formation: FightingFormation, container: Node3D, spec_type: Variant) -> void:
	if container == null:
		printerr("Trying to collect entities from an unknown Node [container=<null>]")
		return
	var count: int = 0
	for child in container.get_children():
		if child is Entity:
			formation.entity_specs.append(_entity_to_spec(child, spec_type))
			count += 1
	print("Found ", count, " of ", spec_type)


func _collect_spawns_into(target_array: Array, container: Node3D, spec_type: Variant, node_type: Variant) -> void:
	if container == null: return
	var count: int = 0
	for child in container.get_children():
		if is_instance_of(child, node_type):
			target_array.append(_node_to_spawn_spec(child, spec_type))
			count += 1
	print("Found ", count, " spawn points inside ", container.name)


func _entity_to_spec(entity: Entity, spec_type: Variant) -> EntitySpec:
	var spec: EntitySpec = spec_type.new()
	spec.scene = load(entity.scene_file_path)
	spec.display_label = entity.name
	spec.free_position = entity.global_position
	spec.rotation_y = entity.rotation.y
	if entity.custom_base_stats != null:
		spec.stats_override = entity.custom_base_stats.duplicate(true)
	return spec


func _node_to_spawn_spec(node: Node3D, spec_type: Variant) -> SpawnSpec:
	var spec: SpawnSpec = spec_type.new()
	spec.scene = load(node.scene_file_path) if node.scene_file_path != "" else null
	spec.display_label = node.name
	spec.transform = node.transform
	return spec


func _container_for_entity_spec(spec: EntitySpec) -> Node3D:
	if spec is HeroSpec:        return _heroes_node
	if spec is AcolyteSpec:     return _acolytes_node
	if spec is AntagonistSpec:  return _antagonists_node
	if spec is BuildingSpec:    return _buildings_node
	if spec is FightingEntitySpec:
		return _container_for_legacy_fighting_role((spec as FightingEntitySpec).role)
	return null


func _container_for_legacy_fighting_role(role: int) -> Node3D:
	match role:
		FightingEntitySpec.FightingRole.ANTAGONIST: return _antagonists_node
		FightingEntitySpec.FightingRole.HERO:       return _heroes_node
		FightingEntitySpec.FightingRole.ACOLYTE:    return _acolytes_node
		FightingEntitySpec.FightingRole.BUILDING:   return _buildings_node
		_:                                          return null


func _container_for_legacy_spawn_role(role: int) -> Node3D:
	match role:
		SpawnPointSpec.SpawnRole.HERO:     return _player_hero_spawns_node
		SpawnPointSpec.SpawnRole.ACOLYTE:  return _player_acolyte_spawns_node
		_:                                 return null


func _get_all_containers() -> Array[Node3D]:
	return [_antagonists_node, _heroes_node, _acolytes_node, _buildings_node, _player_hero_spawns_node, _player_acolyte_spawns_node]
#endregion
