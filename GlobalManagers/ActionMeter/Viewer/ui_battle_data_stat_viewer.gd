class_name UIBattleDataStatViewer
extends Control

signal total_value_changed(value: float)
var _total_value: float
@export var total_value: float:
	get: return _total_value

var _battle_data_stat: BattleDataStat

# For stretching (Bars - Empty)
@onready var _meters_control: Control = %Meters
@onready var _empty_control: Control = %Empty

@onready var _value_label: Label = %ValueLabel
@onready var _percent_label: Label = %PercentLabel
@onready var _floating_label: Label = %FloatingLabel

@onready var _bar_stats_container: HBoxContainer = %BarStatsContainer
var _bsd_color_rects: Dictionary[Utils.ActionType, ColorRect]

#region ============================== Public function ==============================
func set_ratio(ratio: float) -> void:
	if not is_node_ready(): return
	_meters_control.size_flags_stretch_ratio = ratio
	_empty_control.size_flags_stretch_ratio = 1.0 - ratio
	_percent_label.text = str(ratio * 100.0).pad_decimals(2) + " %"


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
	_floating_label.hide()
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
	for action_type: Utils.ActionType in action_meters.keys():
		_bsd_color_rects[action_type] = ColorRect.new()
		_bsd_color_rects[action_type].color = BattleDataStat.ACTION_COLORS[action_type]
		_bsd_color_rects[action_type].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_bsd_color_rects[action_type].mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bar_stats_container.add_child(_bsd_color_rects[action_type])
	_floating_label.text = _battle_data_stat.id


func _update_layout() -> void:
	var action_meters: Dictionary[Utils.ActionType, float] = _battle_data_stat.action_meters
	_total_value = 0
	for value: float in action_meters.values():
		_total_value += value
	if _total_value <= 0: return
	for action_type: Utils.ActionType in action_meters.keys():
		_bsd_color_rects[action_type].size_flags_stretch_ratio = action_meters[action_type] / _total_value
	_value_label.text = str(_total_value).pad_decimals(0)
	total_value_changed.emit(_total_value)
#endregion



#region ============================== Callbacks ==============================
func _on_mouse_entered() -> void:
	_floating_label.show()


func _on_mouse_exited() -> void:
	_floating_label.hide()


func _on_battle_data_stat_stat_changed(_action_type: Utils.ActionType, _value: float) -> void:
	_update_layout()
#endregion



#region ============================== Static functions ==============================
static func compare(a: UIBattleDataStatViewer, b: UIBattleDataStatViewer) -> bool:
	return a.total_value > b.total_value
#endregion









 
