class_name UIBattleDataStatViewer
extends Control

signal total_value_changed(value: float)

var _total_value: float
@export var total_value: float:
	get: return _total_value


@onready var _meters_control: Control = %Meters
@onready var _empty_control: Control = %Empty
@onready var _bar_stats_container: HBoxContainer = %BarStatsContainer
@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel
@onready var _value_label: Label = %ValueLabel
@onready var _percent_label: Label = %PercentLabel

var _bsd_color_rects: Dictionary[Utils.ActionType, ColorRect]
var _bsd_value_labels: Dictionary[Utils.ActionType, Label]
var _battle_data_stat: BattleDataStat
var _show_percent: bool = true
var _show_sub_values: bool = false
var _is_hovered: bool = false

#region ============================== Public function ==============================
func set_ratio(ratio: float) -> void:
	if not is_node_ready(): return
	if ratio == 0:
		_empty_control.hide()
		return
	else:
		_empty_control.show()
	_meters_control.size_flags_stretch_ratio = ratio
	_empty_control.size_flags_stretch_ratio = 1.0 - ratio
	_percent_label.text = str(ratio * 100.0).pad_decimals(2) + " %"


func set_show_percent(value: bool) -> void:
	_show_percent = value
	if is_node_ready():
		_percent_label.visible = _show_percent


func set_show_sub_values(value: bool) -> void:
	_show_sub_values = value
	_update_sub_values_visibility()


func connect_battle_data_stat(battle_data_stats: BattleDataStat) -> void:
	if _battle_data_stat != null:
		_disconnect_signals()
	_battle_data_stat = battle_data_stats
	_connect_signals()
	_reset_layout()
	_update_layout()


func init(battle_data_stats: BattleDataStat) -> void:
	_battle_data_stat = battle_data_stats
#endregion



#region ============================== Node base functions ==============================
func _ready() -> void:
	_percent_label.visible = _show_percent
	if _battle_data_stat != null:
		_connect_signals()
		_reset_layout()
		_update_layout()
#endregion



#region ============================== Private functions ==============================
func _connect_signals() -> void:
	if not _battle_data_stat.stat_changed.is_connected(_on_battle_data_stat_stat_changed):
		_battle_data_stat.stat_changed.connect(_on_battle_data_stat_stat_changed)


func _disconnect_signals() -> void:
	if _battle_data_stat.stat_changed.is_connected(_on_battle_data_stat_stat_changed):
		_battle_data_stat.stat_changed.disconnect(_on_battle_data_stat_stat_changed)


func _reset_layout() -> void:
	var action_meters: Dictionary[Utils.ActionType, float] = _battle_data_stat.action_meters
	for child in _bar_stats_container.get_children():
		child.queue_free()
	_bsd_color_rects.clear()
	_bsd_value_labels.clear()
	_name_label.text = _battle_data_stat.id
	for action_type: Utils.ActionType in action_meters.keys():
		var color_rect := ColorRect.new()
		color_rect.color = BattleDataStat.ACTION_COLORS[action_type]
		color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bar_stats_container.add_child(color_rect)
		_bsd_color_rects[action_type] = color_rect

		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		value_label.set_anchors_preset(Control.PRESET_CENTER)
		value_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
		value_label.grow_vertical = Control.GROW_DIRECTION_BOTH
		value_label.add_theme_font_size_override("font_size", 12)
		value_label.add_theme_constant_override("outline_size", 5)
		value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		value_label.visible = _show_sub_values
		color_rect.add_child(value_label)
		_bsd_value_labels[action_type] = value_label


func _update_layout() -> void:
	var action_meters: Dictionary[Utils.ActionType, float] = _battle_data_stat.action_meters
	_total_value = 0
	for action_type: Utils.ActionType in action_meters.keys():
		var value = action_meters[action_type]
		_total_value += value
		if value == 0:
			_bsd_color_rects[action_type].hide()
		else:
			_bsd_color_rects[action_type].show()
		_bsd_color_rects[action_type].size_flags_stretch_ratio = value / _total_value
		_bsd_value_labels[action_type].text = str(value).pad_decimals(0)
	_value_label.text = str(_total_value).pad_decimals(0)
	total_value_changed.emit(_total_value)


func _update_sub_values_visibility() -> void:
	var should_show: bool = _show_sub_values or _is_hovered
	for label: Label in _bsd_value_labels.values():
		label.visible = should_show
#endregion



#region ============================== Callbacks ==============================
func _on_mouse_entered() -> void:
	_is_hovered = true
	_update_sub_values_visibility()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_sub_values_visibility()


func _on_battle_data_stat_stat_changed(_action_type: Utils.ActionType, _value: float) -> void:
	_update_layout()
#endregion



#region ============================== Static functions ==============================
static func compare(a: UIBattleDataStatViewer, b: UIBattleDataStatViewer) -> bool:
	return a.total_value > b.total_value
#endregion









 
