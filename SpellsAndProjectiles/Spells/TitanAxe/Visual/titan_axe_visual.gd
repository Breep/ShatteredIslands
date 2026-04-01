extends Node3D

const HIT_VFX = preload("res://VFX/VFX_3D/VFX/Scenes/VFX_Hit_dark.tscn")

const START_HEIGHT: float = 2.0
const DEPLOY_TIME: float = 0.3

@onready var _axe_mesh: MeshInstance3D = $AxeMesh

var _elapsed: float = 0.0
var _is_falling: bool = false
var _start_pos: Vector3
var _end_pos: Vector3


func _ready() -> void:
	_end_pos = Vector3.ZERO
	_start_pos = Vector3(0, START_HEIGHT, 0)
	_axe_mesh.position = _start_pos
	_is_falling = true


func _process(delta: float) -> void:
	if not _is_falling:
		return

	_elapsed += delta
	var t := clampf(_elapsed / DEPLOY_TIME, 0.0, 1.0)
	var eased_t := t * t * t

	_axe_mesh.position = _start_pos.lerp(_end_pos, eased_t)

	if t >= 1.0:
		_is_falling = false
		_axe_mesh.position = _end_pos
		_on_impact()


func _on_impact() -> void:
	_axe_mesh.visible = false
	var hit := HIT_VFX.instantiate() as Node3D
	add_child(hit)
	hit.position = _end_pos

	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(queue_free)
