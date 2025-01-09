extends Button


@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
#@export var max_offset_shadow: float = 50.0

#var tween_rot: Tween
#var tween_hover: Tween
#var tween_handle: Tween
#

@onready var card_texture = $SubViewportContainer
#
#var following_mouse: bool = false
#@onready var collision_shape = $Area2D/CollisionShape2D
#
#func _on_mouse_entered() -> void:
	#if tween_hover and tween_hover.is_running():
		#tween_hover.kill()
		#tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		#tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)


#func _on_mouse_exited() -> void:
	## Reset rotation
	#if tween_rot and tween_rot.is_running():
		#tween_rot.kill()
		#tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
		#tween_rot.tween_property($SubViewportContainer/SubViewport/CardUI.material, "shader_parameter/x_rot", 0.0, 0.5)
		#tween_rot.tween_property($SubViewportContainer/SubViewport/CardUI.material, "shader_parameter/y_rot", 0.0, 0.5)
	#
	## Reset scale
	#if tween_hover and tween_hover.is_running():
		#tween_hover.kill()
		#tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		#tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
#
#
#func _on_pressed() -> void:
	#$".".hide()
#
#func handle_mouse_click(event: InputEvent) -> void:
	#if not event is InputEventMouseButton: return
	#if event.button_index != MOUSE_BUTTON_LEFT: return
	#
	#if event.is_pressed():
		#following_mouse = true
	#else:
		## drop card
		#following_mouse = false
		#collision_shape.set_deferred("disabled", false)
		#if tween_handle and tween_handle.is_running():
			#tween_handle.kill()
		#tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		#tween_handle.tween_property(self, "rotation", 0.0, 0.3)
#
func _on_gui_input(event: InputEvent) -> void:
	print("coucou")
	
	#handle_mouse_click(event)
	if not event is InputEventMouseMotion: return
	
	print("coucou")
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)


func _on_pressed() -> void:
	print("coucou")
