class_name EncounterRunner
extends Node

func start(player_encounter: FightingPlayerEncounter, mob_encounter: FightingMobEncounter) -> void:
	Verbose.debug("Starting encounter Player VS Mob [" + mob_encounter.encounter_id + "]", Verbose.Category.ENCOUNTER_RUNNER)
	if mob_encounter.island_scene == null:
		Verbose.error("MobEncounter doesn't have an island set", Verbose.Category.ENCOUNTER_RUNNER)
		return
	
	var island: FightingIsland = mob_encounter.island_scene.instantiate()
	if island == null:
		Verbose.error("Could not instantiate the island", Verbose.Category.ENCOUNTER_RUNNER)
		return
	
	get_tree().root.add_child(island)
	
