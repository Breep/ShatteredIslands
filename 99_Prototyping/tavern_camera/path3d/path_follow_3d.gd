# PathFollow3D.gd
extends PathFollow3D

@export var speed: float = 2.0

func _process(delta):
	# Avancement sur le chemin
	progress += speed * delta
