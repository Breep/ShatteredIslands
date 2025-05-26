class_name Game
extends Node3D

# ============================== Enum ==============================

enum GameState {
	STARTING,
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

var _current_round_number: int
var _current_round_battles: Array[Battle]

# ============================== Local nodes ==============================

@export var _buying_island: BuyingIsland
@export var _scene_switcher: SceneSwitcher
@export var _hero_selector: HeroSelector

@export var _node_fighting_islands: Node3D # Network spawn of FloatingIslands
@export var _node_characters: Node3D # Network spawn of Characters

# ============================== Node base functions ==============================

func _ready() -> void:
	#_buying_area.phase_ended.connect(_on_buying_area_phase_ended)
	_hero_selector.all_heroes_picked.connect(_on_hero_selector_all_heroes_picked)
	#GlobalFightingManager.all_fights_are_over.connect(_on_global_fighting_manager_all_fights_are_over)
	
	_start_game()

# ============================== Private functions ==============================

func _start_game() -> void:
	# Start hero selection
	# Start first round
	_start_hero_selection()
	#_start_new_round()


func _start_hero_selection() -> void:
	game_state = GameState.STARTING
	_hero_selector.start()
	#_buying_area.start_hero_selection(heroes)


func _start_new_round() ->void:
	print("[", multiplayer.get_unique_id(), "] Game: Start new round")
	_current_round_battles = await RoundManager.get_current_round_battles()
	await PlayerManager.sync_point(PlayerManager.SyncID.STARTING_NEW_ROUND)
	RoundManager.starting_round_player_changes()
	_start_buying_phase()


func _spawn_all_fighting_areas(battles: Array[Battle]) -> void:
	if not multiplayer.is_server():
		return


func _start_buying_phase() -> void:
	game_state = GameState.BUYING
	_buying_island.start_buying_phase(_current_round_battles)
	#_buying_area.start_round(_current_round_battles)


func _start_fighting_phase() -> void:
	game_state = GameState.FIGHTING
	print("[", multiplayer.get_unique_id(), "] Game: Start fights !")
	#for fighting_area in _fighting_areas:
		#fighting_area.start_fight()
	GlobalFightingManager.start()


func _spawn_all_characters() -> void:
	if not multiplayer.is_server(): return
	for player in PlayerManager.players.values():
		var character: Character = Shared.CHARACTERS[player.hero.id].instantiate()
		character.owner_player_id = player.id
		_node_characters.add_child(character)
		player.character = character

# ============================== Callbacks ==============================

func _on_buying_area_phase_ended() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: BUYING PHASE ENDED")
	_start_fighting_phase()


func _on_hero_selector_all_heroes_picked() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: BUYING AREA ALL HEAROES PICKED")
	_spawn_all_characters()
	_start_new_round()

func _on_global_fighting_manager_all_fights_are_over() -> void:
	print("[", multiplayer.get_unique_id(), "] Game: ALL FIGHTS ARE OVER")
	await RoundManager.ending_round_player_changes()
	await get_tree().create_timer(1.0).timeout
	await PlayerManager.sync_point(PlayerManager.SyncID.ENDING_ROUND)
	_start_new_round()
