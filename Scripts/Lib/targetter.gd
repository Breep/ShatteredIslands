extends Node

# ============================== Enums ==============================

enum TargettingStrategy {
	CLOSEST,
	FARTHEST,
	RANDOM,
}

# ============================== Private ==============================

var _characters: Array[Character] # ALL character on the fighting scene
var _enemies: Array[Character] # All enemies of the owned character
var _allies: Array[Character] # All allies of the owned character

var _source: Character # Owned character

# ============================== Public ==============================

func init(source: Character,
		characters: Array[Character],
		enemies: Array[Character],
		allies: Array[Character]) -> void:
	_source = source
	_characters = characters
	_enemies = enemies
	_allies = allies

func get_target(targetting_strategy: TargettingStrategy) -> Character:
	match targetting_strategy:
		TargettingStrategy.CLOSEST:
			return _get_closest_enemy()
		TargettingStrategy.FARTHEST:
			printerr("Targetter: Not implemented yet !")
			return null
		TargettingStrategy.RANDOM:
			printerr("Targetter: Not implemented yet !")
			return null
	
	printerr("Targetter: Undef strategy for the Targetter")
	return null


func _get_closest_enemy() -> Character:
	if _enemies.is_empty():
		return null
	
	var closest_enemy: Character = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - _source.position).length_squared() < (closest_enemy.position - _source.position).length_squared():
			closest_enemy = enemy
	
	return closest_enemy
