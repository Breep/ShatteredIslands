extends Control

# Prototyping scene for UIBraiseBubble. Lets you spawn the bubble pointing at
# any of the four corner buttons (or centered, no target) to validate position
# logic, arrow side selection, typewriter and pop animations in isolation.

const _BUBBLE_SCENE: PackedScene = preload("res://04_UI/Tool/Tutorial/BraiseBubble/ui_braise_bubble.tscn")

const _SHORT_TEXT: String = "Coucou ! Je suis Braise."
const _LONG_TEXT: String = "Bienvenue aux Îles Brisées ! Je suis Braise. Le jeu TV va bientôt commencer. Choisis vite ton héros et rejoins-nous ! Chacun a un style unique avec son propre arbre de talents personnalisable."

@onready var _target_top_left: Button = %TargetTopLeft
@onready var _target_top_right: Button = %TargetTopRight
@onready var _target_bottom_left: Button = %TargetBottomLeft
@onready var _target_bottom_right: Button = %TargetBottomRight
@onready var _target_center: Button = %TargetCenter

@onready var _btn_show_centered: Button = %BtnShowCentered
@onready var _btn_show_top_left: Button = %BtnShowTopLeft
@onready var _btn_show_top_right: Button = %BtnShowTopRight
@onready var _btn_show_bottom_left: Button = %BtnShowBottomLeft
@onready var _btn_show_bottom_right: Button = %BtnShowBottomRight
@onready var _btn_show_center: Button = %BtnShowCenter
@onready var _btn_show_long: Button = %BtnShowLong
@onready var _btn_hide: Button = %BtnHide

var _current_bubble: UIBraiseBubble


func _ready() -> void:
	_btn_show_centered.pressed.connect(func(): _spawn(_SHORT_TEXT, null))
	_btn_show_top_left.pressed.connect(func(): _spawn(_SHORT_TEXT, _target_top_left))
	_btn_show_top_right.pressed.connect(func(): _spawn(_SHORT_TEXT, _target_top_right))
	_btn_show_bottom_left.pressed.connect(func(): _spawn(_SHORT_TEXT, _target_bottom_left))
	_btn_show_bottom_right.pressed.connect(func(): _spawn(_SHORT_TEXT, _target_bottom_right))
	_btn_show_center.pressed.connect(func(): _spawn(_SHORT_TEXT, _target_center))
	_btn_show_long.pressed.connect(func(): _spawn(_LONG_TEXT, _target_center))
	_btn_hide.pressed.connect(_hide_current)


func _spawn(text: String, target: Control) -> void:
	_hide_current()
	_current_bubble = _BUBBLE_SCENE.instantiate()
	add_child(_current_bubble)
	_current_bubble.closed.connect(_on_bubble_closed)
	_current_bubble.show_bubble(text, target)


func _hide_current() -> void:
	if _current_bubble != null and is_instance_valid(_current_bubble):
		_current_bubble.hide_bubble()


func _on_bubble_closed() -> void:
	_current_bubble = null
