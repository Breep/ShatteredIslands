class_name TargetManager
extends Node

# ============================== Enums ==============================

enum TargettingStrategy {
	CLOSEST, # Closest character except self (can be null)
	CLOSEST_ENEMY, # Closest enemy (can be null)
	CLOSEST_ALLY, # Closest ally except self (can be null)
	FARTHEST, # Farthest character except self (can be null)
	FARTHEST_ENEMY, # Farthest enemy (can be null)
	FARTHEST_ALLY, # Farthest ally except self (can be null)
	RANDOM, # Random character except self (can be null)
	RANDOM_ENEMY, # Random enemy (can be null)
	RANDOM_ALLY, # Random ally except self (can be null)
	RANDOM_ALLY_INCLUDING_SELF, # Random ally
	LOWEST_HP_ALLY_INCLUDING_SELF, # Lowest hp ally (in % of max life)
}

enum MultipleTargettingStrategy {
	ALL,
	ALLIES,
	ENEMIES, # (can be empty)
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
			return _get_closest(_characters, _source)
		TargettingStrategy.CLOSEST_ENEMY:
			return _get_closest(_enemies, _source)
		TargettingStrategy.CLOSEST_ALLY:
			return _get_closest(_allies, _source)
		TargettingStrategy.FARTHEST:
			return _get_farthest(_characters, _source)
		TargettingStrategy.FARTHEST_ENEMY:
			return _get_farthest(_enemies, _source)
		TargettingStrategy.FARTHEST_ALLY:
			return _get_farthest(_allies, _source)
		TargettingStrategy.RANDOM:
			return _get_random(_characters, _source)
		TargettingStrategy.RANDOM_ENEMY:
			return _get_random(_enemies, _source)
		TargettingStrategy.RANDOM_ALLY:
			return _get_random(_allies, _source)
		TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF:
			return _get_random(_allies, null)
		TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF:
			return _get_lowest_hp(_allies, null)
	
	printerr("TargetManager: Undef strategy for the TargetManager")
	return null


# Get closest character of "from_character" who is an enemy of _source
func get_closest_enemy_from(from_character: Character) -> Character:
	if _enemies.is_empty():
		return null
	
	var enemies_copy: Array[Character] = _enemies.duplicate()
	enemies_copy.erase(from_character)
	if enemies_copy.is_empty():
		return null
	
	var closest_enemy = enemies_copy[0]
	for enemy in _enemies:
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


func get_targets(strategy: MultipleTargettingStrategy) -> Array[Character]:
	match strategy:
		MultipleTargettingStrategy.ALL:
			return _characters.duplicate()
		MultipleTargettingStrategy.ALLIES:
			return _allies.duplicate()
		MultipleTargettingStrategy.ENEMIES:
			return _enemies.duplicate()
	
	printerr("TargetManager: Unknown strategy")
	var empty: Array[Character]
	return empty

# ============================== Private functions ==============================

func _get_all_scene_characters() -> Array[Character]:
	var ret: Array[Character]
	for node in get_tree().get_nodes_in_group("CHARACTER"):
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


# ============================== Target strategy functions ==============================

func _get_closest(characters: Array[Character], excluded_character: Character) -> Character:
	if characters.is_empty():
		return null
	
	var characters_copy: Array[Character] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_whithout_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	var closest_character = characters_copy[0]
	for character in characters:
		if character != _source:
			if (character.position - _source.position).length_squared() < (closest_character.position - _source.position).length_squared():
				closest_character = character
	
	return closest_character


func _get_farthest(characters: Array[Character], excluded_character: Character) -> Character:
	if characters.is_empty():
		return null
	
	var characters_copy: Array[Character] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_whithout_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	var farthest_character = characters_copy[0]
	for character in characters:
		if character != _source:
			if (character.position - _source.position).length_squared() > (farthest_character.position - _source.position).length_squared():
				farthest_character = character
	
	return farthest_character


func _get_random(characters: Array[Character], excluded_character: Character) -> Character:
	if characters.is_empty():
		return null
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var characters_copy: Array[Character] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_whithout_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_whithout_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	return characters_copy[rng.randi_range(0, characters_copy.size()-1)]


# TODO améliorer cette fonction pour ne pas pouvoir heal une target untargetable autre que nous
func _get_lowest_hp(characters: Array[Character], excluded_character: Character) -> Character:
	if characters.is_empty():
		return null
	
	var characters_copy: Array[Character] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	var lowest_hp_character = characters_copy[0]
	for character in characters:
		var character_hp_percent: float = ((character.stats.health as float) / (character.stats.health_max as float)) * 100.0
		var lowest_hp_character_hp_percent: float = ((lowest_hp_character.stats.health as float) / (lowest_hp_character.stats.health_max as float)) * 100.0
		if character_hp_percent < lowest_hp_character_hp_percent:
			lowest_hp_character = character
	
	return lowest_hp_character


func _get_array_whithout_untargetable_targets(characters: Array[Character]) -> Array[Character]:
	var characters_copy: Array[Character] = characters.duplicate()
	for character in  characters_copy:
		if character.stats.shadow.untargetable:
			characters_copy.erase(character)
	return characters_copy
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
