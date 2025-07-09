extends TextureRect

@export var viewport: SubViewport

func _ready() -> void:
	set_process_unhandled_input(true)
	set_process_input(true)

#func _unhandled_input(event):
	#for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		#if is_instance_of(event, mouse_event):
			## If the event is a mouse/touch event, then we can ignore it here, because it will be
			## handled via Physics Picking.
			#return
	#viewport.push_input(event)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouse or not is_visible_in_tree():
		return
	
	# Convert the event position from the TextureRect to Viewport space
	var local_pos: Vector2 = get_local_mouse_position()
	var texture_size: Vector2 = size
	var viewport_size: Vector2 = viewport.size as Vector2

	# Scale position to match viewport size
	var viewport_pos = (local_pos / texture_size) * viewport_size

	# Duplicate event and adjust position
	var new_event = event.duplicate()
	new_event.position = viewport_pos

	# Send event to viewport
	viewport.push_input(new_event)
