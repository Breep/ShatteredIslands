@tool
class_name TavernFormationBuilder
extends FormationBuilder

@export_group("Local Nodes")
@export var _antagonists_node: Node3D
@export var _heroes_node: Node3D
@export var _acolytes_node: Node3D
@export var _buildings_node: Node3D
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

	var path = output_dir.path_join(str(formation_id) + ".fighting.tres")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var err = ResourceSaver.save(formation, path)
	if err == OK:
		print_rich("[color=green]Formation saved: %s[/color]" % path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		print_rich("[color=red]Formation.save failed with code %d[/color]" % err)


func _build() -> TavernFormation:
	var formation := TavernFormation.new()
	for container in _get_all_containers():
		for child in container.get_children():
			if child is Entity:
				formation.entity_specs.append(_entity_to_tavern_spec(child, container.role))
			else:
				formation.prop_specs.append(_entity_to_tavern_spec(child, container.role))
	return formation


func _load() -> void:
	if formation_to_load == null:
		print_rich("[color=red]Nothing to load[/color]")
		return
	
	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0
	for spec: EntitySpec in formation_to_load.entity_specs:
		var container := _get_tavern_container_for_role(spec.role)
		if container == null:
			print_rich("[color=red]No container for role %s, skipping '%s'[/color]" % [EntitySpec.Role.keys()[spec.role], spec.display_label])
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1
	for spec: PropSpec in formation_to_load.prop_specs:
		if _props_node == null:
			print_rich("[color=red]No props container, skipping '%s'[/color]", spec.display_label)
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
func _entity_to_tavern_spec(node: Node3D, role: EntitySpec.Role) -> EntitySpec:
	var spec := EntitySpec.new()
	if node is Entity:
		var entity := node as Entity
		spec.entity_scene = load(entity.scene_file_path)
	else:
		spec.entity_scene = load(node.scene_file_path) if node.scene_file_path != "" else null
	spec.role = role
	spec.transform = node.transform
	spec.display_label = node.name
	return spec


func _get_all_containers() -> Array[Node3D]:
	return [_antagonists_node, _heroes_node, _acolytes_node, _buildings_node, _props_node]


func _get_tavern_container_for_role(role: EntitySpec.Role) -> Node3D:
	match role:
		EntitySpec.Role.ANTAGONIST: return _antagonists_node
		EntitySpec.Role.ACOLYTE:    return _acolytes_node
		EntitySpec.Role.BUILDING:   return _buildings_node
		EntitySpec.Role.HERO:       return _heroes_node
		_:                          return null
#endregion
