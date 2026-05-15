# Parcourt un Run : exécute chaque Confrontation dans l'ordre via le
# ConfrontationRunner enfant. Top-level orchestrateur de la session de jeu.
class_name GameRunner
extends Node

@export var _confrontation_runner: ConfrontationRunner


func run(the_run: Run, party: Party) -> void:
	if the_run == null:
		Verbose.error("GameRunner.run: the_run null", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _confrontation_runner == null:
		Verbose.error("GameRunner.run: _confrontation_runner not assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	the_run.current_index = 0
	while not the_run.is_finished():
		var confrontation: Confrontation = the_run.get_current()
		if confrontation == null:
			break
		await _confrontation_runner.run(confrontation, party)
		the_run.advance()
