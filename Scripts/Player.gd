extends StaticBody2D
class_name Player

# ============================== Global scene nodes ==============================

var fightingArea: FightingArea

# ============================== TMP ==============================

@export var team: int
@export var hero: Hero

# ============================== Private ==============================

var _players: Array[Player]
var _enemies: Array[Player]
var _allies: Array[Player]

var _deck: PlayerDeck = PlayerDeck.new()

# ============================== Public ==============================

var stats: CharacterStats # Needs to be public for easier upgrades access

@export var _aa_projectile: PackedScene # tmp
@export var tmp_card1: Card

# ============================== Node base functions ==============================

func _ready() -> void:
	fightingArea = get_tree().get_root().find_child("FightingArea", true, false)
	stats = hero.baseStats
	_moveToCell(Vector2(0,0))
	_players = _getAllScenePlayers()
	_enemies = _getEnemiesFromPlayers()
	_allies = _getAlliesFromPlayers()
	
	if team == 1:# TMP
		return

	print("I'm ", hero.name)
	print("AttackDamage: ", stats.autoAttack.dammage)
	_deck.add_card(tmp_card1)
	tmp_card1.lvl = 2
	_deck.add_card(tmp_card1)
	_applyAllCardsUpgrades()
	print("AttackDamage: ", stats.autoAttack.dammage)

# ============================== Private functions ==============================

func _moveToCell(cell : Vector2):
	if team == 1: # TMP Dev
		return
	position = fightingArea.getGlobalCellPosition(cell)

func _getClosestEnemy() -> Player:
	if _enemies.is_empty():
		print("No enemies")
		return null
	var closestEnemy: Player = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - position).length_squared() < (closestEnemy.position - position).length_squared():
			closestEnemy = enemy
	return closestEnemy

func _auto_attack(target: Player):
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.speed = 100
	projectile.target = target
	projectile.global_position = $ProjectileSpawn.global_position
	projectile.global_rotation = $ProjectileSpawn.global_rotation
	get_tree().root.add_child(projectile)

func _getAllScenePlayers() -> Array[Player]:
	var ret: Array[Player]
	for node in get_tree().get_nodes_in_group("PLAYERS"):
		ret.append(node as Player)
	return ret

func _getEnemiesFromPlayers() -> Array[Player]:
	var ret: Array[Player]
	for player in _players:
		if player.team != team:
			ret.append(player)
	return ret

func _getAlliesFromPlayers() -> Array[Player]:
	var ret: Array[Player]
	for player in _players:
		if player.team != team:
			ret.append(player)
	return ret

func _applyAllCardsUpgrades() -> void:
	for card in _deck.cardPile:
		card.playerUpgrade.apply(self, card.lvl)

# ============================== Timer Callback ==============================

func _on_auto_attack_timer_timeout() -> void:
	_auto_attack(_getClosestEnemy())

func _on_moving_timer_timeout() -> void:
	if team == 1:# TMP
		return
	
	if fightingArea.isSelectionActive:
		_moveToCell(fightingArea.selectionCell)
