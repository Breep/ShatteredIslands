extends StaticBody2D
class_name Character

# ============================== Local scene nodes ==============================

@onready var aaTimer: Timer = $Timers/AutoAttackTimer
@onready var characterVisual: CharacterVisual = $CharacterVisual

# ============================== Global scene nodes ==============================

var fightingArea: FightingArea

# ============================== Public ==============================

@export var team: int
@export var hero: Hero
var playerDeck: PlayerDeck
var stats: CharacterStats # Needs to be public for easier upgrades access

var _aa_projectile = load("res://Scenes/Prefabs/projectile.tscn")

signal death(deadPlayer)

# ============================== Node base functions ==============================

func _ready() -> void:
	print("Hello I'm a character !")
	fightingArea = get_tree().get_root().find_child("FightingArea", true, false)
	stats = hero.baseStats.duplicate(true) # Copy all hero base stats into a new stat resource
	_characters = _getAllScenePlayers()
	_enemies = _getEnemiesFromPlayers()
	_allies = _getAlliesFromPlayers()
	characterVisual.updateHealthBar(stats.health, hero.baseStats.health)
	
	#connect to all death signals
	for character in _characters:
		character.death.connect(_on_death)
	
	_applyAllCardsUpgrades()

	if team == 1:# TMP
		return

# ============================== Public functions ==============================

func hitByAutoAttack(src: Character, aaStats: AutoAttackProjectileStats):
	stats.health -= aaStats.damage
	characterVisual.updateHealthBar(stats.health, hero.baseStats.health)
	if stats.health <= 0 and !_is_dead:
		death.emit(self)
		_is_dead = true


# ============================== Private ==============================

var _characters: Array[Character]
var _enemies: Array[Character]
var _allies: Array[Character]

var _is_dead: bool = false

# ============================== Private functions ==============================

func _moveToCell(cell : Vector2):
	if _is_dead: return
	if team == 1: # TMP Dev
		return
	position = fightingArea.getGlobalCellPosition(cell)

func _getClosestEnemy() -> Character:
	if _enemies.is_empty():
		return null
	var closestEnemy: Character = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - position).length_squared() < (closestEnemy.position - position).length_squared():
			closestEnemy = enemy
	return closestEnemy

func _auto_attack(target: Character):
	if target == null: return # No enemies, nothing to do
	var projectile: Projectile = _aa_projectile.instantiate()
	projectile.setStatFromPlayerStats(stats)
	projectile.target = target
	projectile.source = self
	projectile.global_position = $ProjectileSpawn.global_position
	projectile.global_rotation = $ProjectileSpawn.global_rotation
	fightingArea.add_child(projectile)

func _getAllScenePlayers() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("PLAYERS"):
		ret.append(node as Character)
	return ret

func _getEnemiesFromPlayers() -> Array[Character]:
	var ret: Array[Character]
	for character in _characters:
		if character.team != team:
			ret.append(character)
	return ret

func _getAlliesFromPlayers() -> Array[Character]:
	var ret: Array[Character]
	for character in _characters:
		if character.team != team:
			ret.append(character)
	return ret
 
func _applyAllCardsUpgrades() -> void:
	if playerDeck == null:
		return
	stats = hero.baseStats.duplicate(true) # Reset stats
	for card in playerDeck.cardPile:
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

func _on_death(deadPlayer: Character):
	print("Oh no! ", deadPlayer.name, " is dead :(")
	_characters.erase(deadPlayer)
	_enemies.erase(deadPlayer)
	_allies.erase(deadPlayer)
