class_name Table
extends Node3D

# ============================== Local nodes ==============================

@onready var entities_node: Node3D = %Entities

# ============================== Export (Local) ==============================

@export var _coin_piles: Array[CoinPile]
@export var _hero_spawns: Array[Node3D]

@export var battle_type: Battle.BattleType
@export var battle_id: int

# ============================== Node base functions ==============================

func _enter_tree() -> void:
	for hero_spawn in _hero_spawns:
		for child in hero_spawn.get_children():
			child.queue_free()

func _ready() -> void:
	if _hero_spawns.size() != _coin_piles.size(): # or _card_fans.size() != _hero_spawns.size():
		printerr("Table: There are not the same amount of CoinPile/HereSpawn")
		return

# ============================== Public functions ==============================

func connect_to_players(players: Array[Player]) -> void:
	for child in entities_node.get_children():
		child.queue_free()
	
	if players.size() > _hero_spawns.size():
		printerr("Table: There are too many players for this table !")
		return
	
	for i in players.size():
		var character: Character = Shared.CHARACTERS[players[i].hero.id].instantiate()
		character.owner_player_id = players[i].id
		print(character.owner_player_id, "   ", players[i].id)
		character.apply_cards_upgrade(players[i].deck)
		entities_node.add_child(character)
		character.global_position = _hero_spawns[i].global_position
		character.global_rotation = _hero_spawns[i].global_rotation
		_coin_piles[i].connect_to_player(players[i])
