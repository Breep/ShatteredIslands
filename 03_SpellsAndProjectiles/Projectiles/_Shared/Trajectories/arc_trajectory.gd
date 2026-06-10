class_name ArcTrajectory
extends ProjectileTrajectory

## Arc parabolique (hauteur sinusoïdale, pic à mi-parcours).
##
## - follow_target = true  : suit la cible VIVANTE (missile guidé), l'arc se
##   recale chaque frame sur la position courante de la cible.
## - follow_target = false : vise le point figé au tir et descend jusqu'au sol.
## Si la cible disparaît en vol (mort), on retombe au sol sur sa dernière
## position connue — le projectile ne casse pas.
##
## destroy_on_ground : quand l'arc atteint le sol (mode non-guidé ou cible
## perdue), true détruit le projectile, false le laisse au sol (sa lifetime_max
## reste le filet de sécurité).

@export var arc_height: float = 2.0           # Maximum height of the arc
@export var randomize_by: float = 0.5         # ± randomness on arc height
@export var vertical_offset: float = 1.0      # Height offset from target
@export var follow_target: bool = false       # Suit la cible vivante (homing)
@export var destroy_on_ground: bool = true    # Détruit au contact du sol (non-guidé)
@export var ground_height: float = 0.0        # Y monde du sol visé en non-guidé

var _travel_time: float
var _target_snapshot: Vector3
var _height_variation: float


func _on_init() -> void:
	_target_snapshot = _target.get_collision_center()
	_travel_time = _compute_travel_time()
	_height_variation = randf_range(-randomize_by, randomize_by)


func update(logic_pos: Vector3, delta: float) -> Vector3:
	_t = min(1.0, _t + delta / _travel_time)
	var endpoint := _endpoint()

	# Interpolate along the line start -> endpoint
	var base := _start_pos.lerp(endpoint, _t)

	# Add sinusoidal height (peaks at t=0.5)
	var height := (arc_height + _height_variation) * sin(PI * _t)
	logic_pos = base + Vector3.UP * height

	# Look ahead to next position for smooth orientation
	var next_t: float = min(1.0, _t + 0.02)
	var next_base := _start_pos.lerp(endpoint, next_t)
	var next_height := (arc_height + _height_variation) * sin(PI * next_t)
	var look_point := next_base + Vector3.UP * next_height
	if _projectile and logic_pos.distance_squared_to(look_point) > 0.01:
		_projectile.look_at(look_point)

	# Fin d'arc au sol (non-guidé / cible perdue) : destruction optionnelle.
	if _t >= 1.0 and not _is_homing() and destroy_on_ground and is_instance_valid(_projectile):
		_projectile.queue_free()
	return logic_pos


func _on_retarget() -> void:
	_target_snapshot = _target.get_collision_center()
	_travel_time = _compute_travel_time()
	_height_variation = randf_range(-randomize_by, randomize_by)


# Homing actif uniquement si le flag est posé ET la cible est encore vivante.
func _is_homing() -> bool:
	return follow_target and is_instance_valid(_target)


# Point d'arrivée de l'arc. Guidé : centre de la cible (mis à jour en continu).
# Non-guidé / cible perdue : le sol sous la dernière position connue.
func _endpoint() -> Vector3:
	if _is_homing():
		_target_snapshot = _target.get_collision_center()
		return _target_snapshot
	return Vector3(_target_snapshot.x, ground_height, _target_snapshot.z)


func _compute_travel_time() -> float:
	var distance := _start_pos.distance_to(_target_snapshot)
	return max(0.001, distance / max(0.001, speed))
