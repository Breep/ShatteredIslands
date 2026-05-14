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
# acolytes du joueur aux HeroSpawnSpec / AcolyteSpawnSpec.
func populate_from_encounter(encounter: TavernEncounter, hero_scene: PackedScene, acolyte_scenes: Array[PackedScene]) -> void:
	if encounter == null or encounter.tavern_formation == null:
		Verbose.error("Tavern.populate_from_encounter: encounter or tavern_formation is null", Verbose.Category.ENCOUNTER_RUNNER)
		return

	var formation: TavernFormation = encounter.tavern_formation
	var root: Node3D = _get_or_make_encounter_root()
	_clear_children(root)

	for spec: PropSpec in formation.prop_specs:
		spec.spawn_into(root)

	for spec: EntitySpec in formation.entity_specs:
		spec.spawn_into(root)

	if hero_scene != null and not formation.hero_spawn_specs.is_empty():
		_spawn_at(hero_scene, formation.hero_spawn_specs[0].transform, "Hero", root)

	var placed_acolytes: int = mini(acolyte_scenes.size(), formation.acolyte_spawn_specs.size())
	for i in placed_acolytes:
		if acolyte_scenes[i] == null: continue
		_spawn_at(acolyte_scenes[i], formation.acolyte_spawn_specs[i].transform, "Acolyte_" + str(i), root)


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


func _spawn_at(scene: PackedScene, target_transform: Transform3D, fallback_name: String, parent: Node3D) -> void:
	var node: Node = scene.instantiate()
	parent.add_child(node)
	if node is Node3D:
		(node as Node3D).transform = target_transform
	node.name = fallback_name
