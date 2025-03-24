extends TextureRect

@export var viewport: SubViewport

func _ready() -> void:
	set_process_unhandled_input(true)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouse or not is_visible_in_tree():
		return
	
	print("Transmit event")
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
