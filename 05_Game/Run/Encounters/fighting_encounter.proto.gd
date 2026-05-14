# Proto scene pour valider le combat à partir d'un FightingEncounter.
# Construit la formation team_a en matérialisant un template (FightingFormation
# par défaut, ex: default_solo.fighting.tres) avec les héros et acolytes
# fournis en export, puis appelle directement island.init_fight_3() sans
# passer par l'EncounterRunner (testé ailleurs).
# UI minimale : un bouton Start (lance le combat) + un bouton Reload (recharge la scène).
extends Node

@export_group("Proto Inputs")
@export var _fighting_encounter: FightingEncounter
@export var _default_player_formation: FightingFormation
@export var _hero_scenes: Array[PackedScene] = []
@export var _acolyte_scenes: Array[PackedScene] = []

@export_group("Teams")
@export var _player_team: int = 1
@export var _mob_team: int = 2

@onready var _start_button: Button = %StartButton
@onready var _reload_button: Button = %ReloadButton

var _island: FightingIsland


func _ready() -> void:
	if _fighting_encounter == null:
		Verbose.error("FightingEncounter proto: no _fighting_encounter assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _fighting_encounter.island_scene == null:
		Verbose.error("FightingEncounter proto: encounter has no island_scene", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _fighting_encounter.team_b_formation == null:
		Verbose.error("FightingEncounter proto: encounter has no team_b_formation", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _default_player_formation == null:
		Verbose.error("FightingEncounter proto: no _default_player_formation assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	GameManager.init()

	_island = _fighting_encounter.island_scene.instantiate()
	add_child.call_deferred(_island)
	await _island.ready
	_island.set_active()

	var player_formation: FightingFormation = _default_player_formation.populate_with(_hero_scenes, _acolyte_scenes)
	var mob_formation: FightingFormation = _fighting_encounter.team_b_formation
	_island.init_fight_3(player_formation.mirrored(), mob_formation, _player_team, _mob_team)

	_start_button.pressed.connect(_on_start_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)


func _on_start_pressed() -> void:
	_start_button.disabled = true
	GlobalFightingManager.start()


func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()
