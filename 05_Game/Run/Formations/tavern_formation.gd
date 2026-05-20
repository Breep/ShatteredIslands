class_name TavernFormation
extends Formation

@export var entity_specs: Array[EntitySpec]
@export var hero_spawn_specs: Array[HeroSpawnSpec]
@export var acolyte_spawn_specs: Array[AcolyteSpawnSpec]
@export var prop_specs: Array[PropSpec]

# Legacy field for migration from old .tres. Empty after re-save via builders.
@export var spawn_point_specs: Array[SpawnPointSpec]
