class_name ArenaZoneManager
extends Node

static var _arena_randomization_number: int = -1

# ============================== Signals ==============================

# ============================== Enums ==============================

enum ZoneType {
	TEAM,           # Zone for a specific team
	CENTER,         # Center of the arena
	FULL_ARENA      # Entire arena
}

# ============================== Private variables ==============================

@export_group("Optional")
@export var _team_zones: Dictionary[int, Area3D] = {}
@export var _center_zone: Area3D = null
@export var _full_arena_zone: Area3D = null

@export var _is_initialized: bool = false

@export var _battle_id: int = -1

# ============================== Public functions ==============================

## Initialize the arena zones from the FightingArea configuration.
## team_zones: Dictionary mapping team number to Area3D zone
## center_zone: Area3D for the center zone (optional)
## full_arena_zone: Area3D for the full arena (optional)
func init(team_zones: Dictionary[int, Area3D], battle_id: int, center_zone: Area3D = null, full_arena_zone: Area3D = null) -> void:
	_team_zones = team_zones
	_center_zone = center_zone
	_full_arena_zone = full_arena_zone
	_is_initialized = true
	_battle_id = battle_id
	
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


## Clamp a position to the full arena zone bounds.
## If the position is outside, returns the closest point inside the arena.
func clamp_to_arena(position: Vector3) -> Vector3:
	if _full_arena_zone == null:
		Verbose.warn("ArenaZoneManager: No full arena zone defined, cannot clamp", Verbose.Category.FIGHTING_AREA)
		return position

	var collision_shape: CollisionShape3D = null
	for child in _full_arena_zone.get_children():
		if child is CollisionShape3D:
			collision_shape = child
			break

	if collision_shape == null:
		Verbose.warn("ArenaZoneManager: No CollisionShape3D in full arena zone, cannot clamp", Verbose.Category.FIGHTING_AREA)
		return position

	var shape := collision_shape.shape
	if shape is BoxShape3D:
		var half_size: Vector3 = shape.size / 2.0
		var center := collision_shape.global_position
		var clamped := position
		clamped.x = clampf(position.x, center.x - half_size.x, center.x + half_size.x)
		clamped.z = clampf(position.z, center.z - half_size.z, center.z + half_size.z)
		return clamped

	Verbose.warn("ArenaZoneManager: Unsupported shape type for clamp, returning original position", Verbose.Category.FIGHTING_AREA)
	return position


## Position of a full-arena corner, pulled inward by `inset` so spawns never land on
## or past the boundary. x_sign / z_sign pick the corner (e.g. (-1, 1) and (1, -1) are
## the two opposite corners of one diagonal). Y is kept at the arena's ground level.
func get_arena_corner(x_sign: float, z_sign: float, inset: float = 0.0) -> Vector3:
	if _full_arena_zone == null:
		Verbose.warn("ArenaZoneManager: No full arena zone defined, cannot get corner", Verbose.Category.FIGHTING_AREA)
		return Vector3.ZERO

	var collision_shape: CollisionShape3D = null
	for child in _full_arena_zone.get_children():
		if child is CollisionShape3D:
			collision_shape = child
			break

	if collision_shape == null:
		Verbose.warn("ArenaZoneManager: No CollisionShape3D in full arena zone, cannot get corner", Verbose.Category.FIGHTING_AREA)
		return _full_arena_zone.global_position

	var shape := collision_shape.shape
	if shape is BoxShape3D:
		var half_size: Vector3 = shape.size / 2.0
		var center := collision_shape.global_position
		var x: float = center.x + signf(x_sign) * maxf(0.0, half_size.x - inset)
		var z: float = center.z + signf(z_sign) * maxf(0.0, half_size.z - inset)
		return Vector3(x, center.y, z)

	Verbose.warn("ArenaZoneManager: Unsupported shape type for corner, returning center", Verbose.Category.FIGHTING_AREA)
	return collision_shape.global_position


## Horizontal frame for the dragon's backline sweep. The sweep axis is fixed to world X
## (right<->left); the backline depth runs along world Z, on the enemy side (inferred from
## the team-zone Z positions). origin = enemy back-edge centre at `altitude`, pulled inward
## by `back_inset`. basis.x = world X (lateral sweep); basis.z points toward the enemy back
## wall (so +basis.z bows the arc toward the backline).
func get_enemy_back_frame(own_team: int, back_inset: float, altitude: float) -> Transform3D:
	var collision_shape: CollisionShape3D = null
	if _full_arena_zone != null:
		for child in _full_arena_zone.get_children():
			if child is CollisionShape3D:
				collision_shape = child
				break

	var center: Vector3 = collision_shape.global_position if collision_shape != null \
		else (_full_arena_zone.global_position if _full_arena_zone != null else Vector3.ZERO)

	# Which Z side belongs to the enemy.
	var enemy_sign := 1.0
	var enemy_team: int = own_team
	for t: int in _team_zones:
		if t != own_team:
			enemy_team = t
			break
	if _team_zones.has(own_team) and _team_zones.has(enemy_team):
		var dz: float = _team_zones[enemy_team].global_position.z - _team_zones[own_team].global_position.z
		if absf(dz) > 0.0001:
			enemy_sign = signf(dz)

	var back_z: float = center.z
	if collision_shape != null and collision_shape.shape is BoxShape3D:
		var half_z: float = (collision_shape.shape as BoxShape3D).size.z / 2.0
		back_z = center.z + enemy_sign * maxf(0.0, half_z - back_inset)

	var anchor := Vector3(center.x, center.y + altitude, back_z)
	return Transform3D(Basis(Vector3.RIGHT, Vector3.UP, Vector3(0.0, 0.0, enemy_sign)), anchor)


## Apply randomization offset to a position
func apply_randomization(position: Vector3, radius: float) -> Vector3:
	if radius <= 0.0:
		return position
	
	_arena_randomization_number += 1
	var random_angle: float = Utils.get_randf_range(0, TAU, _battle_id, "arena_apply_randomization_" + str(_arena_randomization_number))
	_arena_randomization_number += 1
	var random_distance: float = Utils.get_randf_range(0, radius, _battle_id, "arena_apply_randomization_" + str(_arena_randomization_number))
	
	var offset: Vector3 = Vector3(
		cos(random_angle) * random_distance,
		0.0,  # Keep Y unchanged
		sin(random_angle) * random_distance
	)
	
	return position + offset


# ============================== Private functions ==============================

#TODO Handle more shapes
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
func _get_random_position_in_box(_area_position: Vector3, shape_position: Vector3, box_shape: BoxShape3D) -> Vector3:
	var size := box_shape.size
	var half_size := size / 2.0
		
	_arena_randomization_number += 1
	var random_x: float = Utils.get_randf_range(-half_size.x, half_size.x, _battle_id, "arena_pos_in_box_" + str(_arena_randomization_number))
	var random_y: float = 0.0  # Keep at ground level
	_arena_randomization_number += 1
	var random_z: float = Utils.get_randf_range(-half_size.z, half_size.z, _battle_id, "arena_pos_in_box_" + str(_arena_randomization_number))
	
	# Position relative to the collision shape, then convert to global
	return shape_position + Vector3(random_x, random_y, random_z)
