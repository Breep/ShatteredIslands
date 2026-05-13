# Orchestre une Confrontation : instancie l'île de combat et y lance la phase
# Fighting (l'init de la phase Taverne viendra dans une passe ultérieure).
class_name EncounterRunner
extends Node


func init_fight(left_encounter: FightingEncounter, right_encounter: FightingEncounter) -> void:
	Verbose.debug("Starting encounter [" + right_encounter.encounter_id + "]", Verbose.Category.ENCOUNTER_RUNNER)
	if right_encounter.island_scene == null:
		Verbose.error("FightingEncounter has no island_scene", Verbose.Category.ENCOUNTER_RUNNER)
		return

	var island: FightingIsland = right_encounter.island_scene.instantiate()
	if island == null:
		Verbose.error("Could not instantiate the island", Verbose.Category.ENCOUNTER_RUNNER)
		return

	get_tree().root.add_child.call_deferred(island)
	await island.ready
	var left_formation: FightingFormation = left_encounter.team_b_formation.mirrored().force_team(1)
	var right_formation: FightingFormation = right_encounter.team_b_formation.force_team(2)
	island.init_fight_3(left_formation, right_formation)
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
