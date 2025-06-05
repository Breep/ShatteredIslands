class_name CharacterAnimator
extends Node

@export var _animation_tree: AnimationTree

func _ready() -> void:
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)


func _on_global_fighting_manager_state_changed(new_state: GlobalFightingManager.FightingState) -> void:
	pass
