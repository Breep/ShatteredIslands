# Orchestre une Confrontation : phase taverne suivie de la phase combat.
# Délègue l'exécution à un EncounterRunner (configuré via @export).
# Émet confrontation_ended quand toutes les phases sont terminées.
class_name ConfrontationRunner
extends Node

signal confrontation_ended

@export var _encounter_runner: EncounterRunner


func run(confrontation: Confrontation, party: Party) -> void:
	if confrontation == null:
		Verbose.error("ConfrontationRunner.run: confrontation null", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _encounter_runner == null:
		Verbose.error("ConfrontationRunner.run: _encounter_runner not assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	if confrontation.tavern_encounter != null:
		await _encounter_runner.run_tavern(confrontation.tavern_encounter, party)

	if confrontation.fighting_encounter != null:
		var party_formation: FightingFormation = party.formation if party != null else null
		await _encounter_runner.run_fighting(confrontation.fighting_encounter, party_formation)

	confrontation_ended.emit()
