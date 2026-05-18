# Racine du Flow B (run roguelite) : récupère le RunContext préparé par
# GameManager au change_scene, déclenche GameRunner.run() sur la Run, et émet
# run_finished à la fin des confrontations. Save inter-confrontation via le
# signal confrontation_ended. Affiche l'écran de résultat via UIGame.
class_name RunRoot
extends Node3D

const MAIN_MENU_SCENE_PATH := "res://05_Game/MainMenu/main_menu.tscn"
const RUN_WIN_PLAYER_PLACE := 1

signal run_finished

@export var _game_runner: GameRunner
@export var _confrontation_runner: ConfrontationRunner
@export var _ui_game: UIGame

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
	if _confrontation_runner == null:
		Verbose.error("RunRoot: _confrontation_runner non assigné", Verbose.Category.GAME)
		return
	if _ui_game == null:
		Verbose.error("RunRoot: _ui_game non assigné", Verbose.Category.GAME)
		return

	_ui_game.result_leave_requested.connect(_on_result_leave_requested)
	_confrontation_runner.confrontation_ended.connect(_on_confrontation_ended)

	Verbose.debug("RunRoot: démarrage Run id=" + _run_context.run_id + " (" + str(_run_context.run.confrontations.size()) + " confrontations)", Verbose.Category.GAME)
	await _game_runner.run(_run_context.run, _run_context.party)
	Verbose.debug("RunRoot: Run terminée", Verbose.Category.GAME)
	run_finished.emit()
	_ui_game.show_run_result(RUN_WIN_PLAYER_PLACE)


func _on_confrontation_ended() -> void:
	GameManager.save_run_context()


func _on_result_leave_requested() -> void:
	GameManager.clear_save()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
