class_name UIHeroPortraitButton
extends Control

# ============================== Signals ==============================

signal selected(selected_hero: Hero)

# ============================== Public variables ==============================

var _hero: Hero
var hero: Hero:
	get: return _hero
	set(value):
		if _hero == value: return
		_hero = value
		_portrait.texture = _hero.portrait

var disabled: bool = false

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _portrait: TextureRect
@export var _button: Button

# ============================== Public variables ==============================

func disable() -> void:
	disabled = true
	_button.disabled = true
	create_tween().tween_property(self, "modulate", Color.RED, 0.2)

# ============================== Callbacks ==============================

func _on_button_pressed() -> void:
	print("DEBUG - Selected hero : ", _hero)
	selected.emit(_hero)
