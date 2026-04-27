@tool

class_name Chain
extends Node3D

const CHAIN_LINK: PackedScene = preload("res://Tool/Chain/chain_link.tscn")
const BASE_LINK: PackedScene = preload("res://Tool/Chain/base_link.tscn")

@export_group("Configuration")
@export var _link_number: int
@export var _scale: float = 1.0

@export_subgroup("Extra Configuration")
@export_range(0.01, 16.0, 0.01) var _linear_limit_softness: float = 0.7
@export_range(0.01, 16.0, 0.01) var _linear_limit_restitution: float = 0.5
@export_range(0.01, 16.0, 0.01) var _linear_limit_damping: float = 1.0


@export_group("Generation")
var _cleanup_chain_trigger: bool
@export var cleanup_chain_trigger: bool:
	get: return _cleanup_chain_trigger
	set(value):
		if not Engine.is_editor_hint(): return
		if value == false: return
		_cleanup_chain()
		_cleanup_chain_trigger = false

var _generate_chain_trigger: bool
@export var generate_chain_trigger: bool:
	get: return _generate_chain_trigger
	set(value):
		if not Engine.is_editor_hint(): return
		if value == false: return
		_update_links()
		_generate_chain_trigger = false


var _links: Array[Node3D] = []

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Engine.time_scale = 0.5
	_cleanup_chain()
	_update_links()


func _cleanup_chain() -> void:
	print("DEBUG - cleanup chain")
	for child in get_children(false):
		if child is ChainLink or child is BaseLink or child is Joint3D:
			print("DEBUG - queue freeing ", child.name)
			child.queue_free()
			child.owner = get_tree().edited_scene_root


func _instantiate_new_hinge_join() -> Generic6DOFJoint3D:
	var j := Generic6DOFJoint3D.new()

	# Keep anchors glued together
	for axis in ["x","y","z"]:
		j.set("linear_limit_%s/enabled" % axis, true)
		j.set("linear_limit_%s/lower" % axis, 0.0)
		j.set("linear_limit_%s/upper" % axis, 0.0)

	# Allow some swing/twist (tune small angles)
	j.set("angular_limit_x/enabled", true)
	j.set("angular_limit_x/upper_angle", deg_to_rad(30.0))
	j.set("angular_limit_x/lower_angle", -deg_to_rad(30.0))
	j.set("angular_spring_x/enabled", true)
	#j.set("angular_limit_x/softness", 0.05)
	#j.set("angular_limit_x/restitution", 1.0)
	j.set("linear_limit_x/softness", _linear_limit_softness)
	j.set("linear_limit_x/restitution", _linear_limit_restitution)
	j.set("linear_limit_x/damping", _linear_limit_damping)

	j.set("angular_limit_y/enabled", true)
	j.set("angular_limit_y/upper_angle", deg_to_rad(10.0))
	j.set("angular_limit_y/lower_angle", -deg_to_rad(10.0))
	#j.set("angular_limit_y/softness", 0.05)
	#j.set("angular_limit_y/restitution", 1.0)
	j.set("linear_limit_y/softness", _linear_limit_softness)
	j.set("linear_limit_y/restitution", _linear_limit_restitution)
	j.set("linear_limit_y/damping", _linear_limit_damping)

	j.set("angular_limit_z/enabled", true)
	j.set("angular_limit_z/upper_angle", deg_to_rad(30.0))
	j.set("angular_limit_z/lower_angle", -deg_to_rad(30.0))
	j.set("angular_spring_z/enabled", true)
	#j.set("angular_limit_z/softness", 0.05)
	#j.set("angular_limit_z/restitution", 1.0)
	j.set("linear_limit_z/softness", _linear_limit_softness)
	j.set("linear_limit_z/restitution", _linear_limit_restitution)
	j.set("linear_limit_z/damping", _linear_limit_damping)

	return j


func _rescale_rigidbody(body: Node3D) -> void:
	for child in body.get_children(true):
		if child is CollisionShape3D:
			var collision: CollisionShape3D = child
			var shape: Shape3D = collision.shape.duplicate(true)
			shape.resource_local_to_scene = false
			print("DEBUG - Rescale rigidbody")
			if shape is SphereShape3D:
				print("DEBUG - Rescale rigidbody SPHERE")
				(shape as SphereShape3D).radius *= _scale
			collision.shape = shape
		elif child is MeshInstance3D:
			child.scale *= _scale
		elif child is Node3D:
			_rescale_rigidbody(child)


func _update_links() -> void:
	#print("DEBUG - Updating links: ", _link_number)
	var base_link : BaseLink = BASE_LINK.instantiate()
	_rescale_rigidbody(base_link)
	add_child(base_link)
	base_link.owner = get_tree().edited_scene_root
	
	var previous_link: Node3D = base_link
	for i in _link_number:
		#print("DEBUG _ Adding link number ", i)
		var chain_link: ChainLink = CHAIN_LINK.instantiate().duplicate()
		chain_link.name = "ChainLink" + str(i)
		_rescale_rigidbody(chain_link)
		add_child(chain_link)
		chain_link.owner = get_tree().edited_scene_root
		chain_link.position = (i+1) * Vector3.UP * _scale
		chain_link.rotation = 0.5 * PI * (i + 1) * Vector3.UP
		
		var generic_joint: Generic6DOFJoint3D = _instantiate_new_hinge_join()
		#previous_link.add_child(generic_joint)
		add_child(generic_joint)
		#generic_joint.position = 0.5 * Vector3.UP * _scale
		generic_joint.position = (i+1) * Vector3.UP * _scale
		generic_joint.owner = get_tree().edited_scene_root
		generic_joint.node_a = generic_joint.get_path_to(previous_link)
		generic_joint.node_b = generic_joint.get_path_to(chain_link)
		
		previous_link = chain_link
