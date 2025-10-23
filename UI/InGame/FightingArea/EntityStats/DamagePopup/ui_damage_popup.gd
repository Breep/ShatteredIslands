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
var lifetime: float = 0.8                  # total anim time (s)
var end_scale: float = 1.2                 # End scale of the label
var rise_distance: float = 48.0            # how far it floats up (px)
var horizontal_wiggle: float = 10.0        # random left/right drift (px)
var delay: float = 0.0                     # optional delay before anim
var critical_scale_multiplier: float = 2.0 # how much critics are displayed bigger

# Optional fine control on easing
var rise_ease: Tween.EaseType = Tween.EASE_OUT
var fade_ease: Tween.EaseType = Tween.EASE_IN
var scale_ease: Tween.EaseType = Tween.EASE_OUT
var trans: Tween.TransitionType = Tween.TRANS_CUBIC
#endregion

# ================== API ==================
func setup(value: int, damage_type: Utils.DamageType, global_start_pos: Vector2, critical: bool = false,) -> UIDamagePopup:
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
	#add_theme_font_size_override("font_size", 50)
	if _is_crit:
		end_scale *= critical_scale_multiplier
	
	_start_animation()

# ================== Internals ==================
func _start_animation() -> void:
	var tw: Tween = create_tween()
	if delay > 0.0:
		tw.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
		tw.pause()
		await get_tree().create_timer(delay).timeout
		tw.play()

	tw.set_trans(trans)

	# Random slight horizontal offset (left or right)
	var dx: float
	if _damage_type == Utils.DamageType.HEAL:
		dx = randf_range(-3 * horizontal_wiggle, -horizontal_wiggle)
	else:
		dx = randf_range(0, horizontal_wiggle)
	var start_pos := position
	var end_pos := start_pos + Vector2(dx, -rise_distance)

	# POP: quick up-scale, then ease to end_scale while moving up & fading out
	#var pop_time = min(0.16, lifetime * 0.25)
	#var remain = max(0.0, lifetime - pop_time)

	# Phase 1 (pop) - scale up quickly
	#tw.parallel().set_ease(scale_ease).tween_property(self, "scale", Vector2(pop_scale, pop_scale), pop_time)

	# Phase 2 (settle) - scale down slightly while rising & fading
	if lifetime > 0.0:
		tw = tw.chain() # next phase
		tw.set_trans(trans)
		tw.parallel().set_ease(rise_ease).tween_property(self, "position", end_pos, lifetime) # Move UP
		tw.parallel().set_ease(fade_ease).tween_property(self, "modulate:a", 0.0, lifetime) # FADE OUT
		tw.parallel().set_ease(scale_ease).tween_property(self, "scale", Vector2(end_scale, end_scale), lifetime) # Scaling

	# Cleanup when finished
	tw.finished.connect(queue_free, CONNECT_ONE_SHOT)
