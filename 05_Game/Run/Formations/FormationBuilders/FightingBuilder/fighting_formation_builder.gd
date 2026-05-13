@tool
class_name FightingFormationBuilder
extends FormationBuilder

@export_group("Local Nodes")
@export var _antagonists_node: Node3D
@export var _heroes_node: Node3D
@export var _acolytes_node: Node3D
@export var _buildings_node: Node3D

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
	_collect_entities(formation, _antagonists_node, FightingEntitySpec.FightingRole.ANTAGONIST)
	_collect_entities(formation, _heroes_node, FightingEntitySpec.FightingRole.HERO)
	_collect_entities(formation, _acolytes_node, FightingEntitySpec.FightingRole.ACOLYTE)
	_collect_entities(formation, _buildings_node, FightingEntitySpec.FightingRole.BUILDING)
	return formation


func _load() -> void:
	if formation_to_load == null:
		print_rich("[color=red]Nothing to load[/color]")
		return

	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0
	for spec: FightingEntitySpec in formation_to_load.entity_specs:
		var container := _get_container_for_role(spec.role)
		if container == null:
			print_rich("[color=red]No container for role %s, skipping '%s'[/color]" % [FightingEntitySpec.FightingRole.keys()[spec.role], spec.display_label])
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
func _collect_entities(formation: FightingFormation, container: Node3D, role: FightingEntitySpec.FightingRole) -> void:
	if container == null:
		printerr("Trying to collect entities from an unknown Node [container=<null>]")
		return
	var count: int = 0
	for child in container.get_children():
		if child is Entity:
			formation.entity_specs.append(_entity_to_fighting_spec(child, role))
			count += 1
	print("Found ", count, " ", FightingEntitySpec.FightingRole.keys()[role])


func _entity_to_fighting_spec(entity: Entity, role: FightingEntitySpec.FightingRole) -> FightingEntitySpec:
	var spec := FightingEntitySpec.new()
	spec.scene = load(entity.scene_file_path)
	spec.role = role
	spec.team = entity.team
	spec.display_label = entity.name

	spec.free_position = entity.global_position
	spec.rotation_y = entity.rotation.y

	if entity.custom_base_stats != null:
		spec.stats_override = entity.custom_base_stats.duplicate(true)
	return spec


func _get_all_containers() -> Array[Node3D]:
	return [_antagonists_node, _heroes_node, _acolytes_node, _buildings_node]


func _get_container_for_role(role: FightingEntitySpec.FightingRole) -> Node3D:
	match role:
		FightingEntitySpec.FightingRole.ANTAGONIST: return _antagonists_node
		FightingEntitySpec.FightingRole.HERO:       return _heroes_node
		FightingEntitySpec.FightingRole.ACOLYTE:    return _acolytes_node
		FightingEntitySpec.FightingRole.BUILDING:   return _buildings_node
		_:                                          return null
#endregion
