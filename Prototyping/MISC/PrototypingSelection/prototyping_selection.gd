extends Node3D

@export var _feedback: ClickableSelectionFeedback

func _ready() -> void:
	_feedback.set_active()
