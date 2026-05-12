@tool
class_name FightingFormationBuilder
extends FormationBuilder

@export_group("Local Nodes")
@export var _antagonists_nodes: Node3D
@export var _heroes_nodes: Node3D
@export var _acolytes_nodes: Node3D
@export var _buildings_nodes: Node3D

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
	for container in _get_all_containers():
		if container == null: continue
		for child in container.get_children():
			if child is Entity:
				formation.entity_specs.append(_entity_to_fighting_spec(child, container.role))
	return formation


func _load() -> void:
	if formation_to_load == null:
		print_rich("[color=red]Nothing to load[/color]")
		return
	
	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0
	for spec: EntitySpec in formation_to_load.entity_specs:
		var container := _get_fighting_container_for_role(spec.role)
		if container == null:
			print_rich("No fighting container for role %s, skipping '%s'" % [EntitySpec.Role.keys()[spec.role], spec.display_label])
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1
	print("Loaded %d entities (%d skipped) from '%s'." % [loaded, skipped, formation_to_load.id])


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
func _entity_to_fighting_spec(entity: Entity, role: EntitySpec.Role) -> EntitySpec:
	var spec := EntitySpec.new()
	spec.entity_scene = load(entity.scene_file_path)
	spec.role = role
	spec.team = entity.team
	spec.display_label = entity.name

	spec.free_position = entity.global_position
	spec.rotation_y = entity.rotation.y

	if entity.custom_base_stats != null:
		spec.stats_override = entity.custom_base_stats.duplicate(true)
	return spec


func _get_all_containers() -> Array[Node3D]:
	return [_antagonists_nodes, _heroes_nodes, _acolytes_nodes, _buildings_nodes]


func _get_fighting_container_for_role(role: EntitySpec.Role) -> Node3D:
	match role:
		EntitySpec.Role.ANTAGONIST: return _antagonists_nodes
		EntitySpec.Role.ACOLYTE:    return _acolytes_nodes
		EntitySpec.Role.BUILDING:   return _buildings_nodes
		EntitySpec.Role.HERO:       return _heroes_nodes
		_:                          return null
#endregion
