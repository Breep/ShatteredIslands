@tool
class_name EncounterSnapshotter
extends Node

# Editor tool for the EncounterBuilder scene: load an existing .tres into the
# scene to re-edit it, snapshot the current scene state into a .tres, or wipe
# all entities from the builder.

enum EncounterType { FIGHTING, TAVERN }

@export var encounter_type: EncounterType = EncounterType.FIGHTING
@export var encounter_id: StringName = &""
@export var display_name: String = ""
@export_multiline var design_notes: String = ""
@export var output_dir: String = "res://05_Game/Encounters/Pool/Prototyping/"

@export_group("Fighting Encounter")
@export var island_scene: PackedScene
@export_subgroup("Entity Nodes")
@export var _fighting_antagonists_nodes: Node3D
@export var _fighting_heroes_nodes: Node3D
@export var _fighting_acolytes_nodes: Node3D
@export var _fighting_buildings_nodes: Node3D
@export var _fighting_npcs_nodes: Node3D

@export_group("Tavern Encounter")
@export var tavern_scene: PackedScene

@export_group("ACTIONS")
@export var encounter_to_load: EncounterResource
@warning_ignore("unused_private_class_variable")
@export_tool_button("📥 Load Encounter") var _load_btn = _do_load
@warning_ignore("unused_private_class_variable")
@export_tool_button("📸 Snapshot Encounter") var _snap_btn = _do_snapshot
@warning_ignore("unused_private_class_variable")
@export_tool_button("✅ Validate (no save)") var _validate_btn = _do_validate
@export_group("ACTIONS/CLEANUP")
@warning_ignore("unused_private_class_variable")
@export_tool_button("🧹 Cleanup Scene") var _cleanup_btn = _do_cleanup


# === Tool actions ===
func _do_validate() -> void:
	var errors = _validate()
	if errors.is_empty():
		print("✅ Encounter is valid, ready to snapshot.")
	else:
		for e in errors:
			push_warning(e)


func _do_snapshot() -> void:
	var errors = _validate()
	if not errors.is_empty():
		push_error("Cannot snapshot: %d validation errors. Run Validate first." % errors.size())
		return

	var encounter: EncounterResource
	match encounter_type:
		EncounterType.FIGHTING: encounter = _build_fighting()
		EncounterType.TAVERN:   encounter = _build_tavern()

	var path = output_dir.path_join(str(encounter_id) + ".tres")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var err = ResourceSaver.save(encounter, path)
	if err == OK:
		print("✅ Encounter saved: %s" % path)
		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("❌ ResourceSaver.save failed with code %d" % err)


func _do_cleanup() -> void:
	var removed := 0
	for container in _get_all_containers():
		if container == null: continue
		for child in container.get_children():
			child.queue_free()
			removed += 1
	print("🧹 Removed %d entities from the scene." % removed)


func _do_load() -> void:
	if encounter_to_load == null:
		push_error("encounter_to_load is null. Drop a .tres into the LOAD group first.")
		return

	if encounter_to_load is FightingEncounter:
		_do_cleanup()
		_load_fighting(encounter_to_load as FightingEncounter)
	elif encounter_to_load is TavernEncounter:
		_do_cleanup()
		_load_tavern(encounter_to_load as TavernEncounter)
	else:
		push_error("encounter_to_load is neither a FightingEncounter nor a TavernEncounter")


# === Loaders ===
func _load_fighting(enc: FightingEncounter) -> void:
	encounter_type = EncounterType.FIGHTING
	encounter_id = enc.encounter_id
	display_name = enc.display_name
	design_notes = enc.design_notes
	island_scene = enc.island_scene

	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0
	for spec: EntitySpec in enc.entity_specs:
		var container := _get_fighting_container_for_role(spec.role)
		if container == null:
			push_warning("No fighting container for role %s, skipping '%s'" % [EntitySpec.Role.keys()[spec.role], spec.display_label])
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1
	print("Loaded %d entities (%d skipped) from '%s'." % [loaded, skipped, enc.encounter_id])


func _load_tavern(enc: TavernEncounter) -> void:
	encounter_type = EncounterType.TAVERN
	encounter_id = enc.encounter_id
	display_name = enc.display_name
	design_notes = enc.design_notes
	tavern_scene = enc.tavern_scene

	var by_role: Dictionary[int, EditorContainerNode] = {}
	for c in _get_tavern_containers():
		by_role[c.role] = c

	var edited_root := EditorInterface.get_edited_scene_root()
	var loaded := 0
	var skipped := 0
	for spec: EntitySpec in enc.entity_specs:
		var container: EditorContainerNode = by_role.get(spec.role)
		if container == null:
			push_warning("No tavern container for role %s, skipping '%s'" % [EntitySpec.Role.keys()[spec.role], spec.display_label])
			skipped += 1
			continue
		if _instantiate_spec_into(spec, container, edited_root):
			loaded += 1
		else:
			skipped += 1
	print("Loaded %d entities (%d skipped) from '%s'." % [loaded, skipped, enc.encounter_id])


