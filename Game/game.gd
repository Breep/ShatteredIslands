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

var _families_ref: Dictionary # Reference Dictionary to all families
var _active_families: Array[Family] # Array of all families activated for this game only
var _rules: GameRules

var _fighting_islands: Dictionary[int, FightingIsland]

var _current_round_battles: Array[Battle]

# ============================== Local nodes ==============================

@export var _buying_island: BuyingIsland
@export var _scene_switcher: SceneSwitcher
@export var _hero_selector: HeroSelector

@export var _node_fighting_islands: Node3D # Network spawn of FloatingIslands TODO (Spawn Island from the player Island)
@export var _node_characters: Node3D # Network spawn of Characters

@export var _islands_spawn_points: Array[SpawnPoint]

@export var _ui_game: UIGame

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
	_current_round_battles = await RoundManager.get_current_round_battles()
	await PlayerManager.sync_point(PlayerManager.SyncID.STARTING_NEW_ROUND)
	RoundManager.starting_round_player_changes()
	_start_buying_phase(_current_round_battles)


func _start_buying_phase(battles: Array[Battle]) -> void:
	print("[", multiplayer.get_unique_id(), "] Game: Start BUYING !")
	game_state = GameState.BUYING
	_buying_island.set_active()
	_buying_island.start_buying_phase(battles)


func _start_fighting_phase(battles: Array[Battle]) -> void:
	print("[", multiplayer.get_unique_id(), "] Game: Start fights !")
	game_state = GameState.FIGHTING
	var fighting_islands_choosen: Array[FightingIsland] = _pickup_n_random_islands(battles.size())
	for i in battles.size():
		var characters: Array[Character]
		for player in battles[i].players:
			player.character.battle_id = battles[i].id
			characters.append(player.character)
		fighting_islands_choosen[i].start_fight(characters, battles[i].battle_type, battles[i].id)
	# Start fight on each island
	GlobalFightingManager.start()


# ============================== Private functions ==============================

func _pickup_n_random_islands(islands_number: int) -> Array[FightingIsland]:
	if not multiplayer.is_server(): return [] # TODO
	var fighting_islands_choosen: Array[FightingIsland]
	var alive_players: Array[Player] = PlayerManager.get_alive_players().values().duplicate()
	for i in islands_number:
		var random_player: Player = alive_players.pick_random()
		fighting_islands_choosen.append(_fighting_islands[random_player.id])
		alive_players.erase(random_player)
	return fighting_islands_choosen

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
		var character: Character = Shared.CHARACTERS[player.hero.id].instantiate()
		character.owner_player_id = player.id
		_node_characters.add_child(character)
		player.character = character

# ============================== Callbacks ==============================

func _on_buying_island_buying_phase_finished() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: BUYING PHASE ENDED")
	_start_fighting_phase(_current_round_battles)


func _on_hero_selector_all_heroes_picked() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: BUYING AREA ALL HEAROES PICKED")
	_spawn_all_characters()
	_start_new_round()


func _on_global_fighting_manager_all_fights_are_over() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: ALL FIGHTS ARE OVER")
	await RoundManager.ending_round_player_changes()
	print("[", multiplayer.get_unique_id(), "] Game: ALL FIGHTS ARE OVER 1")
	await get_tree().create_timer(1.0).timeout
	print("[", multiplayer.get_unique_id(), "] Game: ALL FIGHTS ARE OVER 2")
	await PlayerManager.sync_point(PlayerManager.SyncID.ENDING_ROUND)
	print("[", multiplayer.get_unique_id(), "] Game: ALL FIGHTS ARE OVER 3")
	_start_new_round()
