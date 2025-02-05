class_name FightingArea
extends Node3D

signal map_clicked(position: Vector3)

@onready var camera = %Camera3D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select_object(event.position)


func select_object(screen_position):
	if not camera: return
	print("Try select object")
	
	# Convert screen position to a ray in 3D
	var ray_origin = camera.project_ray_origin(screen_position)
	var ray_dir = camera.project_ray_normal(screen_position)

	# Define the ray end position (extend it far enough)
	var ray_end = ray_origin + ray_dir * 1000  # 1000 units ahead

	# Perform the raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)

	if result:
		var selected_object = result.collider
		print("Selected object: ", selected_object.name)
		print("Position clicked: ", result.position)
		map_clicked.emit(result.position) # TODO check group, improve raycast to go through characters and others spells


func _on_timer_timeout() -> void:
	GameManager.game_switch_to(GameManager.GameState.Buying)
