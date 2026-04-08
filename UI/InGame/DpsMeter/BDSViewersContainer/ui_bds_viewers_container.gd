class_name UIBDSViewersContainer
extends VBoxContainer

const UI_BATTLE_DATA_STAT_VIEWER_SCENE: PackedScene = preload("res://UI/InGame/DpsMeter/BattleDataStatViewer/ui_battle_data_stat_viewer.tscn")


#region ============================== Private variables ==============================
var _total_value: float
var _battle_data_stat_viewers: Array[UIBattleDataStatViewer]
var _show_percent: bool = true
var _show_sub_values: bool = false
#endregion



#region ============================== Public functions ==============================
func add_battle_data_stat(battle_data_stat: BattleDataStat) -> void:
	var bds_viewer: UIBattleDataStatViewer = UI_BATTLE_DATA_STAT_VIEWER_SCENE.instantiate()
	bds_viewer.init(battle_data_stat)
	bds_viewer.set_show_percent(_show_percent)
	bds_viewer.set_show_sub_values(_show_sub_values)
	add_child(bds_viewer)
	_battle_data_stat_viewers.append(bds_viewer)
	bds_viewer.total_value_changed.connect(_on_battle_data_stat_viewer_total_value_changed)
	_sort_bds_viewers.call_deferred()
	_scale_bds_viewers.call_deferred()


func clear() -> void:
	for viewer: UIBattleDataStatViewer in _battle_data_stat_viewers:
		viewer.queue_free()
	_battle_data_stat_viewers.clear()
	_total_value = 0.0


func set_show_percent(value: bool) -> void:
	_show_percent = value
	for viewer: UIBattleDataStatViewer in _battle_data_stat_viewers:
		viewer.set_show_percent(value)


func set_show_sub_values(value: bool) -> void:
	_show_sub_values = value
	for viewer: UIBattleDataStatViewer in _battle_data_stat_viewers:
		viewer.set_show_sub_values(value)
#endregion



#region ============================== Private functions ==============================
func _sort_bds_viewers() -> void:
	if not is_node_ready(): return
	_total_value = 0
	_battle_data_stat_viewers.sort_custom(UIBattleDataStatViewer.compare)
	for i: int in _battle_data_stat_viewers.size():
		var bdsv: UIBattleDataStatViewer = _battle_data_stat_viewers[i]
		_total_value += bdsv.total_value
		move_child.call_deferred(bdsv, i)


func _scale_bds_viewers() -> void:
	if not is_node_ready(): return
	if _total_value <= 0: return
	for bdsv: UIBattleDataStatViewer in _battle_data_stat_viewers:
		bdsv.set_ratio(bdsv.total_value / _total_value)
#endregion



#region ============================== Callbacks ==============================
func _on_battle_data_stat_viewer_total_value_changed(_value: float) -> void:
	_sort_bds_viewers()
	_scale_bds_viewers()
#endregion
