class_name UIAllPlayersPortrait
extends Control

# ============================== Local export ==============================

@export var _players_portraits: Array[UIPlayerPortrait]

# ============================== Private variables ==============================

var _player_id_player_portrait_map: Dictionary[int, UIPlayerPortrait] # Key=<player id>, Value=<UIPlayerPortrait>

# ============================== Local nodes ==============================

@onready var vbox_container: VBoxContainer = %VBoxContainer

# ============================== Public functions ==============================

func connect_all_players(players: Array[Player]) -> void:
	if _players_portraits.size() != players.size():
		printerr("UIAllPlayersPortrait: Players number and players portrait number mismatch")
		return
	
	for i in _players_portraits.size():
		_players_portraits[i].connect_to_player(players[i])
		players[i].health_changed.connect(_on_player_health_changed)
		_player_id_player_portrait_map[players[i].id] = _players_portraits[i]

# ============================== Private functions ==============================

func _reorder_portraits() -> void:
	var players_sorted: Array[Player] = _get_players_ordered_by_health()
	for i in players_sorted.size():
		var player: Player = players_sorted[i]
		vbox_container.move_child(_player_id_player_portrait_map[player.id], i)


func _get_players_ordered_by_health() -> Array[Player]:
	var array_sorted: Array[Player] = PlayerManager.players.values().duplicate()
	array_sorted.sort_custom(_compare_player_health)
	return array_sorted


func _compare_player_health(player1: Player, player2: Player) -> bool:
	return player2.health < player1.health

# ============================== Callbacks ==============================

func _on_player_health_changed(_new_health: int) -> void:
	_reorder_portraits()
