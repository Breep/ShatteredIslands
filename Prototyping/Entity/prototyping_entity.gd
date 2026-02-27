extends Node3D

var _entities: Array[Entity]

@export var _auto_attack_enabled: bool = false
@export var _family_managers_enabled: bool = false

@onready var _entities_node: Node3D = %Entities
@onready var _center_point_camera: CenterPointCamera = %CenterPointCamera
@onready var _fighting_manager: FightingManager = %FightingManager
@onready var _spawn_manager: SpawnManager = %SpawnManager

@onready var _auto_attack_check_button: CheckButton = %AutoAttackCheckButton
@onready var _family_managers_check_button: CheckButton = %FamilyManagersCheckButton


func _ready() -> void:
	GameManager.init()
	GameManager.game_rules.duration_fighting_positioning = 0
	GameManager.game_rules.duration_fighting_countdown = 0
	GameManager.game_rules.duration_fighting_normal = 240
	GlobalFightingManager.__prototyping = true
	
	_respawn_entites_with_spawn_manager()
	
	_center_point_camera.set_active()
	_fighting_manager.init(_spawn_manager, 42)
	_auto_attack_check_button.button_pressed = _auto_attack_enabled
	_family_managers_check_button.button_pressed = _family_managers_enabled


func _respawn_entites_with_spawn_manager() -> void:
	for child in _entities_node.get_children():
		if child is Hero:
			var entity_data = {
				"team": child.team,
				"custom_base_stats": child.custom_base_stats,
				"custom_deck": child._custom_deck,
				"hero_id": child.hero_desc.id,
				"global_pos": child.global_position,
				"global_rot": child.global_rotation,
				"context": child.get_context()
			}
			child.queue_free()
			
			# On passe par le SpawnManager pour obtenir un UID et l'ajouter aux listes de tick
			var hero: Hero = Shared.HERO_SCENES[entity_data["hero_id"]].instantiate()
			hero.custom_base_stats = entity_data["custom_base_stats"]
			hero._custom_deck = entity_data["custom_deck"]
			hero.team = entity_data["team"]
			
			_spawn_manager.spawn_entity(hero, entity_data["global_pos"], entity_data["context"])
			hero.global_rotation = entity_data["global_rot"]
			_entities.append(hero)
			hero.set_display_mode(Hero.DisplayMode.FIGHTING_PHASE)

# ===== UI =====
#region Global Commands
func _on_start_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		# Disable auto-attack for manual control during prototyping
		entity.auto_attack_enabled = _auto_attack_enabled
		entity.family_managers_enabled = _family_managers_enabled
		GlobalFightingManager.start()
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
