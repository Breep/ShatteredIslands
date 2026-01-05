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

@export_group("Characters")
@export var _characters: Array[Character]

@export_group("Battle")
@export var _floating_island: FightingIsland
@export var _battle_type: Battle.BattleType

@onready var _ui_fighting_area: UIFightingArea = %UIFightingArea
@onready var _ui_proto: Control = %UIProto

@onready var _ui_player_stats: UIDebugEntityStats = %PlayerStats
@onready var _ui_entity_bds_registry: UIEntityBDSRegistry = %EntityBDSRegistry

# add a way to show stats when player press tabs button (input mapped on "see_stats")

func _enter_tree() -> void:
	_init_players()


func _ready() -> void:
	GameManager.init()
	_add_player_cards()
	_floating_island.init_fight(_characters, _battle_type)
	GameManager.game_rules.duration_fighting_positioning = 0.5
	GameManager.game_rules.duration_fighting_countdown = 0.5
	GameManager.game_rules.duration_fighting_normal = 240.0
	GameManager.game_state = GameManager.GameState.FIGHTING
	GlobalFightingManager.start()
	_floating_island.set_active()
	_ui_fighting_area.update_content(_floating_island._fighting_area)
	_ui_fighting_area.set_active()
	_ui_player_stats.hide()
	_ui_player_stats.connect_entity(_characters[0])
	_ui_entity_bds_registry.connect_entity_bds_registry(_characters[0].bds_registry)


# Add a way to show stats when player presses Tab (input mapped on "see_stats")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_action_pressed("see_stats"):
			_ui_player_stats.visible = not _ui_player_stats.visible
		if event.is_action_pressed("trigger_bds_viewer"):
			_ui_entity_bds_registry.visible = not _ui_entity_bds_registry.visible
		if event.is_action_pressed("scene_switch_1") and _characters.size() > 0: _ui_player_stats.connect_entity(_characters[0])
		if event.is_action_pressed("scene_switch_2") and _characters.size() > 1: _ui_player_stats.connect_entity(_characters[1])
		if event.is_action_pressed("scene_switch_3") and _characters.size() > 2: _ui_player_stats.connect_entity(_characters[2])
		if event.is_action_pressed("scene_switch_4") and _characters.size() > 3: _ui_player_stats.connect_entity(_characters[3])
		if event.is_action_pressed("scene_switch_5") and _characters.size() > 4: _ui_player_stats.connect_entity(_characters[4])
		if event.is_action_pressed("scene_switch_6") and _characters.size() > 5: _ui_player_stats.connect_entity(_characters[5])
		if event.is_action_pressed("scene_switch_7") and _characters.size() > 6: _ui_player_stats.connect_entity(_characters[6])
		if event.is_action_pressed("scene_switch_8") and _characters.size() > 7: _ui_player_stats.connect_entity(_characters[7])
		if event.is_action_pressed("hide_ui"):
			_ui_fighting_area.visible = not _ui_fighting_area.visible
			_ui_proto.visible = not _ui_proto.visible
		if event.is_action_pressed("hide_3d_ui"):
			for character: Character in _characters:
				character._character_visual.visible = not character._character_visual.visible


func _init_players() -> void:
	for i: int in _characters.size():
		var player: Player = Player.new()
		player.name = "Player" + str(i+1)
		player.id = 1
		player.character = _characters[i]
		player.character.name = player.name
		player.character.player = player
		player.skill_manager = SkillManager.new()


func _add_player_cards() -> void:
	var players_cards: Array[Array] = [
		_player1_cards, _player2_cards, _player3_cards, _player4_cards, _player5_cards, _player6_cards,_player7_cards, _player8_cards
	]
	
	for i: int in _characters.size():
		_characters[i].player.skill_manager.init(_characters[i].player)
		var uid: int = 0
		for card: Card in players_cards[i]:
			card.uid = uid
			uid += 1
			_characters[i].player.deck.add_card(card)
