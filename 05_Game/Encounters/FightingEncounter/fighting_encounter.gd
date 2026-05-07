class_name FightingEncounter
extends EncounterResource

@export var arena_layout: ArenaLayout              # la grille hex de cette arène
@export var island_scene: PackedScene              # la scène de l'île de combat

# Helpers de filtrage (computed, pas exportés)
func get_antagonists() -> Array[EntitySpec]:
	return entity_specs.filter(func(s): return s.role == EntitySpec.Role.ANTAGONIST)

func get_acolytes() -> Array[EntitySpec]:
	return entity_specs.filter(func(s): return s.role == EntitySpec.Role.ACOLYTE)

func get_buildings() -> Array[EntitySpec]:
	return entity_specs.filter(func(s): return s.role == EntitySpec.Role.BUILDING)
