## Bouton portrait d'une RoasterEntry dans UIRoasterList. Cliquable tant que
## l'unité n'est pas placée ; grisé/désactivé une fois posée. Émet `pressed_down`
## à l'appui et `released` au relâchement, pour piloter directement le drag de
## l'entité (drag lancé sur l'appui, drop sur le relâchement du bouton).
class_name UIEntityPortraitButton
extends Control

# ============================== Signals ==============================

signal pressed_down(entry: RoasterEntry)
signal released(entry: RoasterEntry)

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _portrait: TextureRect
@export var _button: Button

# ============================== Private variables ==============================

var _entry: RoasterEntry

# ============================== Node base functions ==============================

func _ready() -> void:
	_button.button_down.connect(_on_button_down)
	_button.button_up.connect(_on_button_up)

# ============================== Public functions ==============================

func setup(entry: RoasterEntry) -> void:
	_entry = entry
	if entry != null and entry.desc != null:
		_portrait.texture = entry.desc.portrait
	set_placed(entry.placed if entry != null else false)


func set_placed(placed: bool) -> void:
	_button.disabled = placed
	modulate = Color(0.5, 0.5, 0.5, 0.6) if placed else Color.WHITE

# ============================== Callbacks ==============================

func _on_button_down() -> void:
	if _button.disabled:
		return
	pressed_down.emit(_entry)


func _on_button_up() -> void:
	released.emit(_entry)
