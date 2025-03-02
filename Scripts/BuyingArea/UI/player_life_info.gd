class_name PlayerLifeInfo

extends Control

@export var _self_ui_number: int
@onready var _icon = %Icon
@onready var _player_name = %BlackLabel
@onready var _health = %Health
@onready var _health_value = %HealthValue


signal mouse_entered_player_life(number:int)
signal mouse_exited_player_life(number:int)

# Définition des déplacements et durées
const HOVER_OFFSET_Y = -15.0  # Déplacement vertical de l'icône
const HOVER_OFFSET_X = -25.0  # Déplacement horizontal du nom du joueur
const HOVER_TIME = 0.2  # Durée de l'animation

var _tween: Tween = null  # Variable pour stocker le Tween
var _initial_name_x: float  # Position initiale du nom du joueur
var _initial_icon_y: float
func _ready() -> void:
	print("players_life_info ready")
	# Stocke la position initiale du nom du joueur
	_initial_name_x = _player_name.position.x
	_initial_icon_y = _icon.position.y
	
	_player_name.hide()  # Cache le nom du joueur au début


# Quand la souris entre, on anime l'icône et on affiche le nom du joueur
func _on_area_2d_mouse_entered() -> void:
	_start_tween(_icon.position.y + HOVER_OFFSET_Y, _initial_name_x + HOVER_OFFSET_X)
	mouse_entered_player_life.emit(_self_ui_number)

# Quand la souris sort, on rétablit la position et on cache le nom du joueur
func _on_area_2d_mouse_exited() -> void:
	_start_tween(_initial_icon_y, _initial_name_x, true)
	mouse_exited_player_life.emit(_self_ui_number)

func _start_tween(target_y: float, target_x: float, hide_name: bool = false) -> void:
	# Supprime le Tween précédent s'il existe
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween().bind_node(self).set_parallel(true)
	_tween.tween_property(_icon, "position:y", target_y, HOVER_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_player_name, "position:x", target_x, HOVER_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Cache le nom après l'animation si nécessaire
	if hide_name:
		_tween.tween_callback(_player_name.hide).set_delay(HOVER_TIME)
	else:
		_player_name.show()
		
func update_visual(player: Player) -> void:
	_health.value = player.health
	_health_value.text = str(player.health)
	pass
