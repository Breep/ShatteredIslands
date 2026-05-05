class_name TutorialBlocker
extends Control

# Fullscreen Control used by TutorialOverlay to (a) optionally darken the screen
# around a target rect (spotlight effect), and (b) optionally block player
# input outside that rect (hole-punch). The two concerns are independent:
#
#   dim=on,  block=off → spotlight visual only (passive tutorial highlight)
#   dim=off, block=on  → invisible blocker (input gate, no visual change)
#   dim=on,  block=on  → spotlight + input gate (modal-dimmed flow)
#   both off           → blocker hidden entirely
#
# The dim is drawn via _draw() as 4 strips around target_rect, leaving the
# target itself fully unobstructed. modulate.a is tweened by the overlay for
# fade-in/out. _has_point handles input pass-through inside the target rect
# only when input_blocking is true.

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
var target_rect: Rect2 = Rect2() ## Empty rect = no hole; covers everything.
var dim_active: bool = false
var input_blocking: bool = false
#endregion


#region ============================== Private variables ==============================
var _pulse_phase: float = 0.0
#endregion


#region ============================== Node base functions ==============================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	set_process(false)


func _process(delta: float) -> void:
	if pulse_speed > 0.0:
		_pulse_phase += delta * (TAU / pulse_speed)
	queue_redraw()


func _draw() -> void:
	if not dim_active: return
	var full: Rect2 = Rect2(Vector2.ZERO, size)
	if target_rect.size == Vector2.ZERO:
		Verbose.debug("[Blocker] _draw full dim (no target rect) | size=%s modulate.a=%.2f" % [size, modulate.a], Verbose.Category.TUTORIAL)
		draw_rect(full, dim_color)
		return

	var local: Rect2 = Rect2(target_rect.position - global_position, target_rect.size)
	local = local.intersection(full)
	if local.size == Vector2.ZERO:
		Verbose.debug("[Blocker] _draw full dim (target intersection empty) | full=%s target=%s gpos=%s" % [full, target_rect, global_position], Verbose.Category.TUTORIAL)
		draw_rect(full, dim_color)
		return

	Verbose.debug("[Blocker] _draw spotlight | full=%s local=%s modulate.a=%.2f" % [full, local, modulate.a], Verbose.Category.TUTORIAL)

	# 4 dim strips around the spotlight
	if local.position.y > 0:
		draw_rect(Rect2(0, 0, full.size.x, local.position.y), dim_color)
	if local.end.y < full.size.y:
		draw_rect(Rect2(0, local.end.y, full.size.x, full.size.y - local.end.y), dim_color)
	if local.position.x > 0:
		draw_rect(Rect2(0, local.position.y, local.position.x, local.size.y), dim_color)
	if local.end.x < full.size.x:
		draw_rect(Rect2(local.end.x, local.position.y, full.size.x - local.end.x, local.size.y), dim_color)

	# External glow halo: concentric outlines fading out as they grow
	for i in range(1, glow_layers + 1):
		var grow: float = i * glow_step
		var halo_rect: Rect2 = Rect2(local.position - Vector2(grow, grow), local.size + Vector2(grow * 2.0, grow * 2.0))
		var halo_color: Color = border_color
		halo_color.a = (1.0 - float(i) / float(glow_layers + 1)) * 0.4
		draw_rect(halo_rect, halo_color, false, max(1.0, glow_step))

	# Pulsed border on the target rect
	var pulse: float = lerp(pulse_min_alpha, pulse_max_alpha, 0.5 + 0.5 * sin(_pulse_phase))
	var stroke: Color = border_color
	stroke.a = pulse
	draw_rect(local, stroke, false, border_width)
#endregion


#region ============================== Public functions ==============================
func set_state(p_dim: bool, p_block: bool, p_target_rect: Rect2) -> void:
	dim_active = p_dim
	input_blocking = p_block
	target_rect = p_target_rect
	mouse_filter = Control.MOUSE_FILTER_STOP if p_block else Control.MOUSE_FILTER_IGNORE
	visible = p_dim or p_block
	set_process(p_dim and p_target_rect.size != Vector2.ZERO)
	if not (p_dim and p_target_rect.size != Vector2.ZERO):
		_pulse_phase = 0.0
	queue_redraw()


func _has_point(point: Vector2) -> bool:
	if not input_blocking:
		return false
	if target_rect.size == Vector2.ZERO:
		return true
	var global_p: Vector2 = get_global_transform() * point
	return not target_rect.has_point(global_p)
#endregion
