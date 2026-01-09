class_name Game
extends Node3D

#region ============================== Private variables ==============================
var _fighting_islands: Dictionary[int, FightingIsland] # [player_id, FightingIslands]
var _current_round_battles: Array[Battle]
var _current_round_player_id_islands: Array[int] # player_id
#endregion

#region ============================== Local nodes ==============================
@export_group("Local Nodes")
@export var _buying_island: BuyingIsland
@export var _scene_switcher: SceneSwitcher
@export var _hero_selector: HeroSelector
@export var _node_fighting_islands: Node3D # Network spawn of FloatingIslands TODO (Spawn Island from the player Island)
@export var _node_characters: Node3D # Network spawn of Characters
@export var _islands_spawn_points: Array[SpawnPoint]
@onready var _island_spawns_to_be_removed: Node3D = %IslandSpawns
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	_hero_selector.all_heroes_picked.connect(_on_hero_selector_all_heroes_picked)
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	Shared.scene_switcher = _scene_switcher
	_start_game()
#endregion

#region ============================== Private functions ==============================
func _start_game() -> void:
	Verbose.debug("Starting game", Verbose.Category.GAME)
	GameManager.game_state = GameManager.GameState.STARTING
	_spawn_fighting_islands()
	_start_hero_selection()


func _start_hero_selection() -> void:
	_hero_selector.start()


func _start_new_round() ->void:
	Verbose.debug("Start new round", Verbose.Category.GAME)
	_current_round_player_id_islands.clear()
	
	if GameManager.is_end_of_game(): # TODO Rien à faire ici ça, à corriger
		GameManager.game_state = GameManager.GameState.FINISHED
		Verbose.debug("Looks like we have a winner ! Congrats " + PlayerManager.get_alive_players().values()[0].name, Verbose.Category.GAME)
		return
	
	_current_round_battles = await RoundManager.get_current_round_battles()
	await _init_current_round_player_id_islands(_current_round_battles.size())
	RoundManager.starting_round_player_changes()
	await PlayerManager.sync_point(PlayerManager.SyncID.ROUND_SETUP)
	GameManager.game_state = GameManager.GameState.BUYING # TODO Peut-être revoir ça ? Envoyer un signal et laisser le GameManager changer ses états tout seul ?


func _start_buying_phase() -> void:
	Verbose.debug("Start BUYING !", Verbose.Category.GAME)
	_scene_switcher.set_island_active_only(_buying_island)
	_buying_island.start_buying_phase(_current_round_battles)
	GameManager.game_state_timer.wait_time = GameManager.game_rules.duration_buying_phase
	GameManager.game_state_timer.start()


func _start_fighting_phase() -> void:
	Verbose.debug("Start fights !", Verbose.Category.GAME)
	var battles: Array[Battle] = _current_round_battles
	for i in battles.size():
		var heroes: Array[Hero]
		for player: Player in battles[i].players:
			player.character.battle_id = battles[i].id
			heroes.append(player.character)
		var player_id: int = _current_round_player_id_islands[i]
		var fighting_island: FightingIsland = PlayerManager.players[player_id].fighting_island
		fighting_island.init_fight(heroes, battles[i].battle_type, battles[i].id)
	# Start fight on each island
	GlobalFightingManager.start()
#endregion

# ============================== Random islands functions ==============================

signal _current_round_player_id_islands_received
func _init_current_round_player_id_islands(islands_number: int) -> void:
	Verbose.trace("_init_current_round_player_id_islands() | " + str(islands_number), Verbose.Category.GAME)
	if not multiplayer.is_server():
		if _current_round_player_id_islands.is_empty():
			await _current_round_player_id_islands_received
	else:
		var alive_players: Array[Player] = PlayerManager.get_alive_players().values().duplicate()
		for i in islands_number:
			var random_player: Player = alive_players.pick_random()
			_current_round_player_id_islands.append(random_player.id)
			alive_players.erase(random_player)
		_current_round_player_id_islands_sync.rpc(_current_round_player_id_islands)
	Verbose.trace("_init_current_round_player_id_islands() | " + str(_current_round_player_id_islands), Verbose.Category.GAME)


@rpc("authority", "call_remote", "reliable")
func _current_round_player_id_islands_sync(current_round_player_id_islands: Array[int]) -> void:
	_current_round_player_id_islands = current_round_player_id_islands
	_current_round_player_id_islands_received.emit()

#region ============================== Spawn functions ==============================
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
#endregion

#region ============================== Callbacks ==============================
func _on_buying_island_buying_phase_finished() -> void:
	Verbose.debug("BUYING PHASE ENDED", Verbose.Category.GAME)
	_start_fighting_phase()
	_buying_island.cleanup()


func _on_hero_selector_all_heroes_picked() -> void:
	Verbose.debug("BUYING AREA ALL HEROES PICKED", Verbose.Category.GAME)
	GameManager.game_state = GameManager.GameState.INIT_ROUND


func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.INIT_ROUND: _start_new_round()
		GameManager.GameState.BUYING: _start_buying_phase()
		GameManager.GameState.FIGHTING: _start_fighting_phase()
#endregion
