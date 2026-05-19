extends Node3D

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
@export var _hero_teams: Array[int] = [0, 0, 0, 0, 1, 1, 1, 1] # Team assignment for each hero

var _heroes: Array[Hero] = [] # Dynamically instantiated heroes

@export_group("Battle")
@export var _floating_island: FightingIsland
@export var _battle_type: Battle.BattleType

@onready var _ui_proto: Control = %UIProto

@onready var _ui_player_stats: UIDebugEntityStats = %PlayerStats
@onready var _ui_entity_bds_registry: UIEntityBDSRegistry = %EntityBDSRegistry

var _players: Array[Player] = []

# add a way to show stats when player press tabs button (input mapped on "see_stats")

func _enter_tree() -> void:
	pass # Players will be initialized after heroes are created


func _ready() -> void:
	GameManager.init()
	
	# Instantiate heroes dynamically from HeroDesc
	_instantiate_heroes()
	
	# Initialize players with the created heroes
	_init_players()
	
	_add_player_cards()
	GameManager.game_rules.duration_fighting_countdown = 1
	GameManager.game_rules.duration_fighting_normal = 240.0
	GameManager.request_state_transition(GameManager.GameState.FIGHTING)
	GlobalFightingManager.start()
	_floating_island.set_active()
	_ui_player_stats.hide()
	_ui_player_stats.connect_entity(_heroes[0])
	_ui_entity_bds_registry.connect_entity_bds_registry(_heroes[0].bds_registry)


# Add a way to show stats when player presses Tab (input mapped on "see_stats")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_action_pressed("see_stats"):
			_ui_player_stats.visible = not _ui_player_stats.visible
		if event.is_action_pressed("trigger_bds_viewer"):
			_ui_entity_bds_registry.visible = not _ui_entity_bds_registry.visible
		if event.is_action_pressed("scene_switch_1") and _heroes.size() > 0: _ui_player_stats.connect_entity(_heroes[0])
		if event.is_action_pressed("scene_switch_2") and _heroes.size() > 1: _ui_player_stats.connect_entity(_heroes[1])
		if event.is_action_pressed("scene_switch_3") and _heroes.size() > 2: _ui_player_stats.connect_entity(_heroes[2])
		if event.is_action_pressed("scene_switch_4") and _heroes.size() > 3: _ui_player_stats.connect_entity(_heroes[3])
		if event.is_action_pressed("scene_switch_5") and _heroes.size() > 4: _ui_player_stats.connect_entity(_heroes[4])
		if event.is_action_pressed("scene_switch_6") and _heroes.size() > 5: _ui_player_stats.connect_entity(_heroes[5])
		if event.is_action_pressed("scene_switch_7") and _heroes.size() > 6: _ui_player_stats.connect_entity(_heroes[6])
		if event.is_action_pressed("scene_switch_8") and _heroes.size() > 7: _ui_player_stats.connect_entity(_heroes[7])
		if event.is_action_pressed("hide_ui"):
			_ui_proto.visible = not _ui_proto.visible
		if event.is_action_pressed("hide_3d_ui"):
			for hero: Hero in _heroes:
				hero._entity_info_panel_3d.visible = not hero._entity_info_panel_3d.visible


func _instantiate_heroes() -> void:
	for i: int in _hero_descs.size():
		var hero_desc: HeroDesc = _hero_descs[i]
		if hero_desc == null:
			Verbose.warn("HeroDesc at index " + str(i) + " is null, skipping", Verbose.Category.DEFAULT)
			continue
		
		# Instantiate hero with FIGHTING_PHASE display mode for prototyping
		var hero: Hero = Shared.HERO_SCENES[hero_desc.id].instantiate().init(Hero.DisplayMode.FIGHTING_PHASE)
		hero.entity_name = "Player" + str(i + 1)
		
		# Assign team (default to index-based if array is too small)
		if i < _hero_teams.size():
			hero.team = _hero_teams[i]
		else:
			hero.team = i % 2 # Default: alternate between team 0 and 1
		
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
		# player.hero_desc supprimé en Phase 3 (vit sur HeroSpec maintenant) — proto à reworker
		player.hero = _heroes[i]
		player.hero.entity_name = player.player_name
		player.skill_manager = SkillManager.new()
		_players.append(player)
		add_child(player)


func _add_player_cards() -> void:
	var players_cards: Array[Array] = [
		_player1_cards, _player2_cards, _player3_cards, _player4_cards, _player5_cards, _player6_cards, _player7_cards, _player8_cards
	]

	for i: int in _players.size():
		_players[i].skill_manager.init(_players[i])
		var uid: int = 0
		for card: Card in players_cards[i]:
			card.uid = uid
			uid += 1
			_players[i].deck.add_card(card)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
