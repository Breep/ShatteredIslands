class_name FloorRayCast
extends RayCast3D

# Return the position of the first 
func get_clicked_position() -> Vector3:
	print("FloorRayCast: [DEBUG] ", get_collision_point())
	return get_collision_point()
