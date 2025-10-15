extends TextureRect

@export var viewport: SubViewport

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if viewport == null or !is_visible_in_tree():
		return
	if !(event is InputEventMouse):
		return

	# Global -> local using canvas transform (works for Control/CanvasItem in Godot 4)
	var global_mouse: Vector2 = get_viewport().get_mouse_position()
	var local_mouse: Vector2 = get_global_transform_with_canvas().affine_inverse() * global_mouse

	if !Rect2(Vector2.ZERO, size).has_point(local_mouse):
		return

	var vp_size_i: Vector2i = viewport.size
	var tex_px_size: Vector2 = Vector2(vp_size_i)
	var draw_rect: Rect2 = _compute_draw_rect(size, tex_px_size, stretch_mode)
	if draw_rect.size.x <= 0.0 or draw_rect.size.y <= 0.0:
		return

	var uv: Vector2 = (local_mouse - draw_rect.position) / draw_rect.size
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		return

	var vp_pos: Vector2 = uv * tex_px_size
	var e := event.duplicate()
	e.position = vp_pos
	e.global_position = vp_pos

	if e is InputEventMouseMotion:
		var mm := e as InputEventMouseMotion
		var scale_xy: Vector2 = tex_px_size / draw_rect.size
		mm.relative *= scale_xy
		mm.velocity *= scale_xy

	viewport.push_input(e)

func _compute_draw_rect(control_size: Vector2, tex_size: Vector2, mode: int) -> Rect2:
	var cs: Vector2 = control_size
	var ts: Vector2 = tex_size
	if ts.x <= 0.0 or ts.y <= 0.0 or cs.x <= 0.0 or cs.y <= 0.0:
		return Rect2(Vector2.ZERO, Vector2.ZERO)

	match mode:
		TextureRect.STRETCH_SCALE:
			return Rect2(Vector2.ZERO, cs)
		TextureRect.STRETCH_TILE:
			return Rect2(Vector2.ZERO, cs)
		TextureRect.STRETCH_KEEP:
			return Rect2(Vector2.ZERO, ts)
		TextureRect.STRETCH_KEEP_CENTERED:
			var pos_centered: Vector2 = (cs - ts) * 0.5
			return Rect2(pos_centered, ts)
		TextureRect.STRETCH_KEEP_ASPECT, TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
			var scale_fit: float = min(cs.x / ts.x, cs.y / ts.y)
			var draw_size: Vector2 = ts * scale_fit
			var pos_fit: Vector2 = (cs - draw_size) * 0.5
			return Rect2(pos_fit, draw_size)
		TextureRect.STRETCH_KEEP_ASPECT_COVERED:
			var scale_cover: float = max(cs.x / ts.x, cs.y / ts.y)
			var draw_size2: Vector2 = ts * scale_cover
			var pos_cover: Vector2 = (cs - draw_size2) * 0.5
			return Rect2(pos_cover, draw_size2)
		_:
			return Rect2(Vector2.ZERO, cs)
