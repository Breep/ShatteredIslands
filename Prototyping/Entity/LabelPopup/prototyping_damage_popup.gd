extends Node3D

@export_group("3D")
@export var _chicken: ChickenBasic
@export var _center_point_camera: CenterPointCamera
@export var _center_point: Node3D
@export var _damage_popup_spawn: Marker3D

@export_group("UI")
@export var _crit_chance_spinbox: SpinBox
@export var _min_value_spinbox: SpinBox
@export var _max_value_spinbox: SpinBox
@export var _loop_count_spinbox: SpinBox
@export var _blocked_by_armor_toggle: CheckButton
@export var _rot_toggle: CheckButton
@export var _rot_speed_spinbox: SpinBox
@export var _translate_toggle: CheckButton
@export var _speed_spinbox: SpinBox
@export var _amplitude_spinbox: SpinBox

var _translate_time: float = 0.0


func _ready() -> void:
	_center_point_camera.set_active()
	_chicken._health_bar.hide()
	_chicken._label_popup_module.queue_free()


func _process(delta: float) -> void:
	if _rot_toggle.button_pressed:
		_center_point.rotation_degrees.y += _rot_speed_spinbox.value * delta

	if _translate_toggle.button_pressed:
		_translate_time += delta
		_damage_popup_spawn.position.x = sin(_translate_time * _speed_spinbox.value) * _amplitude_spinbox.value


# ============================== Helpers ==============================

func _get_damage_value() -> float:
	return randf_range(_min_value_spinbox.value, _max_value_spinbox.value)


func _is_critical() -> bool:
	return randf() * 100.0 < _crit_chance_spinbox.value


func _is_blocked_by_armor() -> bool:
	return _blocked_by_armor_toggle.button_pressed


func _emit_damage(damage_type: Utils.ActionType) -> void:
	for i in int(_loop_count_spinbox.value):
		_chicken.damage_taken.emit(_get_damage_value(), damage_type, _is_critical(), _is_blocked_by_armor())


func _emit_stacks(stack_type: Alteration.Type) -> void:
	for i in int(_loop_count_spinbox.value):
		_chicken.stack_taken.emit(stack_type, _get_damage_value(), _is_critical())

# ============================== Dégâts ==============================

func _on_btn_physical_pressed() -> void:
	_emit_damage(Utils.ActionType.DAMAGE_PHYSICAL)


func _on_btn_magical_pressed() -> void:
	_emit_damage(Utils.ActionType.DAMAGE_MAGICAL)


func _on_btn_poison_dmg_pressed() -> void:
	_emit_damage(Utils.ActionType.DAMAGE_POISON)


func _on_btn_pure_pressed() -> void:
	_emit_damage(Utils.ActionType.DAMAGE_PURE)


# ============================== Soins ==============================

func _on_btn_heal_pressed() -> void:
	for i in int(_loop_count_spinbox.value):
		_chicken.heal_taken.emit(_get_damage_value(), _is_critical())


# ============================== Stacks ==============================

func _on_btn_stack_poison_pressed() -> void:
	_emit_stacks(Alteration.Type.POISON)


func _on_btn_stack_ignite_pressed() -> void:
	_emit_stacks(Alteration.Type.IGNITE)


func _on_btn_stack_necrosis_pressed() -> void:
	_emit_stacks(Alteration.Type.NECROSIS)


func _on_btn_stack_regen_pressed() -> void:
	_emit_stacks(Alteration.Type.REGEN)


func _on_btn_stack_shield_pressed() -> void:
	_emit_stacks(Alteration.Type.SHIELD)


# ============================== Évènements combat ==============================

func _on_btn_dodge_pressed() -> void:
	for i in int(_loop_count_spinbox.value):
		_chicken.action_dodged.emit(_chicken, Utils.ActionType.DAMAGE_PHYSICAL, _get_damage_value(), _is_critical())
