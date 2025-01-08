extends StaticBody2D
class_name PlayerFighting

# ============================== Global scene nodes ==============================

@onready var fightingArea: FightingArea = get_tree().get_root().find_child("FightingArea", true, false)

# ============================== TMP ==============================

@export var team: int
@export var playerName: String

# ============================== Private ==============================

var _players: Array[PlayerFighting]
var _enemies: Array[PlayerFighting]
var _allies: Array[PlayerFighting]

var _cards: CardPile

@export var _aa_projectile: PackedScene

# ============================== Node base functions ==============================

func _ready() -> void:
	_moveToCell(Vector2(0,0))
	_players = _getAllScenePlayers()
	_enemies = _getEnemiesFromPlayers()
	_allies = _getAlliesFromPlayers()

func _physics_process(delta: float) -> void:
	pass

# ============================== Private functions ==============================

func _moveToCell(cell : Vector2):
	if team == 1: # TMP Dev
		return
	position = fightingArea.getGlobalCellPosition(cell)

func _getClosestEnemy() -> PlayerFighting:
	if _enemies.is_empty():
		print("No enemies")
		return null
	var closestEnemy: PlayerFighting = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - position).length_squared() < (closestEnemy.position - position).length_squared():
			closestEnemy = enemy
	return closestEnemy

func _auto_attack(target: PlayerFighting):
	print(playerName, " is attacking ", target.playerName)
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.speed = 100
	projectile.target = target
	projectile.global_position = $ProjectileSpawn.global_position
	projectile.global_rotation = $ProjectileSpawn.global_rotation
	get_tree().root.add_child(projectile)

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
	_auto_attack(_getClosestEnemy())

func _on_moving_timer_timeout() -> void:
	if team == 1:# TMP
		return
	
	if fightingArea.isSelectionActive:
		_moveToCell(fightingArea.selectionCell)
