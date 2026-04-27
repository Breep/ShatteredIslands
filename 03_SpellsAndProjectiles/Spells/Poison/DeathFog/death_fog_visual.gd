class_name DeathSmokeVisual
extends Node3D

@onready var _fog_left: FogVolume = %FogVolumeLeft
@onready var _fog_right: FogVolume = %FogVolumeRight
@onready var _debug_mesh_left: MeshInstance3D = %DebugMeshLeft
@onready var _debug_mesh_right: MeshInstance3D = %DebugMeshRight

const FIGHTING_AREA_SIZE := Vector2(20, 10) # must match DeathSmoke

# Called from DeathSmoke._update_visual()
func mirror_from_collision_shapes(left_cs: CollisionShape3D, right_cs: CollisionShape3D) -> void:
	if left_cs and left_cs.shape:
		_update_fog_from_shape(_fog_left, left_cs)
		_debug_mesh_left.position = left_cs.position
		(_debug_mesh_left.mesh as BoxMesh).size.x = (left_cs.shape as BoxShape3D).size.x
		(_debug_mesh_left.mesh as BoxMesh).size.y = (left_cs.shape as BoxShape3D).size.y
		(_debug_mesh_left.mesh as BoxMesh).size.z = (left_cs.shape as BoxShape3D).size.z
	
	if right_cs and right_cs.shape:
		_update_fog_from_shape(_fog_right, right_cs)
		_debug_mesh_right.position = right_cs.position
		(_debug_mesh_right.mesh as BoxMesh).size.x = (right_cs.shape as BoxShape3D).size.x
		(_debug_mesh_right.mesh as BoxMesh).size.y = (right_cs.shape as BoxShape3D).size.y
		(_debug_mesh_right.mesh as BoxMesh).size.z = (right_cs.shape as BoxShape3D).size.z

func _update_fog_from_shape(fog: FogVolume, cs: CollisionShape3D) -> void:
	if fog == null or cs == null or cs.shape == null:
		return
	fog.position = cs.position
	fog.size.x = (cs.shape as BoxShape3D).size.x
	fog.size.y = (cs.shape as BoxShape3D).size.y
	fog.size.z = (cs.shape as BoxShape3D).size.z
