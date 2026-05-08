class_name EncounterRunner
extends Node

func start(player_encounter: FightingEncounter, mob_encounter: FightingEncounter) -> void:
	Verbose.debug("Starting encounter Player VS Mob [" + mob_encounter.encounter_id + "]", Verbose.Category.ENCOUNTER_RUNNER)
	if mob_encounter.island_scene == null:
		Verbose.error("MobEncounter doesn't have an island set", Verbose.Category.ENCOUNTER_RUNNER)
		return
	
	var island: FightingIsland = mob_encounter.island_scene.instantiate()
	if island == null:
		Verbose.error("Could not instantiate the island", Verbose.Category.ENCOUNTER_RUNNER)
		return
	
	get_tree().root.add_child.call_deferred(island)
	await island.ready
	island.init_fight_2(player_encounter.force_team(1), mob_encounter.force_team(2))
	island.set_active()
	GlobalFightingManager.start()
