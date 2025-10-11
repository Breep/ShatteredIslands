@tool
extends PathSection
class_name SpiralSection

@export var height: float = 10.0
@export var turns: float = 3.0
@export var radius: float = 5.0
@export var radius_profile: Curve

func generate(curve: Curve3D, start_transform: Transform3D, segments_per_turn: int) -> Transform3D:
	if not radius_profile or turns <= 0:
		return start_transform
		
	var total_segments = int(turns * segments_per_turn)
	var last_transform = start_transform
	
	for i in range(1, total_segments + 1):
		var progress = float(i) / total_segments
		var radius_multiplier = radius_profile.sample(progress)
		var current_radius = radius * radius_multiplier
		
		var angle = TAU * turns * progress
		var y = -height * progress
		
		var relative_pos = Vector3(cos(angle) * current_radius, y, sin(angle) * current_radius)
		
		# On calcule la nouvelle position globale
		var new_pos = start_transform.origin + start_transform.basis * relative_pos
		curve.add_point(new_pos)
		
		# On met à jour la "dernière transform" pour le retour
		last_transform.origin = new_pos
	
	# Pour la direction, on calcule la tangente à la fin
	if total_segments > 0:
		var p1 = curve.get_point_position(curve.get_point_count() - 2)
		var p2 = curve.get_point_position(curve.get_point_count() - 1)
		last_transform = last_transform.looking_at(p2 + (p2 - p1), Vector3.UP)
		
	return last_transform
