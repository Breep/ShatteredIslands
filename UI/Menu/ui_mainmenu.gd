extends Control

@export_group("Local Nodes")
@export var _play_button: Button

func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)

	var args = OS.get_cmdline_args()
	print("Command-line arguments:", args)

	# Example: check for custom flags
	if "server" in args:
		print("Server enabled")
		get_tree().change_scene_to_file("res://TMP_MultiplayerStart.tscn")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TMP_MultiplayerStart.tscn")
