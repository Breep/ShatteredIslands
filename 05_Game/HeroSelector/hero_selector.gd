class_name HeroSelector
extends Node

# Drives the hero selection scene: feeds the picking UI with the available
# heroes, reacts to its selection/lock signals (spawning + animating the stage
# preview), and plays the intro lighting sequence (main light cut, then
# spotlights snapping on one by one).
#
# La scène de preview de l'entité porte désormais TOUT ce qu'elle affiche (héros
# + compagnons) et expose ses animations via EntityPreview — plus aucune notion
# d'acolyte ici.

# ============================== Signals ==============================

signal all_heroes_picked
signal _player_hero_picked

# ============================== Configuration ==============================

@export var _available_heroes: Array[HeroDesc]

## Delay between locking the hero (fanfare/cheer) and transitioning to the Run.
@export var _lock_transition_delay: float = 1.5

## Vitesse de rotation du preview au clic-glissé (radians par pixel horizontal).
@export var _rotation_speed: float = 0.01

@export_group("Dazed gauge")
## Remplissage de la jauge par pixel de rotation horizontale.
@export var _gauge_fill_per_pixel: float = 1.0
## Décroissance de la jauge (unités/seconde) : fixe la vitesse de rotation minimale
## à dépasser pour que la jauge monte au lieu de redescendre.
@export var _gauge_decay: float = 400.0
## Seuil cumulé déclenchant le dazed (plus haut = brassage plus long requis).
@export var _gauge_threshold: float = 1000.0

@export_group("Intro lighting")
## Delay before the first spotlight snaps on.
@export var _first_spot_delay: float = 1.0
## Delay between each subsequent spotlight.
@export var _between_spots_delay: float = 0.6

# ============================== Local nodes ==============================

@export var _spot_lights: Array[TavernSpotLight]

@onready var _ui_hero_picking_screen: UIHeroPickingScreen = %UIHeroPickingScreen
@onready var _hero_spawn_point: Marker3D = %HeroSpawnPoint
@onready var _main_light: Node3D = $Tavern/Light/MainLight

# ============================== Private vars ==============================

var _current_preview: EntityPreview
var _is_dragging: bool = false
var _rotation_gauge: float = 0.0

# ============================== Node base functions ==============================

func _ready() -> void:
	_main_light.visible = false

	_ui_hero_picking_screen.hero_selected.connect(_on_hero_selected)
	_ui_hero_picking_screen.hero_locked.connect(_on_hero_locked)
	_ui_hero_picking_screen.setup(_available_heroes)

	_play_intro_lighting()
	AudioManager.play_sfx("tavern_background_ambient")


# Rotation du preview au clic-glissé, hors UI : _unhandled_input ne reçoit que les
# events non consommés par un Control (donc inactif quand la souris est sur l'UI).
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_dragging = event.pressed
		if _is_dragging:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion and _is_dragging:
		# Auto-réarme si le bouton a été relâché au-dessus d'un Control (release
		# consommé par l'UI, jamais reçu ici).
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_is_dragging = false
		elif is_instance_valid(_current_preview):
			_current_preview.rotate_y(event.relative.x * _rotation_speed)
			_add_rotation_to_gauge(absf(event.relative.x))


# La jauge se vide en continu ; seules des rotations plus rapides que _gauge_decay
# la font monter (cf. _add_rotation_to_gauge).
func _process(delta: float) -> void:
	if _rotation_gauge > 0.0:
		_rotation_gauge = maxf(0.0, _rotation_gauge - _gauge_decay * delta)


# ============================== Private functions ==============================

# Jauge "à fuite" : un brassage soutenu finit par franchir le seuil et étourdit
# l'entité. Le franchissement remet la jauge à zéro (il faut re-remplir pour
# re-déclencher).
func _add_rotation_to_gauge(amount: float) -> void:
	_rotation_gauge = minf(_gauge_threshold, _rotation_gauge + amount * _gauge_fill_per_pixel)
	if _rotation_gauge >= _gauge_threshold:
		_rotation_gauge = 0.0
		if is_instance_valid(_current_preview):
			_current_preview.start_dazed_animation()

func _spawn_preview(scene: PackedScene) -> EntityPreview:
	for child in _hero_spawn_point.get_children():
		child.queue_free()
	if scene == null:
		return null
	var preview: Node = scene.instantiate()
	_hero_spawn_point.add_child(preview)
	return preview as EntityPreview


func _play_intro_lighting() -> void:
	var tween := create_tween()
	tween.tween_interval(_first_spot_delay)
	for i in _spot_lights.size():
		tween.tween_callback(_spot_lights[i].turn_on)
		if i < _spot_lights.size() - 1:
			tween.tween_interval(_between_spots_delay)


# ============================== Callbacks ==============================

func _on_hero_selected(hero: HeroDesc) -> void:
	_rotation_gauge = 0.0
	_current_preview = _spawn_preview(hero.preview_scene)
	if _current_preview != null:
		_current_preview.start_spawn_animation()


func _on_hero_locked(hero: HeroDesc) -> void:
	if _current_preview != null:
		_current_preview.start_selected_animation()
	AudioManager.play_sfx("fanfar_trumpet", -1)
	AudioManager.play_sfx("crowd_cheer_small")
	await get_tree().create_timer(_lock_transition_delay).timeout
	GameManager.lock_hero_into_run(hero)
