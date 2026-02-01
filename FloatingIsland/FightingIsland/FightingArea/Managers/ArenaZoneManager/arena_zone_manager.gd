class_name ArenaZoneManager
extends Node

# ============================== Signals ==============================

# ============================== Enums ==============================

enum ZoneType {
	TEAM,           # Zone for a specific team
	CENTER,         # Center of the arena
	FULL_ARENA      # Entire arena
}

# ============================== Private variables ==============================

var _team_zones: Dictionary[int, Area3D] = {}
var _center_zone: Area3D = null
var _full_arena_zone: Area3D = null

var _is_initialized: bool = false

# ============================== Public functions ==============================

## Initialize the arena zones from a FightingFloor
## team_zones: Dictionary mapping team number to Area3D zone
## center_zone: Area3D for the center zone (optional)
## full_arena_zone: Area3D for the full arena (optional)
func initialize(team_zones: Dictionary[int, Area3D], center_zone: Area3D = null, full_arena_zone: Area3D = null) -> void:
	_team_zones = team_zones
	_center_zone = center_zone
	_full_arena_zone = full_arena_zone
	_is_initialized = true
	
	Verbose.debug("ArenaZoneManager initialized with " + str(_team_zones.size()) + " team zones", Verbose.Category.FIGHTING_AREA)


## Get a random position within a team's zone
func get_random_position_for_team(team: int) -> Vector3:
	if not _is_initialized:
		printerr("ArenaZoneManager: Not initialized")
		return Vector3.ZERO
	
	if not _team_zones.has(team):
		printerr("ArenaZoneManager: No zone defined for team ", team)
		return Vector3.ZERO
	
	return _get_random_position_in_area(_team_zones[team])


## Get a random position in the center zone
func get_random_position_in_center() -> Vector3:
	if not _is_initialized:
		printerr("ArenaZoneManager: Not initialized")
		return Vector3.ZERO
	
	if _center_zone == null:
		printerr("ArenaZoneManager: No center zone defined")
		return Vector3.ZERO
	
	return _get_random_position_in_area(_center_zone)


## Get a random position in the full arena
func get_random_position_in_arena() -> Vector3:
	if not _is_initialized:
		printerr("ArenaZoneManager: Not initialized")
		return Vector3.ZERO
	
	if _full_arena_zone == null:
		printerr("ArenaZoneManager: No full arena zone defined")
		return Vector3.ZERO
	
	return _get_random_position_in_area(_full_arena_zone)


## Get the center position of a team's zone
func get_team_zone_center(team: int) -> Vector3:
	if not _is_initialized:
		printerr("ArenaZoneManager: Not initialized")
		return Vector3.ZERO
	
	if not _team_zones.has(team):
		printerr("ArenaZoneManager: No zone defined for team ", team)
		return Vector3.ZERO
	
	return _team_zones[team].global_position


## Get the center position of the center zone
func get_center_zone_center() -> Vector3:
	if not _is_initialized or _center_zone == null:
		printerr("ArenaZoneManager: Center zone not available")
		return Vector3.ZERO
	
	return _center_zone.global_position


## Apply randomization offset to a position
func apply_randomization(position: Vector3, radius: float) -> Vector3:
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


# ============================== Private functions ==============================

## Get a random position within an Area3D's collision shape
func _get_random_position_in_area(area: Area3D) -> Vector3:
	if area == null:
		printerr("ArenaZoneManager: Area is null")
		return Vector3.ZERO
	
	# Get the first CollisionShape3D child
	var collision_shape: CollisionShape3D = null
	for child in area.get_children():
		if child is CollisionShape3D:
			collision_shape = child
			break
	
	if collision_shape == null:
		printerr("ArenaZoneManager: No CollisionShape3D found in area ", area.name)
		return area.global_position
	
	var shape := collision_shape.shape
	if shape is BoxShape3D:
		return _get_random_position_in_box(area.global_position, collision_shape.global_position, shape)
	else:
		# Fallback to area center for unsupported shapes
		Verbose.warn("ArenaZoneManager: Unsupported shape type, using area center", Verbose.Category.FIGHTING_AREA)
		return area.global_position


## Get a random position within a BoxShape3D
func _get_random_position_in_box(area_position: Vector3, shape_position: Vector3, box_shape: BoxShape3D) -> Vector3:
	var size := box_shape.size
	var half_size := size / 2.0
	
	var random_x := randf_range(-half_size.x, half_size.x)
	var random_y := 0.0  # Keep at ground level
	var random_z := randf_range(-half_size.z, half_size.z)
	
	# Position relative to the collision shape, then convert to global
	return shape_position + Vector3(random_x, random_y, random_z)
