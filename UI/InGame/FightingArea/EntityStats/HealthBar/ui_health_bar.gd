class_name UIHealthBar
extends Control

@export var _health_bar: FlexibleProgressBar
@export var _poison_bar: ColorRect
@export var _armor_bar: FlexibleProgressBar

@export var _show_poison: bool = true
var show_poison: bool:
	get: return _show_poison
	set(value):
		_show_poison = value
		if _show_poison == true: _poison_bar.show()
		else: _poison_bar.hide()

@export var _show_armor: bool = true
var show_armor: bool:
	get: return _show_armor
	set(value):
		_show_armor = value
		if _show_armor == true: _armor_bar.show()
		else: _armor_bar.hide()

@export var _poison_multiplier: float = 1.0
@export var _armor_multiplier: float = 1.0

var _poison_stacks: int = 10
@export var poison_stacks: int:
	get: return _poison_stacks
	set(value):
		_poison_stacks = value
		_update_layout()

var _armor_stacks: int = 15
@export var armor_stacks: int:
	get: return _armor_stacks
	set(value):
		_armor_stacks = value
		_update_layout()

var _current_health: int = 70
@export var current_health: int:
	get: return _current_health
	set(value):
		_current_health = value
		_update_layout()

var _max_health: int = 100
@export var max_health: int:
	get: return _max_health
	set(value):
		_max_health = value
		_update_layout()

func _ready() -> void:
	if _show_armor: _armor_bar.show()
	if _show_poison: _poison_bar.show()
	_update_layout()


func _update_layout() -> void:
	var end_pos: Vector2 = _get_health_bar_end_pos()
	_update_health_bar()
	_update_poison_bar(end_pos)
	_update_armor_bar(end_pos)


func _update_poison_bar(start_pos: Vector2) -> void:
	_poison_bar.size.x = (float(_poison_stacks) / _health_bar.max_value) * _health_bar.size.x * _poison_multiplier
	_poison_bar.size.y = _health_bar.size.y
	_poison_bar.position = start_pos - _poison_bar.size.x * Vector2.RIGHT


func _update_armor_bar(start_pos: Vector2) -> void:
	_armor_bar.size.x = (float(armor_stacks) / _health_bar.max_value) * _health_bar.size.x * _armor_multiplier
	_armor_bar.size.y = _health_bar.size.y
	_armor_bar.position = start_pos


func _update_health_bar() -> void:
	_health_bar.set_max_value(_max_health)
	_health_bar.set_bar_value(_current_health)


func _get_health_bar_end_pos() -> Vector2:
	var ratio: float = float(_current_health) / float(_max_health)
	return _health_bar.position + ratio * _health_bar.size.x * Vector2.RIGHT
