class_name Table
extends Node3D

# ============================== Export ==============================

#@export var _card_fans: Array[CardFan]
@export var _coin_piles: Array[CoinPile]
@export var _hero_spawns: Array[Node3D]

@export var battle_type: Battle.BattleType
@export var battle_id: int

# ============================== Node base functions ==============================

func _ready() -> void:
	if _hero_spawns.size() != _coin_piles.size(): # or _card_fans.size() != _hero_spawns.size():
		printerr("Table: There are not the same amount of CoinPile/HereSpawn")
		return

# ============================== Public functions ==============================

func connect_to_players(players: Array[Player]) -> void:
	if players.size() > _hero_spawns.size():
		printerr("Table: There are too many players for this table !")
		return
	
	for i in players.size():
		#_card_fans[i].connect_to_player(players[i])
		_coin_piles[i].connect_to_player(players[i])
