# Proto scene pour tester une Confrontation via le ConfrontationRunner.
# La Confrontation s'auto-exécute (tavern → fight → done). Les phases qui n'ont
# pas encore de signal de fin naturel (taverne) sont terminées manuellement via
# des boutons qui émettent eux-mêmes les signaux d'EncounterRunner.
extends Node

@export_group("Proto Inputs")
@export var _confrontation: Confrontation
@export var _default_player_formation: FightingFormation
@export var _hero_scenes: Array[PackedScene] = []
@export var _acolyte_scenes: Array[PackedScene] = []

@onready var _end_tavern_button: Button = %EndTavernButton
@onready var _end_fight_button: Button = %EndFightButton
@onready var _reload_button: Button = %ReloadButton

var _encounter_runner: EncounterRunner
var _confrontation_runner: ConfrontationRunner


func _ready() -> void:
	if _confrontation == null:
		Verbose.error("Confrontation proto: no _confrontation assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _default_player_formation == null:
		Verbose.error("Confrontation proto: no _default_player_formation assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	GameManager.init()
	GameManager.game_type = GameManager.GameType.SOLO
	CardShopManager.init(GameManager.active_families, GameManager.game_rules)
	_create_fake_player()

	_encounter_runner = EncounterRunner.new()
	add_child(_encounter_runner)
	_confrontation_runner = ConfrontationRunner.new()
	_confrontation_runner._encounter_runner = _encounter_runner
	add_child(_confrontation_runner)
	_confrontation_runner.confrontation_ended.connect(_on_confrontation_ended)

	var party: Party = Party.new()
	party.formation = _default_player_formation.populate_with(party, _hero_scenes, _acolyte_scenes)

	_end_tavern_button.pressed.connect(_on_end_tavern_pressed)
	_end_fight_button.pressed.connect(_on_end_fight_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)

	_confrontation_runner.run(_confrontation, party)


func _on_end_tavern_pressed() -> void:
	_end_tavern_button.disabled = true
	_encounter_runner.tavern_phase_ended.emit()


func _on_end_fight_pressed() -> void:
	_end_fight_button.disabled = true
	_encounter_runner.fighting_phase_ended.emit()


func _on_confrontation_ended() -> void:
	Verbose.debug("Confrontation ended", Verbose.Category.ENCOUNTER_RUNNER)


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
