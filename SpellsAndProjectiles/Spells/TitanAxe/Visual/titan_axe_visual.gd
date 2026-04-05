extends Node3D

const HIT_VFX = preload("res://VFX/VFX_3D/VFX/Scenes/VFX_Hit_dark.tscn")

const START_HEIGHT: float = 12.0
const DEPLOY_TIME: float = 0.7

@onready var _axe_mesh: Node3D = $titan_axe

var _elapsed: float = 0.0
var _is_falling: bool = false
var _start_pos: Vector3
var _end_pos: Vector3

var _initial_basis: Basis
var _spin_axis: Vector3


func _ready() -> void:
	_end_pos = Vector3.ZERO
	_start_pos = Vector3(0, START_HEIGHT, 0)
	_axe_mesh.position = _start_pos

	# Sauvegarder la rotation de base du mesh
	_initial_basis = _axe_mesh.basis

	# Rotation sur l'axe Z (la transform du mesh remap les axes)
	_spin_axis = Vector3.FORWARD

	# Commencer à l'envers (rotation de PI = 180°)
	_axe_mesh.basis = _initial_basis * Basis(_spin_axis, PI)

	_is_falling = true


func _process(delta: float) -> void:
	if not _is_falling:
		return

	var camera = get_viewport().get_camera_3d()
	if camera != null:
		look_at_target_y_only(camera.global_position)

	_elapsed += delta
	var t := clampf(_elapsed / DEPLOY_TIME, 0.0, 1.0)

	# Easing cubique pour la chute (accélère en tombant)
	var eased_t := t * t * t

	# Position : chute de haut en bas
	_axe_mesh.position = _start_pos.lerp(_end_pos, eased_t)

	# Rotation : demi-tour de PI à 0 (à l'envers → lame en bas)
	# Accélère avec la chute
	var spin_t := t * t
	var current_angle := PI * (1.0 - spin_t)
	_axe_mesh.basis = _initial_basis * Basis(_spin_axis, current_angle)

	if t >= 1.0:
		_is_falling = false
		_axe_mesh.position = _end_pos
		_axe_mesh.basis = _initial_basis
		_on_impact()

func look_at_target_y_only(target_position: Vector3):
	var direction = target_position - global_position
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)
		
func _on_impact() -> void:
	# Spawn du VFX d'impact
	var hit := HIT_VFX.instantiate() as Node3D
	add_child(hit)
	hit.position = _end_pos

	var tween := create_tween()
	tween.tween_interval(0.0)
	tween.tween_callback(queue_free)
