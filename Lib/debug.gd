extends Node

# La référence vers le nœud que tu veux analyser
var target_node: Node = null

func _input(event: InputEvent) -> void:
	# Détection de la touche F12
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		if target_node and is_instance_valid(target_node):
			var total = _count_recursive(target_node)
			print("--- [DEBUG COUNT] ---")
			print("Cible : ", target_node.name, " (", target_node.get_class(), ")")
			print("Nombre total de nœuds : ", total)
			print("---------------------")
		else:
			# Si aucune cible n'est définie, on compte tout le projet
			var total = _count_recursive(get_tree().root)
			print("--- [DEBUG COUNT] ---")
			print("Cible : ROOT (Projet complet)")
			print("Nombre total de nœuds : ", total)
			print("---------------------")
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		set_target(get_tree().root)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F10:
		if target_node and is_instance_valid(target_node):
			print("--- [DEBUG COUNT] ---")
			for child in target_node.get_children():
				var total =_count_recursive(child)
				print("Cible : ", child.name, " (", child.get_class(), ")")
				print("Nombre total de nœuds : ", total)
				print("--")
			print("---------------------")
			print("\n")

# L'algorithme récursif
func _count_recursive(node: Node) -> int:
	var count = 1
	for child in node.get_children():
		count += _count_recursive(child)
	return count

# Fonction pour changer la cible depuis n'importe quel autre script
func set_target(node: Node) -> void:
	target_node = node
	print("[Debug] Nouvelle cible d'analyse : ", node.name)
