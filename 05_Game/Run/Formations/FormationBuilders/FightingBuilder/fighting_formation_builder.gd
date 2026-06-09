@tool
class_name FightingFormationBuilder
extends FormationBuilder

@export_group("Local Nodes")
@export var _entities_node: Node3D
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
	_collect_entities_into(formation, _entities_node)
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
		if _instantiate_spec_into(spec, _entities_node, edited_root): loaded += 1
		else: skipped += 1

	for spec: HeroSpawnSpec in formation_to_load.hero_spawn_specs:
		if _instantiate_spec_into(spec, _player_hero_spawns_node, edited_root): loaded += 1
		else: skipped += 1

	for spec: AcolyteSpawnSpec in formation_to_load.acolyte_spawn_specs:
		if _instantiate_spec_into(spec, _player_acolyte_spawns_node, edited_root): loaded += 1
		else: skipped += 1

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
func _collect_entities_into(formation: FightingFormation, container: Node3D) -> void:
	if container == null:
		printerr("Trying to collect entities from an unknown Node [container=<null>]")
		return
	var count: int = 0
	for child in container.get_children():
		if child is Entity:
			formation.entity_specs.append(_entity_to_spec(child))
			count += 1
	print("Found ", count, " entities")


func _collect_spawns_into(target_array: Array, container: Node3D, spec_type: Variant, node_type: Variant) -> void:
	if container == null: return
	var count: int = 0
	for child in container.get_children():
		if is_instance_of(child, node_type):
			target_array.append(_node_to_spawn_spec(child, spec_type))
			count += 1
	print("Found ", count, " spawn points inside ", container.name)


func _entity_to_spec(entity: Entity) -> EntitySpec:
	var spec := EntitySpec.new()
	spec.scene = load(entity.scene_file_path)
	spec.display_label = entity.name
	spec.free_position = entity.global_position
	spec.rotation_y = entity.rotation.y
	if entity.override_base_stats != null:
		spec.stats_override = entity.override_base_stats.duplicate(true)
	return spec


func _node_to_spawn_spec(node: Node3D, spec_type: Variant) -> SpawnSpec:
	var spec: SpawnSpec = spec_type.new()
	spec.scene = load(node.scene_file_path) if node.scene_file_path != "" else null
	spec.display_label = node.name
	spec.transform = node.transform
	return spec


func _get_all_containers() -> Array[Node3D]:
	return [_entities_node, _player_hero_spawns_node, _player_acolyte_spawns_node]
#endregion
