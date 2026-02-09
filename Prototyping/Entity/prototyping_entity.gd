extends Node3D

var _entities: Array[Entity]

@export var _auto_attack_enabled: bool = false
@export var _family_managers_enabled: bool = false

@onready var _entities_node: Node3D = %Entities
@onready var _center_point_camera: CenterPointCamera = %CenterPointCamera

@onready var _auto_attack_check_button: CheckButton = %AutoAttackCheckButton
@onready var _family_managers_check_button: CheckButton = %FamilyManagersCheckButton

func _ready() -> void:
	for child in _entities_node.get_children():
		if child is Entity:
			_entities.append(child)
	
	_center_point_camera.set_active()
	_auto_attack_check_button.button_pressed = _auto_attack_enabled
	_family_managers_check_button.button_pressed = _family_managers_enabled


# ===== UI =====
#region Global Commands
func _on_start_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		# Disable auto-attack for manual control during prototyping
		entity.auto_attack_enabled = _auto_attack_enabled
		entity.family_managers_enabled = _family_managers_enabled
		entity.fighting_state = Entity.FightingState.FIGHTING
		if entity is Hero:
			entity.set_display_mode(Hero.DisplayMode.FIGHTING_PHASE)
		_auto_attack_check_button.hide()
		_family_managers_check_button.hide()


func _on_stop_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		entity.fighting_state = Entity.FightingState.IDLE
	_auto_attack_check_button.show()
	_family_managers_check_button.show()


func _on_reset_fight_button_pressed() -> void:
	get_tree().reload_current_scene()
#endregion


func _on_auto_attack_check_button_toggled(toggled_on: bool) -> void:
	_auto_attack_enabled = toggled_on


func _on_family_managers_check_button_toggled(toggled_on: bool) -> void:
	_family_managers_enabled = toggled_on
