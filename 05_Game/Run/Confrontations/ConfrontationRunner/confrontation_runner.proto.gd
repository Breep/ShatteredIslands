# Proto scene pour tester une Confrontation hors d'un Run.
# Trois boutons : lancer la phase taverne, lancer la phase combat, recharger.
# Chaque phase est déclenchable indépendamment — la Confrontation vit en isolation.
# (Un Encounter peut aussi vivre seul via encounter_runner.proto.
#  Une Formation peut vivre seule via fighting_formation.proto.)
extends Node

@export_group("Proto Inputs")
@export var _confrontation: Confrontation
@export var _default_player_formation: FightingFormation
@export var _hero_scenes: Array[PackedScene] = []
@export var _acolyte_scenes: Array[PackedScene] = []

@onready var _tavern_button: Button = %TavernButton
@onready var _fight_button: Button = %FightButton
@onready var _reload_button: Button = %ReloadButton

var _encounter_runner: EncounterRunner
var _party: Party


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

	_party = Party.new()
	_party.formation = _default_player_formation.populate_with(_hero_scenes, _acolyte_scenes)

	_tavern_button.pressed.connect(_on_tavern_pressed)
	_fight_button.pressed.connect(_on_fight_pressed)
	_reload_button.pressed.connect(_on_reload_pressed)


func _on_tavern_pressed() -> void:
	if _confrontation.tavern_encounter == null:
		Verbose.warn("Confrontation has no tavern_encounter", Verbose.Category.ENCOUNTER_RUNNER)
		return
	_tavern_button.disabled = true
	await _encounter_runner.setup_tavern(_confrontation.tavern_encounter, _party)


func _on_fight_pressed() -> void:
	if _confrontation.fighting_encounter == null:
		Verbose.warn("Confrontation has no fighting_encounter", Verbose.Category.ENCOUNTER_RUNNER)
		return
	_fight_button.disabled = true
	await _encounter_runner.setup_fighting(_confrontation.fighting_encounter, _party.formation)
	GlobalFightingManager.start()


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
