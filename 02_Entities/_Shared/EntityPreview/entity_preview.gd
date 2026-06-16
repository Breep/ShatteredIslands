## Base des scènes de présentation d'entité (écrans de sélection / présentation).
## Expose les points d'entrée d'animation déclenchés par l'UI ; chaque preview
## concret surcharge ces virtuelles pour les jouer sur ses propres
## AnimationPlayer / AnimationTree.
class_name EntityPreview
extends Node3D


# ============================== Public functions ==============================

func start_spawn_animation() -> void:
	pass


func start_selected_animation() -> void:
	pass


func start_dazed_animation() -> void:
	pass
