extends HBoxContainer

signal bds_type_changed(new_bsd_type: BattleDataStat.Type)

@onready var _damage_done_button: Button = %DamageDoneButton
@onready var _damage_received_button: Button = %DamageReceivedButton
@onready var _heal_done_button: Button = %HealDoneButton
@onready var _heal_received_button: Button = %HealReceivedButton
@onready var _misc_done_button: Button = %MiscDoneButton
@onready var _misc_received_button: Button = %MiscReceivedButton

var _button_to_type: Dictionary[Button, BattleDataStat.Type]
var _current_button: Button


#region ============================== Node base functions ==============================
func _ready() -> void:
	_button_to_type = {
		_damage_done_button: BattleDataStat.Type.DAMAGE_DONE,
		_damage_received_button: BattleDataStat.Type.DAMAGE_RECEIVED,
		_heal_done_button: BattleDataStat.Type.HEAL_DONE,
		_heal_received_button: BattleDataStat.Type.HEAL_RECEIVED,
		_misc_done_button: BattleDataStat.Type.STACK_INFLICTED,
		_misc_received_button: BattleDataStat.Type.STACK_RECEIVED,
	}
	for button: Button in _button_to_type:
		button.pressed.connect(_on_tab_button_pressed.bind(button))
	_select_button(_damage_done_button)
#endregion



#region ============================== Private functions ==============================
func _select_button(button: Button) -> void:
	if _current_button == button: return
	if _current_button != null:
		_current_button.button_pressed = false
	_current_button = button
	_current_button.button_pressed = true
	bds_type_changed.emit(_button_to_type[button])
#endregion



#region ============================== Callbacks ==============================
func _on_tab_button_pressed(button: Button) -> void:
	if button == _current_button:
		button.button_pressed = true
		return
	_select_button(button)
#endregion
