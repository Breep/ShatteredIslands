@tool
extends PathSection
class_name FlatCircleSection

@export var turns: float = 1.0
@export var radius: float = -1.0 # -1 signifie "utilise le rayon de la section précédente"
@export var clockwise: bool = true # Choisir la direction du cercle

func generate(curve: Curve3D, start_transform: Transform3D, segments_per_turn: int) -> Transform3D:
	if turns <= 0 or curve.get_point_count() == 0:
		return start_transform
		
	# --- 1. Déterminer le rayon et le centre du cercle (Logique de calcul corrigée) ---
	
	var circle_radius = radius
	if circle_radius < 0:
		var last_point = curve.get_point_position(curve.get_point_count() - 1)
		var axis_origin = start_transform.origin
		var axis_direction = start_transform.basis.y
		
		# --- CORRECTION ---
		# La fonction Geometry3D n'existe pas. Voici le calcul manuel correct :
		# 1. On prend le vecteur de l'axe vers le point.
		var vec_to_point = last_point - axis_origin
		# 2. On le projette sur l'axe.
		var projection_on_axis = vec_to_point.project(axis_direction)
		# 3. Le rayon est la longueur du vecteur qui va de la projection au point.
		circle_radius = (vec_to_point - projection_on_axis).length()
		# --- FIN DE LA CORRECTION ---

	if is_zero_approx(circle_radius): circle_radius = 1.0

	var right_vector = start_transform.basis.x
	var to_center_vector = right_vector if clockwise else -right_vector
	var circle_center = start_transform.origin + to_center_vector * circle_radius
	
	# --- 2. Générer les points du cercle (Cette partie était déjà correcte) ---
	
	var total_segments = int(turns * segments_per_turn)
	var last_transform = start_transform
	
	for i in range(1, total_segments + 1):
		var progress = float(i) / total_segments
		var angle = TAU * turns * progress
		
		if clockwise:
			angle = -angle
		
		var start_vec = -to_center_vector * circle_radius
		var point_vec = start_vec.rotated(start_transform.basis.y, angle)
		var new_pos = circle_center + point_vec
		curve.add_point(new_pos)

	# --- 3. Mettre à jour la transform finale ---
	
	if curve.get_point_count() >= 2:
		var p1 = curve.get_point_position(curve.get_point_count() - 2)
		var p2 = curve.get_point_position(curve.get_point_count() - 1)
		last_transform = start_transform.looking_at(p2 + (p2 - p1).normalized(), Vector3.UP)
		last_transform.origin = p2
		
	return last_transform
