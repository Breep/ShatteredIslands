class_name EntityStatsWriter
extends EntityStatsViewer

## Variante éditable de [EntityStatsViewer] : même affichage, mais un clic sur une
## ligne ouvre un mini-éditeur qui injecte un StatModifier en direct sur l'entité
## ciblée (outil de debug / équilibrage in-game).

#region ============================== Private variables ==============================
var _edit_popup: PanelContainer
var _stat_label: Label
var _value_spin: SpinBox
var _calc_option: OptionButton
var _editing_stat_type: EntityStats.StatType
var _next_modifier_id: int = 0
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	super._ready()
	_build_edit_popup()
	for i: int in _list.item_count:
		_list.set_item_selectable(i, true)
	_list.item_clicked.connect(_on_item_clicked)
#endregion

#region ============================== Private functions ==============================
func _build_edit_popup() -> void:
	_edit_popup = PanelContainer.new()
	_edit_popup.hide()
	_edit_popup.mouse_filter = Control.MOUSE_FILTER_STOP

	var vbox := VBoxContainer.new()
	_edit_popup.add_child(vbox)

	_stat_label = Label.new()
	vbox.add_child(_stat_label)

	var value_row := HBoxContainer.new()
	vbox.add_child(value_row)
	var value_caption := Label.new()
	value_caption.text = "Valeur"
	value_row.add_child(value_caption)
	_value_spin = SpinBox.new()
	_value_spin.min_value = -100000.0
	_value_spin.max_value = 100000.0
	_value_spin.step = 0.1
	_value_spin.allow_greater = true
	_value_spin.allow_lesser = true
	value_row.add_child(_value_spin)

	_calc_option = OptionButton.new()
	_calc_option.add_item("ADD", StatModifier.CalcType.ADD)
	_calc_option.add_item("MULT", StatModifier.CalcType.MULT)
	_calc_option.select(0)
	vbox.add_child(_calc_option)

	var button_row := HBoxContainer.new()
	vbox.add_child(button_row)
	var apply_button := Button.new()
	apply_button.text = "Appliquer"
	apply_button.pressed.connect(_on_apply_pressed)
	button_row.add_child(apply_button)
	var close_button := Button.new()
	close_button.text = "Fermer"
	close_button.pressed.connect(_close_edit_popup)
	button_row.add_child(close_button)

	# Le popup vit sous le CanvasLayer (parent de MainControl), pas sous le PanelContainer :
	# sinon ce dernier l'intégrerait à son layout et sa taille redeviendrait variable.
	_main.get_parent().add_child(_edit_popup)


func _close_edit_popup() -> void:
	if _edit_popup != null:
		_edit_popup.hide()


func _unbind() -> void:
	super._unbind()
	_close_edit_popup()
#endregion

#region ============================== Callbacks ==============================
func _on_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if not is_instance_valid(_entity): return
	if index < 0 or index >= _STATS.size(): return
	_editing_stat_type = _STATS.keys()[index]
	_stat_label.text = _STATS[_editing_stat_type]["name"]
	_value_spin.value = 0.0
	_edit_popup.position = _main.position + Vector2(_main.size.x + 8.0, 0.0)
	_edit_popup.show()


func _on_apply_pressed() -> void:
	if not is_instance_valid(_entity): return
	if _entity.stat_modifiers_registry == null: return
	var modifier := StatModifier.new()
	modifier.stat_type = _editing_stat_type
	modifier.value = _value_spin.value
	modifier.calc_type = _calc_option.get_selected_id()
	modifier.id = &"writer_%d" % _next_modifier_id
	_next_modifier_id += 1
	_entity.stat_modifiers_registry.register_modifier(modifier)
#endregion
