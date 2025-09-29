class_name HexButton
extends TextureRect

signal pressed(self_ref: HexButton)

@export var _make_shader_unique: bool = false

@onready var _border: TextureRect = %Border

func _ready() -> void:
	if _make_shader_unique:
		_border.material = _border.material.duplicate(true)


func _on_texture_button_pressed() -> void:
	_activate_outline_highlight()
	pressed.emit(self)


func _activate_outline_highlight() -> void:
	var now := float(Time.get_ticks_msec()) / 1000.0
	_border.material.set_shader_parameter("start_time", now-1.0)
	_border.material.set_shader_parameter("effect_enabled", true)


func desactivate_outline_highlight() -> void:
	_border.material.set_shader_parameter("effect_enabled", false)
