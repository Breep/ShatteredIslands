# Proto scene pour valider un TavernEncounter via l'EncounterRunner.
# Construit une Party locale (template de formation par défaut + héros/acolytes
# exportés), instancie un faux Player pour la plomberie shop, puis utilise
# EncounterRunner.setup_tavern() pour peupler la BuyingIsland.
extends Node

@export_group("Proto Inputs")
@export var _tavern_encounter: TavernEncounter
@export var _default_player_formation: FightingFormation
@export var _hero_scenes: Array[PackedScene] = []
@export var _acolyte_scenes: Array[PackedScene] = []

var _encounter_runner: EncounterRunner


func _ready() -> void:
	if _tavern_encounter == null:
		Verbose.error("TavernEncounter proto: no _tavern_encounter assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return
	if _default_player_formation == null:
		Verbose.error("TavernEncounter proto: no _default_player_formation assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	GameManager.init()
	CardShopManager.init(GameManager.active_families, GameManager.game_rules)
	_create_fake_player()

	_encounter_runner = EncounterRunner.new()
	add_child(_encounter_runner)

	var party: Party = Party.new()
	party.formation = _default_player_formation.populate_with(_hero_scenes, _acolyte_scenes)

	await _encounter_runner._setup_tavern(_tavern_encounter, party)


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
