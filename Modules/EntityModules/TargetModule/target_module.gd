class_name TargetModule
extends Module

# ============================== Enums ==============================
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
	
	# ------- HIGHEST HP (Absolute Value) -------
	HIGHEST_HP_ENEMY,       # Enemy with highest current HP
	HIGHEST_HP_HERO_ENEMY,  # Enemy HeroDesc with highest current HP
	
	# ------- LOWEST HP % (Percentage) -------
	LOWEST_HP_PERCENT_ENEMY, # Enemy with lowest HP percentage
	
	# ------- HIGHEST HP % (Percentage) -------
	HIGHEST_HP_PERCENT_ENEMY,      # Enemy with highest HP percentage
	HIGHEST_HP_PERCENT_HERO_ENEMY, # Enemy HeroDesc with highest HP percentage
	
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

enum TargettingFromStrategy {
	# ------- CLOSEST -------
	CLOSEST, # Closest entity except self (can be null)
	CLOSEST_ENEMY, # Closest enemy (can be null)
	CLOSEST_ALLY, # Closest ally except self (can be null)
	
	# ------- FARTHEST -------
	FARTHEST, # Farthest entity except self (can be null)
	FARTHEST_ENEMY, # Farthest enemy (can be null)
	FARTHEST_ALLY, # Farthest ally except self (can be null)
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
# --- DISTANCE ---
		TargettingStrategy.CLOSEST: return _get_closest(_entities, _owner)
		TargettingStrategy.CLOSEST_ENEMY: return _get_closest(_enemies, null)
		TargettingStrategy.CLOSEST_ALLY: return _get_closest(_allies, _owner)
		TargettingStrategy.FARTHEST: return _get_farthest(_entities, _owner)
		TargettingStrategy.FARTHEST_ENEMY: return _get_farthest(_enemies, null)
		TargettingStrategy.FARTHEST_ALLY: return _get_farthest(_allies, _owner)
		
		# --- RANDOM ---
		TargettingStrategy.RANDOM: return _get_random(_entities, _owner)
		TargettingStrategy.RANDOM_ENEMY: return _get_random(_enemies, null)
		TargettingStrategy.RANDOM_HERO_ENEMY: return _get_random(_enemy_heroes, null)
		TargettingStrategy.RANDOM_ALLY: return _get_random(_allies, _owner)
		TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF: return _get_random(_allies, null)
		
		# --- HP ---
		TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF: return _get_lowest_hp(_allies, null)
		TargettingStrategy.HIGHEST_HP_ENEMY: return _get_highest_hp(_enemies, null)
		TargettingStrategy.HIGHEST_HP_HERO_ENEMY: return _get_highest_hp(_enemy_heroes, null)
		TargettingStrategy.LOWEST_HP_PERCENT_ENEMY: return _get_lowest_hp_percent(_enemies, null)
		TargettingStrategy.HIGHEST_HP_PERCENT_ENEMY: return _get_highest_hp_percent(_enemies, null)
		TargettingStrategy.HIGHEST_HP_PERCENT_HERO_ENEMY: return _get_highest_hp_percent(_enemy_heroes, null)
		
		# --- SHIELD ---
		TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO: return _get_highest_shield(_enemy_heroes, _owner)
		TargettingStrategy.HIGHEST_SHIELD_ALLIES_HERO: return _get_highest_shield(_ally_heroes, null)
		
	push_error("TargetModule: Undef strategy for the TargetModule")
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


func get_target_from(from_pos: Vector3, targetting_from_strategy: TargettingFromStrategy, exclude_list: Array[Entity] = []) -> Entity:
	match targetting_from_strategy:
		TargettingFromStrategy.CLOSEST: return _get_closest_from(from_pos, _entities, exclude_list)
		TargettingFromStrategy.CLOSEST_ENEMY: return _get_closest_from(from_pos, _enemies, exclude_list)
		TargettingFromStrategy.CLOSEST_ALLY: return _get_closest_from(from_pos, _allies, exclude_list)
		TargettingFromStrategy.FARTHEST: return _get_farthest_from(from_pos, _entities, exclude_list)
		TargettingFromStrategy.FARTHEST_ENEMY: return _get_farthest_from(from_pos, _enemies, exclude_list)
		TargettingFromStrategy.FARTHEST_ALLY: return _get_farthest_from(from_pos, _allies, exclude_list)
	
