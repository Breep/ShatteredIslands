extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer 
@onready var mimic_chest_animation = "mimic_chest"  # Nom de l'animation

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if animation_player.has_animation(mimic_chest_animation):
			animation_player.play(mimic_chest_animation)
		else:
			printerr("Animation 'mimic_chest' non trouvée dans l'AnimationPlayer !")
