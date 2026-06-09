# Proto scene pour valider un FightingEncounter via l'EncounterRunner.
# Construit une Party locale à partir des héros/acolytes exportés et du template
# de formation par défaut, puis utilise EncounterRunner.setup_fighting() pour
# instancier l'île. GlobalFightingManager.start() est déclenché par le bouton Start.
extends Node

@export_group("Proto Inputs")
@export var _fighting_encounter: FightingEncounter
@export var _default_player_formation: FightingFormation

@onready var _start_button: Button = %StartButton
@onready var _reload_button: Button = %ReloadButton

var _encounter_runner: EncounterRunner


func _ready() -> void:
	if _fighting_encounter == null:
		Verbose.error("FightingEncounter proto: no _fighting_encounter assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _default_player_formation == null:
		Verbose.error("FightingEncounter proto: no _default_player_formation assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	GameManager.init()

	_encounter_runner = EncounterRunner.new()
	add_child.call_deferred(_encounter_runner)
	await _encounter_runner.ready

	var party: Party = Party.new()
	# Proto à retravailler : FightingFormation.populate_with() a été supprimé.
	#party.formation = _default_player_formation.populate_with(party, _hero_scenes, _acolyte_scenes)

	await _encounter_runner.setup_fighting(_fighting_encounter, party.formation)

	_start_button.pressed.connect(_on_start_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)


func _on_start_pressed() -> void:
	_start_button.disabled = true
	GlobalFightingManager.start()


func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()
