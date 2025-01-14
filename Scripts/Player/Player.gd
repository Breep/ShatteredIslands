extends StaticBody2D
class_name Player

# ============================== Local scene nodes ==============================

@onready var aaTimer: Timer = $Timers/AutoAttackTimer
@onready var playerVisual: PlayerVisual = $PlayerVisual

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

var _is_dead: bool = false

# ============================== Public ==============================

var stats: CharacterStats # Needs to be public for easier upgrades access

@export var _aa_projectile: PackedScene # tmp
@export var tmp_cards: Array[Card]

signal dead(deadPlayer)

# ============================== Node base functions ==============================

func _ready() -> void:
	fightingArea = get_tree().get_root().find_child("FightingArea", true, false)
	stats = hero.baseStats.duplicate(true) # Copy all hero base stats into a new stat resource
	_moveToCell(Vector2(0,0))
	_players = _getAllScenePlayers()
	_enemies = _getEnemiesFromPlayers()
	_allies = _getAlliesFromPlayers()
	playerVisual.updateHealthBar(stats.health, hero.baseStats.health)
	
	#connect to all dead signals
	for player in _players:
		player.dead.connect(_on_dead)
	
	if team == 1:# TMP
		return

	print("I'm ", hero.name)
	print("Player AttackDamage: ", stats.autoAttack.damage)
	print("Player AttackSpeed: ", stats.autoAttack.speed)
	print("Player CriticalChance: ", stats.autoAttack.critical_chance)
	print("Player CriticalMultiplier: ", stats.autoAttack.critical_multiplier)
	for card in tmp_cards:
		_deck.add_card(card)
	_applyAllCardsUpgrades()
	print("")
	print("AttackDamage: ", stats.autoAttack.damage)
	print("AttackSpeed: ", stats.autoAttack.speed)
	print("Player CriticalChance: ", stats.autoAttack.critical_chance)
	print("Player CriticalMultiplier: ", stats.autoAttack.critical_multiplier)

# ============================== Public functions ==============================

func hitByAutoAttack(src: Player, aaStats: AutoAttackProjectileStats):
	stats.health -= aaStats.damage
	playerVisual.updateHealthBar(stats.health, hero.baseStats.health)
	if stats.health <= 0 and !_is_dead:
		dead.emit(self)
		_is_dead = true

# ============================== Private functions ==============================

func _moveToCell(cell : Vector2):
	if _is_dead: return
	if team == 1: # TMP Dev
		return
	position = fightingArea.getGlobalCellPosition(cell)

func _getClosestEnemy() -> Player:
	if _enemies.is_empty():
		return null
	var closestEnemy: Player = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - position).length_squared() < (closestEnemy.position - position).length_squared():
			closestEnemy = enemy
	return closestEnemy

func _auto_attack(target: Player):
	if target == null: return # No enemies, nothing to do
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.setStatFromPlayerStats(stats)
	projectile.target = target
	projectile.source = self
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
	stats = hero.baseStats.duplicate(true) # Reset stats
	for card in _deck.cardPile:
		card.playerUpgrade.apply(self, card.lvl)
	aaTimer.wait_time = 1.0 / stats.autoAttack.speed

# ============================== Signals callback ==============================

func _on_auto_attack_timer_timeout() -> void:
	if _is_dead: return
	_auto_attack(_getClosestEnemy())

func _on_moving_timer_timeout() -> void:
	if _is_dead: return
	if team == 1:# TMP
		return	
	if fightingArea.isSelectionActive:
		_moveToCell(fightingArea.selectionCell)

func _on_dead(deadPlayer: Player):
	print("Oh no! ", deadPlayer.name, " is dead :(")
	_players.erase(deadPlayer)
	_enemies.erase(deadPlayer)
	_allies.erase(deadPlayer)
