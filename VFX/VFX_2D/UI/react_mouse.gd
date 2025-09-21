extends TextureRect

@onready var shader_material = material as ShaderMaterial

func _process(delta):
	# On s'assure que le matériel existe bien
	if shader_material:
		# On envoie la position LOCALE de la souris au shader
		shader_material.set_shader_parameter("mouse_pos", get_local_mouse_position())
		
		# On envoie également la taille du TextureRect
		shader_material.set_shader_parameter("node_size", size)
