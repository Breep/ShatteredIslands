class_name LabelPopup
extends Control

# ============================== Private variables ==============================
#region Private Variables
var _is_crit: bool = false
var _is_blocked_by_armor: bool = false
var _global_start_pos: Vector2
var _color: Color
var _is_setup: bool = false
var _damage_type: Utils.DamageType
var _stack_type: Utils.StackType
var _is_damage: bool = false
var _is_mirrored: bool = false
var _value: int
#endregion


#region ===== Tuning
enum VMoveType { UP, DOWN }
enum HMoveType { LEFT, RIGHT }
var popup_ratio: float = 2.0
var lifetime: float = 2.0                  # total anim time (s)
var end_scale: float = 1.5                 # End scale of the label
var rise_distance: float = 20.0            # how far it floats up (px)
var horizontal_wiggle: float = 50.0        # random left/right drift (px)
var critical_scale_multiplier: float = 2.0 # how much critics are displayed bigger
var vmove: VMoveType = VMoveType.UP
var hmove: HMoveType = HMoveType.LEFT

# Optional fine control on easing
var rise_ease: Tween.EaseType = Tween.EASE_OUT
var fade_ease: Tween.EaseType = Tween.EASE_IN
var scale_ease: Tween.EaseType = Tween.EASE_OUT
var trans: Tween.TransitionType = Tween.TRANS_CUBIC
#endregion

#region ===== Local Nodes
@onready var _label: Label = %Label
@onready var _critical_background: TextureRect = %CriticalBackground
#endregion

# ================== API ==================

func mirror(is_mirrored: bool) -> LabelPopup:
	_is_mirrored = is_mirrored
	return self


func setup_damage(value: int, damage_type: Utils.DamageType, global_start_pos: Vector2, critical: bool = false, blocked_by_armor: bool = false) -> LabelPopup:
	_is_crit = critical
	_is_blocked_by_armor = blocked_by_armor
	_global_start_pos = global_start_pos
	_value = value
	_color = Utils.DAMAGE_COLORS[damage_type]
	_damage_type = damage_type
	_is_damage = true
	_is_setup = true
	return self


func setup_stack(value: int, stack_type: Utils.StackType, global_start_pos: Vector2, critical: bool = false) -> LabelPopup:
	_is_crit = critical
	_stack_type = stack_type
	_global_start_pos = global_start_pos
	_color = Utils.STACK_COLORS[stack_type]
	_value = value
	_is_damage = false
	_is_setup = true
	return self

# ============================== Node base functions ==============================
func _ready() -> void:
	if not _is_setup:
		push_warning("UIDamagePopups: Need to be setup before entering tree")
		queue_free()
		return
	scale = Vector2(0.01, 0.01)
	_label.modulate = _color
	global_position = _global_start_pos - 0.5 * size.x * Vector2.RIGHT
	rise_distance *= popup_ratio
	horizontal_wiggle *= popup_ratio
	set_anchors_preset(Control.PRESET_CENTER)
	pivot_offset = size / 2
	
	if _is_damage:
		vmove = VMoveType.UP
		if _damage_type == Utils.DamageType.HEAL:
			hmove = HMoveType.LEFT
			_label.text = "+" + str(_value)
		else:
			hmove = HMoveType.RIGHT
			_label.text = "-" + str(_value)
	else:
		vmove = VMoveType.DOWN
		_label.text = "" + str(_value)
		if _stack_type == Utils.StackType.SHIELD or _stack_type == Utils.StackType.REGEN:
			hmove = HMoveType.LEFT
		else:
			hmove = HMoveType.RIGHT
	
	if _is_crit:
		rise_distance *= 2
		lifetime *= 1.5
		end_scale *= critical_scale_multiplier
		_critical_background.show()
	else:
		_critical_background.hide()
	
	if _is_mirrored:
		horizontal_wiggle *= -1.0
	
	_start_animation()

# ================== Internals ==================
const MIN_MUL: float = 0.1
const MAX_MUL: float = 1.0
func _start_animation() -> void:
	var tw: Tween = create_tween()

	# Random slight horizontal offset (left or right)
	var dx: float = randf_range(MIN_MUL * horizontal_wiggle, MAX_MUL * horizontal_wiggle)
	if hmove == HMoveType.LEFT: dx *= -1.0
	if vmove == VMoveType.DOWN: rise_distance *= -1
	var end_pos := position + Vector2(dx, -rise_distance)
	if lifetime > 0.0:
		tw.set_trans(trans)
		tw.parallel().set_ease(rise_ease).tween_property(self, "position", end_pos, lifetime) # Move UP
		tw.parallel().set_ease(fade_ease).tween_property(self, "modulate:a", 0.0, lifetime) # FADE OUT
		tw.parallel().set_ease(scale_ease).tween_property(self, "scale", Vector2(end_scale, end_scale), lifetime) # Scaling

	# Cleanup when finished
	tw.finished.connect(queue_free, CONNECT_ONE_SHOT)
