class_name TutorialBlocker
extends Control

# Fullscreen Control used by TutorialOverlay to (a) optionally darken the screen
# around one or more target rects (spotlight effect), and (b) optionally block
# player input outside those rects (hole-punch). The two concerns are independent:
#
#   dim=on,  block=off → spotlight visual only (passive tutorial highlight)
#   dim=off, block=on  → invisible blocker (input gate, no visual change)
#   dim=on,  block=on  → spotlight + input gate (modal-dimmed flow)
#   both off           → blocker hidden entirely
#
# Several targets are supported: the dim is the full screen minus every hole
# (rectangle subtraction), and each hole gets its own glow + pulsing border.
# _has_point lets input through inside ANY hole when input_blocking is true.

#region ============================== Export ==============================
@export var dim_color: Color = Color(0, 0, 0, 0.78)
@export var border_color: Color = Color(1.0, 0.92, 0.55, 1.0)
@export var border_width: float = 3.0
@export var glow_layers: int = 3
@export var glow_step: float = 5.0
@export var pulse_speed: float = 1.5 ## Period of the breathing pulse, in seconds.
@export var pulse_min_alpha: float = 0.55
@export var pulse_max_alpha: float = 1.0
#endregion


#region ============================== Public variables ==============================
var target_rects: Array[Rect2] = [] ## One spotlight hole per target. Empty = cover everything.
var dim_active: bool = false
var input_blocking: bool = false
#endregion


#region ============================== Private variables ==============================
var _pulse_phase: float = 0.0
var _target_ctrls: Array[Control] = []
var _target_padding: float = 0.0
var _block_through_holes: bool = false ## When true, input is blocked even inside the holes (highlight stays purely visual).
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	set_process(false)


func _process(delta: float) -> void:
	_refresh_target_rects()
	if pulse_speed > 0.0:
		_pulse_phase += delta * (TAU / pulse_speed)
	queue_redraw()


func _draw() -> void:
	if not dim_active: return
	var full: Rect2 = Rect2(Vector2.ZERO, size)

	# Collect holes in local space, clipped to the visible rect.
	var holes: Array[Rect2] = []
	for r: Rect2 in target_rects:
		if r.size == Vector2.ZERO: continue
		var local: Rect2 = Rect2(r.position - global_position, r.size).intersection(full)
		if local.size.x > 0.0 and local.size.y > 0.0:
			holes.append(local)

	if holes.is_empty():
		draw_rect(full, dim_color)
		return

	# Dim = full screen minus every hole (carve one hole at a time).
	var dim_rects: Array[Rect2] = [full]
	for hole: Rect2 in holes:
		var next: Array[Rect2] = []
		for d: Rect2 in dim_rects:
			next.append_array(_subtract(d, hole))
		dim_rects = next
	for d: Rect2 in dim_rects:
		draw_rect(d, dim_color)

	# Glow halo + pulsing border around each hole.
	var pulse: float = lerp(pulse_min_alpha, pulse_max_alpha, 0.5 + 0.5 * sin(_pulse_phase))
	for hole: Rect2 in holes:
		for i in range(1, glow_layers + 1):
			var grow: float = i * glow_step
			var halo_rect: Rect2 = Rect2(hole.position - Vector2(grow, grow), hole.size + Vector2(grow * 2.0, grow * 2.0))
			var halo_color: Color = border_color
			halo_color.a = (1.0 - float(i) / float(glow_layers + 1)) * 0.4
			draw_rect(halo_rect, halo_color, false, max(1.0, glow_step))
		var stroke: Color = border_color
		stroke.a = pulse
		draw_rect(hole, stroke, false, border_width)


func _has_point(point: Vector2) -> bool:
	if not input_blocking:
		return false
	if _block_through_holes:
		return true
	if target_rects.is_empty():
		return true
	var global_p: Vector2 = get_global_transform() * point
	for r: Rect2 in target_rects:
		if r.size != Vector2.ZERO and r.has_point(global_p):
			return false
	return true
#endregion


#region ============================== Public functions ==============================
func set_state(p_dim: bool, p_block: bool, p_targets: Array[Control], p_padding: float = 0.0, p_block_through_holes: bool = false) -> void:
	dim_active = p_dim
	input_blocking = p_block
	_target_ctrls = p_targets
	_target_padding = p_padding
	_block_through_holes = p_block_through_holes
	mouse_filter = Control.MOUSE_FILTER_STOP if p_block else Control.MOUSE_FILTER_IGNORE
	visible = p_dim or p_block
	_refresh_target_rects()
	if p_dim:
		set_process(true)
	else:
		set_process(false)
		_pulse_phase = 0.0
	queue_redraw()
#endregion


#region ============================== Private functions ==============================
func _refresh_target_rects() -> void:
	target_rects.clear()
	for ctrl: Control in _target_ctrls:
		if ctrl == null or not is_instance_valid(ctrl): continue
		var xform: Transform2D = ctrl.get_global_transform_with_canvas()
		var r: Rect2 = xform * Rect2(Vector2.ZERO, ctrl.size)
		if _target_padding != 0.0:
			r = r.grow(_target_padding)
		target_rects.append(r)


# Returns the parts of `rect` lying outside `hole`, as up to 4 sub-rects.
func _subtract(rect: Rect2, hole: Rect2) -> Array[Rect2]:
	var inter: Rect2 = rect.intersection(hole)
	if inter.size.x <= 0.0 or inter.size.y <= 0.0:
		var whole: Array[Rect2] = [rect]
		return whole
	var out: Array[Rect2] = []
	if inter.position.y > rect.position.y: # top band
		out.append(Rect2(rect.position.x, rect.position.y, rect.size.x, inter.position.y - rect.position.y))
	if inter.end.y < rect.end.y: # bottom band
		out.append(Rect2(rect.position.x, inter.end.y, rect.size.x, rect.end.y - inter.end.y))
	if inter.position.x > rect.position.x: # left band
		out.append(Rect2(rect.position.x, inter.position.y, inter.position.x - rect.position.x, inter.size.y))
	if inter.end.x < rect.end.x: # right band
		out.append(Rect2(inter.end.x, inter.position.y, rect.end.x - inter.end.x, inter.size.y))
	return out
#endregion
