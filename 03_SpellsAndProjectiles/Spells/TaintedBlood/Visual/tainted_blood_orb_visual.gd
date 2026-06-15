class_name TaintedBloodOrbVisual
extends Node3D

## A single poison orb (green) gently orbiting a hero.
## Call launch_projectile() to fire a visual projectile from the orb toward a target.

const ORB_SHADER_CODE: String = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform vec3 core_color : source_color = vec3(0.0, 1.0, 0.3);
uniform vec3 glow_color : source_color = vec3(0.0, 0.8, 0.2);
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float glow_strength : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_intensity;
	ALBEDO = mix(core_color, glow_color, fresnel) * pulse;
	EMISSION = glow_color * fresnel * glow_strength * pulse;
	ALPHA = clamp(0.6 + fresnel * 0.4, 0.0, 1.0);
}
"""

const PROJECTILE_SHADER_CODE: String = """
shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec3 color : source_color = vec3(0.0, 1.0, 0.3);
uniform float glow : hint_range(0.0, 8.0) = 3.0;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 1.5);
	ALBEDO = color * glow;
	EMISSION = color * glow * (0.5 + fresnel);
	ALPHA = clamp(0.8 + fresnel * 0.2, 0.0, 1.0);
}
"""

# Orbit settings — slow and smooth
const ORBIT_RADIUS: float = 1.5
const ORBIT_SPEED: float = 0.8 # rad/s
const ORB_SCALE: float = 0.18

# Height bob settings — gentle, single sine
const BOB_AMPLITUDE_POISON: float = 0.2
const BOB_FREQ_POISON: float = 0.5
const BOB_PHASE_POISON: float = 0.0
const BOB_BASE_POISON: float = 1.6

# Projectile
const PROJECTILE_TRAVEL_TIME: float = 0.35
const PROJECTILE_SCALE: float = 0.12

# Colors
const POISON_CORE := Color(0.15, 0.85, 0.2)
const POISON_GLOW := Color(0.0, 1.0, 0.3)

var _hero: Node3D
var _angle: float = 0.0
var _time: float = 0.0
var _poison_orb: MeshInstance3D
var _orb_shader: Shader
var _proj_shader: Shader


func setup(hero: Node3D) -> void:
	_hero = hero


func _ready() -> void:
	_orb_shader = Shader.new()
	_orb_shader.code = ORB_SHADER_CODE

	_proj_shader = Shader.new()
	_proj_shader.code = PROJECTILE_SHADER_CODE

	_poison_orb = _create_orb(POISON_CORE, POISON_GLOW, 2.5)
	add_child(_poison_orb)

	# Random start angle for variety
	_angle = randf() * TAU


func _process(delta: float) -> void:
	if not is_instance_valid(_hero):
		queue_free()
		return

	_time += delta
	_angle += ORBIT_SPEED * delta
	if _angle > TAU:
		_angle -= TAU

	var center := _hero.global_position

	var poison_x := center.x + cos(_angle) * ORBIT_RADIUS
	var poison_z := center.z + sin(_angle) * ORBIT_RADIUS
	var poison_y := BOB_BASE_POISON + sin(_time * BOB_FREQ_POISON * TAU + BOB_PHASE_POISON) * BOB_AMPLITUDE_POISON
	_poison_orb.global_position = Vector3(poison_x, poison_y, poison_z)


func launch_projectile(target: Node3D) -> void:
	if not is_instance_valid(target):
		return

	var projectile := _create_projectile(POISON_GLOW)
	get_tree().root.add_child(projectile)
	projectile.global_position = _poison_orb.global_position

	var target_pos := target.global_position + Vector3(0, 1.0, 0)

	var tween := create_tween()
	# Gentle arc: rise slightly then ease down to target
	var mid_pos := (projectile.global_position + target_pos) / 2.0 + Vector3(0, 0.8, 0)

	tween.tween_property(projectile, "global_position", mid_pos, PROJECTILE_TRAVEL_TIME * 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(projectile, "global_position", target_pos, PROJECTILE_TRAVEL_TIME * 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(projectile.queue_free)


func _create_orb(core_color: Color, glow_color: Color, pulse_speed: float) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = ORB_SCALE
	sphere.height = ORB_SCALE * 2.0
	sphere.radial_segments = 16
	sphere.rings = 8
	mesh_instance.mesh = sphere

	var mat := ShaderMaterial.new()
	mat.shader = _orb_shader
	mat.set_shader_parameter("core_color", Vector3(core_color.r, core_color.g, core_color.b))
	mat.set_shader_parameter("glow_color", Vector3(glow_color.r, glow_color.g, glow_color.b))
	mat.set_shader_parameter("fresnel_power", 2.0)
	mat.set_shader_parameter("pulse_speed", pulse_speed)
	mat.set_shader_parameter("pulse_intensity", 0.3)
	mat.set_shader_parameter("glow_strength", 2.5)
	mesh_instance.material_override = mat

	# Point light for ambient glow
	var light := OmniLight3D.new()
	light.light_color = glow_color
	light.light_energy = 0.6
	light.omni_range = 1.5
	light.shadow_enabled = false
	mesh_instance.add_child(light)

	return mesh_instance


func _create_projectile(color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = PROJECTILE_SCALE
	sphere.height = PROJECTILE_SCALE * 2.0
	sphere.radial_segments = 12
	sphere.rings = 6
	mesh_instance.mesh = sphere

	var mat := ShaderMaterial.new()
	mat.shader = _proj_shader
	mat.set_shader_parameter("color", Vector3(color.r, color.g, color.b))
	mat.set_shader_parameter("glow", 4.0)
	mesh_instance.material_override = mat

	# Bright trail light
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 1.0
	light.omni_range = 1.2
	light.shadow_enabled = false
	mesh_instance.add_child(light)

	return mesh_instance
