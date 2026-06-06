# Disposition d'une formation côté combat : entity_specs porte le placement
# concret (positions relatives à la fighting_area). hero_spawn_specs /
# acolyte_spawn_specs sont utilisés UNIQUEMENT par les .tres "template" de
# layout de départ (consommés par le runtime pour bâtir une formation à partir
# d'un roaster). Une vraie formation de combat n'a généralement que
# entity_specs renseigné.
class_name FightingFormation
extends Formation

@export var entity_specs: Array[EntitySpec]
@export var hero_spawn_specs: Array[HeroSpawnSpec]
@export var acolyte_spawn_specs: Array[AcolyteSpawnSpec]

# Legacy field for migration from old .tres. Empty after re-save via builders.
@export var spawn_point_specs: Array[SpawnPointSpec]


func mirrored() -> FightingFormation:
	var copy: FightingFormation = duplicate(true)
	for entity_spec: EntitySpec in copy.entity_specs:
		entity_spec.free_position.x *= -1
		entity_spec.rotation_y *= -1
	for spawn_spec: HeroSpawnSpec in copy.hero_spawn_specs:
		spawn_spec.free_position.x *= -1
		spawn_spec.rotation_y *= -1
	for spawn_spec: AcolyteSpawnSpec in copy.acolyte_spawn_specs:
		spawn_spec.free_position.x *= -1
		spawn_spec.rotation_y *= -1
	return copy


func add_entity(spec: EntitySpec) -> EntitySpec:
	if spec == null: return null
	entity_specs.append(spec)
	return spec


# Construit une FightingFormation en posant les entries du Roaster sur les
# spawn_specs du template. Premier hero → premier hero_spawn_spec ; acolytes
# dans l'ordre sur acolyte_spawn_specs. Surplus dropé. Template null → formation
# vide.
static func from_roaster(roaster: Roaster, template: FightingFormation) -> FightingFormation:
	var formation := FightingFormation.new()
	if roaster == null or template == null:
		return formation

	if roaster.hero != null and template.hero_spawn_specs.size() > 0:
		formation.entity_specs.append(_make_spec_for_entry(roaster.hero, template.hero_spawn_specs[0].transform, "Hero_0"))

	var acolyte_count: int = mini(roaster.acolytes.size(), template.acolyte_spawn_specs.size())
	for i in acolyte_count:
		formation.entity_specs.append(_make_spec_for_entry(roaster.acolytes[i], template.acolyte_spawn_specs[i].transform, "Acolyte_" + str(i)))

	return formation


# Helper transitionnel utilisé par les proto scenes : depuis ce template
# (spawn_specs uniquement), crée une formation peuplée. Side effect : pose
# le héros et les acolytes (avec EntityDesc transient) sur le roaster du slot
# PLAYER_1. Les protos ne modélisent qu'un seul joueur local.
func populate_with(party: Party, hero_scenes: Array[PackedScene], acolyte_scenes: Array[PackedScene]) -> FightingFormation:
	var formation := FightingFormation.new()
	if party == null:
		return formation
	var roaster: Roaster = party.get_or_create_roaster(PlayerState.Slot.PLAYER_1)

	var placed_heroes: int = mini(hero_scenes.size(), hero_spawn_specs.size())
	for i in placed_heroes:
		if hero_scenes[i] == null: continue
		# set_hero écrase à chaque itération — en proto avec plusieurs "heroes"
		# seul le dernier reste hero ; les précédents perdent leur place dans le
		# roaster mais leur spec reste dans la formation pour le rendu.
		var entry: RoasterEntry = roaster.set_hero(_make_transient_desc(hero_scenes[i], Entity.Category.HERO))
		formation.entity_specs.append(_make_spec_for_entry(entry, hero_spawn_specs[i].transform, "Hero_" + str(i)))

	var placed_acolytes: int = mini(acolyte_scenes.size(), acolyte_spawn_specs.size())
	for i in placed_acolytes:
		if acolyte_scenes[i] == null: continue
		var entry: RoasterEntry = roaster.add_acolyte(_make_transient_desc(acolyte_scenes[i], Entity.Category.ACOLYTE))
		formation.entity_specs.append(_make_spec_for_entry(entry, acolyte_spawn_specs[i].transform, "Acolyte_" + str(i)))

	return formation


static func _make_transient_desc(scene: PackedScene, category: Entity.Category) -> EntityDesc:
	var desc := EntityDesc.new()
	desc.scene = scene
	desc.default_category = category
	desc.name = "Transient"
	return desc


static func _make_spec_for_entry(entry: RoasterEntry, t: Transform3D, label: String) -> EntitySpec:
	var spec := EntitySpec.new()
	spec.desc = entry.desc
	spec.entry = entry
	spec.transform = t
	spec.display_label = label
	return spec


func remove_entity(spec: EntitySpec) -> bool:
	var idx: int = entity_specs.find(spec)
	if idx == -1:
		return false
	entity_specs.remove_at(idx)
	return true


func move_entity(spec: EntitySpec, new_position: Vector3, new_rotation_y: float = NAN) -> void:
	spec.free_position = new_position
	if not is_nan(new_rotation_y):
		spec.rotation_y = new_rotation_y