func _instantiate_spec_into(spec: EntitySpec, container: Node, edited_root: Node) -> bool:
	if spec.entity_scene == null:
		push_warning("Spec '%s' has no entity_scene" % spec.display_label)
		return false

	var node := spec.entity_scene.instantiate()
	container.add_child(node)
	if edited_root != null:
		node.owner = edited_root
	if node is Node3D:
		var n3d := node as Node3D
		n3d.global_position = spec.free_position
		n3d.rotation.y = spec.rotation_y
	if spec.display_label != "":
		node.name = spec.display_label
	if node is Entity and spec.stats_override != null:
		(node as Entity).custom_base_stats = spec.stats_override.duplicate(true)
	return true


# === Validation ===
func _validate() -> Array[String]:
	var errors: Array[String] = []
	if encounter_id == &"":
		errors.append("encounter_id is empty")

	if encounter_type == EncounterType.FIGHTING:
		if island_scene == null:
			errors.append("island_scene is null for FIGHTING encounter")
		for container in _get_fighting_containers():
			for child in container.get_children():
				if child is Entity:
					_validate_fighting_entity(child, errors)

	if encounter_type == EncounterType.TAVERN:
		if tavern_scene == null:
			errors.append("tavern_scene is null for TAVERN encounter")

	return errors


func _validate_fighting_entity(entity: Entity, errors: Array[String]) -> void:
	if entity.scene_file_path == "":
		errors.append("Entity '%s' has no scene_file_path (not a saved scene instance)" % entity.name)


# === Builders ===
func _build_fighting() -> FightingEncounter:
	var enc := FightingEncounter.new()
	_fill_base_fields(enc)
	enc.island_scene = island_scene

	for container in _get_fighting_containers():
		for child in container.get_children():
			if child is Entity:
				enc.entity_specs.append(_entity_to_fighting_spec(child, container.role))
	return enc


func _build_tavern() -> TavernEncounter:
	var enc := TavernEncounter.new()
	_fill_base_fields(enc)
	enc.tavern_scene = tavern_scene

	for container in _get_tavern_containers():
		for child in container.get_children():
			if child is Entity or container.role == EntitySpec.Role.DECOR:
				enc.entity_specs.append(_entity_to_tavern_spec(child, container.role))
	return enc


func _fill_base_fields(enc: EncounterResource) -> void:
	enc.encounter_id = encounter_id
	enc.display_name = display_name
	enc.design_notes = design_notes


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


func _entity_to_tavern_spec(node: Node3D, role: EntitySpec.Role) -> EntitySpec:
	var spec := EntitySpec.new()
	if node is Entity:
		var entity := node as Entity
		spec.entity_scene = load(entity.scene_file_path)
		spec.team = entity.team
		if entity.custom_base_stats != null:
			spec.stats_override = entity.custom_base_stats.duplicate(true)
	else:
		spec.entity_scene = load(node.scene_file_path) if node.scene_file_path != "" else null
	spec.role = role
	spec.free_position = node.global_position
	spec.rotation_y = node.rotation.y
	spec.display_label = node.name
	return spec


# === Container resolution ===
func _get_fighting_containers() -> Array[Node3D]:
	return [_fighting_antagonists_nodes, _fighting_acolytes_nodes, _fighting_buildings_nodes, _fighting_npcs_nodes]


func _get_fighting_container_for_role(role: EntitySpec.Role) -> Node3D:
	match role:
		EntitySpec.Role.ANTAGONIST: return _fighting_antagonists_nodes
		EntitySpec.Role.ACOLYTE:    return _fighting_acolytes_nodes
		EntitySpec.Role.BUILDING:   return _fighting_buildings_nodes
		EntitySpec.Role.NPC:        return _fighting_npcs_nodes
		_:                          return null


func _get_tavern_containers() -> Array[EditorContainerNode]:
	var result: Array[EditorContainerNode] = []
	var entities_root = get_parent().get_node_or_null("TavernEncounter/Entities")
	if entities_root == null: return result
	for c in entities_root.get_children():
		if c is EditorContainerNode:
			result.append(c)
	return result


func _get_all_containers() -> Array[Node]:
	var result: Array[Node] = []
	for c in _get_fighting_containers():
		if c != null: result.append(c)
	for c in _get_tavern_containers():
		result.append(c)
	return result
