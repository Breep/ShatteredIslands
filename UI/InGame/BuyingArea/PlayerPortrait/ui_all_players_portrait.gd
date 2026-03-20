class_name UIAllPlayersPortrait
extends Control

# ============================== Local export ==============================

@export var _players_portraits: Array[UIPlayerPortrait]

# ============================== Private variables ==============================

var _player_id_player_portrait_map: Dictionary[int, UIPlayerPortrait] # Key=<player id>, Value=<UIPlayerPortrait>

# ============================== Local nodes ==============================

@onready var vbox_container: HexGridContainer = %VBoxContainer

# ============================== Node base functions ==============================

func _ready() -> void:
	_connect_all_players(PlayerManager.players.values())

# ============================== Public functions ==============================

# ============================== Private functions ==============================

func _connect_all_players(players: Array[Player]) -> void:
	if _players_portraits.size() < players.size():
		printerr("UIAllPlayersPortrait: Too many players")
		return
	
	for i in _players_portraits.size():
		_players_portraits[i].hide()
	
	for i in players.size():
		_players_portraits[i].show()
		_players_portraits[i].connect_to_player(players[i])
		players[i].health_changed.connect(_on_player_health_changed)
		_player_id_player_portrait_map[players[i].id] = _players_portraits[i]


func _reorder_portraits() -> void:
	var players_sorted: Array[Player] = PlayerManager.get_players_ordered()
	for i in players_sorted.size():
		var player: Player = players_sorted[i]
		_player_id_player_portrait_map[player.id].flip_ui = (i % 2 == 1)
		vbox_container.move_child(_player_id_player_portrait_map[player.id], i)


# ============================== Callbacks ==============================

func _on_player_health_changed(_player: Player, _new_health: int) -> void:
	_reorder_portraits()
