extends Node3D

@export_group("3D")
@export var _owner_entity: Entity
@export var _center_point_camera: CenterPointCamera
@export var _center_point: Node3D
@export var _damage_popup_spawn: Marker3D

@export_group("UI")
@export var _crit_chance_spinbox: SpinBox
@export var _min_value_spinbox: SpinBox
@export var _max_value_spinbox: SpinBox
@export var _loop_count_spinbox: SpinBox
@export var _rot_toggle: CheckButton
@export var _rot_speed_spinbox: SpinBox
@export var _translate_toggle: CheckButton
@export var _speed_spinbox: SpinBox
@export var _amplitude_spinbox: SpinBox

var _translate_time: float = 0.0


func _ready() -> void:
	_center_point_camera.set_active()


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


func _apply_damage(damage_type: Utils.ActionType, action_id: StringName) -> void:
	for i in int(_loop_count_spinbox.value):
		_owner_entity.take_damage(_get_damage_value(), damage_type, _is_critical(), action_id)


func _apply_stacks(stack_type: Stack.Type, action_id: StringName) -> void:
	for i in int(_loop_count_spinbox.value):
		_owner_entity.take_condition_stacks(_get_damage_value(), stack_type, _is_critical(), action_id)


# ============================== Dégâts ==============================

func _on_btn_physical_pressed() -> void:
	_apply_damage(Utils.ActionType.DAMAGE_PHYSICAL, &"test_physical")


func _on_btn_magical_pressed() -> void:
	_apply_damage(Utils.ActionType.DAMAGE_MAGICAL, &"test_magical")


func _on_btn_poison_dmg_pressed() -> void:
	_apply_damage(Utils.ActionType.DAMAGE_POISON, &"test_poison_dmg")


func _on_btn_pure_pressed() -> void:
	_apply_damage(Utils.ActionType.DAMAGE_PURE, &"test_pure")


# ============================== Soins ==============================

func _on_btn_heal_pressed() -> void:
	for i in int(_loop_count_spinbox.value):
		_owner_entity.take_heal(_get_damage_value(), _is_critical(), &"test_heal")


# ============================== Stacks ==============================

func _on_btn_stack_poison_pressed() -> void:
	_apply_stacks(Stack.Type.POISON, &"test_stack_poison")


func _on_btn_stack_ignite_pressed() -> void:
	_apply_stacks(Stack.Type.IGNITE, &"test_stack_ignite")


func _on_btn_stack_necrosis_pressed() -> void:
	_apply_stacks(Stack.Type.NECROSIS, &"test_stack_necrosis")


func _on_btn_stack_regen_pressed() -> void:
	_apply_stacks(Stack.Type.REGEN, &"test_stack_regen")


func _on_btn_stack_shield_pressed() -> void:
	_apply_stacks(Stack.Type.SHIELD, &"test_stack_shield")


# ============================== Évènements combat ==============================

func _on_btn_dodge_pressed() -> void:
	for i in int(_loop_count_spinbox.value):
		_owner_entity.action_dodged.emit(_owner_entity, Utils.ActionType.DAMAGE_PHYSICAL, _get_damage_value(), _is_critical())
