#extends Control
#
#
#@export var _bds_type_option: OptionButton
#@export var _ratio_slider: HSlider
#@export var _ratio_label: Label
#@export var _value_spinbox: SpinBox
#@export var _action_buttons_container: VBoxContainer
#@export var _show_percent_check: CheckButton
#@export var _show_sub_values_check: CheckButton
#@export var _action_id_line_edit: LineEdit
#@export var _scale_slider: HSlider
#@export var _scale_label: Label
#
#var _bds: BattleDataStat
#var _action_buttons: Dictionary[Utils.ActionType, Button]
#
#
##region ============================== Node base functions ==============================
#func _ready() -> void:
	#_setup_bds_type_options()
	#_update_action_buttons()
	#_ratio_slider.value_changed.connect(_on_ratio_slider_value_changed)
##endregion
#
#
#
##region ============================== BDS Type Selection ==============================
#func _setup_bds_type_options() -> void:
	#_bds_type_option.clear()
	#for type_value: int in BattleDataStat.Type.values():
		#var type: BattleDataStat.Type = type_value as BattleDataStat.Type
		#_bds_type_option.add_item(BattleDataStat.TYPE_NAMES[type], type_value)
#
#
#func _on_bds_type_option_item_selected(_index: int) -> void:
	#_update_action_buttons()
##endregion
#
#
#
##region ============================== Create & Connect ==============================
#func _on_create_connect_button_pressed() -> void:
	#var type_value: int = _bds_type_option.get_selected_id()
	#var type: BattleDataStat.Type = type_value as BattleDataStat.Type
	#var action_id: StringName = _action_id_line_edit.text if not _action_id_line_edit.text.is_empty() else "PROTO_TEST"
	#_bds = BattleDataStat.new(action_id, type)
	#_bds_viewer.connect_battle_data_stat(_bds)
	#_update_action_buttons()
##endregion
#
#
#
##region ============================== Ratio ==============================
#func _on_ratio_slider_value_changed(value: float) -> void:
	#_bds_viewer.set_ratio(value)
	#_ratio_label.text = str(value * 100.0).pad_decimals(1) + " %"
##endregion
#
#
#
##region ============================== Action Type Buttons ==============================
#func _update_action_buttons() -> void:
	#for child in _action_buttons_container.get_children():
		#child.queue_free()
	#_action_buttons.clear()
#
	#var type_value: int = _bds_type_option.get_selected_id()
	#var type: BattleDataStat.Type = type_value as BattleDataStat.Type
	#var action_types: Array[Utils.ActionType] = BattleDataStat.battle_data_stat_type_to_action_types(type)
#
	#for action_type: Utils.ActionType in action_types:
		#var btn := Button.new()
		#btn.text = "ADD " + Utils.ActionType.keys()[action_type]
		#btn.pressed.connect(_on_action_button_pressed.bind(action_type))
		#_action_buttons_container.add_child(btn)
		#_action_buttons[action_type] = btn
#
#
#func _on_action_button_pressed(action_type: Utils.ActionType) -> void:
	#if _bds == null:
		#push_warning("PrototypingBattleDataStatViewer: No BDS created yet")
		#return
	#_bds.register_action(action_type, _value_spinbox.value)
##endregion
#
#
#
##region ============================== Display Options ==============================
#func _on_show_percent_check_toggled(toggled_on: bool) -> void:
	#_bds_viewer.set_show_percent(toggled_on)
#
#
#func _on_show_sub_values_check_toggled(toggled_on: bool) -> void:
	#_bds_viewer.set_show_sub_values(toggled_on)
#
#
#func _on_scale_slider_value_changed(value: float) -> void:
	#_bds_viewer.scale = Vector2(value, value)
	#_scale_label.text = str(value).pad_decimals(1) + "x"
##endregion
