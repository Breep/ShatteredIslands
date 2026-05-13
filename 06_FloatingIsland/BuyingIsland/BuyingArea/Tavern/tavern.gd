class_name Tavern
extends Node3D

@export_group("External Nodes")
@export var _tarven_center: TavernCenter

@export_group("Encounter Spawn Root")
@export var _encounter_root: Node3D


# === Old API (à supprimer une fois la nouvelle validée) ===
func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)


func cleanup() -> void:
	_tarven_center.cleanup_table_layouts()


# === New API: populate from a TavernEncounter ===
# Instancie tous les éléments d'une TavernFormation et injecte le héros / les
# acolytes du joueur aux SpawnPointSpec marqués HERO / ACOLYTE.
func populate_from_encounter(encounter: TavernEncounter, hero_scene: PackedScene, acolyte_scenes: Array[PackedScene]) -> void:
	if encounter == null or encounter.tavern_formation == null:
		Verbose.error("Tavern.populate_from_encounter: encounter or tavern_formation is null", Verbose.Category.ENCOUNTER_RUNNER)
		return

	var formation: TavernFormation = encounter.tavern_formation
	var root: Node3D = _get_or_make_encounter_root()
	_clear_children(root)

	for spec: PropSpec in formation.prop_specs:
		_spawn_simple(spec, root)

	for spec: TavernEntitySpec in formation.entity_specs:
		_spawn_entity(spec, root)

	var hero_placed: bool = false
	var acolyte_idx: int = 0
	for spec: SpawnPointSpec in formation.spawn_point_specs:
		match spec.role:
			SpawnPointSpec.SpawnRole.HERO:
				if not hero_placed and hero_scene != null:
					_spawn_at(hero_scene, spec.transform, "Hero", root)
					hero_placed = true
			SpawnPointSpec.SpawnRole.ACOLYTE:
				if acolyte_idx < acolyte_scenes.size() and acolyte_scenes[acolyte_idx] != null:
					_spawn_at(acolyte_scenes[acolyte_idx], spec.transform, "Acolyte_" + str(acolyte_idx), root)
					acolyte_idx += 1


# === Private helpers ===
func _get_or_make_encounter_root() -> Node3D:
	if _encounter_root != null:
		return _encounter_root
	_encounter_root = Node3D.new()
	_encounter_root.name = "EncounterRoot"
	add_child(_encounter_root)
	return _encounter_root


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _spawn_simple(spec: SpawnSpec, parent: Node3D) -> void:
	if spec.scene == null:
		return
	var node: Node = spec.scene.instantiate()
	parent.add_child(node)
	if node is Node3D:
		(node as Node3D).transform = spec.transform
	if spec.display_label != "":
		node.name = spec.display_label


func _spawn_entity(spec: TavernEntitySpec, parent: Node3D) -> void:
	if spec.scene == null:
		return
	var node: Node = spec.scene.instantiate()
	parent.add_child(node)
	if node is Node3D:
		(node as Node3D).transform = spec.transform
	if spec.display_label != "":
		node.name = spec.display_label
	if node is Entity and spec.stats_override != null:
		(node as Entity).custom_base_stats = spec.stats_override.duplicate(true)


func _spawn_at(scene: PackedScene, target_transform: Transform3D, fallback_name: String, parent: Node3D) -> void:
	var node: Node = scene.instantiate()
	parent.add_child(node)
	if node is Node3D:
		(node as Node3D).transform = target_transform
	node.name = fallback_name
