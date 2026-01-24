extends Control

@onready var _ui_health_bar: UIHealthBar = %HealthBar

@onready var _max_health_text_edit: TextEdit = %MaxHealthTextEdit
@onready var _current_health_text_edit: TextEdit = %CurrentHealthTextEdit
@onready var _poison_stacks_text_edit: TextEdit = %PoisonTextEdit
@onready var _armor_stacks_text_edit: TextEdit = %ArmorTextEdit

@onready var _damage_text_edit: TextEdit = %DamageTextEdit
@onready var _variation_text_edit: TextEdit = %VariationTextEdit


@onready var _rng:= RandomNumberGenerator.new()

var _health: int = 1000
var _max_health: int = 1000
var _armor_stacks: int = 0
var _poison_stacks: int = 0

func _ready() -> void:
	_on_poison_button_pressed()
	_on_validate_max_health_button_pressed()
	_on_validate_current_health_button_pressed()
	_on_armor_button_pressed()

func _on_validate_max_health_button_pressed() -> void:
	var max_health:= int(_max_health_text_edit.text)
	if max_health > 0:
		_ui_health_bar.max_health = max_health


func _on_validate_current_health_button_pressed() -> void:
	var current_health:= int(_current_health_text_edit.text)
	if current_health > 0:
		_health = current_health
		_ui_health_bar.current_health = current_health


func _on_deal_damage_button_pressed() -> void:
	var damage_raw := int(_damage_text_edit.text)
	var variation := int(_variation_text_edit.text)
	var damage: int = _rng.randi_range(clampi(damage_raw - variation, 0, 10000), clampi(damage_raw + variation, 0, 10000))
	if damage > 0:
		var armor_stacks_lost: int = min(damage, _armor_stacks)
		_health -= (damage - armor_stacks_lost)
		_armor_stacks -= armor_stacks_lost
		_ui_health_bar.shield_stacks = _armor_stacks
		_ui_health_bar.current_health = _health


func _on_poison_button_pressed() -> void:
	var poison_stacks:= int(_poison_stacks_text_edit.text)
	if poison_stacks >= 0:
		_ui_health_bar.poison_stacks = poison_stacks


func _on_armor_button_pressed() -> void:
	var armor_stacks:= int(_armor_stacks_text_edit.text)
	if armor_stacks >= 0:
		_armor_stacks = armor_stacks
		_ui_health_bar.shield_stacks = armor_stacks
