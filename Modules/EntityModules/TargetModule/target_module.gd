class_name TargetModule
extends Module

# ============================== Enums ==============================
#TODO : Attacker ( Celui qui a attaqué, par exemple pour le dodge)
#HERO / ENTITIES
enum TargettingStrategy {
	
	# ------- CLOSEST -------
	CLOSEST, # Closest entity except self (can be null)
	CLOSEST_ENEMY, # Closest enemy (can be null)
	CLOSEST_ALLY, # Closest ally except self (can be null)
	
	# ------- FARTHEST -------
	FARTHEST, # Farthest entity except self (can be null)
	FARTHEST_ENEMY, # Farthest enemy (can be null)
	FARTHEST_ALLY, # Farthest ally except self (can be null)
	
	# ------- LOWEST HP -------
	LOWEST_HP_ALLY_INCLUDING_SELF, # Lowest hp ally (in % of max life)
	
	# ------- HIGHEST HP -------
	
	# ------- LOWEST HP % -------
	
	# ------- HIGHEST HP % -------
	
	# ------- RANDOM -------
	RANDOM, # Random entity except self (can be null)
	RANDOM_ENEMY, # Random enemy (can be null)
	RANDOM_HERO_ENEMY, #random enemy hero, (can be null)
	RANDOM_ALLY, # Random ally except self (can be null)
	RANDOM_ALLY_INCLUDING_SELF, # Random ally
	
	# ------- MISC -------
	HIGHEST_SHIELD_ENEMIES_HERO, # highest amount of shield among heroes enemies (can be null)
	HIGHEST_SHIELD_ALLIES_HERO, # highest amount of shield among heroes allies (can be null)
	
}

enum MultipleTargettingStrategy {
	ALL,
	ALLIES,
	ENEMIES, # (can be empty)
}

# ============================== Private variables ==============================

var _entities: Array[Entity] # All entities on the fighting scene
var _enemies: Array[Entity] # All enemies of the owned entity
var _allies: Array[Entity] # All allies of the owned entity
var _heroes: Array[Entity] # All heroes
var _enemy_heroes: Array[Entity] # All heroes enemies
var _ally_heroes: Array[Entity] # All heroes allies

# ============================== Local nodes ==============================

@onready var _scanning_area: Area3D = %ScanningArea

# ============================== Node base functions ==============================

func _ready() -> void:
	if _owner == null:
		printerr("TargetModule: TargetModule need a ref to its owner")
		return

# ============================== Public functions ==============================

func start() -> void:
	_clear()
	_scanning_area.monitoring = true
	var bodies: Array[Node3D] = _scanning_area.get_overlapping_bodies()
	for body in bodies:
		_add_body_as_entity(body)


func stop() -> void:
	_scanning_area.monitoring = false


# Get target of the owned character from a given strategy
func get_target(targetting_strategy: TargettingStrategy) -> Entity:
	match targetting_strategy:
		TargettingStrategy.CLOSEST:
			return _get_closest(_entities, _owner)
		TargettingStrategy.CLOSEST_ENEMY:
			return _get_closest(_enemies, _owner)
		TargettingStrategy.CLOSEST_ALLY:
			return _get_closest(_allies, _owner)
		TargettingStrategy.FARTHEST:
			return _get_farthest(_entities, _owner)
		TargettingStrategy.FARTHEST_ENEMY:
			return _get_farthest(_enemies, null)
		TargettingStrategy.FARTHEST_ALLY:
			return _get_farthest(_allies, _owner)
		TargettingStrategy.RANDOM:
			return _get_random(_entities, _owner)
		TargettingStrategy.RANDOM_ENEMY:
			return _get_random(_enemies, null)
		TargettingStrategy.RANDOM_ALLY:
			return _get_random(_allies, _owner)
		TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF:
			return _get_random(_allies, null)
		TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF:
			return _get_lowest_hp(_allies, null)
		TargettingStrategy.RANDOM_HERO_ENEMY:
			return _get_random(_enemy_heroes, null)
		TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO:
			return _get_highest_shield(_enemy_heroes, _owner)
		TargettingStrategy.HIGHEST_SHIELD_ALLIES_HERO:
			return _get_highest_shield(_ally_heroes, null)
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
	
	
func get_targets(strategy: MultipleTargettingStrategy, radius:float = -1.0) -> Array[Entity]:
	if radius <= 0:
		match strategy:
			MultipleTargettingStrategy.ALL: return _entities.duplicate()
			MultipleTargettingStrategy.ALLIES: return _allies.duplicate()
			MultipleTargettingStrategy.ENEMIES: return _enemies.duplicate()
	else:
		var returned_entities: Array[Entity]
		match strategy:
			MultipleTargettingStrategy.ALL:
				for entity in _entities:
					if entity == null: continue
					if entity.global_position.distance_to(_owner.global_position) <= radius:
						returned_entities.append(entity)
			MultipleTargettingStrategy.ALLIES:
				for entity in _allies:
					if entity == null: continue
					if entity.global_position.distance_to(_owner.global_position) <= radius:
						returned_entities.append(entity)
			MultipleTargettingStrategy.ENEMIES:
				for entity in _enemies:
					if entity == null: continue
					if entity.global_position.distance_to(_owner.global_position) <= radius:
						returned_entities.append(entity)
		return returned_entities
	
	printerr("TargetModule: Unknown strategy")
	var empty: Array[Entity]
	return empty

