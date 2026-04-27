extends Control

@export var _prototyping_ui_result: UIResult

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_pressed("scene_switch_1"): _prototyping_ui_result.show_result(1)
		if Input.is_action_pressed("scene_switch_2"): _prototyping_ui_result.show_result(2)
		if Input.is_action_pressed("scene_switch_3"): _prototyping_ui_result.show_result(3)
		if Input.is_action_pressed("scene_switch_4"): _prototyping_ui_result.show_result(4)
		if Input.is_action_pressed("scene_switch_5"): _prototyping_ui_result.show_result(5)
		if Input.is_action_pressed("scene_switch_6"): _prototyping_ui_result.show_result(6)
		if Input.is_action_pressed("scene_switch_7"): _prototyping_ui_result.show_result(7)
		if Input.is_action_pressed("scene_switch_8"): _prototyping_ui_result.show_result(8)
