@tool
extends PathSection
class_name LineSection

@export var length: float = 5.0
@export_range(-180, 180, 0.1) var orientation_offset_deg: float = 0.0 # Virage à gauche/droite
@export_range(-90, 90, 0.1) var incline_deg: float = 0.0 # Montée/descente

func generate(curve: Curve3D, start_transform: Transform3D, segments_per_turn: int) -> Transform3D:
	# On prend la direction "avant" de la transform de départ
	var direction = -start_transform.basis.z
	
	# 1. On applique le virage (rotation autour de l'axe Y)
	direction = direction.rotated(start_transform.basis.y, deg_to_rad(orientation_offset_deg))
	
	# 2. On applique l'inclinaison (rotation autour de l'axe X local)
	direction = direction.rotated(start_transform.basis.x, deg_to_rad(incline_deg))

	var end_point = start_transform.origin + direction.normalized() * length
	curve.add_point(end_point)
	
	var end_transform = start_transform.looking_at(end_point + direction, Vector3.UP)
	end_transform.origin = end_point
	
	return end_transform
