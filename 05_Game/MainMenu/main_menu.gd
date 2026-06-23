class_name MainMenu
extends Node3D

func _ready() -> void:
	GlobalGameManager.reset_all_managers()
	RunTracker.reset()
	TutorialManager.reset_session()
	AudioManager.play_bgm("tavern_music")