# ============================== Private functions ==============================
func _get_highest_shield(entities: Array[Entity], excluded_character: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_character)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	var highest_shield_entity = entities_copy[0]
	for entity in entities_copy:
		if entity != _owner:
			if entity.stats.armor_stacks > highest_shield_entity.stats.armor_stacks :
				highest_shield_entity = entity
	
	return highest_shield_entity


func _get_alive_entities(entities: Array[Entity]) -> Array[Entity]:
	var alive_entities: Array[Entity]
	for entity in entities:
		if not entity.is_dead:
			alive_entities.append(entity)
	return alive_entities


func _add_body_as_entity(body: Node3D) -> void:
	if not body is Entity:
		printerr("TargetModule: A body detected by a TargetModule has an Entity mask but is not an entity: [", body.get_path(), "]")
		return
		
	var entity: Entity = body
	if entity.team == _owner.team: _allies.append(entity)
	else: _enemies.append(entity)
	_entities.append(entity)
	if entity is Character: 
		if entity.team == _owner.team: _ally_heroes.append(entity)
		else: _enemy_heroes.append(entity)
		_heroes.append(entity)


func _clear() -> void:
	_enemies.clear()
	_allies.clear()
	_entities.clear()
	_heroes.clear()
	_enemy_heroes.clear()
	_heroes.clear()

# ============================== Target strategy functions ==============================

func _get_closest(entities: Array[Entity], excluded_character: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_character)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	var closest_character = entities_copy[0]
	for character in entities_copy:
		if character != _owner:
			if (character.position - _owner.position).length_squared() < (closest_character.position - _owner.position).length_squared():
				closest_character = character
	
	return closest_character


func _get_farthest(entities: Array[Entity], excluded_character: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_character)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	var farthest_character = entities_copy[0]
	for character in entities_copy:
		if character != _owner:
			if (character.global_position - _owner.global_position).length_squared() > (farthest_character.global_position - _owner.global_position).length_squared():
				farthest_character = character
	
	return farthest_character


func _get_random(entities: Array[Entity], excluded_character: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_character)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	return entities_copy[rng.randi_range(0, entities_copy.size()-1)]


# TODO améliorer cette fonction pour ne pas pouvoir heal une target untargetable autre que nous
func _get_lowest_hp(entities: Array[Entity], excluded_character: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_character)
	if entities_copy.is_empty():
		return null
	
	var lowest_hp_character = entities_copy[0]
	for character in entities:
		var character_hp_percent: float = ((character.stats.health as float) / (character.stats.health_max as float)) * 100.0
		var lowest_hp_character_hp_percent: float = ((lowest_hp_character.stats.health as float) / (lowest_hp_character.stats.health_max as float)) * 100.0
		if character_hp_percent < lowest_hp_character_hp_percent:
			lowest_hp_character = character
	
	return lowest_hp_character


func _get_array_without_untargetable_targets(entities: Array[Entity]) -> Array[Entity]:
	var entities_copy: Array[Entity] = entities.duplicate()
	# TODO Here it was for shadow untargetable. Maybe some heroes will have untargetable ultimate
	return entities_copy

# ============================== Callback ==============================
func _on_scanning_area_body_entered(body: Node3D) -> void:
	_add_body_as_entity(body)


func _on_scanning_area_body_exited(body: Node3D) -> void:
	if not body is Entity:
		printerr("TargetModule: A body detected by a TargetModule has a Entity mask but is not an entity: [", body.get_path(), "]")
		return
	
	var entity: Entity = body
	if entity.team == _owner.team and _allies.has(entity): _allies.erase(entity)
	elif entity.team == _owner.team and _enemies.has(entity): _enemies.append(entity)
	if _entities.has(entity):  _enemies.erase(entity)
