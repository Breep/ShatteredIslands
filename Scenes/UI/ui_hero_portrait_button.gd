@tool

class_name HeroPortraitButton
extends TextureButton

var hero: Hero

signal selected(hero: Hero)

func _process(delta):
	custom_minimum_size.y = size.x


func init_hero(new_hero: Hero) -> void:
	hero = new_hero


func disable() -> void:
	disabled = true
	create_tween().tween_property(self, "modulate", Color.RED, 0.5)


func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = StretchMode.STRETCH_SCALE
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_FILL
	if hero != null:
		texture_normal = hero.portrait


func _on_pressed() -> void:
	selected.emit(hero)
