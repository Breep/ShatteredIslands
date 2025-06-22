class_name PoisonCloudArea
extends Area3D

# ==================================================================
# === This is the poison cloud area from the Card [Poison Cloud] ===
# ==================================================================

var _characters_inside: Array[Character] # Array of all character inside the area
var _stacks: float = 0 # Stacks applied every tick
var _source: Character # Owner of this poison cloud
var _wait_time: float # period between two ticks of the poison cloud (in seconds)
var _radius: float # Radius of the poison cloud area (in m)

@onready var _effect_timer: Timer = %EffectTimer
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape2D
@onready var tmp_debug_mesh: MeshInstance3D = $PoisonCloudVisual

func init(source: Character, stacks: float, period: float, radius: float) -> void:
	_source = source
	_stacks = stacks
	_wait_time = period
	_radius = radius


func _ready() -> void:
	if _source == null:
		printerr("PoisonCloudArea: No source character assigned to")

	(_collision_shape_3d.shape as CylinderShape3D).radius = _radius
	(tmp_debug_mesh.mesh as CylinderMesh).top_radius = _radius
	(tmp_debug_mesh.mesh as CylinderMesh).bottom_radius = _radius
	_effect_timer.wait_time = _wait_time
	_effect_timer.start()


func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		_characters_inside.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body is Character:
		_characters_inside.erase(body)


func _on_effect_timer_timeout() -> void:
	for character in _characters_inside:
		if character.team != _source.team:
			character.take_condition_stacks(_stacks, Utils.StackType.POISON, _source)
