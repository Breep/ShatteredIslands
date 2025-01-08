extends StaticBody2D
class_name PlayerFighting

# ==============================================================================

@onready var fightingArea: FightingArea = get_tree().get_root().find_child("FightingArea", true, false)

# ============================== Private ==============================

@export var team: int
@export var playerName: String

# ============================== Private ==============================

var _players: Array[PlayerFighting]
var _enemies: Array[PlayerFighting]
var _allies: Array[PlayerFighting]

# ============================== Base functions ==============================

func _ready() -> void:
	_moveToCell(Vector2(0,0))
	_players = _getAllScenePlayers()
	_enemies = _getEnemiesFromPlayers()
	_allies = _getAlliesFromPlayers()

	if team == 1: # TMP Dev
		return
	
	print("Players:")
	for player in _players:
		print(player.playerName)
	
	print("Enemies:")
	for player in _enemies:
		print(player.playerName)

func _physics_process(delta: float) -> void:
	pass

# ============================== Private functions ==============================

func _moveToCell(cell : Vector2):
	if team == 1: # TMP Dev
		return

	position = fightingArea.getGlobalCellPosition(cell)

func _findClosestEnemy():
	pass

func _auto_attack():
	pass

func _getAllScenePlayers() -> Array[PlayerFighting]:
	var ret: Array[PlayerFighting]
	for node in get_tree().get_nodes_in_group("PLAYERS"):
		ret.append(node as PlayerFighting)
	return ret

func _getEnemiesFromPlayers() -> Array[PlayerFighting]:
	var ret: Array[PlayerFighting]
	for player in _players:
		if player.team != team:
			ret.append(player)
	return ret

func _getAlliesFromPlayers() -> Array[PlayerFighting]:
	var ret: Array[PlayerFighting]
	for player in _players:
		if player.team != team:
			ret.append(player)
	return ret

# ============================== Timer Callback ==============================

func _on_auto_attack_timer_timeout() -> void:
	_findClosestEnemy()
	_auto_attack()

func _on_moving_timer_timeout() -> void:
	if fightingArea.isSelectionActive:
		_moveToCell(fightingArea.selectionCell)
