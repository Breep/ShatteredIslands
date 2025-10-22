class_name UIDamagePopup
extends Label

# ================== Tuning ==================
@export var is_crit: bool = false
@export var is_heal: bool = false

@export var lifetime: float = 0.8             # total anim time (s)
@export var pop_scale: float = 1.25           # initial scale burst
@export var end_scale: float = 0.9            # slight shrink at the end
@export var rise_distance: float = 48.0       # how far it floats up (px)
@export var horizontal_wiggle: float = 10.0   # random left/right drift (px)
@export var delay: float = 0.0                # optional delay before anim

@export var crit_color: Color = Color(0.655, 0.128, 0.169, 1.0)   # gold-ish
@export var dmg_color: Color = Color(0.394, 0.43, 0.418, 1.0)   # red-ish
@export var heal_color: Color = Color(0.465, 0.673, 0.369, 1.0)    # green-ish

# Optional fine control on easing
@export var rise_ease: Tween.EaseType = Tween.EASE_OUT
@export var fade_ease: Tween.EaseType = Tween.EASE_IN
@export var scale_ease: Tween.EaseType = Tween.EASE_OUT
@export var trans: Tween.TransitionType = Tween.TRANS_CUBIC

var _color: Color

# ================== API ==================
## Call this right after instancing if you want to override defaults in code.
func setup(value: int, critical: bool=false, healed: bool=false, color: Color = Color(-1, -1, -1)) -> UIDamagePopup:
	is_crit = critical
	is_heal = healed
	text = str(value)
	_color = color
	return self

# ================== Lifecycle ==================
func _ready() -> void:
	scale = Vector2(0.01, 0.01)
	modulate.a = 1.0

	_start_animation()

# ================== Internals ==================
func _start_animation() -> void:
	var tw := get_tree().create_tween()
	if delay > 0.0:
		tw.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
		tw.pause()
		await get_tree().create_timer(delay).timeout
		tw.play()

	tw.set_trans(trans)

	# Random slight horizontal offset (left or right)
	var dx := randf_range(-horizontal_wiggle, horizontal_wiggle)
	var start_pos := position
	var end_pos := start_pos + Vector2(dx, -rise_distance)

	# POP: quick up-scale, then ease to end_scale while moving up & fading out
	var pop_time = min(0.16, lifetime * 0.25)
	var remain = max(0.0, lifetime - pop_time)

	# Phase 1 (pop) - scale up quickly
	tw.parallel().set_ease(scale_ease)\
		.tween_property(self, "scale", Vector2(pop_scale, pop_scale), pop_time)

	# Phase 2 (settle) - scale down slightly while rising & fading
	if remain > 0.0:
		tw = tw.chain() # next phase
		tw.set_trans(trans)

		# Move up
		tw.parallel().set_ease(rise_ease)\
			.tween_property(self, "position", end_pos, remain)

		# Fade out
		tw.parallel().set_ease(fade_ease)\
			.tween_property(self, "modulate:a", 0.0, remain)

		# Scale settle
		tw.parallel().set_ease(scale_ease)\
			.tween_property(self, "scale", Vector2(end_scale, end_scale), remain)

	# Cleanup when finished
	tw.finished.connect(queue_free, CONNECT_ONE_SHOT)
