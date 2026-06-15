# Disposition d'une formation côté combat : entity_specs porte le placement
# concret (positions relatives à la fighting_area). hero_spawn_specs /
# acolyte_spawn_specs ne sont renseignés que dans les .tres "template" de
# layout de départ, produits par le FightingFormationBuilder. Une vraie
# formation de combat n'a généralement que entity_specs renseigné.
class_name FightingFormation
extends Formation

@export var entity_specs: Array[EntitySpec]
@export var hero_spawn_specs: Array[HeroSpawnSpec]
@export var acolyte_spawn_specs: Array[AcolyteSpawnSpec]

# Legacy field for migration from old .tres. Empty after re-save via builders.
@export var spawn_point_specs: Array[SpawnPointSpec]
