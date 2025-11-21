extends TextureRect

@export var viewport: SubViewport
@export var rotation_strength: float = 0.5 # tweak for sensitivity

var _was_inside := false


func _ready() -> void:
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))


func _input(event: InputEvent) -> void:
	if viewport == null or !is_visible_in_tree():
		return
	if !(event is InputEventMouse):
		return

	var global_mouse: Vector2 = get_viewport().get_mouse_position()
	var local_mouse: Vector2 = get_global_transform_with_canvas().affine_inverse() * global_mouse

	var vp_size := viewport.size
	var draw_rect_a := _compute_draw_area(size, vp_size, stretch_mode)

	var inside := Rect2(Vector2.ZERO, size).has_point(local_mouse)
	if event is InputEventMouseMotion and !inside:
		if _was_inside:
			_send_outside_motion()
		_was_inside = false
		return

	# ----------------------------------------------
	# Simple projection alignment based on rotation
	# ----------------------------------------------
	var uv := (local_mouse - draw_rect_a.position) / draw_rect_a.size
	if flip_h: uv.x = 1.0 - uv.x
	if flip_v: uv.y = 1.0 - uv.y

	# Optional: adjust the pointer to visually match shader rotation
	var mat := material
	if mat and mat is ShaderMaterial:
		var y_rot := deg_to_rad(float(mat.get_shader_parameter("y_rot")))
		var x_rot := deg_to_rad(float(mat.get_shader_parameter("x_rot")))
		var tilt := Vector2(sin(y_rot), -sin(x_rot)) * rotation_strength
		uv += tilt

	uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
	var vp_pos := uv * Vector2(vp_size)

	# Duplicate and forward event
	var e := event.duplicate() as InputEvent
	e.position = vp_pos
	e.global_position = vp_pos

	if e is InputEventMouseMotion:
		var mm := e as InputEventMouseMotion
		var scale_xy := Vector2(vp_size) / draw_rect_a.size
		mm.relative *= scale_xy
		mm.velocity *= scale_xy

	if inside:
		_was_inside = true
		viewport.push_input(e)
	else:
		if e is InputEventMouseButton and !(e as InputEventMouseButton).pressed:
			var mb := InputEventMouseButton.new()
			mb.button_index = (e as InputEventMouseButton).button_index
			mb.pressed = false
			mb.position = Vector2(-1, -1)
			mb.global_position = mb.position
			viewport.push_input(mb)
		_was_inside = false


func _on_mouse_exited() -> void:
	if viewport:
		_send_outside_motion()
	_was_inside = false


func _send_outside_motion() -> void:
	var out := InputEventMouseMotion.new()
	out.position = Vector2(-1, -1)
	out.global_position = out.position
	out.relative = Vector2.ZERO
	out.velocity = Vector2.ZERO
	viewport.push_input(out)


func _get_viewport_tex_size() -> Vector2i:
	if texture and texture is Texture2D:
		var s := texture.get_size()
		return Vector2i(int(s.x), int(s.y))
	return viewport.size


func _compute_draw_area(control_size: Vector2, tex_size: Vector2i, mode: int) -> Rect2:
	var cs := control_size
	var ts := Vector2(tex_size)
	if ts.x <= 0.0 or ts.y <= 0.0 or cs.x <= 0.0 or cs.y <= 0.0:
		return Rect2(Vector2.ZERO, Vector2.ZERO)

	match mode:
		TextureRect.STRETCH_SCALE, TextureRect.STRETCH_TILE:
			return Rect2(Vector2.ZERO, cs)
		TextureRect.STRETCH_KEEP:
			return Rect2(Vector2.ZERO, ts)
		TextureRect.STRETCH_KEEP_CENTERED:
			return Rect2((cs - ts) * 0.5, ts)
		TextureRect.STRETCH_KEEP_ASPECT, TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
			var scale_fit = min(cs.x / ts.x, cs.y / ts.y)
			var draw_size = ts * scale_fit
			return Rect2((cs - draw_size) * 0.5, draw_size)
		TextureRect.STRETCH_KEEP_ASPECT_COVERED:
			var scale_cover = max(cs.x / ts.x, cs.y / ts.y)
			var draw_size2 = ts * scale_cover
			return Rect2((cs - draw_size2) * 0.5, draw_size2)
		_:
			return Rect2(Vector2.ZERO, cs)
