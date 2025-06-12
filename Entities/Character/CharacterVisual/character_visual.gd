class_name CharacterVisual
extends Node3D

# ============================== Local scene nodes ==============================

@export_group("Popup Spawns")
@export var physical_popup_spawn: SpawnPoint
@export var magic_popup_spawn: SpawnPoint
@export var poison_popup_spawn: SpawnPoint
@export var heal_popup_spawn: SpawnPoint

@export_group("Local Nodes")
@export var _health_bar: ProgressBar
@export var _mana_bar: ProgressBar
@export var _name_displayed: Label

var _camera: Camera3D # If defined, the visual will look at it

# ============================== Node base functions ==============================

func _process(delta: float) -> void:
	if _camera != null:
		look_at(_camera.global_position)


func set_camera(camera: Camera3D) -> void:
	_camera = camera

# ============================== Public ==============================

#func attach_to_attack_done_signal(attack_done_signal: Signal) -> void:
	#_hero_model.attach_to_attack_done_signal(attack_done_signal)


func update_health_bar(health: int, health_max: int) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health


func update_mana_bar(mana: float, mana_max: float) -> void:
	_mana_bar.max_value = mana_max
	_mana_bar.value = mana


func update_name_displayed(player_name: String) -> void:
	_name_displayed.text = player_name


func damage_popup(amount: float, damage_type: Utils.DamageType, is_critic: bool):
	var popup: DamagePopUp = Shared.DAMAGE_POPUP_SCENE.instantiate()
	var offset = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), 0) 
	popup.text = str(amount as int)
	get_tree().current_scene.add_child(popup)
	
	if is_critic:
		popup.modulate = Color8(95, 20, 28, 255)
	
	match damage_type:
		Utils.DamageType.POISON:
			popup.global_position = poison_popup_spawn.global_position + offset
			popup.outline_modulate = Color8(20, 95, 28, 255)
		Utils.DamageType.PHYSICAL:
			popup.global_position = physical_popup_spawn.global_position + offset
		Utils.DamageType.MAGICAL:
			popup.global_position = magic_popup_spawn.global_position + offset
			popup.outline_modulate = Color8(0, 0, 204, 255)
		Utils.DamageType.HEAL:
			popup.global_position = heal_popup_spawn.global_position + offset
			popup.outline_modulate = Color8(51, 255, 153, 255)
