# Proto scene pour valider une Confrontation complète (taverne → combat) via
# le ConfrontationRunner. Crée une Party locale, instancie les runners,
# enchaîne les phases automatiquement.
extends Node

@export_group("Proto Inputs")
@export var _confrontation: Confrontation
@export var _default_player_formation: FightingFormation
@export var _hero_scenes: Array[PackedScene] = []
@export var _acolyte_scenes: Array[PackedScene] = []

var _encounter_runner: EncounterRunner
var _confrontation_runner: ConfrontationRunner


func _ready() -> void:
	if _confrontation == null:
		Verbose.error("EncounterRunner proto: no _confrontation assigned", Verbose.Category.ENCOUNTER_RUNNER)
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
	_confrontation_runner = ConfrontationRunner.new()
	_confrontation_runner._encounter_runner = _encounter_runner
	add_child(_confrontation_runner)

	var party: Party = Party.new()
	party.formation = _default_player_formation.populate_with(_hero_scenes, _acolyte_scenes)

	await _confrontation_runner.run(_confrontation, party)


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
