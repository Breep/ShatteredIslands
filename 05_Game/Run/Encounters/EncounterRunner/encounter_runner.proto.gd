# Proto scene pour tester l'EncounterRunner avec un Encounter unique
# (FightingEncounter OU TavernEncounter — dispatch automatique selon le type).
# Permet de valider qu'un Encounter peut vivre hors d'une Confrontation.
extends Node

@export_group("Proto Inputs")
@export var _encounter: Encounter
@export var _default_player_formation: FightingFormation
@export var _hero_scenes: Array[PackedScene] = []
@export var _acolyte_scenes: Array[PackedScene] = []

@onready var _run_button: Button = %RunButton
@onready var _reload_button: Button = %ReloadButton

var _encounter_runner: EncounterRunner
var _party: Party


func _ready() -> void:
	if _encounter == null:
		Verbose.error("EncounterRunner proto: no _encounter assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _default_player_formation == null:
		Verbose.error("EncounterRunner proto: no _default_player_formation assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	GameManager.init()
	GameManager.game_type = GameManager.GameType.SOLO
	CardShopManager.init(GameManager.active_families, GameManager.game_rules)
	_create_fake_player()

	_encounter_runner = EncounterRunner.new()
	add_child(_encounter_runner)

	_party = Party.new()
	# Proto à retravailler : FightingFormation.populate_with() a été supprimé.
	#_party.formation = _default_player_formation.populate_with(_party, _hero_scenes, _acolyte_scenes)

	_run_button.pressed.connect(_on_run_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)


func _on_run_pressed() -> void:
	_run_button.disabled = true
	if _encounter is FightingEncounter:
		await _encounter_runner.setup_fighting(_encounter, _party.formation)
		GlobalFightingManager.start()
	elif _encounter is TavernEncounter:
		await _encounter_runner._setup_tavern(_encounter, _party)
	else:
		Verbose.warn("EncounterRunner proto: unknown encounter type", Verbose.Category.ENCOUNTER_RUNNER)


func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()


func _create_fake_player() -> void:
	var player: Player = PlayerManager.PLAYER_SCENE.instantiate()
	player.init_player()
	player.name = "Player_proto"
	player.player_name = "Proto"
	player.id = multiplayer.get_unique_id()
	player.is_bot = false
	PlayerManager.add_child(player)
	PlayerManager.players[player.id] = player
	player.setup_components()
