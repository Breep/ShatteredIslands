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
# Instancie les props/entités statiques du TavernEncounter, puis pose le héros
# et les acolytes du joueur via leurs specs (HeroSpec porte deck/level/data_memory,
# AcolyteSpec idem une fois codés). Les spawn points viennent du tavern_formation
# de l'encounter, pas du spec — la position en tavern est encounter-driven, pas
# formation-driven.
func populate_from_encounter(encounter: TavernEncounter, hero_spec: HeroSpec, acolyte_specs: Array[AcolyteSpec]) -> void:
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

	var ctx: EntityContext = _build_tavern_ctx()

	if hero_spec != null and not formation.hero_spawn_specs.is_empty():
		_spawn_player_unit_at(hero_spec, formation.hero_spawn_specs[0].transform, "Hero", root, ctx)

	var placed_acolytes: int = mini(acolyte_specs.size(), formation.acolyte_spawn_specs.size())
	for i in placed_acolytes:
		if acolyte_specs[i] == null: continue
		_spawn_player_unit_at(acolyte_specs[i], formation.acolyte_spawn_specs[i].transform, "Acolyte_" + str(i), root, ctx)


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


func _build_tavern_ctx() -> EntityContext:
	var ctx := EntityContext.new()
	ctx.display_mode = Hero.DisplayMode.BUYING_PHASE
	ctx.runtime_owner_player = PlayerManager.get_local_player()
	# pas de spawn_manager : la tavern n'a pas de tick system, le fallback
	# add_child d'EntitySpec.spawn_into / HeroSpec.spawn_into est utilisé.
	return ctx


func _spawn_player_unit_at(spec: EntitySpec, target_transform: Transform3D, fallback_name: String, parent: Node3D, ctx: EntityContext) -> void:
	var node: Node = spec.spawn_into(parent, ctx)
	if node == null: return
	if node is Node3D:
		(node as Node3D).transform = target_transform
	if spec.display_label == "":
		node.name = fallback_name
