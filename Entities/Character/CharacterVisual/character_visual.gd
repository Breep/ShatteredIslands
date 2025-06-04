class_name CharacterVisual
extends Node3D

# ============================== TMP TODO improve this crapy code TMP ==============================

@export var physical_popup_spawn: Node3D
@export var magic_popup_spawn: Node3D
@export var poison_popup_spawn: Node3D
@export var heal_popup_spawn: Node3D

# ============================== Local scene nodes ==============================

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _mana_bar: ProgressBar = %ManaBar
@onready var _energy_bar: ProgressBar = %EnergyBar
@onready var _name_displayed: Label = %NameDisplayed

# ============================== Public ==============================

#func attach_to_attack_done_signal(attack_done_signal: Signal) -> void:
	#_hero_model.attach_to_attack_done_signal(attack_done_signal)


func update_health_bar(health: int, health_max: int) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health


func update_mana_bar(mana: float, mana_max: float) -> void:
	_mana_bar.max_value = mana_max
	_mana_bar.value = mana


func update_energy_bar(energy: float, energy_max: float) -> void:
	_energy_bar.max_value = energy_max * 100.0
	_energy_bar.value = energy * 100.0


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
