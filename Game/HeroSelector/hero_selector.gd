class_name HeroSelector
extends Node

# ============================== Signals ==============================

signal all_heroes_picked
signal _player_hero_picked

# ============================== Enums ==============================

enum SelectionType {
	UNIQUE,
	MULTIPLE
}

# ============================== Local nodes ==============================

@export var _ui_hero_picking_screen: UIHeroPickingScreen

# ============================== Private variables ==============================

var _available_heroes: Array[HeroDesc]
var _heroes_ready: int
var _selection_type: SelectionType = SelectionType.MULTIPLE

# ============================== Node base functions ==============================

func _ready() -> void:
	_ui_hero_picking_screen.hide()
	_player_hero_picked.connect(_on_player_hero_picked)
	_ui_hero_picking_screen.hero_locked.connect(_on_ui_hero_picking_screen_hero_locked)

# ============================== Public functions ==============================

func start() -> void:
	var heroes: Array[HeroDesc] = await GameManager.get_current_game_heroes()
	
	_available_heroes = heroes.duplicate()
	_ui_hero_picking_screen.show()
	_ui_hero_picking_screen.update_heroes(heroes)
	
	if GameManager.game_type == GameManager.GameType.SOLO:
		_ui_hero_picking_screen.open_hero_selection()
	
	_start_multiple_hero_selection_behaviour()

# ============================== Private functions ==============================

func _start_unique_hero_selection_behaviour() -> void:
	_selection_type = SelectionType.UNIQUE
	if multiplayer.is_server():
		var pickup_order_players = await GameManager.get_hero_pickup_order()
		for player in pickup_order_players:
			_start_player_turn_to_pick.rpc(player.id)
			await _player_hero_picked


func _start_multiple_hero_selection_behaviour() -> void:
	_selection_type = SelectionType.MULTIPLE
	if multiplayer.is_server():
		_start_hero_selection.rpc()
		for player in PlayerManager.players.values():
			if player.is_bot:
				player.hero = await _get_random_hero_and_wait_random_duration()
				Verbose.debug("Player " + player.name + " picked " + player.hero.name, Verbose.Category.HERO_SELECTOR)
				_pick_hero_multiple.rpc(player.id, player.hero.id)

# ============================== MULTIPLE HERO SELECTION BEHAVIOUR ==============================

@rpc("authority", "call_local", "reliable")
func _start_hero_selection() -> void:
	_ui_hero_picking_screen.update_countdown(30)
	_ui_hero_picking_screen.update_bottom_message("Waiting for all players to pick their hero")
	if not multiplayer.is_server():
		_ui_hero_picking_screen.open_hero_selection()


# TODO check if the client is taking an available hero in the server
@rpc("any_peer", "call_local", "reliable")
func _pick_hero_multiple(player_id: int, hero_id: HeroDesc.HeroId) -> void:
	PlayerManager.players[player_id].hero = Shared.HEROES[hero_id]
	_player_hero_picked.emit()

# ============================== UNIQUE HERO SELECTION BEHAVIOUR ==============================

@rpc("authority", "call_local", "reliable")
func _start_player_turn_to_pick(player_id: int) -> void:
	var player_picking = PlayerManager.players[player_id]
	if multiplayer.is_server():
		_ui_hero_picking_screen.update_bottom_player_name(player_picking.name, false)
		if player_picking.is_bot:
			player_picking.hero = await _get_random_hero_and_wait_random_duration()
			Verbose.debug("Player " + player_picking.name + " picked " + player_picking.hero.name, Verbose.Category.HERO_SELECTOR)
			_pick_hero_unique.rpc(player_picking.id, player_picking.hero.id)
	else:
		if player_picking == PlayerManager.get_local_player():
			_ui_hero_picking_screen.update_bottom_player_name(player_picking.name, true)
			_ui_hero_picking_screen.open_hero_selection()
		else:
			_ui_hero_picking_screen.update_bottom_player_name(player_picking.name, false)


func _get_random_hero_and_wait_random_duration() -> HeroDesc:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	await get_tree().create_timer(rng.randf_range(0.1, 0.5)).timeout
	var random_hero: HeroDesc = _available_heroes.pick_random()
	return random_hero


@rpc("any_peer", "call_local", "reliable")
func _pick_hero_unique(player_id: int, hero_id: HeroDesc.HeroId) -> void:
	_available_heroes.erase(Shared.HEROES[hero_id])
	PlayerManager.players[player_id].hero = Shared.HEROES[hero_id]
	_ui_hero_picking_screen.make_hero_unavailable(Shared.HEROES[hero_id])
	_player_hero_picked.emit()

# ============================== Callbacks ==============================

func _on_ui_hero_picking_screen_hero_locked(hero: HeroDesc) -> void:
	if hero == null: return
	if _selection_type == SelectionType.UNIQUE:
		_pick_hero_unique.rpc(multiplayer.get_unique_id(), hero.id)
	else:
		_pick_hero_multiple.rpc(multiplayer.get_unique_id(), hero.id)


func _on_player_hero_picked() -> void:
	_heroes_ready += 1
	if _heroes_ready >= PlayerManager.MAX_PLAYERS:
		_ui_hero_picking_screen.hide()
		all_heroes_picked.emit()
