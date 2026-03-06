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
	HIGHEST_HP_ENEMY, # Enemy with highest current HP
	HIGHEST_HP_HERO_ENEMY, # Enemy HeroDesc with highest current HP
	
	# ------- LOWEST HP % (Percentage) -------
	LOWEST_HP_PERCENT_ENEMY, # Enemy with lowest HP percentage
	
	# ------- HIGHEST HP % (Percentage) -------
	HIGHEST_HP_PERCENT_ENEMY, # Enemy with highest HP percentage
	HIGHEST_HP_PERCENT_HERO_ENEMY, # Enemy HeroDesc with highest HP percentage
	
	# ------- RANDOM -------
	RANDOM, # Random entity except self (can be null)
	RANDOM_ENEMY, # Random enemy (can be null)
	RANDOM_HERO_ENEMY, # random enemy hero, (can be null)
	RANDOM_ALLY, # Random ally except self (can be null)
	RANDOM_ALLY_INCLUDING_SELF, # Random ally
	RANDOM_HERO_ALLY, # Random Hero ally
	
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
	Verbose.debug("TargetModule: Starting", Verbose.Category.TARGET_MODULE)
	_scanning_area.monitoring = true
	var bodies: Array[Node3D] = _scanning_area.get_overlapping_bodies()
	for body in bodies:
		_add_body_as_entity(body)


func stop() -> void:
	Verbose.debug("TargetModule: Stopping", Verbose.Category.TARGET_MODULE)
	_scanning_area.monitoring = false


# Get target of the owned entity from a given strategy
func get_target(targetting_strategy: TargettingStrategy) -> Entity:
	Verbose.debug("TargetModule: Getting target from strategy: " + TargettingStrategy.keys()[targetting_strategy], Verbose.Category.ENTITY_MODULE)
	if _owner == null:
		Verbose.error("TargetModule need a ref to its owner", Verbose.Category.ENTITY_MODULE)
		return null
	
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
		TargettingStrategy.RANDOM_ENEMY: return _get_random(_enemies, null, true)
		TargettingStrategy.RANDOM_HERO_ENEMY: return _get_random(_enemy_heroes, null, true)
		TargettingStrategy.RANDOM_ALLY: return _get_random(_allies, _owner)
		TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF: return _get_random(_allies, null)
		TargettingStrategy.RANDOM_HERO_ALLY: return _get_random(_ally_heroes, null)
		
		# --- HP ---
		TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF: return _get_lowest_hp(_allies, null)
		TargettingStrategy.HIGHEST_HP_ENEMY: return _get_highest_hp(_enemies, null, true)
		TargettingStrategy.HIGHEST_HP_HERO_ENEMY: return _get_highest_hp(_enemy_heroes, null, true)
		TargettingStrategy.LOWEST_HP_PERCENT_ENEMY: return _get_lowest_hp_percent(_enemies, null, true)
		TargettingStrategy.HIGHEST_HP_PERCENT_ENEMY: return _get_highest_hp_percent(_enemies, null, true)
		TargettingStrategy.HIGHEST_HP_PERCENT_HERO_ENEMY: return _get_highest_hp_percent(_enemy_heroes, null, true)
		
		# --- SHIELD ---
		TargettingStrategy.HIGHEST_SHIELD_ENEMIES_HERO: return _get_highest_shield(_enemy_heroes, _owner, true)
		TargettingStrategy.HIGHEST_SHIELD_ALLIES_HERO: return _get_highest_shield(_ally_heroes, null)
		
	push_error("TargetModule: Undef strategy for the TargetModule")
	return null


# Get closest entity of "from_entity" who is an enemy of source
func get_closest_enemy_from(from_entity: Entity) -> Entity:
	if _enemies.is_empty():
		return null
	
	var enemies_copy: Array[Entity] = _enemies.duplicate()
	enemies_copy.erase(from_entity)
	if enemies_copy.is_empty():
		return null
	
	var closest_enemy = enemies_copy[0]
	for enemy in enemies_copy:
		var enemy_distance = (enemy.global_position - from_entity.global_position).length_squared()
		var closest_enemy_distance = (closest_enemy.global_position - from_entity.global_position).length_squared()
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


## Check if entity is within attack range
func is_in_attack_range(entity: Entity) -> bool:
	# -1 means unlimited range
	if _owner.stats.attack_range < 0:
		return true
	return entity.global_position.distance_squared_to(_owner.global_position) <= _owner.stats.attack_range * _owner.stats.attack_range


# ============================== Private functions ==============================

