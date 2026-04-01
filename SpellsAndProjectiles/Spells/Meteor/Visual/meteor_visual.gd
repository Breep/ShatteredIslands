extends Node3D

const HIT_VFX = preload("res://Props/DefaultBattleIsland/Arch_island/VFX/Scenes/VFX_meteor_hit.tscn")

## Angle d'approche depuis l'horizontale (70° = steep diagonal, style D4)
const APPROACH_ANGLE: float = 70.0
## Hauteur de départ du météore
const START_HEIGHT: float = 30.0
## Hauteur bonus pour le point de contrôle bezier (forme l'arc)
const ARC_HEIGHT_BONUS: float = 3.0
## Léger spread aléatoire sur la position de départ
const LATERAL_OFFSET: float = 3.0

@onready var _meteor_3d: Node3D = %VFX_FireBall

var _deploy_time: float = 0.9
var _elapsed: float = 0.0
var _is_falling: bool = false

var _p0: Vector3 # start
var _p1: Vector3 # control point
var _p2: Vector3 # impact = Vector3.ZERO


func _ready() -> void:
	_compute_trajectory()
	_meteor_3d.position = _p0
	# Orient toward first segment of the curve
	var initial_dir := (_p1 - _p0).normalized()
	if initial_dir.length_squared() > 0.001:
		_meteor_3d.look_at(_meteor_3d.global_position + initial_dir)
	_is_falling = true


func _process(delta: float) -> void:
	if not _is_falling:
		return

	_elapsed += delta
	var linear_t := clampf(_elapsed / _deploy_time, 0.0, 1.0)

	# t^4 ease-in: at t=0.5 only 6% traveled, last 20% of time = 60% of distance
	var eased_t := linear_t * linear_t * linear_t * linear_t

	# Quadratic bezier: lerp(lerp(P0,P1,t), lerp(P1,P2,t), t)
	var a := _p0.lerp(_p1, eased_t)
	var b := _p1.lerp(_p2, eased_t)
	_meteor_3d.position = a.lerp(b, eased_t)

	# Tangent = direction of travel
	var tangent := (b - a).normalized()
	if tangent.length_squared() > 0.001:
		# Fallback up vector when tangent is near-vertical to avoid gimbal lock
		var up := Vector3.FORWARD if absf(tangent.dot(Vector3.UP)) > 0.99 else Vector3.UP
		_meteor_3d.look_at(_meteor_3d.global_position + tangent, up)

	if linear_t >= 1.0:
		_is_falling = false
		_meteor_3d.position = _p2
		_on_impact()


func _compute_trajectory() -> void:
	_p2 = Vector3.ZERO

	# Random horizontal approach direction
	var dir_rad := randf() * TAU

	# Horizontal distance from approach angle
	var angle_rad := deg_to_rad(APPROACH_ANGLE)
	var horizontal_dist := START_HEIGHT / tan(angle_rad)

	_p0 = Vector3(
		cos(dir_rad) * horizontal_dist + randf_range(-LATERAL_OFFSET, LATERAL_OFFSET),
		START_HEIGHT,
		sin(dir_rad) * horizontal_dist + randf_range(-LATERAL_OFFSET, LATERAL_OFFSET)
	)

	# Control point: midway, pushed up for arc shape
	var midpoint := (_p0 + _p2) * 0.5
	_p1 = midpoint + Vector3.UP * ARC_HEIGHT_BONUS


func _on_impact() -> void:
	_meteor_3d.visible = false
	var hit = HIT_VFX.instantiate()
	add_child(hit)
	hit.position = _p2
	get_tree().create_timer(2.0).timeout.connect(hit.queue_free)
