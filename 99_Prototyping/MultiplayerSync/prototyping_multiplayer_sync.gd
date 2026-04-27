extends Node3D

# ============================== Description ==============================
#
# Prototyping scene for testing multiplayer sync
# Uses same setup as prototyping_map_1v1 but adds configurable sync parameters
# and a debug panel for comparing server/client battle log sync

# ============================== Export variables ==============================

@export_group("Player Cards")
@export var _player1_cards: Array[Card]
@export var _player2_cards: Array[Card]
@export var _player3_cards: Array[Card]
@export var _player4_cards: Array[Card]
@export var _player5_cards: Array[Card]
@export var _player6_cards: Array[Card]
@export var _player7_cards: Array[Card]
@export var _player8_cards: Array[Card]

@export_group("Heroes")
@export var _hero_descs: Array[HeroDesc]
@export var _hero_teams: Array[int] = [1, 2]

@export_group("Battle")
@export var _fighting_island_scene: PackedScene
@export var _battle_type: Battle.BattleType

@export_group("Sync Settings")
@export var _initial_sync_period: float = 1.0
@export var _initial_client_delay_ms: int = 0

# ============================== Private variables ==============================

var _heroes: Array[Hero] = []
var _players: Array[Player] = []
var _floating_island: FightingIsland

# ============================== Onready nodes ==============================

@onready var _ui_fighting_area: UIFightingArea = %UIFightingArea
@onready var _ui_proto: Control = %UIProto
@onready var _sync_debug_panel: Control = %SyncDebugPanel

# ============================== Constants ==============================

const SERVER_PORT: int = 4242
const SERVER_IP: String = "127.0.0.1"

# ============================== Node base functions ==============================

func _ready() -> void:
	_setup_network()
	_sync_debug_panel.update_role()
	
	GameManager.init()
	GameManager.game_rules.duration_fighting_countdown = 3
	GameManager.game_rules.duration_fighting_normal = 240.0

	_instantiate_heroes()
	_init_players()
	_add_player_cards()


func _setup_network() -> void:
	var peer := ENetMultiplayerPeer.new()

	if "--server" in OS.get_cmdline_args():
		# SERVER: create server and wait for client
		Verbose.info("Proto Sync: Starting server on port " + str(SERVER_PORT), Verbose.Category.NET)
		var error: Error = peer.create_server(SERVER_PORT, 8)
		if error != OK:
			Verbose.error("Proto Sync: Failed to create server: " + str(error), Verbose.Category.NET)
			return
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)

		# Wait for a client to connect, then enable the Start button
		multiplayer.peer_connected.connect(_on_client_connected)
		multiplayer.peer_disconnected.connect(_on_client_disconnected)
		Verbose.info("Proto Sync: Waiting for client...", Verbose.Category.NET)
	else:
		# CLIENT: connect to server
		Verbose.info("Proto Sync: Connecting to server at " + SERVER_IP + ":" + str(SERVER_PORT), Verbose.Category.NET)
		var error: Error = peer.create_client(SERVER_IP, SERVER_PORT)
		if error != OK:
			Verbose.error("Proto Sync: Failed to connect: " + str(error), Verbose.Category.NET)
			return
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)

		# Wait for connection
		multiplayer.connected_to_server.connect(_on_connected_to_server, CONNECT_ONE_SHOT)
		multiplayer.connection_failed.connect(func() -> void:
			Verbose.error("Proto Sync: Connection failed!", Verbose.Category.NET)
		)

	# Connect the Start Fight button from SyncDebugPanel
	_sync_debug_panel.start_fight_requested.connect(_on_start_fight_requested)


func _on_client_connected(_peer_id: int) -> void:
	Verbose.info("Proto Sync: Client connected!", Verbose.Category.NET)
	_sync_debug_panel.set_client_connected(true)
	_floating_island = _fighting_island_scene.instantiate() as FightingIsland
	add_child(_floating_island)


func _on_client_disconnected(_peer_id: int) -> void:
	Verbose.info("Proto Sync: Client disconnected!", Verbose.Category.NET)
	_sync_debug_panel.set_client_connected(false)


func _on_connected_to_server() -> void:
	Verbose.info("Proto Sync: Connected to server! Waiting for fight start...", Verbose.Category.NET)
	_sync_debug_panel.set_client_connected(true)
	_floating_island = _fighting_island_scene.instantiate() as FightingIsland
	add_child(_floating_island)


