## Bouton portrait d'une RoasterEntry dans UIRoasterList. Cliquable tant que
## l'unité n'est pas placée ; grisé/désactivé une fois posée. Émet `selected`
## sur button_down (press maintenu) pour enchaîner sur le drag de l'entité.
class_name UIEntityPortraitButton
extends Control

# ============================== Signals ==============================

signal selected(entry: RoasterEntry)

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _portrait: TextureRect
@export var _button: Button

# ============================== Private variables ==============================

var _entry: RoasterEntry

# ============================== Node base functions ==============================

func _ready() -> void:
	_button.button_down.connect(_on_button_down)

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
	selected.emit(_entry)
