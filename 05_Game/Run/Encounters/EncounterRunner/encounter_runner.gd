# Exécute un Encounter (combat ou taverne) : instancie la scène, initialise,
# attend la fin.
#
# API :
# - setup_*  : instancie + initialise. N'auto-démarre pas. Retourne l'île.
#              Le caller décide quand démarrer (ex: proto qui veut un bouton Start).
# - run_*    : setup + démarrage + await fin. Utilisé par ConfrontationRunner.
#
# Convention combat : la Party joue toujours côté A (override de formation_a).
# Côté A = team 1, mirrored. Côté B = team 2, as-authored.
class_name EncounterRunner
extends Node

signal tavern_phase_ended
signal fighting_phase_ended

const BUYING_ISLAND_SCENE: PackedScene = preload("res://06_FloatingIsland/BuyingIsland/buying_island.tscn")


#region ============================== Fighting ==============================
func setup_fighting(encounter: FightingEncounter, party_formation: FightingFormation = null) -> FightingIsland:
	if encounter == null:
		Verbose.error("EncounterRunner.setup_fighting: encounter null", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	if encounter.island_scene == null:
		Verbose.error("EncounterRunner.setup_fighting: encounter has no island_scene", Verbose.Category.ENCOUNTER_RUNNER)
		return null

	var fa: FightingFormation = party_formation if party_formation != null else encounter.formation_a
	var fb: FightingFormation = encounter.formation_b
	if fa == null or fb == null:
		Verbose.error("EncounterRunner.setup_fighting: formation_a or formation_b is null", Verbose.Category.ENCOUNTER_RUNNER)
		return null

	var island: FightingIsland = encounter.island_scene.instantiate()
	get_tree().root.add_child.call_deferred(island)
	await island.ready
	island.set_active()
	island.init_fight_3(fa.mirrored(), fb, 1, 2)
	return island


func run_fighting(encounter: FightingEncounter, party_formation: FightingFormation = null) -> void:
	var island: FightingIsland = await setup_fighting(encounter, party_formation)
	if island == null: return
	GlobalFightingManager.start()
	await GlobalFightingManager.all_fights_are_over
	island.queue_free()
	fighting_phase_ended.emit()
#endregion


#region ============================== Tavern ==============================
func setup_tavern(encounter: TavernEncounter, party: Party = null) -> BuyingIsland:
	if encounter == null:
		Verbose.error("EncounterRunner.setup_tavern: encounter null", Verbose.Category.ENCOUNTER_RUNNER)
		return null

	var buying_island: BuyingIsland = BUYING_ISLAND_SCENE.instantiate()
	get_tree().root.add_child.call_deferred(buying_island)
	await buying_island.ready

	var hero_scene: PackedScene = null
	var acolyte_scenes: Array[PackedScene] = []
	if party != null:
		var heroes: Array[PackedScene] = party.get_hero_scenes()
		if not heroes.is_empty():
			hero_scene = heroes[0]
		acolyte_scenes = party.get_acolyte_scenes()

	buying_island.start_buying_phase_from_encounter(encounter, hero_scene, acolyte_scenes)
	buying_island.set_active()
	return buying_island


func run_tavern(encounter: TavernEncounter, party: Party = null) -> void:
	var island: BuyingIsland = await setup_tavern(encounter, party)
	if island == null: return
	# Manuel pour le moment : le caller (proto) émet tavern_phase_ended.
	# TODO: brancher sur un vrai signal de fin de phase côté BuyingIsland.
	await tavern_phase_ended
	island.queue_free()
#endregion
