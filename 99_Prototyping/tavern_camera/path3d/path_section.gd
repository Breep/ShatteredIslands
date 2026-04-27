@tool
extends Resource
class_name PathSection

# Chaque section devra implémenter cette fonction.
# Elle prend la courbe existante, la transforme du point de départ,
# et doit retourner la transforme du point d'arrivée.
func generate(curve: Curve3D, start_transform: Transform3D, segments_per_turn: int) -> Transform3D:
	# Cette fonction est vide car elle sera surchargée par les enfants.
	return start_transform
