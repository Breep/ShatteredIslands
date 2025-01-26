class_name CharacterVisual
extends Node2D

@onready var damage_popup_scene = preload("res://Scenes/Character/damage_pop_up.tscn")

@export var normal_popup_theme: Theme
@export var critic_popup_theme: Theme
@export var magic_popup_theme: Theme
@export var poison_popup_theme: Theme

# ============================== Local scene nodes ==============================

@onready var _health_bar: ProgressBar = $HealthBar
@onready var _name_displayed: Label = $NameDisplayed

# ============================== Public ==============================

func update_health_bar(health: int, health_max: int) -> void:
	_health_bar.max_value = health_max
	_health_bar.value = health


func update_name_displayed(player_name: String) -> void:
	_name_displayed.text = player_name


func damage_popup(amount: float, damage_type: Character.DamageType):
	var popup = damage_popup_scene.instantiate()
	var target_position = Vector2(randf_range(10,30), randf_range(10,-30)) 
	popup.text = str(amount)
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position + target_position
	popup.z_index = 1
	match damage_type:
		Character.DamageType.POISON:
			popup.set("theme", poison_popup_theme)
		Character.DamageType.NORMAL:
			popup.set("theme", normal_popup_theme)
		Character.DamageType.CRITIC:
			popup.set("theme", critic_popup_theme)
		Character.DamageType.MAGIC:
			popup.set("theme", magic_popup_theme)
