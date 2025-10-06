extends Control

@onready var _max_health_text_edit: TextEdit = %MaxHealthTextEdit
@onready var _current_health_text_edit: TextEdit = %CurrentHealthTextEdit
@onready var _ui_health_bar: UIHealthBar = %UIHealthBar
@onready var _damage_text_edit: TextEdit = %DamageTextEdit
@onready var _variation_text_edit: TextEdit = %VariationTextEdit

@onready var _rng:= RandomNumberGenerator.new()

var _health: int = 1000

func _ready() -> void:
	_ui_health_bar.update_max_health(_health)
	_ui_health_bar.update_current_health(_health)


func _on_validate_max_health_button_pressed() -> void:
	var max_health:= int(_max_health_text_edit.text)
	if max_health > 0:
		_ui_health_bar.update_max_health(max_health)


func _on_validate_current_health_button_pressed() -> void:
	var current_health:= int(_current_health_text_edit.text)
	if current_health > 0:
		_health = current_health
		_ui_health_bar.update_current_health(current_health)


func _on_deal_damage_button_pressed() -> void:
	var damage_raw := int(_damage_text_edit.text)
	var variation := int(_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	if damage > 0:
		_health -= damage
		_ui_health_bar.update_current_health(_health)
