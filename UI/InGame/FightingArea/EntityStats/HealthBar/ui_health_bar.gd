class_name UIHealthBar
extends Control

#region Flash config/state
@export_group("Flash Configuration")
@export var _flash_delay: float = 0.15
@export var _flash_duration: float = 0.25
var _flash_target: float = 0.0
var _flash_tween: Tween
var _flash_delay_timer: Timer
#endregion

#region Segment configuration
@export_group("Segment configuration")
@export var _health_per_segment: int = 250
#endregion

#region Local Nodes
@onready var _flash_bar: ProgressBar = %FlashBar
@onready var _segments: FlexibleProgressBar = %Segments

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel

@onready var _armor_bar: ProgressBar = %ArmorBar
@onready var _armor_label: Label = %ArmorLabel
#@export var _armor_multiplier: float = 1.0

@onready var _ignite_bar: ColorRect = %IgniteBar
@onready var _ignite_label: Label = %IgniteLabel
@export var _ignite_multiplier: float = 1.0
@export var _ignite_vsize_divider: float = 1.0

@onready var _poison_bar: ColorRect = %PoisonBar
@onready var _poison_label: Label = %PoisonLabel
@export var _poison_multiplier: float = 1.0
@export var _poison_vsize_divider: float = 1.0
#endregion

#region HealthBar variables
var _show_poison: bool = true
var show_poison: bool:
	get: return _show_poison
	set(value):
		_show_poison = value
		if _show_poison == true: _poison_bar.show()
		else: _poison_bar.hide()

var _show_armor: bool = true
var show_armor: bool:
	get: return _show_armor
	set(value):
		_show_armor = value
		if _show_armor == true: _armor_bar.show()
		else: _armor_bar.hide()

var _poison_stacks: int = 0
var poison_stacks: int:
	get: return _poison_stacks
	set(value):
		var end_pos: Vector2 = _get_health_bar_end_pos()
		_poison_stacks = value
		_update_poison_bar(end_pos)

var _armor_stacks: int = 0
var armor_stacks: int:
	get: return _armor_stacks
	set(value):
		_armor_stacks = value
		_pending_total_max = _max_health + _armor_stacks
		_apply_max_after_flash = true
		_update_armor_bar()

var _ignite_stacks: int = 0
var ignite_stacks: int:
	get: return _ignite_stacks
	set(value):
		var end_pos: Vector2 = _get_health_bar_end_pos()
		_ignite_stacks = value
		_update_ignite(end_pos)

var _current_health: int = 1000
var current_health: int:
	get: return _current_health
	set(value):
		_current_health = value
		_update_layout()

var _max_health: int = 1000
var max_health: int:
	get: return _max_health
	set(value):
		_max_health = value
		# If max health changes during a flash, also defer
		_pending_total_max = _max_health + _armor_stacks
		_apply_max_after_flash = _apply_max_after_flash or _is_flash_active()
		_update_layout()
#endregion

# ======== Defer logic ========
var _apply_max_after_flash: bool = false
var _pending_total_max: int = -1

func _is_flash_active() -> bool:
	return (_flash_delay_timer != null and _flash_delay_timer.time_left > 0.0) \
		or (_flash_tween != null and _flash_tween.is_running())

func _apply_max_values(total_max: int) -> void:
	_health_bar.max_value = total_max
	_flash_bar.max_value = total_max
	_armor_bar.max_value = total_max
	_segments.update_segment_count(round(float(total_max) / float(_health_per_segment)))

# ============================

func _ready() -> void:
	if _show_armor: _armor_bar.show()
	if _show_poison: _poison_bar.show()
	_flash_delay_timer = Timer.new()
	_flash_delay_timer.one_shot = true
	add_child(_flash_delay_timer)
	_flash_delay_timer.timeout.connect(_on_flash_delay_timeout)
	_update_layout()


