# Racine du Flow B (run roguelite) : récupère le RunContext préparé par
# GameManager au change_scene, déclenche GameRunner.run() sur la Run, et émet
# run_finished à la fin des confrontations. Écran de fin / retour menu seront
# branchés en D5.
class_name RunRoot
extends Node3D

signal run_finished

@export var _game_runner: GameRunner

var _run_context: RunContext


func _ready() -> void:
	_run_context = GameManager.run_context
	if _run_context == null:
		Verbose.error("RunRoot: pas de RunContext disponible", Verbose.Category.GAME)
		return
	if _run_context.run == null or _run_context.run.confrontations.is_empty():
		Verbose.error("RunRoot: RunContext.run vide ou sans confrontations", Verbose.Category.GAME)
		return
	if _game_runner == null:
		Verbose.error("RunRoot: _game_runner non assigné", Verbose.Category.GAME)
		return

	Verbose.debug("RunRoot: démarrage Run id=" + _run_context.run_id + " (" + str(_run_context.run.confrontations.size()) + " confrontations)", Verbose.Category.GAME)
	await _game_runner.run(_run_context.run, _run_context.party)
	Verbose.debug("RunRoot: Run terminée", Verbose.Category.GAME)
	run_finished.emit()
