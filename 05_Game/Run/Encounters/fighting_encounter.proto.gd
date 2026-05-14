# Proto scene pour valider le combat à partir d'un FightingEncounter.
# Instancie l'island_scene de l'encounter, construit une formation joueur à la
# volée depuis le hero + acolytes exportés, et appelle directement
# island.init_fight_3() (sans passer par l'EncounterRunner — testé ailleurs).
# UI minimale : un bouton Start (lance le combat) + un bouton Reload (recharge la scène).
extends Node

@export_group("Proto Inputs")
@export var _fighting_encounter: FightingEncounter
@export var _hero_scene: PackedScene
@export var _acolyte_scenes: Array[PackedScene] = []

@export_group("Player formation layout")
@export var _hero_offset: Vector3 = Vector3(5.0, 0.0, 0.0)
@export var _acolyte_step: Vector3 = Vector3(0.0, 0.0, 1.0)
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
	
	GameManager.init()
	
	_island = _fighting_encounter.island_scene.instantiate()
	add_child.call_deferred(_island)
	await _island.ready
	_island.set_active()
	
	var player_formation: FightingFormation = _build_player_formation()
	var mob_formation: FightingFormation = _fighting_encounter.team_b_formation.force_team(_mob_team)
	_island.init_fight_3(player_formation, mob_formation)
	
	_start_button.pressed.connect(_on_start_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)


func _on_start_pressed() -> void:
	_start_button.disabled = true
	GlobalFightingManager.start()


func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()


func _build_player_formation() -> FightingFormation:
	var formation: FightingFormation = FightingFormation.new()
	formation.id = "proto_player"
	if _hero_scene != null:
		formation.entity_specs.append(_make_spec(_hero_scene, FightingEntitySpec.FightingRole.HERO, _hero_offset, "Hero"))
	for i in _acolyte_scenes.size():
		if _acolyte_scenes[i] == null: continue
		var pos: Vector3 = _hero_offset + _acolyte_step * (i + 1)
		formation.entity_specs.append(_make_spec(_acolyte_scenes[i], FightingEntitySpec.FightingRole.ACOLYTE, pos, "Acolyte_" + str(i)))
	return formation


func _make_spec(scene: PackedScene, role: FightingEntitySpec.FightingRole, pos: Vector3, label: String) -> FightingEntitySpec:
	var spec: FightingEntitySpec = FightingEntitySpec.new()
	spec.scene = scene
	spec.role = role
	spec.team = _player_team
	spec.display_label = label
	spec.free_position = pos
	return spec
