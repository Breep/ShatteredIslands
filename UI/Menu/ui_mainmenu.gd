extends Control

@export_group("Local Nodes")
@export var _play_button: Button

func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)
	

func _on_play_button_pressed() -> void:
	print("HELLO")
	get_tree().change_scene_to_file("res://TMP_MultiplayerStart.tscn")
