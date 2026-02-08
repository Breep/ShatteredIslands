class_name SpawnLocationConfig
extends Resource

# ============================== Enums ==============================

enum LocationType {
	EXACT,           # Exact Vector3 position (global)
	ARENA_CENTER,    # Center of the arena
	TEAM_ZONE,       # Random position in a specific team's zone
	ENTITY,          # Relative to a specific entity/Node3D
	RANDOM_ARENA     # Random position anywhere in arena
}

# ============================== Export variables ==============================

## Type of spawn location
var location_type: LocationType = LocationType.EXACT

## Exact global position (used when location_type is EXACT)
var exact_position: Vector3 = Vector3.ZERO

## Team id for team zone spawning (used when location_type is TEAM_ZONE)
var team: int = 0

## Target entity for relative positioning (used when location_type is ENTITY)
var target_entity: Node3D = null

## Randomization radius applied to the final position
var randomization_radius: float = 0.0

# ============================== Public functions ==============================

## Resolve the spawn location to an actual Vector3 position
## arena_zone_manager: The ArenaZoneManager to use for zone-based spawning
## Returns: The resolved global position
func resolve(arena_zone_manager: ArenaZoneManager) -> Vector3:
	var base_position := Vector3.ZERO
	
	match location_type:
		LocationType.EXACT:
			base_position = exact_position
		
		LocationType.ARENA_CENTER:
			if arena_zone_manager == null:
				Verbose.error("ArenaZoneManager required for ARENA_CENTER", Verbose.Category.SPAWN_LOCATION_CONFIG)
				return Vector3.ZERO
			base_position = arena_zone_manager.get_center_zone_center()
		
		LocationType.TEAM_ZONE:
			if arena_zone_manager == null:
				Verbose.error("ArenaZoneManager required for TEAM_ZONE", Verbose.Category.SPAWN_LOCATION_CONFIG)
				return Vector3.ZERO
			base_position = arena_zone_manager.get_random_position_for_team(team)
		
		LocationType.ENTITY:
			if target_entity == null:
				Verbose.error("target_entity required for ENTITY location type", Verbose.Category.SPAWN_LOCATION_CONFIG)
				return Vector3.ZERO
			base_position = target_entity.global_position
		
		LocationType.RANDOM_ARENA:
			if arena_zone_manager == null:
				Verbose.error("ArenaZoneManager required for RANDOM_ARENA", Verbose.Category.SPAWN_LOCATION_CONFIG)
				return Vector3.ZERO
			base_position = arena_zone_manager.get_random_position_in_arena()
		
		_:
			Verbose.error("Unknown location type", Verbose.Category.SPAWN_LOCATION_CONFIG)
			return Vector3.ZERO
	
	# Apply randomization if specified
	if randomization_radius > 0.0:
		if arena_zone_manager != null:
			return arena_zone_manager.apply_randomization(base_position, randomization_radius)
		else:
			return _apply_randomization(base_position, randomization_radius)
	
	return base_position


## Create a simple config for exact position spawning
static func create_exact(position: Vector3, randomization: float = 0.0) -> SpawnLocationConfig:
	var config := SpawnLocationConfig.new()
	config.location_type = LocationType.EXACT
	config.exact_position = position
	config.randomization_radius = randomization
	return config


## Create a config for arena center spawning
static func create_arena_center(randomization: float = 0.0) -> SpawnLocationConfig:
	var config := SpawnLocationConfig.new()
	config.location_type = LocationType.ARENA_CENTER
	config.randomization_radius = randomization
	return config


## Create a config for team zone spawning
## team: Team number, or -1 to use the summoner's team
static func create_team_zone(team: int = -1, randomization: float = 0.0) -> SpawnLocationConfig:
	var config := SpawnLocationConfig.new()
	config.location_type = LocationType.TEAM_ZONE
	config.team = team
	config.randomization_radius = randomization
	return config


## Create a config for ally side spawning (uses summoner's team)
static func create_ally_side(randomization: float = 0.0) -> SpawnLocationConfig:
	return create_team_zone(-1, randomization)


## Create a config for enemy side spawning (specify enemy team number)
static func create_enemy_side(enemy_team: int, randomization: float = 0.0) -> SpawnLocationConfig:
	return create_team_zone(enemy_team, randomization)


## Create a config for entity-relative spawning
static func create_entity_relative(entity: Node3D, randomization: float = 0.0) -> SpawnLocationConfig:
	var config := SpawnLocationConfig.new()
	config.location_type = LocationType.ENTITY
	config.target_entity = entity
	config.randomization_radius = randomization
	return config


## Create a config for random arena spawning
static func create_random_arena(randomization: float = 0.0) -> SpawnLocationConfig:
	var config := SpawnLocationConfig.new()
	config.location_type = LocationType.RANDOM_ARENA
	config.randomization_radius = randomization
	return config

func _apply_randomization(position: Vector3, radius: float) -> Vector3:
	if radius <= 0.0:
		return position
	
	var random_angle := randf() * TAU
	var random_distance := randf() * radius
	
	var offset := Vector3(
		cos(random_angle) * random_distance,
		0.0,  # Keep Y unchanged
		sin(random_angle) * random_distance
	)
	
	return position + offset
