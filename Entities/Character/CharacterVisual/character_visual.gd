class_name CharacterVisual
extends Node3D

# ============================== Local scene nodes ==============================

@export_group("Popup Spawns")
@export var _physical_popup_spawn: SpawnPoint
@export var _magic_popup_spawn: SpawnPoint
@export var _poison_popup_spawn: SpawnPoint
@export var _heal_popup_spawn: SpawnPoint

@export_group("Local Nodes")
@export var _health_bar: ColorRect
@export var _mana_bar: ColorRect

@export_group("External Nodes")
@export var _owner_entity: Entity

@onready var _rank_visualizer: UIRankViewer = %RankViewer

var _camera: Camera3D # If defined, the visual will look at it

# ============================== Node base functions ==============================

func _process(_delta: float) -> void:
	if _camera != null:
		look_at(_camera.global_position)


func _ready() -> void:
	_owner_entity.damage_taken.connect(_on_owner_entity_damage_taken)
	_owner_entity.heal_taken.connect(_on_owner_entity_heal_taken)
	_rank_visualizer.connect_entity(_owner_entity)
	if _health_bar and _health_bar.material:
		_health_bar.material = _health_bar.material.duplicate()
	if _mana_bar and _mana_bar.material:
		_mana_bar.material = _mana_bar.material.duplicate()
	if _owner_entity:
		var stats = _owner_entity.stats
		update_health_bar(_owner_entity.stats.health, _owner_entity.stats.health_max)
		if "mana" in stats and "mana_max" in stats:
			update_mana_bar(stats.mana, stats.mana_max)
			
			if stats.has_signal("mana_changed"):
				stats.mana_changed.connect(_on_mana_changed)
			if stats.has_signal("mana_max_changed"):
				stats.mana_max_changed.connect(_on_mana_max_changed)
	

# ============================== Public ==============================

func set_camera(camera: Camera3D) -> void:
	_camera = camera


func update_health_bar(health: float, health_max: float) -> void:
	if not _health_bar or not _health_bar.material:
		return
	var ratio = clamp(float(health) / float(health_max), 0.0, 1.0)
	_health_bar.material.set_shader_parameter("HealthAmount", ratio)
	_health_bar.material.set_shader_parameter("MaxHealth", float(health_max))

func update_mana_bar(mana: float, mana_max: float) -> void:
	if not _mana_bar or not _mana_bar.material:
		return
	var ratio = clamp(float(mana) / float(mana_max), 0.0, 1.0)
	# Note : On utilise toujours "HealthAmount" et "MaxHealth" comme noms de paramètres
	# car on réutilise le même code Shader. Le shader ne sait pas que c'est de la mana,
	_mana_bar.material.set_shader_parameter("HealthAmount", ratio)
	_mana_bar.material.set_shader_parameter("MaxHealth", float(mana_max))

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


func _on_owner_entity_heal_taken(_entity_ref: Entity, heal_amount: int, is_critical: bool) -> void:
	damage_popup(heal_amount, Utils.DamageType.HEAL, is_critical)

func _on_mana_changed(new_value: int) -> void:
	update_mana_bar(new_value, _owner_entity.stats.mana_max)

func _on_mana_max_changed(new_max: int) -> void:
	update_mana_bar(_owner_entity.stats.mana, new_max)
