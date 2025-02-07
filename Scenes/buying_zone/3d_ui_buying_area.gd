extends Control

@onready var panel_high = %Panel_High
@onready var panel_low = %Panel_low 
@export var area_click: Area2D

func _ready() -> void:
	panel_high.show()
	panel_low.hide()

func _toggle_panels() -> void:
	panel_high.visible = not panel_high.visible
	panel_low.visible = not panel_low.visible

#
#=============== Fonctionne pas ====================
func _on_click_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_panels()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		_toggle_panels()
