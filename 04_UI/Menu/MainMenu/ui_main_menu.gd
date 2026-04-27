class_name UIMainMenu
extends Control

@export_group("Local Nodes")
@export var _play_button: Button

@onready var _play_menu: UIPlayMenu = %PlayMenu

func _ready() -> void:
	_play_button.pressed.connect(_on_play_button_pressed)
	
	#var args = OS.get_cmdline_args()
	
	## Example: check for custom flags
	#if "server" in args:
		#get_tree().change_scene_to_file("res://04_UI/Menu/ServerMenu/ui_server_player_list.tscn")


func _on_play_button_pressed() -> void:
	_play_menu.show()
