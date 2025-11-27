class_name Game
extends Node3D

# ============================== Enum ==============================

enum GameState {
	STARTING,
	INITIATING_NEW_ROUND,
	BUYING,
	FIGHTING_POSITIONING,
	FIGHTING_COUNTDOWN,
	FIGHTING_NORMAL,
	FIGHTING_ACCELERATED,
	FIGHTING_CELEBRATING,
	FIGHTING_FINISHED,
	FINISHED,
	UNDEF
}

var _fighting_islands: Dictionary[int, FightingIsland] # [player_id, FightingIslands]
var _current_round_battles: Array[Battle]

# ============================== Network Export ==============================

@export_group("Network")
@export var _current_round_player_id_islands: Array[int] # player_id

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _buying_island: BuyingIsland
@export var _scene_switcher: SceneSwitcher
@export var _hero_selector: HeroSelector

@export var _node_fighting_islands: Node3D # Network spawn of FloatingIslands TODO (Spawn Island from the player Island)
@export var _node_characters: Node3D # Network spawn of Characters

@export var _islands_spawn_points: Array[SpawnPoint]

@onready var _island_spawns_to_be_removed: Node3D = %IslandSpawns

# ============================== Node base functions ==============================

func _ready() -> void:
	_hero_selector.all_heroes_picked.connect(_on_hero_selector_all_heroes_picked)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	GlobalFightingManager.all_fights_are_over.connect(_on_global_fighting_manager_all_fights_are_over)
	Shared.scene_switcher = _scene_switcher
	_start_game()

# ============================== Private functions ==============================

func _start_game() -> void:
	GlobalLogger.debug("Starting game", GlobalLogger.Category.GAME)
	GameManager.update_game_state(GameState.STARTING, true)
	_spawn_fighting_islands()
	_start_hero_selection()


func _start_hero_selection() -> void:
	_hero_selector.start()


func _start_new_round() ->void:
	GlobalLogger.debug("Start new round", GlobalLogger.Category.GAME)
	_current_round_player_id_islands.clear()
	
	if GameManager.is_end_of_game():
		GameManager.update_game_state(GameState.FINISHED, true)
		GlobalLogger.debug("Looks like we have a winner ! Congrats " + PlayerManager.get_alive_players().values()[0].name, GlobalLogger.Category.GAME)
		return
	
	_current_round_battles = await RoundManager.get_current_round_battles()
	_init_current_round_player_id_islands(_current_round_battles.size())
	RoundManager.starting_round_player_changes()
	await PlayerManager.sync_point(PlayerManager.SyncID.ROUND_SETUP)
	GameManager.update_game_state(Game.GameState.BUYING)


func _start_buying_phase() -> void:
	GlobalLogger.debug("Start BUYING !", GlobalLogger.Category.GAME)
	_scene_switcher.set_island_active_only(_buying_island)
	_buying_island.start_buying_phase(_current_round_battles)
	GameManager.game_state_timer.wait_time = GameManager.game_rules.duration_buying_phase
	GameManager.game_state_timer.start()


func _start_fighting_phase() -> void:
	GlobalLogger.debug("Start fights !", GlobalLogger.Category.GAME)
	var battles: Array[Battle] = _current_round_battles
	for i in battles.size():
		var characters: Array[Character]
		for player in battles[i].players:
			player.character.battle_id = battles[i].id
			characters.append(player.character)
		var player_id: int = _current_round_player_id_islands[i]
		var fighting_island: FightingIsland = PlayerManager.players[player_id].fighting_island
		fighting_island.start_fight(characters, battles[i].battle_type, battles[i].id)
	# Start fight on each island
	GlobalFightingManager.start()

# ============================== Random islands functions ==============================

# Automatically sync with MultiplayerSynchronizer
func _init_current_round_player_id_islands(islands_number: int) -> void:
	if not multiplayer.is_server(): return
	var alive_players: Array[Player] = PlayerManager.get_alive_players().values().duplicate()
	for i in islands_number:
		var random_player: Player = alive_players.pick_random()
		_current_round_player_id_islands.append(random_player.id)
		alive_players.erase(random_player)

# ============================== Spawn functions ==============================

func _spawn_fighting_islands() -> void:
	if multiplayer.is_server():
		var i:int = 0
		for player in PlayerManager.players.values():
			var spawn_point: SpawnPoint = _islands_spawn_points[i]
			var fighting_island: FightingIsland = preload("res://FloatingIsland/FightingIsland/fighting_island.tscn").instantiate()
			fighting_island.player_owner_id = player.id
			fighting_island.name = "FightingIsland_" + player.name
			_node_fighting_islands.add_child(fighting_island)
			fighting_island.global_position = spawn_point.global_position
			fighting_island.global_rotation = spawn_point.global_rotation
			_scene_switcher.fighting_islands[i] = fighting_island
			_fighting_islands[player.id] = fighting_island
			i += 1
	_island_spawns_to_be_removed.queue_free()


func _spawn_all_characters() -> void:
	if not multiplayer.is_server(): return
	for player in PlayerManager.players.values():
		var character: Character = preload("res://Entities/Character/character.tscn").instantiate()
		character.owner_player_id = player.id
		character.hero_id = player.hero.id
		character.name = "Character_" + player.hero.name + "_" + player.name
		_node_characters.add_child(character)
		player.character = character

@rpc("authority", "call_local")
func _end_buying_round() -> void:
	_on_buying_island_buying_phase_finished()

# ============================== Callbacks ==============================

func _on_buying_island_buying_phase_finished() -> void:
	GlobalLogger.debug("BUYING PHASE ENDED", GlobalLogger.Category.GAME)
	_start_fighting_phase()
	_buying_island.cleanup()


func _on_hero_selector_all_heroes_picked() -> void:
	GlobalLogger.debug("BUYING AREA ALL HEROES PICKED", GlobalLogger.Category.GAME)
	_spawn_all_characters()
	GameManager.update_game_state(Game.GameState.INITIATING_NEW_ROUND)


func _on_global_fighting_manager_all_fights_are_over() -> void:
	GlobalLogger.debug("ALL FIGHTS ARE OVER", GlobalLogger.Category.GAME)
	await PlayerManager.sync_point(PlayerManager.SyncID.FIGHTING_PHASE)
	await RoundManager.ending_round_player_changes()
	await PlayerManager.sync_point(PlayerManager.SyncID.ROUND_ENDING)


func _on_game_manager_game_state_changed(game_state: GameState) -> void:
	match game_state:
		GameState.INITIATING_NEW_ROUND: _start_new_round()
		GameState.BUYING: _start_buying_phase()
		GameState.FIGHTING_POSITIONING: _start_fighting_phase()


func _on_buying_area_timer_timeout() -> void:
	if multiplayer.is_server():
		_end_buying_round.rpc()
