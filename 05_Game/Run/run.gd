# Représente une partie en cours : une liste ordonnée de Confrontations
# que le joueur va traverser. Pour l'instant, chemin linéaire ; les
# embranchements viendront plus tard.
class_name Run
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var confrontations: Array[Confrontation] = []

@export var current_index: int = 0

func get_current() -> Confrontation:
	if current_index < 0 or current_index >= confrontations.size():
		return null
	return confrontations[current_index]


func advance() -> Confrontation:
	current_index += 1
	return get_current()


func is_finished() -> bool:
	return current_index >= confrontations.size()
