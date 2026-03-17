extends Node3D

@onready var _mesh_instance: MeshInstance3D = %MeshInstance3D

# On suppose que c'est un ShaderMaterial
var _shader: ShaderMaterial 

func _ready() -> void:
	# On récupère le matériau (attention : .mesh.material modifie la ressource partagée)
	_mesh_instance.mesh.material = _mesh_instance.mesh.material.duplicate(true)
	_shader = _mesh_instance.mesh.material as ShaderMaterial
	
	# On lance la boucle d'animation
	_animate_shader()

func _animate_shader() -> void:
	# 1. On choisit une valeur cible aléatoire (ex: entre 0.1 et 1.0)
	var target_value = randf_range(0.1, 1.0)
	
	# 2. On choisit une durée aléatoire pour la transition (vitesse plus ou moins rapide)
	var duration = randf_range(0.5, 2.0)
	
	# 3. On crée le Tween
	var tween = create_tween()
	
	# On anime le paramètre du shader de façon fluide
	# Note : On utilise le chemin complet de la propriété pour le Tween
	tween.tween_property(_shader, "shader_parameter/vertex_offset_amount", target_value, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# 4. Quand le mouvement est fini, on relance la fonction pour une nouvelle valeur
	tween.finished.connect(_animate_shader)
