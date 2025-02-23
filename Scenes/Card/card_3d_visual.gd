class_name Card3dVisual
extends Node3D

@onready var _visual: MeshInstance3D = %"Mesh"

func set_color(color: Color):
	var material = _visual.get_surface_override_material(0)
	if material:
		material = material.duplicate()  
	else:
		material = StandardMaterial3D.new()
		material.roughness = 0.5
	
	material.albedo_color = color
	_visual.set_surface_override_material(0, material)
