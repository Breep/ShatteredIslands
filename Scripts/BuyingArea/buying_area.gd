class_name BuyingArea
extends Node3D

signal phase_ended()

var _current_round: int
var _battles: Array[Battle]

var _available_heroes: Array[Hero]

@onready var _tavern: Tavern = %Tavern

@onready var _ui_hero_picking_screen: UIHeroPickingScreen = %UIHeroPickingScreen

func _ready() -> void:
	_current_round = RoundManager.current_round
	_ui_hero_picking_screen.hero_locked.connect(_on_ui_hero_picking_screen_hero_locked)
	#_battles = RoundManager.get_current_round_battles()


# Reload the tavern center
func start_round(battles: Array[Battle]) -> void:
	CameraManager.camera_changed.emit(CameraManager.CameraType.BUYING_AREA)
	_tavern.put_tables_according_to_battles(battles)


signal _player_hero_picked()

func start_hero_selection(heroes: Array[Hero]) -> void:
	_tavern.init_hero_selection(heroes)
	_available_heroes = heroes.duplicate()
	_ui_hero_picking_screen.update_heroes(heroes)
	
	if multiplayer.is_server():
		var pickup_order_players = await GameManager.get_hero_pickup_order()
		if not multiplayer.is_server():
			print("break here")
		
		for player in pickup_order_players:
			_start_player_turn_to_pick.rpc(player.id)
			await _player_hero_picked


@rpc("authority", "call_local")
func _start_player_turn_to_pick(player_id: int) -> void:
	var player_picking = PlayerManager.players[player_id]
	if multiplayer.is_server():
		_ui_hero_picking_screen.update_bottom_message(player_picking.name, false)
		if player_picking.is_bot:
			player_picking.hero = await _get_random_hero_and_wait_random_duration(_available_heroes)
			print("Player ", player_picking.name, " picked ", player_picking.hero.name)
			_pick_hero.rpc(player_picking.id, player_picking.hero.id)
	else:
		if player_picking == PlayerManager.get_local_player():
			_ui_hero_picking_screen.update_bottom_message(player_picking.name, true)
			_ui_hero_picking_screen.open_hero_selection()
		else:
			_ui_hero_picking_screen.update_bottom_message(player_picking.name, false)


func _get_random_hero_and_wait_random_duration(heroes: Array[Hero]) -> Hero:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	await get_tree().create_timer(rng.randf_range(1.0, 6.0)).timeout
	var random_hero: Hero = _available_heroes.pick_random()
	_available_heroes.erase(random_hero)
	return random_hero


@rpc("any_peer", "call_local")
func _pick_hero(player_id: int, hero_id: Hero.HeroId) -> void:
	PlayerManager.players[player_id].hero = Shared.HEROES[hero_id]
	_ui_hero_picking_screen.make_hero_unavailable(Shared.HEROES[hero_id])
	_player_hero_picked.emit()


func _on_ui_hero_picking_screen_hero_locked(hero: Hero) -> void:
	if multiplayer.is_server(): return
	_pick_hero.rpc(multiplayer.get_unique_id(), hero.id)













 
