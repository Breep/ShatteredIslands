class_name CharacterVisual
extends Node3D

@onready var damage_popup_scene = preload("res://Scenes/Character/damage_pop_up.tscn")

@export var physical_popup_theme: Theme
@export var magic_popup_theme: Theme
@export var poison_popup_theme: Theme

@export var physical_popup_spawn: Node3D
@export var magic_popup_spawn: Node3D
@export var poison_popup_spawn: Node3D

# ============================== Local scene nodes ==============================

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _name_displayed: Label = %NameDisplayed

@onready var _animated_sprite: AnimatedSprite3D = %AnimatedSprite3D

# ============================== Public ==============================

func _ready() -> void:
	_animated_sprite.play("Idle")

func update_health_bar(health: int, health_max: int) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health


func update_name_displayed(player_name: String) -> void:
	_name_displayed.text = player_name


func damage_popup(amount: float, damage_type: Utils.DamageType):
	var popup: DamagePopUp = damage_popup_scene.instantiate()
	var offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) 
	popup.text = str(amount)
	get_tree().current_scene.add_child(popup)
	match damage_type:
		Utils.DamageType.POISON:
			popup.global_position = poison_popup_spawn.global_position + offset
			popup.outline_modulate = Color(0, 200, 0, 1)
		Utils.DamageType.PHYSICAL:
			popup.global_position = physical_popup_spawn.global_position + offset
		Utils.DamageType.MAGIC:
			popup.global_position = magic_popup_spawn.global_position + offset
			popup.outline_modulate = Color(0, 0, 200, 1)
