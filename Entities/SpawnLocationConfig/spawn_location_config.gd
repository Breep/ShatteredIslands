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

## Team number for team zone spawning (used when location_type is TEAM_ZONE)
var team: int = 0

## Target entity for relative positioning (used when location_type is ENTITY)
var target_entity: Node3D = null

## Randomization radius applied to the final position
var randomization_radius: float = 0.0

# ============================== Public functions ==============================

## Resolve the spawn location to an actual Vector3 position
## arena_zone_manager: The ArenaZoneManager to use for zone-based spawning
## owner_team: The team of the entity doing the summoning (used for TEAM_ZONE with team=-1)
## Returns: The resolved global position
func resolve(arena_zone_manager: ArenaZoneManager, owner_team: int = 0) -> Vector3:
	var base_position := Vector3.ZERO
	
	match location_type:
		LocationType.EXACT:
			base_position = exact_position
		
		LocationType.ARENA_CENTER:
			if arena_zone_manager == null:
				printerr("SpawnLocationConfig: ArenaZoneManager required for ARENA_CENTER")
				return Vector3.ZERO
			base_position = arena_zone_manager.get_center_zone_center()
		
		LocationType.TEAM_ZONE:
			if arena_zone_manager == null:
				printerr("SpawnLocationConfig: ArenaZoneManager required for TEAM_ZONE")
				return Vector3.ZERO
			# If team is -1, use owner's team
			var target_team := team if team >= 0 else owner_team
			base_position = arena_zone_manager.get_random_position_for_team(target_team)
		
		LocationType.ENTITY:
			if target_entity == null:
				printerr("SpawnLocationConfig: target_entity required for ENTITY location type")
				return Vector3.ZERO
			base_position = target_entity.global_position
		
		LocationType.RANDOM_ARENA:
			if arena_zone_manager == null:
				printerr("SpawnLocationConfig: ArenaZoneManager required for RANDOM_ARENA")
				return Vector3.ZERO
			base_position = arena_zone_manager.get_random_position_in_arena()
		
		_:
			printerr("SpawnLocationConfig: Unknown location type")
			return Vector3.ZERO
	
	# Apply randomization if specified
	if arena_zone_manager != null and randomization_radius > 0.0:
		return arena_zone_manager.apply_randomization(base_position, randomization_radius)
	
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