func _on_start_fight_requested() -> void:
	_rpc_start_fight.rpc()


@rpc("authority", "call_local", "reliable")
func _rpc_start_fight() -> void:
	Verbose.info("Proto Sync: Received fight start from server", Verbose.Category.NET)
	_start_fight()


func _start_fight() -> void:
	GameManager.request_state_transition(GameManager.GameState.FIGHTING)
	_floating_island.init_fight(_heroes, _battle_type, 1)
	_floating_island.set_active()
	GlobalFightingManager.start()

	_ui_fighting_area.update_content(_floating_island.get_fighting_area())
	_ui_fighting_area.set_active()

	# Connect sync debug panel
	_setup_sync_debug_panel()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_action_pressed("hide_ui"):
			_ui_fighting_area.visible = not _ui_fighting_area.visible
			_ui_proto.visible = not _ui_proto.visible
		if event.is_action_pressed("hide_3d_ui"):
			for hero: Hero in _heroes:
				hero._entity_info_panel_3d.visible = not hero._entity_info_panel_3d.visible

# ============================== Private functions ==============================

func _instantiate_heroes() -> void:
	for i: int in _hero_descs.size():
		var hero_desc: HeroDesc = _hero_descs[i]
		if hero_desc == null:
			Verbose.warn("HeroDesc at index " + str(i) + " is null, skipping", Verbose.Category.DEFAULT)
			continue

		var hero: Hero = Shared.HERO_SCENES[hero_desc.id].instantiate().init(Hero.DisplayMode.FIGHTING_PHASE)
		hero.level = 1
		hero.entity_name = "Player" + str(i + 1)

		if i < _hero_teams.size():
			hero.team = _hero_teams[i]
		else:
			hero.team = i % 2 + 1

		_heroes.append(hero)
		Verbose.debug("Created hero: " + hero.entity_name + " (Team " + str(hero.team) + ")", Verbose.Category.DEFAULT)


func _init_players() -> void:
	var player_scene: PackedScene = preload("res://Player/player.tscn")
	for i: int in _heroes.size():
		var player: Player = player_scene.instantiate()
		player.init_player()
		player.player_name = "Player" + str(i + 1)
		player.name = "Player_" + str(i + 1)
		player.id = 1
		player.hero_desc = _hero_descs[i]
		player.hero = _heroes[i]
		player.hero.entity_name = player.player_name
		player.skill_manager = SkillManager.new()
		_players.append(player)
		add_child(player)


func _add_player_cards() -> void:
	var players_cards: Array[Array] = [
		_player1_cards, _player2_cards, _player3_cards, _player4_cards,
		_player5_cards, _player6_cards, _player7_cards, _player8_cards
	]

	for i: int in _players.size():
		_players[i].skill_manager.init(_players[i])
		var card_uid: int = 0
		for card: Card in players_cards[i]:
			card.uid = card_uid
			card_uid += 1
			_players[i].deck.add_card(card)


func _setup_sync_debug_panel() -> void:
	var fighting_area: FightingArea = _floating_island.get_fighting_area()
	if fighting_area == null:
		Verbose.error("Cannot setup sync debug panel: FightingArea is null", Verbose.Category.DEFAULT)
		return

	# Wire the debug panel to the battle log nodes inside FightingArea
	_sync_debug_panel._battle_writer = fighting_area.get_node_or_null("BattleWriter") as BattleWriter
	_sync_debug_panel._battle_reader = fighting_area.get_node_or_null("BattleReader") as BattleReader
	_sync_debug_panel._entity_manager = fighting_area.entity_manager

	# Get the BattleLogSynchronizer for sync period control
	var synchronizer: BattleLogSynchronizer = fighting_area.get_node_or_null("BattleLogSynchronizer") as BattleLogSynchronizer
	var reader: BattleReader = _sync_debug_panel._battle_reader

	# Apply initial settings
	if synchronizer != null:
		synchronizer.set_sync_period(_initial_sync_period)
	if reader != null:
		reader.simulated_delay_ms = _initial_client_delay_ms

	# Connect slider signals
	_sync_debug_panel.sync_period_changed.connect(func(new_period: float) -> void:
		if synchronizer != null:
			synchronizer.set_sync_period(new_period)
	)
	_sync_debug_panel.client_delay_changed.connect(func(new_delay_ms: int) -> void:
		if reader != null:
			reader.simulated_delay_ms = new_delay_ms
	)
