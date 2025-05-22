class_name TargetModule
extends Module

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

var _entities: Array[Entity] # All character on the fighting scene
var _enemies: Array[Entity] # All enemies of the owned character
var _allies: Array[Entity] # All allies of the owned character

# ============================== Node base functions ==============================

func _ready() -> void:
	if source == null:
		printerr("TargetModule: TargetModule need a ref to its owner")
		return

# ============================== Public functions ==============================

func connect_to_entity_manager(entity_manager: EntityManager) -> void:
	if entity_manager == null:
		printerr("TargetModule: entity_manager is null")
		return
	
	_entities = entity_manager.entities.values()
	entity_manager.entity_spawned.connect(_on_entity_manager_entity_spawned)
	entity_manager.entity_dead.connect(_on_entity_manager_entity_dead)
	_enemies = _get_enemies_from_entities()
	_allies = _get_allies_from_entities()


# Get target of the owned character from a given strategy
func get_target(targetting_strategy: TargettingStrategy) -> Entity:
	match targetting_strategy:
		TargettingStrategy.CLOSEST:
			return _get_closest(_entities, source)
		TargettingStrategy.CLOSEST_ENEMY:
			return _get_closest(_enemies, source)
		TargettingStrategy.CLOSEST_ALLY:
			return _get_closest(_allies, source)
		TargettingStrategy.FARTHEST:
			return _get_farthest(_entities, source)
		TargettingStrategy.FARTHEST_ENEMY:
			return _get_farthest(_enemies, source)
		TargettingStrategy.FARTHEST_ALLY:
			return _get_farthest(_allies, source)
		TargettingStrategy.RANDOM:
			return _get_random(_entities, source)
		TargettingStrategy.RANDOM_ENEMY:
			return _get_random(_enemies, source)
		TargettingStrategy.RANDOM_ALLY:
			return _get_random(_allies, source)
		TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF:
			return _get_random(_allies, null)
		TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF:
			return _get_lowest_hp(_allies, null)
	
	printerr("TargetModule: Undef strategy for the TargetModule")
	return null


# Get closest character of "from_character" who is an enemy of source
func get_closest_enemy_from(from_character: Entity) -> Entity:
	if _enemies.is_empty():
		return null
	
	var enemies_copy: Array[Entity] = _enemies.duplicate()
	enemies_copy.erase(from_character)
	if enemies_copy.is_empty():
		return null
	
	var closest_enemy = enemies_copy[0]
	for enemy in enemies_copy:
		var enemy_distance = (enemy.global_position - from_character.global_position).length_squared()
		var closest_enemy_distance = (closest_enemy.global_position - from_character.global_position).length_squared()
		if enemy_distance < closest_enemy_distance:
			closest_enemy = enemy
	
	return closest_enemy


func get_targets(strategy: MultipleTargettingStrategy) -> Array[Entity]:
	match strategy:
		MultipleTargettingStrategy.ALL:
			return _entities.duplicate()
		MultipleTargettingStrategy.ALLIES:
			return _allies.duplicate()
		MultipleTargettingStrategy.ENEMIES:
			return _enemies.duplicate()
	
	printerr("TargetModule: Unknown strategy")
	var empty: Array[Entity]
	return empty

# ============================== Private functions ==============================

func _get_enemies_from_entities() -> Array[Entity]:
	var ret: Array[Entity]
	for character in _entities:
		if character.team != source.team:
			ret.append(character)
	return ret


func _get_allies_from_entities() -> Array[Entity]:
	var ret: Array[Entity]
	for character in _entities:
		if character.team == source.team:
			ret.append(character)
	return ret


func _remove_character(character_to_remove: Entity) -> void:
	_enemies.erase(character_to_remove)
	_allies.erase(character_to_remove)

# ============================== Target strategy functions ==============================

func _get_closest(characters: Array[Entity], excluded_character: Entity) -> Entity:
	if characters.is_empty():
		return null
	
	var characters_copy: Array[Entity] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_without_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	var closest_character = characters_copy[0]
	for character in characters:
		if character != source:
			if (character.position - source.position).length_squared() < (closest_character.position - source.position).length_squared():
				closest_character = character
	
	return closest_character


func _get_farthest(characters: Array[Entity], excluded_character: Entity) -> Entity:
	if characters.is_empty():
		return null
	
	var characters_copy: Array[Entity] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_without_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	var farthest_character = characters_copy[0]
	for character in characters:
		if character != source:
			if (character.global_position - source.global_position).length_squared() > (farthest_character.global_position - source.global_position).length_squared():
				farthest_character = character
	
	return farthest_character


func _get_random(characters: Array[Entity], excluded_character: Entity) -> Entity:
	if characters.is_empty():
		return null
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var characters_copy: Array[Entity] = characters.duplicate()
	characters_copy.erase(excluded_character)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_without_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	characters_copy = _get_array_without_untargetable_targets(characters_copy)
	if characters_copy.is_empty():
		return null
	
	return characters_copy[rng.randi_range(0, characters_copy.size()-1)]


# TODO améliorer cette fonction pour ne pas pouvoir heal une target untargetable autre que nous
func _get_lowest_hp(characters: Array[Entity], excluded_character: Entity) -> Entity:
	if characters.is_empty():
		return null
	
	var characters_copy: Array[Entity] = characters.duplicate()
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


func _get_array_without_untargetable_targets(characters: Array[Entity]) -> Array[Entity]:
	var characters_copy: Array[Entity] = characters.duplicate()
	# TODO Here it was for shadow untargetable. Maybe some heroes will have untargetable ultimate
	return characters_copy


# ============================== Callback ==============================

func _on_entity_manager_entity_spawned(who: Entity) -> void:
	if who.team != source.team:
		_enemies.append(who)
	else:
		_allies.append(who)


func _on_entity_manager_entity_dead(who: Entity):
	_remove_character(who)


















 
