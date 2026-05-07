class_name EncounterRunner
extends Node

func start(player_encounter: FightingPlayerEncounter, mob_encounter: FightingMobEncounter) -> void:
	Verbose.trace("Starting encounter Player VS Mob[" + mob_encounter.encounter_id + "]", Verbose.Category.ENCOUNTER_RUNNER)
	var island = mob_encounter.island_scene
	if island == null:
		Verbose.error("MobEncounted doesn't have an island set", Verbose.Category.ENCOUNTER_RUNNER)
		return
	
	get_tree().root.add_child(island)
