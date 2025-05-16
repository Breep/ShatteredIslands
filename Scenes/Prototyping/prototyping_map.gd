extends Node3D

@export var _battle_id: int
@export var _entity_manager: EntityManager
@export var _spawn_manager: SpawnManager

@export var _player1_cards: Array[Card]
@export var _player2_cards: Array[Card]

@export var _character1: Character
@export var _character2: Character

func _enter_tree() -> void:
	Shared.entity_managers_ref[_battle_id] = _entity_manager
	Shared.spawn_managers_ref[_battle_id] = _spawn_manager
	_spawn_manager.battle_id = _battle_id

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
