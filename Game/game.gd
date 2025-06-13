class_name Game
extends Node3D

# ============================== Enum ==============================

enum GameState {
	POSITIONING,
	BUYING,
	FIGHTING,
	UNDEF
}

var _game_state: GameState = GameState.UNDEF
var game_state: GameState:
	get: return _game_state
	set(value):
		if _game_state == value: return
		_game_state = value
		Events.game_state_changed.emit(_game_state)

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
	if PlayerManager.players.size() < 2: return # Don't do anything if there is no player (for testing purpose)
	
	_hero_selector.all_heroes_picked.connect(_on_hero_selector_all_heroes_picked)
	_buying_island.buying_phase_finished.connect(_on_buying_island_buying_phase_finished)
	
	GlobalFightingManager.all_fights_are_over.connect(_on_global_fighting_manager_all_fights_are_over)
	
	_start_game()

# ============================== Private functions ==============================

func _start_game() -> void:
	_spawn_fighting_islands()
	_start_hero_selection()


func _start_hero_selection() -> void:
	game_state = GameState.POSITIONING
	_hero_selector.start()
	#_buying_area.start_hero_selection(heroes)


func _start_new_round() ->void:
	print("[", multiplayer.get_unique_id(), "] Game: Start new round")
	_current_round_player_id_islands.clear()
	
	_current_round_battles = await RoundManager.get_current_round_battles()
	_init_current_round_player_id_islands(_current_round_battles.size())
	RoundManager.starting_round_player_changes()
	await PlayerManager.sync_point(PlayerManager.SyncID.ROUND_SETUP)
	_start_buying_phase(_current_round_battles)


func _start_buying_phase(battles: Array[Battle]) -> void:
	print("[", multiplayer.get_unique_id(), "] Game: Start BUYING !")
	game_state = GameState.BUYING
	_buying_island.set_active()
	_buying_island.start_buying_phase(battles)


func _start_fighting_phase(battles: Array[Battle]) -> void:
	print("[", multiplayer.get_unique_id(), "] Game: Start fights !")
	game_state = GameState.FIGHTING
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
	return

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
		character.name = "Character_" + player.hero.name
		_node_characters.add_child(character)
		player.character = character

# ============================== Callbacks ==============================

func _on_buying_island_buying_phase_finished() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: BUYING PHASE ENDED")
	await PlayerManager.sync_point(PlayerManager.SyncID.BUYING_PHASE)
	_start_fighting_phase(_current_round_battles)


func _on_hero_selector_all_heroes_picked() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: BUYING AREA ALL HEROES PICKED")
	_spawn_all_characters()
	_start_new_round()


func _on_global_fighting_manager_all_fights_are_over() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: ALL FIGHTS ARE OVER")
	await PlayerManager.sync_point(PlayerManager.SyncID.FIGHTING_PHASE)
	await RoundManager.ending_round_player_changes()
	await PlayerManager.sync_point(PlayerManager.SyncID.ROUND_ENDING)
	_start_new_round()
