class_name SpellChainLightningVisual
extends Node3D

@onready var _mesh: MeshInstance3D = %LightningBeam

func _ready() -> void:
	if _mesh:
		_mesh.visible = false

func fire(from_pos: Vector3, to_pos: Vector3, duration: float = 0.5) -> void:
	if _mesh == null:
		return
	_mesh.visible = true
	global_position = (from_pos + to_pos) / 2.0
	if not from_pos.is_equal_approx(to_pos):
		look_at(to_pos, Vector3.UP)
	_mesh.rotation_degrees.x = -90 
	var distance = from_pos.distance_to(to_pos)
	_mesh.scale.y = distance 
	_mesh.scale.x = 0.5 
	_mesh.scale.z = 0.5
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_mesh, "scale:x", 0.0, duration)
	tween.parallel().tween_property(_mesh, "scale:z", 0.0, duration) # Z car couché
	tween.parallel().tween_property(_mesh, "transparency", 1.0, duration)
	tween.finished.connect(queue_free)
