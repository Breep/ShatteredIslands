@tool
extends Path3D

@export var sections: Array[PathSection]:
	set(value):
		sections = value
		if Engine.is_editor_hint():
			_update_curve()

@export var segments_per_turn: int = 32:
	set(value):
		segments_per_turn = value
		if Engine.is_editor_hint():
			_update_curve()

func _ready():
	if Engine.is_editor_hint():
		_update_curve()

func _update_curve():
	var new_curve = Curve3D.new()
	
	# On commence à l'origine, en regardant vers l'avant (-Z)
	var current_transform = Transform3D(Basis(), Vector3.ZERO)
	new_curve.add_point(current_transform.origin) # Ajoute le point de départ
	
	if sections:
		for section in sections:
			if section: # Vérifie si la section n'est pas vide
				current_transform = section.generate(new_curve, current_transform, segments_per_turn)

	self.curve = new_curve
