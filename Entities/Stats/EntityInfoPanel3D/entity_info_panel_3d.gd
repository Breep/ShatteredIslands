class_name EntityInfoPanel3D
extends Node3D

# ============================== Local scene nodes ==============================

@onready var _physical_popup_spawn: SpawnPoint = %PhysicalDamagePopupSpawnPoint
@onready var _magical_popup_spawn: SpawnPoint = %MagicalDamagePopupSpawnPoint
@onready var _poison_popup_spawn: SpawnPoint = %PoisonDamagePopupSpawnPoint
@onready var _heal_popup_spawn: SpawnPoint = %HealPopupSpawnPoint

@onready var _entity_name_label: Label = %EntityNameLabel
@onready var _health_bar: FlexibleProgressBar = %HealthBar

@export_group("External Nodes")
@export var _owner_entity: Entity

var _camera: Camera3D

# ============================== Node base functions ==============================

func _process(_delta: float) -> void:
	_camera = get_viewport().get_camera_3d()
	if _camera != null:
		look_at(_camera.global_position)


func _ready() -> void:
	_owner_entity.damage_taken.connect(_on_owner_entity_damage_taken)
	_owner_entity.heal_taken.connect(_on_owner_entity_heal_taken)
	_owner_entity.stats.health_changed.connect(_on_own_entity_health_change)
	_owner_entity.stats.health_max_changed.connect(_on_own_entity_max_health_change)
	_entity_name_label.text = _owner_entity.entity_name
	_update_health_bar(_owner_entity.stats.health, _owner_entity.stats.health_max)
	if _health_bar.material != null:
		_health_bar.material = _health_bar.material.duplicate(true)

# ============================== Private ==============================

func _update_health_bar(health: float, max_health: float) -> void:
	print("DEBUG - SET BAR ", health, " / ", max_health)
	_health_bar.set_max_value(max_health)
	_health_bar.set_bar_value(health)


func _damage_popup(amount: float, damage_type: Utils.DamageType, is_critic: bool = false):
	var popup: DamagePopUp = Shared.DAMAGE_POPUP_SCENE.instantiate()
	var offset = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), 0) 
	popup.set_value(amount)
	get_tree().current_scene.add_child(popup)
	
	if is_critic:
		popup.modulate(Color8(95, 20, 28, 255))
	
	match damage_type:
		Utils.DamageType.POISON:
			popup.global_position = _poison_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(20, 95, 28, 255))
		Utils.DamageType.PHYSICAL:
			popup.global_position = _physical_popup_spawn.global_position + offset
		Utils.DamageType.MAGICAL:
			popup.global_position = _magical_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(0, 0, 204, 255))
		Utils.DamageType.HEAL:
			popup.global_position = _heal_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(51, 255, 153, 255))
	
	if _camera != null: popup.look_at(_camera.global_position)

# ============================== Callbacks ==============================

func _on_owner_entity_damage_taken(_entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool, _blocked_by_armor) -> void:
	_damage_popup(damage, damage_type, is_critical)


func _on_owner_entity_heal_taken(_entity_ref: Entity, heal_amount: int, is_critical: bool) -> void:
	_damage_popup(heal_amount, Utils.DamageType.HEAL, is_critical)


func _on_own_entity_health_change(health: int) -> void:
	_update_health_bar(health, _owner_entity.stats.health_max)


func _on_own_entity_max_health_change(max_health: int) -> void:
	_update_health_bar(_owner_entity.stats.health, max_health)
