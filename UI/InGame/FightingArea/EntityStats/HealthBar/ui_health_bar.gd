class_name UIHealthBar
extends Control


#region Segment configuration
@export_group("Segment configuration")
@export var _health_per_segment: int = 250
#endregion

#region Local Nodes
@onready var _segments: FlexibleProgressBar = %Segments

@onready var _health_bar: FlexibleProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel

@onready var _armor_bar: FlexibleProgressBar = %ArmorBar
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

@onready var _health_bar_end_positioner: Control = %HealthBarEndPositioner
@onready var _armor_bar_end_positioner: Control = %ArmorBarEndPositioner
#endregion

#region HealthBar variables
var _poison_stacks: int = 0
var poison_stacks: int:
	get: return _poison_stacks
	set(value):
		var end_pos: Vector2 = _get_health_bar_end_pos()
		_poison_stacks = max(0, value)
		_update_poison(end_pos)

var _old_armor_stacks: int = 0
var _armor_stacks: int = 0
var armor_stacks: int:
	get: return _armor_stacks
	set(value):
		_armor_stacks = max(0, value)
		_update_armor()
		_get_armor_bar_end_pos() # Update _armor_end_bar_pos

var _ignite_stacks: int = 0
var ignite_stacks: int:
	get: return _ignite_stacks
	set(value):
		var end_pos: Vector2 = _get_health_bar_end_pos()
		_ignite_stacks = max(0, value)
		_update_ignite(end_pos)

var _old_current_health: int = 0
var _current_health: int = 1000
var current_health: int:
	get: return _current_health
	set(value):
		_current_health = max(0, value)
		_update_health()
		_update_poison(_get_health_bar_end_pos())

var _max_health: int = 1000
var max_health: int:
	get: return _max_health
	set(value):
		_max_health = max(1, value)
		_update_layout()
#endregion

# ============================

func _ready() -> void:
	_update_layout()


func get_damage_popup_global_position(damage_type: Utils.DamageType) -> Vector2:
	if damage_type == Utils.DamageType.POISON or damage_type == Utils.DamageType.HEAL:
		return _health_bar_end_positioner.global_position
	else:
		if _armor_stacks > 0:
			return _armor_bar_end_positioner.global_position
		else:
			return _health_bar_end_positioner.global_position


func _update_layout() -> void:
	if not is_node_ready(): return
	_health_bar.set_max_value(_max_health)
	_armor_bar.set_max_value(_max_health)
	_update_health()
	_update_armor()
	_update_poison(_get_health_bar_end_pos())
	if _armor_stacks > 0:
		_update_ignite(_get_armor_bar_end_pos())
	else:
		_update_ignite(_get_health_bar_end_pos())
	
	_segments.update_segment_count(round(float(_max_health) / float(_health_per_segment)))


func _update_poison(end_pos: Vector2) -> void:
	if _poison_stacks <= 0:
		_poison_bar.hide()
		_poison_label.hide()
	else:
		_poison_bar.show()
		_poison_label.show()
		_poison_label.text = str(_poison_stacks)
	_poison_bar.size.x = (float(_poison_stacks) / _health_bar.max_value) * _health_bar.size.x * _poison_multiplier
	_poison_bar.size.y = _health_bar.size.y / _poison_vsize_divider
	_poison_bar.position = end_pos - _poison_bar.size.x * Vector2.RIGHT


func _update_armor() -> void:
	if _armor_stacks <= 0:
		_armor_bar.hide()
		_armor_label.hide()
	else:
		_armor_bar.show()
		_armor_label.show()
		_armor_label.text = str(_armor_stacks)
	_armor_bar.increase_bar_value(_armor_stacks - _old_armor_stacks)
	_old_armor_stacks = _armor_stacks


func _update_health() -> void:
	_health_label.text = str(current_health)
	_health_bar.increase_bar_value(_current_health - _old_current_health)
	_old_current_health = _current_health


func _update_ignite(_end_pos: Vector2) -> void:
	if _ignite_stacks <= 0:
		#_ignite_bar.hide()
		_ignite_label.hide()
	else:
		#_ignite_bar.show()
		_ignite_label.show()
		_ignite_label.text = str(_ignite_stacks)
	#_ignite_bar.size.x = (float(_ignite_stacks) / _health_bar.max_value) * _health_bar.size.x * _ignite_multiplier
	#_ignite_bar.size.y = _health_bar.size.y / _ignite_vsize_divider
	#_ignite_bar.position = end_pos - (_poison_bar.size.x + _ignite_bar.size.x) * Vector2.RIGHT


func _get_health_bar_end_pos() -> Vector2:
	var ratio: float = float(_current_health) / float(_max_health)
	_health_bar_end_positioner.position = _health_bar.position + ratio * _health_bar.size.x * Vector2.RIGHT
	return _health_bar_end_positioner.position


func _get_armor_bar_end_pos() -> Vector2:
	var ratio: float = 1.0
	if _armor_stacks < _max_health:
		ratio = float(_armor_stacks) / float(_max_health)
	_armor_bar_end_positioner.position = _armor_bar.position + ratio * _armor_bar.size.x * Vector2.RIGHT
	return _armor_bar_end_positioner.position




 
