class_name FortificationDroneBeam
extends Node3D

@onready var _mesh: MeshInstance3D = %Mesh

var _material: ShaderMaterial 

func _ready() -> void:
	_material = _mesh.get_active_material(0) as ShaderMaterial

func update_beam(from_pos: Vector3, to_pos: Vector3) -> void:
	if _mesh == null: return
	global_position = (from_pos + to_pos) / 2.0
	if not from_pos.is_equal_approx(to_pos):
		look_at(to_pos, Vector3.UP)
	var distance = from_pos.distance_to(to_pos)
	_mesh.scale.y = distance

func blink() -> void:
	if _material == null: return
	var original_intensity: float = _material.get_shader_parameter("core_intensity")
	var flash_intensity: float = original_intensity * 3.0
	var tween = create_tween()
	tween.tween_property(_material, "shader_parameter/core_intensity", flash_intensity, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_material, "shader_parameter/core_intensity", original_intensity, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
