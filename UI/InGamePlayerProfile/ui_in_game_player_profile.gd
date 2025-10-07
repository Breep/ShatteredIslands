class_name UIInGamePlayerProfile
extends Control

@export var _effect_duration: float = 0.4

@onready var _texture_rect: TextureRect = %TextureRect

func _ready() -> void:
	hide()
	_texture_rect.modulate.a = 0.0
	_texture_rect.scale = Vector2(0.9, 0.9)

func show_panel() -> void:
	show()
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_texture_rect, "modulate:a", 1.0, _effect_duration).from(0.0)
	tw.parallel().tween_property(_texture_rect, "scale", Vector2.ONE, _effect_duration).from(Vector2(0.9, 0.9))

func hide_panel() -> void:
	_texture_rect.modulate.a = 0.0
	_texture_rect.scale = Vector2(0.9, 0.9)
	hide()
