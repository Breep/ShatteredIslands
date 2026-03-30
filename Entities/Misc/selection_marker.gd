extends Node3D

@onready var _marker_mesh: MeshInstance3D = %Marker

var _material: ShaderMaterial
var _glow_tween: Tween = null


func _ready() -> void:
	(_marker_mesh.mesh as PlaneMesh).material = (_marker_mesh.mesh as PlaneMesh).material.duplicate(true)
	_material = _marker_mesh.mesh.material as ShaderMaterial


func _apply_params(params: Dictionary) -> void:
	for key in params:
		_material.set_shader_parameter(key, params[key])


func show_hover() -> void:
	_kill_tween()
	_apply_params({
		"color": Color(0.558, 0.762, 0.842, 1.0),
		"speed": 3.0,
		"glow": 2.0,
		"glow_min": 2.0,
		"glow_max": 2.0,
		"fill": 0.0,
	})


func show_selected() -> void:
	_kill_tween()
	_apply_params({
		"color": Color(0.0, 0.8, 1.0),
		"speed": 4.0,
		"glow": 4.0,
		"glow_min": 2.0,
		"glow_max": 8.0,
		"fill": 0.0,
	})


func play_click(callback: Callable = Callable()) -> void:
	_kill_tween()
	_apply_params({
		"color": Color(0.0, 0.5, 1.0),
		"speed": 3.0,
		"glow": 4.0,
		"glow_min": 4.0,
		"glow_max": 4.0,
		"fill": 1.0,
	})
	_glow_tween = create_tween()
	_glow_tween.tween_method(_set_glow, 4.0, 2.0, 0.3)
	_glow_tween.tween_method(_set_fill, 1.0, 0.0, 0.3)
	if callback.is_valid():
		_glow_tween.tween_callback(callback)


func _set_glow(value: float) -> void:
	_material.set_shader_parameter("glow", value)
	_material.set_shader_parameter("glow_min", value)
	_material.set_shader_parameter("glow_max", value)


func _set_fill(value: float) -> void:
	_material.set_shader_parameter("fill", value)


func _kill_tween() -> void:
	if _glow_tween != null:
		_glow_tween.kill()
		_glow_tween = null
