class_name UIDamagePopup
extends Label

# ============================== Private variables ==============================
#region Private Variables
var _is_crit: bool = false
var _global_start_pos: Vector2
var _color: Color
var _is_setup: bool = false
var _damage_type: Utils.DamageType
#endregion

# ================== Tuning ==================
#region Tuning
var popup_ratio: float = 2.0
var lifetime: float = 1.5                  # total anim time (s)
var end_scale: float = 1.5                 # End scale of the label
var rise_distance: float = 70.0            # how far it floats up (px)
var horizontal_wiggle: float = 15.0        # random left/right drift (px)
var critical_scale_multiplier: float = 2.0 # how much critics are displayed bigger

# Optional fine control on easing
var rise_ease: Tween.EaseType = Tween.EASE_OUT
var fade_ease: Tween.EaseType = Tween.EASE_IN
var scale_ease: Tween.EaseType = Tween.EASE_OUT
var trans: Tween.TransitionType = Tween.TRANS_CUBIC
#endregion

# ================== API ==================
func setup(value: int, damage_type: Utils.DamageType, global_start_pos: Vector2, critical: bool = false) -> UIDamagePopup:
	_is_crit = critical
	_global_start_pos = global_start_pos
	text = str(value)
	_color = Utils.DAMAGE_COLORS[damage_type]
	_damage_type = damage_type
	_is_setup = true
	return self

# ============================== Node base functions ==============================
func _ready() -> void:
	if not _is_setup:
		push_warning("UIDamagePopups: Need to be setup before entering tree")
		queue_free()
		return
	scale = Vector2(0.01, 0.01)
	modulate = _color
	global_position = _global_start_pos
	rise_distance *= popup_ratio
	horizontal_wiggle *= popup_ratio
	add_theme_font_size_override("font_size", int(16.0 * popup_ratio))
	
	if _is_crit:
		rise_distance *= 2
		lifetime *= 1.5
		end_scale *= critical_scale_multiplier
	
	_start_animation()

# ================== Internals ==================
func _start_animation() -> void:
	var tw: Tween = create_tween()
	tw.set_trans(trans)

	# Random slight horizontal offset (left or right)
	var dx: float
	if _damage_type == Utils.DamageType.HEAL:
		dx = randf_range(-3 * horizontal_wiggle, -horizontal_wiggle)
	else:
		dx = randf_range(0, horizontal_wiggle)
	var start_pos := position
	var end_pos := start_pos + Vector2(dx, -rise_distance)
	if lifetime > 0.0:
		tw = tw.chain() # next phase
		tw.set_trans(trans)
		tw.parallel().set_ease(rise_ease).tween_property(self, "position", end_pos, lifetime) # Move UP
		tw.parallel().set_ease(fade_ease).tween_property(self, "modulate:a", 0.0, lifetime) # FADE OUT
		tw.parallel().set_ease(scale_ease).tween_property(self, "scale", Vector2(end_scale, end_scale), lifetime) # Scaling

	# Cleanup when finished
	tw.finished.connect(queue_free, CONNECT_ONE_SHOT)
