class_name TargetManager
extends Node

# ============================== Enums ==============================

enum TargettingStrategy {
	CLOSEST,
	FARTHEST,
	RANDOM,
}

# ============================== Private variables ==============================

var _characters: Array[Character] # ALL character on the fighting scene
var _enemies: Array[Character] # All enemies of the owned character
var _allies: Array[Character] # All allies of the owned character

var _source: Character # Owned character

# ============================== Public functions ==============================

func init(source: Character) -> void:
	_source = source
	_characters = _get_all_scene_characters()
	_enemies = _get_enemies_from_characters()
	_allies = _get_allies_from_characters()


# Get target of the owned character from a given strategy
func get_target(targetting_strategy: TargettingStrategy) -> Character:
	match targetting_strategy:
		TargettingStrategy.CLOSEST:
			return _get_closest_enemy()
		TargettingStrategy.FARTHEST:
			return _get_farthest_enemy()
		TargettingStrategy.RANDOM:
			return _get_random_enemy()
	
	printerr("TargetManager: Undef strategy for the TargetManager")
	return null


# Get closest enemy of the owned character from an other character
func get_closest_enemy_from(from_character: Character) -> Character:
	if _enemies.is_empty():
		return null
	
	var closest_enemy: Character
	# Find the first not "from_character" character in the enemy list
	for enemy in _enemies:
		if enemy.player.id != from_character.player.id:
			closest_enemy = enemy
			break
	
	if closest_enemy == null:
		return null
	
	# There is at least one enemy who is not "from_character", find the closest to "from_character"
	for enemy in _enemies:
		if enemy.player.id != from_character.player.id:
			var enemy_distance = (enemy.position - from_character.position).length_squared()
			var closest_enemy_distance = (closest_enemy.position - from_character.position).length_squared()
			if enemy_distance < closest_enemy_distance:
				closest_enemy = enemy
	
	return closest_enemy


# Return all characters ref. Duplicate to make sure the caller doesn't mess with the local characters array
func get_all_characters() -> Array[Character]:
	return _characters.duplicate()


func remove_character(character_to_remove: Character) -> void:
	_characters.erase(character_to_remove)
	_enemies.erase(character_to_remove)
	_allies.erase(character_to_remove)

# ============================== Private functions ==============================

func _get_all_scene_characters() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("PLAYERS"):
		ret.append(node as Character)
	return ret


func _get_enemies_from_characters() -> Array[Character]:
	var ret: Array[Character]
	for character in _characters:
		if character.team != _source.team:
			ret.append(character)
	return ret


func _get_allies_from_characters() -> Array[Character]:
	var ret: Array[Character]
	for character in _characters:
		if character.team == _source.team:
			ret.append(character)
	return ret


func _get_closest_enemy() -> Character:
	if _enemies.is_empty():
		return null
	
	var closest_enemy: Character = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - _source.position).length_squared() < (closest_enemy.position - _source.position).length_squared():
			closest_enemy = enemy
	return closest_enemy


func _get_farthest_enemy() -> Character:
	if _enemies.is_empty():
		return null
	
	var farthest_enemy: Character = _enemies[0]
	for enemy in _enemies:
		if (enemy.position - _source.position).length_squared() > (farthest_enemy.position - _source.position).length_squared():
			farthest_enemy = enemy
	return farthest_enemy


func _get_random_enemy() -> Character:
	if _enemies.is_empty():
		return null
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return _enemies[rng.randi_range(0, _enemies.size())]
