class_name CharacterVisual
extends Node3D

# ============================== Local scene nodes ==============================

@export_group("Popup Spawns")
@export var _physical_popup_spawn: SpawnPoint
@export var _magic_popup_spawn: SpawnPoint
@export var _poison_popup_spawn: SpawnPoint
@export var _heal_popup_spawn: SpawnPoint

@export_group("Local Nodes")
@export var _health_bar: ProgressBar
@export var _mana_bar: ProgressBar
@export var _name_displayed: Label

@export_group("External Nodes")
@export var _owner_entity: Entity

var _camera: Camera3D # If defined, the visual will look at it

# ============================== Node base functions ==============================

func _process(_delta: float) -> void:
	if _camera != null:
		look_at(_camera.global_position)


func _ready() -> void:
	_owner_entity.damage_taken.connect(_on_owner_entity_damage_taken)
	_owner_entity.heal_taken.connect(_on_owner_entity_heal_taken)

# ============================== Public ==============================

func set_camera(camera: Camera3D) -> void:
	_camera = camera


func update_health_bar(health: int, health_max: int) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health


func update_mana_bar(mana: float, mana_max: float) -> void:
	_mana_bar.max_value = mana_max
	_mana_bar.value = mana


func update_name_displayed(player_name: String) -> void:
	_name_displayed.text = player_name


func damage_popup(amount: float, damage_type: Utils.DamageType, is_critic: bool = false):
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
			popup.global_position = _magic_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(0, 0, 204, 255))
		Utils.DamageType.HEAL:
			popup.global_position = _heal_popup_spawn.global_position + offset
			popup.outline_modulate(Color8(51, 255, 153, 255))
	
	if _camera != null: popup.look_at(_camera.global_position)

# ============================== Callbacks ==============================

func _on_owner_entity_damage_taken(_entity_ref: Entity, damage: int, damage_type: Utils.DamageType, is_critical: bool, _blocked_by_armor) -> void:
	damage_popup(damage, damage_type, is_critical)


func _on_owner_entity_heal_taken(_entity_ref: Entity, heal_amount: int) -> void:
	damage_popup(heal_amount, Utils.DamageType.HEAL)
