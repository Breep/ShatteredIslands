class_name HeroSelector
extends Node

signal all_heroes_picked

signal _player_hero_picked

@export var _ui_hero_picking_screen: UIHeroPickingScreen

var _available_heroes: Array[Hero]

var _heroes_ready: int

func _ready() -> void:
	_player_hero_picked.connect(_on_player_hero_picked)
	_ui_hero_picking_screen.hero_locked.connect(_on_ui_hero_picking_screen_hero_locked)

func start() -> void:
	var heroes: Array[Hero] = await GameManager.get_current_game_heroes()
	
	_available_heroes = heroes.duplicate()
	_ui_hero_picking_screen.show()
	_ui_hero_picking_screen.update_heroes(heroes)
	
	if multiplayer.is_server():
		var pickup_order_players = await GameManager.get_hero_pickup_order()
		for player in pickup_order_players:
			_start_player_turn_to_pick.rpc(player.id)
			await _player_hero_picked

# ============================== Private functions ==============================

@rpc("authority", "call_local")
func _start_player_turn_to_pick(player_id: int) -> void:
	var player_picking = PlayerManager.players[player_id]
	if multiplayer.is_server():
		_ui_hero_picking_screen.update_bottom_message(player_picking.name, false)
		if player_picking.is_bot:
			player_picking.hero = await _get_random_hero_and_wait_random_duration()
			print("Player ", player_picking.name, " picked ", player_picking.hero.name)
			_pick_hero.rpc(player_picking.id, player_picking.hero.id)
	else:
		if player_picking == PlayerManager.get_local_player():
			_ui_hero_picking_screen.update_bottom_message(player_picking.name, true)
			_ui_hero_picking_screen.open_hero_selection()
		else:
			_ui_hero_picking_screen.update_bottom_message(player_picking.name, false)


func _get_random_hero_and_wait_random_duration() -> Hero:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	await get_tree().create_timer(rng.randf_range(0.1, 0.5)).timeout
	var random_hero: Hero = _available_heroes.pick_random()
	return random_hero


# TODO check if the client is taking an available hero in the server
@rpc("any_peer", "call_local")
func _pick_hero(player_id: int, hero_id: Hero.HeroId) -> void:
	_available_heroes.erase(Shared.HEROES[hero_id])
	PlayerManager.players[player_id].hero = Shared.HEROES[hero_id]
	_ui_hero_picking_screen.make_hero_unavailable(Shared.HEROES[hero_id])
	_player_hero_picked.emit()


func _on_ui_hero_picking_screen_hero_locked(hero: Hero) -> void:
	if multiplayer.is_server(): return
	_pick_hero.rpc(multiplayer.get_unique_id(), hero.id)


func _on_player_hero_picked() -> void:
	print("HERO PICKED")
	_heroes_ready += 1
	if _heroes_ready >= PlayerManager.MAX_PLAYERS:
		_ui_hero_picking_screen.hide()
		all_heroes_picked.emit()
