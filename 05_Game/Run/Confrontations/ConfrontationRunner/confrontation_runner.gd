# Orchestre une Confrontation : phase taverne suivie de la phase combat.
# Délègue l'exécution à un EncounterRunner (configuré via @export).
# Émet confrontation_ended quand toutes les phases sont terminées et retourne
# un ConfrontationResult (null si pas de fighting_encounter).
class_name ConfrontationRunner
extends Node

signal confrontation_ended

@export var _encounter_runner: EncounterRunner


func run(confrontation: Confrontation, party: Party) -> ConfrontationResult:
	if confrontation == null:
		Verbose.error("ConfrontationRunner.run: confrontation null", Verbose.Category.ENCOUNTER_RUNNER)
		return null
	if _encounter_runner == null:
		Verbose.error("ConfrontationRunner.run: _encounter_runner not assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return null

	if confrontation.tavern_encounter != null:
		await _encounter_runner.run_tavern(confrontation.tavern_encounter, party)

	var result: ConfrontationResult = null
	if confrontation.fighting_encounter != null:
		var party_formation: FightingFormation = party.formation if party != null else null
		var party_won: bool = await _encounter_runner.run_fighting(confrontation.fighting_encounter, party_formation)
		result = ConfrontationResult.new()
		result.outcome = ConfrontationResult.Outcome.WIN if party_won else ConfrontationResult.Outcome.LOSS

	confrontation_ended.emit()
	return result
