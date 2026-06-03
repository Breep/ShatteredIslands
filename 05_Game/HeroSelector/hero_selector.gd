class_name HeroSelector
extends Node

# ============================== Signals ==============================

signal all_heroes_picked
signal _player_hero_picked

# ============================== Configuration ==============================



# ============================== Local nodes ==============================

@export var _spot_lights: Array[SpotLight3D]

@onready var _ui_hero_picking_screen: UIHeroPickingScreen = %UIHeroPickingScreen
@onready var _hero_spawn_point: Marker3D = %HeroSpawnPoint

func load_preview(hero_desc: HeroDesc) -> void:
	
	pass
