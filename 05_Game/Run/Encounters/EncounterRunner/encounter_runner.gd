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

signal tavern_started(island: BuyingIsland)
signal tavern_phase_ended
signal fighting_started(island: FightingIsland)
signal fighting_phase_ended

const BUYING_ISLAND_SCENE: PackedScene = preload("res://06_FloatingIsland/BuyingIsland/buying_island.tscn")
const PARTY_TEAM_ID: int = 1

var _last_fight_winner_team: int = -1


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
	island.init_fight(fa.mirrored(), fb, 1, 2)
	fighting_started.emit(island)
	return island


func run_fighting(encounter: FightingEncounter, party_formation: FightingFormation = null) -> bool:
	_last_fight_winner_team = -1
	var island: FightingIsland = await setup_fighting(encounter, party_formation)
	if island == null: return false

	var fm: FightingManager = island.get_fighting_area().fighting_manager
	fm.fight_done.connect(_on_fighting_manager_fight_done, CONNECT_ONE_SHOT)

	GlobalFightingManager.start()
	await GlobalFightingManager.all_fights_are_over
	island.queue_free()
	fighting_phase_ended.emit()
	return _last_fight_winner_team == PARTY_TEAM_ID


func _on_fighting_manager_fight_done(_fm: FightingManager, winner_teams_order: Array[int]) -> void:
	_last_fight_winner_team = winner_teams_order[1]
#endregion


#region ============================== Tavern ==============================


func run_tavern(encounter: TavernEncounter, party: Party = null) -> void:
	var island: BuyingIsland = await _setup_tavern(encounter, party)
	if island == null: return
	await tavern_phase_ended
	island.queue_free()


func _setup_tavern(encounter: TavernEncounter, party: Party = null) -> BuyingIsland:
	if encounter == null:
		Verbose.error("EncounterRunner._setup_tavern: encounter null", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	
	var buying_island: BuyingIsland = BUYING_ISLAND_SCENE.instantiate()
	get_tree().root.add_child.call_deferred(buying_island)
	await buying_island.ready
	
	var hero_spec: HeroSpec = null
	var acolyte_specs: Array[AcolyteSpec] = []
	if party != null:
		var heroe_specs: Array[HeroSpec] = party.get_hero_specs()
		if not heroe_specs.is_empty():
			hero_spec = heroe_specs[0]
		acolyte_specs = party.get_acolyte_specs()
	
	buying_island.start_buying_phase_from_encounter(encounter, hero_spec, acolyte_specs) # TODO Adapter ça pour accepter plusieurs héros
	buying_island.set_active()
	# Relay du signal naturel de l'île vers tavern_phase_ended pour que run_tavern
	# (et toute proto qui émet directement tavern_phase_ended) partage le même await.
	buying_island.phase_ended.connect(_on_buying_island_phase_ended, CONNECT_ONE_SHOT)
	tavern_started.emit(buying_island)
	return buying_island


func _on_buying_island_phase_ended() -> void:
	tavern_phase_ended.emit()
#endregion
