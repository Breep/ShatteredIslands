extends Node3D

var _entities: Array[Entity]

@onready var _entities_node: Node3D = %Entities
@onready var _center_point_camera: CenterPointCamera = %CenterPointCamera

func _ready() -> void:
	for child in _entities_node.get_children():
		if child is Entity:
			_entities.append(child)
	
	_center_point_camera.set_active()


# ===== UI =====
#region Global Commands
func _on_start_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		# Disable auto-attack for manual control during prototyping
		entity.auto_attack_enabled = false
		entity.fighting_state = Entity.FightingState.FIGHTING
		if entity is Hero:
			entity.set_display_mode(Hero.DisplayMode.FIGHTING_PHASE)


func _on_stop_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		entity.fighting_state = Entity.FightingState.IDLE


func _on_reset_fight_button_pressed() -> void:
	get_tree().reload_current_scene()
#endregion
