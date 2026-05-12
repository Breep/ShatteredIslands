class_name EncounterRunner
extends Node

const TAVERN_SCENE: PackedScene = preload("res://06_FloatingIsland/_Maps/tavern.tscn")

func init_fight(player_encounter: FightingEncounter, mob_encounter: FightingEncounter) -> void:
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


func init_tavern(player_encoutner: TavernEncounter, mob_encoutner: TavernEncounter) -> void:
	pass
	# A voir si ça coute cher d'instantier et queue_free la taverne à la volé
	# Actuellement elle est toujours instantié, juste on la cache ou non
	# 
	# => On "active" la taverne
	#     => charge les 2 TavernEncounter, place les entity au endroits indiqué par les tavern encounter
	#     => Pour le moment on ne gère pas encore les animations (dans un second temps)
	
