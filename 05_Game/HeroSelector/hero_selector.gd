class_name HeroSelector
extends Node

# Drives the hero selection scene: feeds the picking UI with the available
# heroes, reacts to its selection/lock signals (updating the stage previews),
# and plays the intro lighting sequence (main light cut, then spotlights
# snapping on one by one).

# ============================== Signals ==============================

signal all_heroes_picked
signal _player_hero_picked

# ============================== Configuration ==============================

@export var _available_heroes: Array[HeroDesc]

@export_group("Intro lighting")
## Delay before the first spotlight snaps on.
@export var _first_spot_delay: float = 1.0
## Delay between each subsequent spotlight.
@export var _between_spots_delay: float = 0.6

# ============================== Local nodes ==============================

@export var _spot_lights: Array[TavernSpotLight]

@onready var _ui_hero_picking_screen: UIHeroPickingScreen = %UIHeroPickingScreen
@onready var _hero_spawn_point: Marker3D = %HeroSpawnPoint
@onready var _acolyte_spawn_point: Marker3D = %AcolyteSpawnPoint
@onready var _main_light: Node3D = $Tavern/Light/MainLight

# ============================== Node base functions ==============================

func _ready() -> void:
	_main_light.visible = false

	_ui_hero_picking_screen.hero_selected.connect(_on_hero_selected)
	_ui_hero_picking_screen.hero_locked.connect(_on_hero_locked)
	_ui_hero_picking_screen.setup(_available_heroes)

	_play_intro_lighting()
	AudioManager.play_sfx("tavern_background_ambient")


# ============================== Private functions ==============================

func _spawn_preview(spawn_point: Marker3D, scene: PackedScene) -> void:
	for child in spawn_point.get_children():
		child.queue_free()
	if scene == null:
		return
	spawn_point.add_child(scene.instantiate())


func _play_intro_lighting() -> void:
	var tween := create_tween()
	tween.tween_interval(_first_spot_delay)
	for i in _spot_lights.size():
		tween.tween_callback(_spot_lights[i].turn_on)
		if i < _spot_lights.size() - 1:
			tween.tween_interval(_between_spots_delay)


# ============================== Callbacks ==============================

func _on_hero_selected(hero: HeroDesc) -> void:
	_spawn_preview(_hero_spawn_point, hero.preview_scene)

	var acolyte: EntityDesc = null
	if not hero.starting_companions.is_empty():
		acolyte = hero.starting_companions[0]
	_spawn_preview(_acolyte_spawn_point, acolyte.preview_scene if acolyte else null)


func _on_hero_locked(_hero: HeroDesc) -> void:
	AudioManager.play_sfx("fanfar_trumpet", -1)
	AudioManager.play_sfx("crowd_cheer_small")
