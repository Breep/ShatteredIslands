extends StaticBody3D

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("COUCOU ", camera.name, " ", event.as_text(), " ", event_position, " ", normal, " ", shape_idx)
