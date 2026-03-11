extends Control

@export var _family_controls: Array[Control]
@export var _family_portraits: Array[BaseButton]
@onready var _connect_bar: ColorRect = %ConnectBar
@onready var _info_panel: Panel = %InfoPanel

var _active_portrait: BaseButton
var _fade_tween: Tween

func _ready() -> void:
	_connect_bar.modulate.a = 0.0
	_info_panel.modulate.a = 0.0
	for family_portrait in _family_portraits:
		family_portrait.toggled.connect(_on_family_portrait_toggled.bind(family_portrait))


func _on_family_portrait_toggled(toggled_on: bool, family_portrait: BaseButton) -> void:
	print("Clicked on ", family_portrait)
	var container := family_portrait.get_parent().get_parent().get_parent() as Control
	if toggled_on:
		_active_portrait = family_portrait
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(container, "custom_minimum_size:y", 70.0, 0.2)
		tween.tween_callback(_on_expand_finished)
		for fp in _family_portraits:
			if fp != family_portrait: fp.button_pressed = false
	else:
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(container, "custom_minimum_size:y", 50.0, 0.2)
		if not _is_any_portrait_toggled():
			_active_portrait = null
			_fade_out_ui()


func _is_any_portrait_toggled() -> bool:
	for fp in _family_portraits:
		if fp.button_pressed:
			return true
	return false


func _on_expand_finished() -> void:
	if not _active_portrait:
		return
	# Attendre une frame pour que le layout se mette à jour après le resize
	await get_tree().process_frame
	_update_connect_bar_position()
	_fade_in_ui()


func _update_connect_bar_position() -> void:
	var portrait_center_y := _active_portrait.global_position.y + _active_portrait.size.y / 2.0
	var portrait_center_x := _active_portrait.global_position.x + _active_portrait.size.x / 2.0
	var local_y := portrait_center_y - global_position.y
	var local_x := portrait_center_x - global_position.x
	_connect_bar.position.y = local_y - _connect_bar.size.y / 2.0
	_connect_bar.position.x = local_x


func _fade_in_ui() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	_fade_tween.tween_property(_connect_bar, "modulate:a", 1.0, 0.15)
	_fade_tween.tween_property(_info_panel, "modulate:a", 1.0, 0.15)


func _fade_out_ui() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	_fade_tween.tween_property(_connect_bar, "modulate:a", 0.0, 0.15)
	_fade_tween.tween_property(_info_panel, "modulate:a", 0.0, 0.15)
