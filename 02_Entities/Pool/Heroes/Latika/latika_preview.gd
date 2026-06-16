## Présentation de Latika et de son loup Vrock sur les écrans de sélection.
## Animations pilotées par l'AnimationTree (cf. DefaultEntityPreview).
class_name LatikaPreview
extends DefaultEntityPreview

@export var _vrock_animation_player: AnimationPlayer

func start_selected_animation() -> void:
	super.start_selected_animation()
	_vrock_animation_player.play("synty_animals_library/idle_var_02")
