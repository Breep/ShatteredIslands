extends TextureRect

@export var viewport: SubViewport

var _was_inside := false

func _ready() -> void:
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _input(event: InputEvent) -> void:
	if viewport == null or !is_visible_in_tree():
		return
	if !(event is InputEventMouse):
		return

	var global_mouse: Vector2 = get_viewport().get_mouse_position()
	var local_mouse: Vector2 = get_global_transform_with_canvas().affine_inverse() * global_mouse

	var vp_size_i: Vector2i = viewport.size
	var tex_px_size := Vector2(vp_size_i)
	var draw_rect := _compute_draw_rect(size, tex_px_size, stretch_mode)
	if draw_rect.size.x <= 0.0 or draw_rect.size.y <= 0.0:
		return

	var inside := Rect2(Vector2.ZERO, size).has_point(local_mouse)
	var uv := (local_mouse - draw_rect.position) / draw_rect.size
	var vp_pos := uv * tex_px_size

	var e := event.duplicate()
	e.position = vp_pos
	e.global_position = vp_pos

	if e is InputEventMouseMotion:
		var mm := e as InputEventMouseMotion
		var scale_xy := tex_px_size / draw_rect.size
		mm.relative *= scale_xy
		mm.velocity *= scale_xy

		if !inside:
			if _was_inside:
				_send_outside_motion()
			_was_inside = false
			return

		_was_inside = true
		viewport.push_input(e)
		return

	# Only forward button events when inside; send a release outside to cancel if needed
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

func _compute_draw_rect(control_size: Vector2, tex_size: Vector2, mode: int) -> Rect2:
	var cs := control_size
	var ts := tex_size
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
