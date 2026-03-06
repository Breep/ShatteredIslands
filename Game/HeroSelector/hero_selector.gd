class_name HeroSelector
extends Node

# ============================== Signals ==============================

signal all_heroes_picked
signal _player_hero_picked

# ============================== Local nodes ==============================

@export var _ui_hero_picking_screen: UIHeroPickingScreen

# ============================== Private variables ==============================

var _available_heroes: Array[HeroDesc]
var _heroes_ready: int

# [Server only]
var _game_heroes_ready: bool = false
signal _heroes_choosen
var _random_heroes_ref: Array[HeroDesc.HeroId]

# [Client only] Emitted when the server has answered the local client request
signal _server_answered

# ============================== Node base functions ==============================

func _ready() -> void:
	_ui_hero_picking_screen.hide()
	_player_hero_picked.connect(_on_player_hero_picked)
	_ui_hero_picking_screen.hero_locked.connect(_on_ui_hero_picking_screen_hero_locked)

# ============================== Public functions ==============================

func start() -> void:
	var heroes: Array[HeroDesc] = await _get_current_game_heroes()

	_available_heroes = heroes.duplicate()
	_ui_hero_picking_screen.show()
	_ui_hero_picking_screen.update_heroes(heroes)

	if GameManager.game_type == GameManager.GameType.SOLO:
		_ui_hero_picking_screen.open_hero_selection()

	_start_multiple_hero_selection_behaviour()

# ============================== Private functions ==============================

func _get_current_game_heroes() -> Array[HeroDesc]:
	if multiplayer.is_server():
		_init_current_game_heroes()
	else:
		_ask_get_n_random_heroes.rpc_id(1, multiplayer.get_unique_id())
		await _server_answered

	var random_heroes: Array[HeroDesc]
	for hero_ref in _random_heroes_ref:
		random_heroes.append(Shared.HEROES[hero_ref])

	return random_heroes


func _init_current_game_heroes() -> void:
	# TODO Disabled for the moment
	#if heroes_number <= 0 or heroes_number > Shared.HEROES.size():
		#printerr("HeroDesc: Wrong heroes_number: ", heroes_number)
		#return

	#var heroes_ref: Array[HeroDesc.HeroId]
	#for hero_ref in Shared.HEROES.keys():
		#heroes_ref.append(hero_ref)
	#
	#var rng := RandomNumberGenerator.new()
	#rng.randomize()
	#for i in heroes_number:
		#var random_index: int = rng.randi_range(0, heroes_ref.size() - 1)
		#_random_heroes_ref.append(heroes_ref.get(random_index))
		#heroes_ref.remove_at(random_index)

	_random_heroes_ref.append(HeroDesc.HeroId.DARK_KNIGHT)
	_heroes_choosen.emit()
	_game_heroes_ready = true


@rpc("any_peer", "call_remote")
func _ask_get_n_random_heroes(peer_id: int) -> void:
	if not multiplayer.is_server():
		Verbose.error("Only server should be asked for random heroes", Verbose.Category.HERO_SELECTOR)
		return

	if not _game_heroes_ready:
		await _heroes_choosen

	_answer_get_n_random_heroes.rpc_id(peer_id, _random_heroes_ref)


@rpc("authority", "call_remote")
func _answer_get_n_random_heroes(heroes_ref: Array[HeroDesc.HeroId]) -> void:
	_random_heroes_ref = heroes_ref
	_server_answered.emit()


func _start_multiple_hero_selection_behaviour() -> void:
	if multiplayer.is_server():
		_start_hero_selection.rpc()
		for player in PlayerManager.players.values():
			if player.is_bot:
				var picked_hero_desc: HeroDesc = await _get_random_hero_and_wait_random_duration()
				Verbose.debug("Player " + player.player_name + " picked " + picked_hero_desc.name, Verbose.Category.HERO_SELECTOR)
				_pick_hero_multiple.rpc(player.id, picked_hero_desc.id)

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
	PlayerManager.players[player_id].hero_desc = Shared.HEROES[hero_id]
	_player_hero_picked.emit()


func _get_random_hero_and_wait_random_duration() -> HeroDesc:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	await get_tree().create_timer(rng.randf_range(0.1, 0.5)).timeout
	var random_hero: HeroDesc = _available_heroes.pick_random()
	return random_hero

# ============================== Callbacks ==============================

func _on_ui_hero_picking_screen_hero_locked(hero: HeroDesc) -> void:
	if hero == null: return
	_pick_hero_multiple.rpc(multiplayer.get_unique_id(), hero.id)


func _on_player_hero_picked() -> void:
	_heroes_ready += 1
	if _heroes_ready >= PlayerManager.players.size():
		_ui_hero_picking_screen.hide()
		all_heroes_picked.emit()
