class_name TavernEncounter
extends EncounterResource

func get_npcs() -> Array[EntitySpec]:
	return entity_specs.filter(func(s): return s.role == EntitySpec.Role.NPC)

func get_disruptors() -> Array[EntitySpec]:
	return entity_specs.filter(func(s): return s.role == EntitySpec.Role.DISRUPTOR)

func get_decor() -> Array[EntitySpec]:
	return entity_specs.filter(func(s): return s.role == EntitySpec.Role.DECOR)
