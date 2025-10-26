@tool

class_name UIHealthBar
extends Control

var _mirrored: bool
@export var mirrored: bool:
	get: return _mirrored
	set(value):
		_mirrored = value
		_mirror_ui(_mirrored)

#region Segment configuration
@export_group("Segment configuration")
@export var _health_per_segment: int = 250
#endregion

#region Local Nodes
#region ProgressBars
@onready var _progress_bar_viewport_texture: TextureRect = %ProgressBarViewportTexture
@onready var _health_bar: FlexibleProgressBar = %HealthBar
@onready var _armor_bar: FlexibleProgressBar = %ArmorBar
@onready var _poison_bar: ColorRect = %PoisonBar
@onready var _ignite_bar: ColorRect = %IgniteBar
@onready var _segments: FlexibleProgressBar = %Segments
#endregion

#region Labels
@onready var _labels_h_box: HBoxContainer = %LabelsHBox
@onready var _debuf_control: Control = %DebufControl
@onready var _buf_control: Control = %BufControl
@onready var _debuf_h_box: HBoxContainer = %DebufHBox
@onready var _ignite_label: Label = %IgniteLabel
@onready var _poison_label: Label = %PoisonLabel
@onready var _health_label: Label = %HealthLabel
@onready var _armor_label: Label = %ArmorLabel
#endregion

@export var _ignite_multiplier: float = 1.0
@export var _ignite_vsize_divider: float = 1.0

@export var _poison_multiplier: float = 1.0
@export var _poison_vsize_divider: float = 1.0

#region End bars positioner
@onready var _health_bar_end_positioner: Control = %HealthBarEndPositioner
@onready var _armor_bar_end_positioner: Control = %ArmorBarEndPositioner
#endregion
#endregion

#region HealthBar variables
var _poison_stacks: int = 0
var poison_stacks: int:
	get: return _poison_stacks
	set(value):
		_poison_stacks = max(0, value)
		_update_poison()

var _armor_stacks: int = 0
var armor_stacks: int:
	get: return _armor_stacks
	set(value):
		_armor_stacks = max(0, value)
		_update_armor()
		_update_armor_bar_end_pos()

var _ignite_stacks: int = 0
var ignite_stacks: int:
	get: return _ignite_stacks
	set(value):
		_ignite_stacks = max(0, value)
		_update_ignite()

var _current_health: int = 1000
var current_health: int:
	get: return _current_health
	set(value):
		_current_health = max(0, value)
		_update_health_bar_end_pos()
		_update_health()
		_update_poison()

var _max_health: int = 1000
var max_health: int:
	get: return _max_health
	set(value):
		_max_health = max(1, value)
		_update_layout()
#endregion

# ============================== Node base functions ==============================

func _ready() -> void:
	_mirror_ui(mirrored)
	if not Engine.is_editor_hint():
		_make_unique()
		_update_layout()

# ============================== Public functions ==============================

func get_armor_popup_global_pos() -> Vector2:
	return _armor_bar_end_positioner.global_position

func get_health_popup_global_position() -> Vector2:
	return _health_bar_end_positioner.global_position

# ============================== Private functions ==============================

func _mirror_ui(is_mirrored: bool) -> void:
	if not is_node_ready(): return
	if is_mirrored:
		_progress_bar_viewport_texture.flip_h = true
		_labels_h_box.move_child(_buf_control, 0)
		_labels_h_box.move_child(_debuf_control, -1)
		_debuf_h_box.move_child(_ignite_label, 0)
		_debuf_h_box.move_child(_poison_label, -1)
	else:
		_progress_bar_viewport_texture.flip_h = false
		_labels_h_box.move_child(_buf_control, -1)
		_labels_h_box.move_child(_debuf_control, 0)
		_debuf_h_box.move_child(_ignite_label, -1)
		_debuf_h_box.move_child(_poison_label, 0)


func _make_unique() -> void:
	if _health_bar.material != null: _health_bar.material = _health_bar.material.duplicate(true)
	if _armor_bar.material != null: _armor_bar.material = _armor_bar.material.duplicate(true)
	if _poison_bar.material != null: _poison_bar.material = _poison_bar.material.duplicate(true)
	if _ignite_bar.material != null: _ignite_bar.material = _ignite_bar.material.duplicate(true)
	if _segments.material != null: _segments.material = _segments.material.duplicate(true)


func _update_layout() -> void:
	if not is_node_ready(): return
	_update_armor_bar_end_pos()
	_update_health_bar_end_pos()
	_health_bar.set_max_value(_max_health)
	_armor_bar.set_max_value(_max_health)
	_update_health()
	_update_armor()
	_update_poison()
	_update_ignite()
	
	_segments.update_segment_count(round(float(_max_health) / float(_health_per_segment)))


func _update_poison() -> void:
	if _poison_stacks <= 0:
		_poison_bar.hide()
		_poison_label.hide()
	else:
		_poison_bar.show()
		_poison_label.show()
		_poison_label.text = str(_poison_stacks)
	_poison_bar.size.x = (float(_poison_stacks) / _health_bar.max_value) * _health_bar.size.x * _poison_multiplier
	_poison_bar.size.y = _health_bar.size.y / _poison_vsize_divider
	var ratio: float = float(_current_health) / float(_max_health)
	var end_pos: Vector2 = _health_bar.position + ratio * _health_bar.size.x * Vector2.RIGHT
	_poison_bar.position = end_pos - _poison_bar.size.x * Vector2.RIGHT


func _update_armor() -> void:
	if _armor_stacks <= 0:
		_armor_bar.hide()
		_armor_label.hide()
	else:
		_armor_bar.show()
		_armor_label.show()
		_armor_label.text = str(_armor_stacks)
	_armor_bar.set_bar_value(_armor_stacks)


func _update_health() -> void:
	_health_label.text = str(current_health)
	_health_bar.set_bar_value(_current_health)


func _update_ignite() -> void:
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


func _update_health_bar_end_pos() -> void:
	var ratio: float = float(_current_health) / float(_max_health)
	if _mirrored:
		_health_bar_end_positioner.position = _progress_bar_viewport_texture.position + (1.0 - ratio) * _progress_bar_viewport_texture.size.x * Vector2.RIGHT
	else:
		_health_bar_end_positioner.position = _progress_bar_viewport_texture.position + ratio * _progress_bar_viewport_texture.size.x * Vector2.RIGHT


func _update_armor_bar_end_pos() -> void:
	var ratio: float = 1.0
	if _armor_stacks < _max_health:
		ratio = float(_armor_stacks) / float(_max_health)
	if _mirrored:
		_armor_bar_end_positioner.position = _progress_bar_viewport_texture.position + (1.0 - ratio) * _progress_bar_viewport_texture.size.x * Vector2.RIGHT
	else:
		_armor_bar_end_positioner.position = _progress_bar_viewport_texture.position + ratio * _progress_bar_viewport_texture.size.x * Vector2.RIGHT



 
