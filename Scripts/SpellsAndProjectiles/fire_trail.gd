extends Node3D

@export var path: Path3D
@export var area_scene: PackedScene
@export var area_length: float  # Length of each Area3D segment

@export var camera: Camera3D

var _areas: Array[Area3D]

func _ready():
	var curve = path.curve
	var path_length = curve.get_baked_length()
	print(path_length)
	var distance = 0.0

	while distance < path_length:
		var position = curve.sample_baked(distance)
		var next_position = curve.sample_baked(min(distance + area_length, path_length))
		print(position, " ", next_position)
		var direction = (next_position - position).normalized()

		var area_instance: Area3D = area_scene.instantiate()
		add_child(area_instance)
		area_instance.global_position = position
		area_instance.look_at(next_position)
		_areas.append(area_instance)

		distance += area_length
	
	#await get_tree().process_frame
	#_late_ready()
#
#func _late_ready() -> void:
	#for area in _areas:
		#area.look_at(camera.global_position)
#
#
#func _process(delta: float) -> void:
	#for area in _areas:
		#area.look_at(camera.global_position)
