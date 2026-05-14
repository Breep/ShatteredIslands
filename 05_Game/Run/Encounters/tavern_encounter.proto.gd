# Proto scene pour valider l'injection d'un TavernEncounter dans la BuyingIsland.
# Instancie un faux Player (pour la plomberie shop de cartes), une BuyingIsland
# complète, puis appelle la nouvelle API start_buying_phase_from_encounter().
extends Node

@export_group("Proto Inputs")
@export var _tavern_encounter: TavernEncounter
@export var _hero_scene: PackedScene
@export var _acolyte_scenes: Array[PackedScene] = []

const BUYING_ISLAND_SCENE: PackedScene = preload("res://06_FloatingIsland/BuyingIsland/buying_island.tscn")


func _ready() -> void:
	if _tavern_encounter == null:
		Verbose.error("TavernEncounter proto: no _tavern_encounter assigned", Verbose.Category.ENCOUNTER_RUNNER)
		return

	GameManager.init()
	CardShopManager.init(GameManager.active_families, GameManager.game_rules)

	_create_fake_player()

	var buying_island: BuyingIsland = BUYING_ISLAND_SCENE.instantiate()
	add_child.call_deferred(buying_island)
	await buying_island.ready
	buying_island.start_buying_phase_from_encounter(_tavern_encounter, _hero_scene, _acolyte_scenes)
	buying_island.set_active()


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
