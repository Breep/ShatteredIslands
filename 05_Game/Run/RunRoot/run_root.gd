# Racine du Flow B (run roguelite) : récupère le RunContext préparé par
# GameManager au change_scene, déclenche GameRunner.run() sur la Run, et émet
# run_finished à la fin des confrontations. Save inter-confrontation via le
# signal confrontation_ended. Affiche l'écran de fin et permet le retour menu.
class_name RunRoot
extends Node3D

const MAIN_MENU_SCENE_PATH := "res://05_Game/MainMenu/main_menu.tscn"

signal run_finished

@export var _game_runner: GameRunner
@export var _confrontation_runner: ConfrontationRunner
@export var _end_screen: Control
@export var _end_screen_label: Label
@export var _return_menu_button: Button

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

	if _end_screen != null:
		_end_screen.hide()
	if _return_menu_button != null:
		_return_menu_button.pressed.connect(_on_return_menu_pressed)

	_confrontation_runner.confrontation_ended.connect(_on_confrontation_ended)

	Verbose.debug("RunRoot: démarrage Run id=" + _run_context.run_id + " (" + str(_run_context.run.confrontations.size()) + " confrontations)", Verbose.Category.GAME)
	await _game_runner.run(_run_context.run, _run_context.party)
	Verbose.debug("RunRoot: Run terminée", Verbose.Category.GAME)
	run_finished.emit()
	_show_end_screen()


func _on_confrontation_ended() -> void:
	GameManager.save_run_context()


func _show_end_screen() -> void:
	if _end_screen == null: return
	if _end_screen_label != null:
		_end_screen_label.text = "Run terminée !"
	_end_screen.show()


func _on_return_menu_pressed() -> void:
	GameManager.clear_save()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