	push_error("TargetModule: Unknown TargettingFromStrategy")
	return null


func get_targets(strategy: MultipleTargettingStrategy, radius: float = -1.0) -> Array[Entity]:
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

# Filters alive, removes excluded, removes untargetable
func _filter_candidates(entities: Array[Entity], excluded_character: Entity) -> Array[Entity]:
	if entities.is_empty():
		return []
	
	var candidates = _get_alive_entities(entities)
	if excluded_character != null:
		candidates.erase(excluded_character)
	
	if candidates.is_empty():
		return []
	
	return _get_array_without_untargetable_targets(candidates)


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
		if is_instance_valid(entity) and not entity.is_dead:
			alive_entities.append(entity)
	return alive_entities


func _add_body_as_entity(body: Node3D) -> void:
	if not body is Entity:
		push_error("TargetModule: A body detected by a TargetModule has an Entity mask but is not an entity: [", body.get_path(), "]")
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


func _get_lowest_hp(entities: Array[Entity], excluded_character: Entity) -> Entity:
	var candidates = _filter_candidates(entities, excluded_character)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	for i in range(1, candidates.size()):
		if candidates[i].stats.health < target.stats.health:
			target = candidates[i]
	return target


func _get_highest_hp(entities: Array[Entity], excluded_character: Entity) -> Entity:
	var candidates = _filter_candidates(entities, excluded_character)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	for i in range(1, candidates.size()):
		if candidates[i].stats.health > target.stats.health:
			target = candidates[i]
	return target


func _get_lowest_hp_percent(entities: Array[Entity], excluded_character: Entity) -> Entity:
	var candidates = _filter_candidates(entities, excluded_character)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	var target_ratio = float(target.stats.health) / float(target.stats.health_max)
	
	for i in range(1, candidates.size()):
		var ratio = float(candidates[i].stats.health) / float(candidates[i].stats.health_max)
		if ratio < target_ratio:
			target = candidates[i]
			target_ratio = ratio
	return target


func _get_highest_hp_percent(entities: Array[Entity], excluded_character: Entity) -> Entity:
	var candidates = _filter_candidates(entities, excluded_character)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	var target_ratio = float(target.stats.health) / float(target.stats.health_max)
	
	for i in range(1, candidates.size()):
		var ratio = float(candidates[i].stats.health) / float(candidates[i].stats.health_max)
		if ratio > target_ratio:
			target = candidates[i]
			target_ratio = ratio
	return target


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


func _get_array_without_untargetable_targets(entities: Array[Entity]) -> Array[Entity]:
	var entities_copy: Array[Entity] = entities.duplicate()
	# TODO Here it was for shadow untargetable. Maybe some heroes will have untargetable ultimate
	return entities_copy

# ============================== "Target from" strategies functions ==============================

func _get_closest_from(from_pos: Vector3, entities: Array[Entity], exclude_list: Array[Entity] = []) -> Entity:
	var candidates = _get_alive_entities(entities)
	candidates = _get_array_without_untargetable_targets(candidates)
	for excluded in exclude_list:
		candidates.erase(excluded)
	
	if candidates.is_empty():
		return null
	
	var closest: Entity = candidates[0]
	var min_dist_sq: float = from_pos.distance_squared_to(closest.global_position)
	
	for i in range(1, candidates.size()):
		var dist_sq = from_pos.distance_squared_to(candidates[i].global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest = candidates[i]
	
	return closest


func _get_farthest_from(from_pos: Vector3, entities: Array[Entity], exclude_list: Array[Entity] = []) -> Entity:
	var candidates = _get_alive_entities(entities)
	candidates = _get_array_without_untargetable_targets(candidates)
	for excluded in exclude_list:
		candidates.erase(excluded)
	
	if candidates.is_empty():
		return null
	
	var closest: Entity = candidates[0]
	var min_dist_sq: float = from_pos.distance_squared_to(closest.global_position)
	
	for i in range(1, candidates.size()):
		var dist_sq = from_pos.distance_squared_to(candidates[i].global_position)
		if dist_sq > min_dist_sq:
			min_dist_sq = dist_sq
			closest = candidates[i]
	
	return closest


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
