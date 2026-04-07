extends Node3D

const HIT_VFX = preload("res://VFX/VFX_3D/VFX/Scenes/VFX_Hit_dark.tscn")

const START_HEIGHT: float = 12.0
const DEPLOY_TIME: float = 0.7

const FRESNEL_SHADER_CODE: String = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D base_texture : source_color;
uniform vec3 fresnel_color : source_color = vec3(1.0, 0.5, 0.0);
uniform float fresnel_power : hint_range(0.1, 10.0) = 2.5;
uniform float fresnel_intensity : hint_range(0.0, 3.0) = 1.5;

void fragment() {
	vec4 tex = texture(base_texture, UV);
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	ALBEDO = tex.rgb + fresnel_color * fresnel * fresnel_intensity;
	EMISSION = fresnel_color * fresnel * fresnel_intensity * 0.6;
}
"""

@onready var _axe_mesh: Node3D = $colossal_titan

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

	_initial_basis = _axe_mesh.basis

	_spin_axis = Vector3.FORWARD

	_axe_mesh.basis = _initial_basis * Basis(_spin_axis, PI)

	_is_falling = true

	_apply_fresnel_shader()


func _apply_fresnel_shader() -> void:
	var mesh_instance: MeshInstance3D = _axe_mesh.get_node_or_null("axe")
	if mesh_instance == null:
		return

	var shader := Shader.new()
	shader.code = FRESNEL_SHADER_CODE

	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = shader
	shader_mat.set_shader_parameter("fresnel_color", Color(1.0, 0.45, 0.0))
	shader_mat.set_shader_parameter("fresnel_power", 2.5)
	shader_mat.set_shader_parameter("fresnel_intensity", 1.5)

	# Copy base texture from original material
	var original_mat = mesh_instance.get_active_material(0)
	if original_mat is StandardMaterial3D:
		shader_mat.set_shader_parameter("base_texture", original_mat.albedo_texture)

	mesh_instance.material_override = shader_mat


func _process(delta: float) -> void:
	if not _is_falling:
		return

	var camera = get_viewport().get_camera_3d()
	if camera != null:
		look_at_target_y_only(camera.global_position)

	_elapsed += delta
	var t := clampf(_elapsed / DEPLOY_TIME, 0.0, 1.0)

	var eased_t := t * t * t

	_axe_mesh.position = _start_pos.lerp(_end_pos, eased_t)

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
	var hit := HIT_VFX.instantiate() as Node3D
	add_child(hit)
	hit.position = _end_pos

	var tween := create_tween()
	tween.tween_interval(0.0)
	tween.tween_callback(queue_free)
