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

func _enter_tree() -> void:
	var _players_cards: Array[Array] = [
		_player1_cards, _player2_cards, _player3_cards, _player4_cards, _player5_cards, _player6_cards,_player7_cards, _player8_cards
	]
	
	for i in _characters.size():
		var player: Player = Player.new()
		player.name = "Player" + str(i)
		player.id = 1
		player.character = _characters[i]
		player.character.player = player
		for card in _players_cards[i]:
			player.deck.add_card(card)


func _ready() -> void:
	_floating_island.start_fight(_characters, _battle_type)
	GlobalFightingManager.start(true)
	_floating_island.set_active()
	#_ui_fighting_area.show()
