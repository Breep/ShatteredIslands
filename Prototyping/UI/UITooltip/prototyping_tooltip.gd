extends Control

@export var test_skill: Skill


func _on_create_skill_window_button_pressed() -> void:
	var skill_window: UISkillWindow = preload("res://UI/Tool/SkillWindow/ui_skill_window.tscn").instantiate()
	skill_window.init(test_skill, get_global_mouse_position())
	get_tree().root.add_child(skill_window)
