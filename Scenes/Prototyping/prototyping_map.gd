extends Node3D

@export var _battle_id: int
@export var _floating_island: FloatingIsland

@export var _player1_cards: Array[Card]
@export var _player2_cards: Array[Card]

@export var _character1: Character
@export var _character2: Character

func _enter_tree() -> void:
	var player1: Player = Player.new()
	player1.name = "Player1"
	player1.id = 1
	player1.character = _character1
	player1.character.player = player1
	for card in _player1_cards:
		player1.deck.add_card(card)
	
	var player2: Player = Player.new()
	player2.name = "Player2"
	player2.id = 2
	player2.character = _character2
	player2.character.player = player2
	for card in _player2_cards:
		player2.deck.add_card(card)


func _ready() -> void:
	_floating_island.start_fight([_character1, _character2], Battle.BattleType.VS_1)
	_character1.fighting_state = GlobalFightingManager.FightingState.FIGHT
	_character2.fighting_state = GlobalFightingManager.FightingState.FIGHT
	_floating_island.set_active()
	#_ui_fighting_area.show()
