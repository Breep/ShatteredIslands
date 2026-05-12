@tool
class_name TavernFormationBuilder
extends FormationBuilder

@export_group("Local Nodes")
@export var _mobs_node: Node3D
@export var _hero_spawns_node: Node3D
@export var _acolyte_spawns_node: Node3D
@export var _props_node: Node3D

@export_group("Load")
@export var formation_to_load: TavernFormation
@warning_ignore("unused_private_class_variable")
@export_tool_button("Load") var _load_btn = _load

#region ============================== Buttons implementation (Public API) ==============================
func _save() -> void:
	if !_validate():
		return

	var formation: TavernFormation = _build()

	var path = output_dir.path_join(str(formation_id) + ".tavern.tres")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var err = ResourceSaver.save(formation, path)
	if err == OK:
		print_rich("[color=green]Formation saved: %s[/color]" % path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		print_rich("[color=red]Formation.save failed with code %d[/color]" % err)


func _build() -> TavernFormation:
	var formation := TavernFormation.new()
	formation.id = formation_id
	_collect_entities(formation, _mobs_node, TavernEntitySpec.TavernRole.MOB)
	_collect_entities(formation, _hero_spawns_node, TavernEntitySpec.TavernRole.HERO_SPAWN)
	_collect_entities(formation, _acolyte_spawns_node, TavernEntitySpec.TavernRole.ACOLYTE_SPAWN)
	_collect_props(formation, _props_node)
	return formation


func _load() -> void:
	if formation_to_load == null:
		print_rich("[color=red]Nothing to load[/color]")
		return

	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0
	for spec: TavernEntitySpec in formation_to_load.entity_specs:
		var container := _get_container_for_role(spec.role)
		if container == null:
			print_rich("[color=red]No container for role %s, skipping '%s'[/color]" % [TavernEntitySpec.TavernRole.keys()[spec.role], spec.display_label])
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1
	for spec: PropSpec in formation_to_load.prop_specs:
		if _props_node == null:
			print_rich("[color=red]No props container, skipping '%s'[/color]" % spec.display_label)
			skipped += 1
			continue
		if _instantiate_spec_into(spec, _props_node, edited_root):
			loaded += 1
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
func _collect_entities(formation: TavernFormation, container: Node3D, role: TavernEntitySpec.TavernRole) -> void:
	if container == null: return
	print("Container '%s' (path: %s) has %d children" % [container.name, container.get_path(), container.get_child_count()])
	for child in container.get_children():
		if child is Entity:
			formation.entity_specs.append(_entity_to_tavern_spec(child, role))


func _collect_props(formation: TavernFormation, container: Node3D) -> void:
	if container == null: return
	for child in container.get_children():
		formation.prop_specs.append(_node_to_prop_spec(child))


func _entity_to_tavern_spec(entity: Entity, role: TavernEntitySpec.TavernRole) -> TavernEntitySpec:
	var spec := TavernEntitySpec.new()
	spec.entity_scene = load(entity.scene_file_path)
	spec.role = role
	spec.display_label = entity.name
	spec.free_position = entity.global_position
	spec.rotation_y = entity.rotation.y
	if entity.custom_base_stats != null:
		spec.stats_override = entity.custom_base_stats.duplicate(true)
	return spec


func _node_to_prop_spec(node: Node3D) -> PropSpec:
	var spec := PropSpec.new()
	spec.entity_scene = load(node.scene_file_path) if node.scene_file_path != "" else null
	spec.display_label = node.name
	spec.transform = node.transform
	return spec


func _get_all_containers() -> Array[Node3D]:
	return [_mobs_node, _hero_spawns_node, _acolyte_spawns_node, _props_node]


func _get_container_for_role(role: TavernEntitySpec.TavernRole) -> Node3D:
	match role:
		TavernEntitySpec.TavernRole.MOB:            return _mobs_node
		TavernEntitySpec.TavernRole.HERO_SPAWN:     return _hero_spawns_node
		TavernEntitySpec.TavernRole.ACOLYTE_SPAWN:  return _acolyte_spawns_node
		_:                                           return null
#endregion
