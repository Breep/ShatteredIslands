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
	GameManager.game_rules.duration_fighting_countdown = 0.05
	GameManager.game_rules.duration_fighting_normal = 100000
	GlobalFightingManager.__prototyping = true

	_adopt_pre_placed_entities()

	_center_point_camera.set_active()
	_fighting_manager.init(_spawn_manager, 42)
	_auto_attack_check_button.button_pressed = _auto_attack_enabled
	_family_managers_check_button.button_pressed = _family_managers_enabled


# Les entités posées en éditeur (enfants statiques de _entities_node) sont
# adoptées par le SpawnManager : elles gardent leur position, leurs overrides
# (@export _override_base_stats, _override_custom_deck, etc.) et leur state
# d'éditeur. Le SpawnManager leur attribue juste un UID et les enregistre.
func _adopt_pre_placed_entities() -> void:
	for child in _entities_node.get_children():
		if not (child is Entity): continue
		var entity: Entity = child
		var ctx: EntityContext = entity.get_context()
		ctx.spawn_manager = _spawn_manager
		_spawn_manager.adopt_entity(entity, ctx)
		_entities.append(entity)

# ===== UI =====
#region Global Commands
func _on_start_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		# Disable auto-attack for manual control during prototyping
		entity.auto_attack_enabled = _auto_attack_enabled
		entity.family_managers_enabled = _family_managers_enabled
		#_fighting_manager.start_fighting()
		_auto_attack_check_button.hide()
		_family_managers_check_button.hide()
	GlobalFightingManager.start()
	_fighting_manager.request_phase_advance()


func _on_stop_fight_button_pressed() -> void:
	for entity: Entity in _entities:
		entity.fighting_state = Entity.FightingState.IDLE
	_auto_attack_check_button.show()
	_family_managers_check_button.show()


func _on_reset_fight_button_pressed() -> void:
	GlobalFightingManager.clear()
	get_tree().reload_current_scene()
#endregion


func _on_auto_attack_check_button_toggled(toggled_on: bool) -> void:
	_auto_attack_enabled = toggled_on


func _on_family_managers_check_button_toggled(toggled_on: bool) -> void:
	_family_managers_enabled = toggled_on











 
