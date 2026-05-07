@tool
class_name EncounterSnapshotter
extends Node

enum EncounterType { FIGHTING, TAVERN }

@export var encounter_type: EncounterType = EncounterType.FIGHTING
@export var encounter_id: StringName = &""
@export var display_name: String = ""
@export_multiline var design_notes: String = ""
@export var output_dir: String = "res://05_Game/Encounters/Pool/Prototyping/"

# Pour Fighting
@export_group("Fighting Encounter")
@export var island_scene: PackedScene
@export_subgroup("Entity Nodes")
@export var _fighting_antagonists_nodes: Node3D
@export var _fighting_heroes_nodes: Node3D
@export var _fighting_acolytes_nodes: Node3D
@export var _fighting_buildings_nodes: Node3D
@export var _fighting_npcs_nodes: Node3D

# Pour Tavern
@export_group("Tavern Encounter")
@export var tavern_scene: PackedScene

@export_group("SNAPSHOT")
@warning_ignore("unused_private_class_variable")
@export_tool_button("📸 Snapshot Encounter") var _snap_btn = _do_snapshot
@warning_ignore("unused_private_class_variable")
@export_tool_button("✅ Validate (no save)") var _validate_btn = _do_validate

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
		EditorInterface.get_resource_filesystem().scan()  # refresh FileSystem dock
	else:
		push_error("❌ ResourceSaver.save failed with code %d" % err)


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


func _get_tavern_containers() -> Array[EditorContainerNode]:
	var result: Array[EditorContainerNode] = []
	var root = get_parent().get_node("EntityContainers")
	for c in [&"NPCs", &"Disruptors", &"Decor"]:
		var n = root.get_node_or_null(c)
		if n is EditorContainerNode:
			result.append(n)
	return result
