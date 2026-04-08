extends Control

@export var _bds_container: UIBDSViewersContainer
@export var _bds_type_option: OptionButton
@export var _bds_selector: OptionButton
@export var _value_spinbox: SpinBox
@export var _action_buttons_container: VBoxContainer
@export var _show_percent_check: CheckButton
@export var _show_sub_values_check: CheckButton
@export var _scale_slider: HSlider
@export var _scale_label: Label

var _bds_list: Array[BattleDataStat]
var _bds_count: int = 0


#region ============================== Node base functions ==============================
func _ready() -> void:
	_setup_bds_type_options()
	_update_action_buttons()
#endregion



#region ============================== BDS Type Selection ==============================
func _setup_bds_type_options() -> void:
	_bds_type_option.clear()
	for type_value: int in BattleDataStat.Type.values():
		var type: BattleDataStat.Type = type_value as BattleDataStat.Type
		_bds_type_option.add_item(BattleDataStat.TYPE_NAMES[type], type_value)
#endregion



#region ============================== Add BDS ==============================
func _on_add_bds_button_pressed() -> void:
	var type_value: int = _bds_type_option.get_selected_id()
	var type: BattleDataStat.Type = type_value as BattleDataStat.Type
	var action_id: StringName = "BDS_" + str(_bds_count)
	_bds_count += 1
	var bds := BattleDataStat.new(action_id, type)
	_bds_list.append(bds)
	_bds_container.add_battle_data_stat(bds)
	_bds_selector.add_item(action_id + " (" + BattleDataStat.TYPE_NAMES[type] + ")")
	_bds_selector.selected = _bds_selector.item_count - 1
	_update_action_buttons()
#endregion



#region ============================== BDS Selector ==============================
func _on_bds_selector_item_selected(_index: int) -> void:
	_update_action_buttons()


func _get_selected_bds() -> BattleDataStat:
	var idx: int = _bds_selector.selected
	if idx < 0 or idx >= _bds_list.size():
		return null
	return _bds_list[idx]
#endregion



#region ============================== Action Type Buttons ==============================
func _update_action_buttons() -> void:
	for child in _action_buttons_container.get_children():
		child.queue_free()

	var bds: BattleDataStat = _get_selected_bds()
	if bds == null: return

	var action_types: Array[Utils.ActionType] = BattleDataStat.battle_data_stat_type_to_action_types(bds.type)
	for action_type: Utils.ActionType in action_types:
		var btn := Button.new()
		btn.text = "ADD " + Utils.ActionType.keys()[action_type]
		btn.pressed.connect(_on_action_button_pressed.bind(action_type))
		_action_buttons_container.add_child(btn)


func _on_action_button_pressed(action_type: Utils.ActionType) -> void:
	var bds: BattleDataStat = _get_selected_bds()
	if bds == null:
		push_warning("PrototypingBDSViewersContainer: No BDS selected")
		return
	bds.register_action(action_type, _value_spinbox.value)
#endregion



#region ============================== Random Value ==============================
func _on_add_random_value_button_pressed() -> void:
	if _bds_list.is_empty(): return
	var bds: BattleDataStat = _bds_list.pick_random()
	var action_types: Array[Utils.ActionType] = BattleDataStat.battle_data_stat_type_to_action_types(bds.type)
	if action_types.is_empty(): return
	var action_type: Utils.ActionType = action_types.pick_random()
	bds.register_action(action_type, randf_range(_value_spinbox.value * 0.5, _value_spinbox.value * 1.5))
#endregion



#region ============================== Display Options ==============================
func _on_show_percent_check_toggled(toggled_on: bool) -> void:
	_bds_container.set_show_percent(toggled_on)


func _on_show_sub_values_check_toggled(toggled_on: bool) -> void:
	_bds_container.set_show_sub_values(toggled_on)


func _on_scale_slider_value_changed(value: float) -> void:
	_bds_container.scale = Vector2(value, value)
	_scale_label.text = str(value).pad_decimals(1) + "x"
#endregion



#region ============================== Reset ==============================
func _on_reset_button_pressed() -> void:
	_bds_container.clear()
	_bds_list.clear()
	_bds_count = 0
	_bds_selector.clear()
	_update_action_buttons()
#endregion
