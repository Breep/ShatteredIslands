class_name UIBattleDataStatsPanel
extends Control

#region ============================== Configuration ==============================
const UI_BATTLE_DATA_STAT_VIEWER_SCENE: PackedScene = preload("res://GlobalManagers/ActionMeter/Viewer/ui_battle_data_stat_viewer.tscn")

var _battle_data_stat_type: BattleDataStat.Type
@export var battle_data_stat_type: BattleDataStat.Type:
	get: return _battle_data_stat_type
	set(value):
		_battle_data_stat_type = value
		if is_node_ready():
			_action_type_label.text = BattleDataStat.TYPE_NAMES[_battle_data_stat_type]
#endregion



#region ============================== Private variables ==============================
var _total_value: float
var _battle_data_stat_viewers: Array[UIBattleDataStatViewer]
#endregion



#region ============================== Local Nodes ==============================
@onready var _bds_viewers_container: VBoxContainer = %BDSViewersContainer 
@onready var _action_type_label: Label = %ActionTypeLabel
#endregion



#region ============================== Public function ==============================
func add_battle_data_stat(battle_data_stat: BattleDataStat) -> void:
	var bds_viewer: UIBattleDataStatViewer = UI_BATTLE_DATA_STAT_VIEWER_SCENE.instantiate()
	bds_viewer.init(battle_data_stat)
	_bds_viewers_container.add_child(bds_viewer)
	_battle_data_stat_viewers.append(bds_viewer)
	bds_viewer.total_value_changed.connect(_on_battle_data_stat_viewer_total_value_changed)
	_sort_bds_viewers.call_deferred()
	_scale_bds_viewers.call_deferred()


func clear() -> void:
	for viewer: UIBattleDataStatViewer in _battle_data_stat_viewers:
		viewer.queue_free()
	_battle_data_stat_viewers.clear()
	_total_value = 0.0
#endregion



#region ============================== Node base functions ==============================
func _ready() -> void:
	for child in _bds_viewers_container.get_children():
		child.queue_free()
	_action_type_label.text = BattleDataStat.TYPE_NAMES[_battle_data_stat_type]
#endregion



#region ============================== Private functions ==============================
func _sort_bds_viewers() -> void:
	if not is_node_ready(): return
	_total_value = 0
	_battle_data_stat_viewers.sort_custom(UIBattleDataStatViewer.compare)
	for i: int in _battle_data_stat_viewers.size():
		var bdsv: UIBattleDataStatViewer = _battle_data_stat_viewers[i]
		_total_value += bdsv.total_value
		_bds_viewers_container.move_child.call_deferred(bdsv, i)


func _scale_bds_viewers() -> void:
	if not is_node_ready(): return
	for bdsv: UIBattleDataStatViewer in _bds_viewers_container.get_children():
		bdsv.set_ratio(bdsv.total_value / _total_value)
#endregion



#region ============================== Callbacks ==============================
func _on_battle_data_stat_viewer_total_value_changed(_value: float) -> void:
	_sort_bds_viewers()
	_scale_bds_viewers()
#endregion














 
