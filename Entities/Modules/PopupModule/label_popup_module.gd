class_name LabelPopupModule
extends Module

@export var _owner_entity: Entity
@export var _popup_marker: Marker3D

@export_group("Optional Configuration")
@export var _radius: float = 1

@onready var random := RandomNumberGenerator.new()


func _ready() -> void:
	if not _owner_entity:
		Verbose.error("EntityInfoPanel3D: _owner_entity is null! This node is misconfigured.", Verbose.Category.ENTITY)
		return

	random.randomize()
	_owner_entity.damage_taken.connect(_on_owner_entity_damage_taken)
	_owner_entity.heal_taken.connect(_on_owner_entity_heal_taken)
	_owner_entity.stack_taken.connect(_on_owner_entity_stack_taken)
	_owner_entity.action_dodged.connect(_on_owner_entity_action_dodged)


func _spawn(popup: LabelPopup) -> void:
	var x := random.randf_range(-1, 1)
	var y := random.randf_range(0.07, 1)
	var offset := Vector3(x, y, x).normalized() * _radius
	popup.init(_popup_marker.global_position + offset)
	add_child(popup)


# ============================== Callbacks ==============================

func _on_owner_entity_damage_taken(damage: float, damage_type: Utils.ActionType, is_critical: bool, _blocked_by_armor) -> void:
	var popup: LabelPopup
	match damage_type:
		Utils.ActionType.DAMAGE_PHYSICAL: popup = LabelPopup.damage_physical(damage)
		Utils.ActionType.DAMAGE_MAGICAL:  popup = LabelPopup.damage_magical(damage)
		Utils.ActionType.DAMAGE_POISON:   popup = LabelPopup.damage_poison(damage)
		Utils.ActionType.DAMAGE_PURE:     popup = LabelPopup.damage_pure(damage)
		_:                                popup = LabelPopup.damage_pure(damage)
	if is_critical:
		popup.set_crit()
	_spawn(popup)


func _on_owner_entity_heal_taken(heal_amount: int, is_critical: bool) -> void:
	var popup := LabelPopup.heal(heal_amount)
	if is_critical:
		popup.set_crit()
	_spawn(popup)


func _on_owner_entity_stack_taken(stack_type: Stack.Type, stack_number: float, is_critical: bool) -> void:
	var popup := LabelPopup.stack(stack_number, stack_type)
	if is_critical:
		popup.set_crit()
	_spawn(popup)


func _on_owner_entity_action_dodged(_source: Entity, _action_type: Utils.ActionType, value: float, is_critical: bool) -> void:
	var popup := LabelPopup.dodge(value, is_critical)
	_spawn(popup)