# Filters alive, removes excluded, removes untargetable, prioritizes taunted
func _filter_candidates(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Array[Entity]:
	if entities.is_empty():
		return []
	
	var candidates = _get_alive_entities(entities)
	if excluded_entity != null:
		candidates.erase(excluded_entity)
	
	if candidates.is_empty():
		return []
	
	candidates = _get_array_without_untargetable_targets(candidates)
	
	# Prioritize taunted targets if requested (for enemy targeting)
	if prioritize_taunted:
		var taunted := _get_taunted_targets(candidates)
		if not taunted.is_empty():
			return taunted
	
	return candidates


func _get_highest_shield(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Entity:
	var candidates := _filter_candidates(entities, excluded_entity, prioritize_taunted)
	if candidates.is_empty():
		return null
	
	var highest_shield_entity = candidates[0]
	for entity in candidates:
		if entity != _owner:
			if entity.conditions.shield_stacks > highest_shield_entity.conditions.shield_stacks:
				highest_shield_entity = entity
	
	return highest_shield_entity


func _get_alive_entities(entities: Array[Entity]) -> Array[Entity]:
	var alive_entities: Array[Entity]
	for entity in entities:
		if is_instance_valid(entity) and not entity.is_dead():
			alive_entities.append(entity)
	return alive_entities


func _add_body_as_entity(body: Node3D) -> void:
	if not body is Entity:
		Verbose.error("A body detected by a TargetModule has an Entity mask but is not an entity: " + str(body.get_path()), Verbose.Category.TARGET_MODULE)
		return
	
	var entity: Entity = body
	Verbose.trace("Adding entity: " + entity.name, Verbose.Category.TARGET_MODULE)
	if entity.team == _owner.team: _allies.append(entity)
	else: _enemies.append(entity)
	_entities.append(entity)
	if entity is Hero:
		if entity.team == _owner.team: _ally_heroes.append(entity)
		else: _enemy_heroes.append(entity)
		_heroes.append(entity)
	_sort_all_lists()


func _clear() -> void:
	_enemies.clear()
	_allies.clear()
	_entities.clear()
	_heroes.clear()
	_enemy_heroes.clear()
	_ally_heroes.clear()


func _sort_all_lists() -> void:
	var sort_by_uid := func(a: Entity, b: Entity) -> bool: return a.uid < b.uid
	_entities.sort_custom(sort_by_uid)
	_enemies.sort_custom(sort_by_uid)
	_allies.sort_custom(sort_by_uid)
	_heroes.sort_custom(sort_by_uid)
	_enemy_heroes.sort_custom(sort_by_uid)
	_ally_heroes.sort_custom(sort_by_uid)

# ============================== Target strategy functions ==============================

func _get_closest(entities: Array[Entity], excluded_entity: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_entity)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	# Prioritize taunted targets for enemy targeting
	var taunted := _get_taunted_targets(entities_copy)
	if not taunted.is_empty():
		entities_copy = taunted
	
	var closest_entity = entities_copy[0]
	for entity in entities_copy:
		if entity != _owner:
			if (entity.position - _owner.position).length_squared() < (closest_entity.position - _owner.position).length_squared():
				closest_entity = entity
	
	return closest_entity


func _get_farthest(entities: Array[Entity], excluded_entity: Entity) -> Entity:
	if entities.is_empty():
		return null
	
	var entities_copy: Array[Entity] = _get_alive_entities(entities).duplicate()
	entities_copy.erase(excluded_entity)
	if entities_copy.is_empty():
		return null
	
	entities_copy = _get_array_without_untargetable_targets(entities_copy)
	if entities_copy.is_empty():
		return null
	
	var farthest_entity = entities_copy[0]
	for entity in entities_copy:
		if entity != _owner:
			if (entity.global_position - _owner.global_position).length_squared() > (farthest_entity.global_position - _owner.global_position).length_squared():
				farthest_entity = entity
	
	return farthest_entity


func _get_lowest_hp(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Entity:
	var candidates = _filter_candidates(entities, excluded_entity, prioritize_taunted)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	for i in range(1, candidates.size()):
		if candidates[i].stats.health < target.stats.health:
			target = candidates[i]
	return target


func _get_highest_hp(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Entity:
	var candidates = _filter_candidates(entities, excluded_entity, prioritize_taunted)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	for i in range(1, candidates.size()):
		if candidates[i].stats.health > target.stats.health:
			target = candidates[i]
	return target


func _get_lowest_hp_percent(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Entity:
	var candidates = _filter_candidates(entities, excluded_entity, prioritize_taunted)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	var target_ratio = float(target.stats.health) / float(target.stats.health_max)
	
	for i in range(1, candidates.size()):
		var ratio = float(candidates[i].stats.health) / float(candidates[i].stats.health_max)
		if ratio < target_ratio:
			target = candidates[i]
			target_ratio = ratio
	return target


func _get_highest_hp_percent(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Entity:
	var candidates = _filter_candidates(entities, excluded_entity, prioritize_taunted)
	if candidates.is_empty(): return null
	
	var target = candidates[0]
	var target_ratio = float(target.stats.health) / float(target.stats.health_max)
	
	for i in range(1, candidates.size()):
		var ratio = float(candidates[i].stats.health) / float(candidates[i].stats.health_max)
		if ratio > target_ratio:
			target = candidates[i]
			target_ratio = ratio
	return target


static var _random_target_number: int = -1
func _get_random(entities: Array[Entity], excluded_entity: Entity, prioritize_taunted: bool = false) -> Entity:
	var candidates := _filter_candidates(entities, excluded_entity, prioritize_taunted)
	if candidates.is_empty():
		return null
	
	_random_target_number += 1
	return Utils.pick_random(candidates, _owner.battle_id, "random_target_" + str(_random_target_number))


func _get_array_without_untargetable_targets(entities: Array[Entity]) -> Array[Entity]:
	var targetable_entities: Array[Entity] = []
	for entity in entities:
		if entity.is_targetable:
			targetable_entities.append(entity)
	return targetable_entities


func _get_taunted_targets(entities: Array[Entity]) -> Array[Entity]:
	var taunted: Array[Entity] = []
	for entity in entities:
		if entity.status_module != null and entity.status_module.has_status(Status.Type.TAUNT):
			taunted.append(entity)
	return taunted

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
	if _allies.has(entity): _allies.erase(entity)
	if _enemies.has(entity): _enemies.erase(entity)
	if _entities.has(entity): _entities.erase(entity)
	if _heroes.has(entity): _heroes.erase(entity)
	if _enemy_heroes.has(entity): _enemy_heroes.erase(entity)
	if _ally_heroes.has(entity): _ally_heroes.erase(entity)
