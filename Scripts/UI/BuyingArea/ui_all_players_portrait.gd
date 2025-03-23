class_name UIAllPlayersPortrait
extends Control

# ============================== Private variables ==============================

@export var _players_portraits: Array[UIPlayerPortrait]

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public functions ==============================

func connect_all_players(players: Array[Player]) -> void:
	if _players_portraits.size() != players.size():
		printerr("UIAllPlayersPortrait: Players number and players portrait number mismatch")
		return
	
	for i in _players_portraits.size():
		_players_portraits[i].connect_to_player(players[i])