func _update_layout() -> void:
	if not is_node_ready(): return
	var end_pos: Vector2 = _get_health_bar_end_pos()
	_update_health_bar()
	_update_armor_bar()
	_update_poison_bar(end_pos)
	_update_ignite(end_pos)


func _update_poison_bar(start_pos: Vector2) -> void:
	if _poison_stacks <= 0:
		_poison_bar.hide()
		_poison_label.hide()
	else:
		_poison_bar.show()
		_poison_label.show()
		_poison_label.text = str(_poison_stacks)
	_poison_bar.size.x = (float(_poison_stacks) / _health_bar.max_value) * _health_bar.size.x * _poison_multiplier
	_poison_bar.size.y = _health_bar.size.y / _poison_vsize_divider
	_poison_bar.position = start_pos - _poison_bar.size.x * Vector2.RIGHT

func _update_armor_bar() -> void:
	if _armor_stacks <= 0:
		_armor_bar.hide()
		_armor_label.hide()
	else:
		_armor_bar.show()
		_armor_label.show()
		_armor_label.text = str(_armor_stacks)

	# Only update maxes immediately if we are NOT deferring
	if not _apply_max_after_flash:
		var total_max := _max_health + _armor_stacks
		_apply_max_values(total_max)

	# Value uses current health + armor; if deferring, ProgressBar will clamp visually until max is applied
	_armor_bar.value = _health_bar.value + _armor_stacks

	# Flash to (health + armor) but if deferring, target may exceed current max; that's OK—visual clamp now, real size later
	_schedule_flash_to(_current_health + _armor_stacks)

func _update_health_bar() -> void:
	_health_label.text = str(current_health)

	# Only update maxes immediately if we are NOT deferring
	if not _apply_max_after_flash:
		var total_max := _max_health + _armor_stacks
		_apply_max_values(total_max)

	_health_bar.value = _current_health
	_schedule_flash_to(_current_health + _armor_stacks)

func _update_ignite(start_pos: Vector2) -> void:
	if _ignite_stacks <= 0:
		_ignite_bar.hide()
		_ignite_label.hide()
	else:
		_ignite_bar.show()
		_ignite_label.show()
		_ignite_label.text = str(_ignite_stacks)
	_ignite_bar.size.x = (float(_ignite_stacks) / _health_bar.max_value) * _health_bar.size.x * _ignite_multiplier
	_ignite_bar.size.y = _health_bar.size.y / _ignite_vsize_divider
	_ignite_bar.position = start_pos - (_poison_bar.size.x + _ignite_bar.size.x) * Vector2.RIGHT

func _get_health_bar_end_pos() -> Vector2:
	var total_max: float = float(_max_health + _armor_stacks)
	var ratio: float = float(_current_health) / total_max if total_max > 0.0 else 0.0
	return _health_bar.position + ratio * _health_bar.size.x * Vector2.RIGHT

func _schedule_flash_to(target: float) -> void:
	_flash_target = target
	if _flash_tween: _flash_tween.kill()
	_flash_delay_timer.start(_flash_delay)

func _on_flash_delay_timeout() -> void:
	# Do NOT pre-apply maxes here if we're deferring
	if not _apply_max_after_flash:
		_flash_bar.max_value = max(_flash_bar.max_value, _health_bar.max_value)

	_flash_tween = get_tree().create_tween()
	_flash_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(_flash_bar, "value", _flash_target, _flash_duration)
	# When the tween finishes, finalize any deferred max updates and re-sync bars
	_flash_tween.finished.connect(_on_flash_finished, CONNECT_ONE_SHOT)

func _on_flash_finished() -> void:
	if _apply_max_after_flash and _pending_total_max >= 0:
		_apply_max_values(_pending_total_max)
		_apply_max_after_flash = false
		_pending_total_max = -1
		# After maxes change, resync values and overlays
		var end_pos: Vector2 = _get_health_bar_end_pos()
		_health_bar.value = _current_health
		_armor_bar.value = _current_health + _armor_stacks
		_update_poison_bar(end_pos)
