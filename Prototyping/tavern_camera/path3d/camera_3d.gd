# Camera3D.gd
extends Camera3D

@export var target: Node3D

func _process(delta):
	if target:
		# La caméra regarde directement la position globale de la cible
		look_at(target.global_transform.origin)
		# Optionnel : Si vous voulez un lissage comme avec slerp,
		# vous pouvez faire ceci à la place. C'est un peu plus complexe
		# mais donne un effet plus fluide.
		# var transform_cible = global_transform.looking_at(target.global_transform.origin, Vector3.UP)
		# global_transform = global_transform.interpolate_with(transform_cible, delta * 2.0)
