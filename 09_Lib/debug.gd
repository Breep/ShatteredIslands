extends Node

# La référence vers le nœud que tu veux analyser
var target_node: Node = null
var _mouse_debug_enabled: bool = false

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
	# F9 : Activer/désactiver le mode "debug clic souris"
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		_mouse_debug_enabled = !_mouse_debug_enabled
		print("[Debug] Mouse click debug : ", "ON" if _mouse_debug_enabled else "OFF")
	# Clic souris : identifier le noeud sous le curseur
	if _mouse_debug_enabled and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_print_nodes_under_mouse()

# L'algorithme récursif
func _count_recursive(node: Node) -> int:
	var count = 1
	for child in node.get_children():
		count += _count_recursive(child)
	return count

func _print_nodes_under_mouse() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	print("--- [DEBUG MOUSE CLICK] pos: ", mouse_pos, " ---")

	# 1. UI Controls — détection Godot (is_hovered)
	var hovered_hits: Array[Control] = []
	_find_hovered_controls(get_tree().root, hovered_hits)
	if hovered_hits.size() > 0:
		print("  HOVERED par Godot (%d) :" % hovered_hits.size())
		for ctrl in hovered_hits:
			var filter_name = _mouse_filter_name(ctrl.mouse_filter)
			var cursor_name = _cursor_shape_name(ctrl.mouse_default_cursor_shape)
			var rect = ctrl.get_global_rect()
			print("    -> %s (%s) | filter=%s | cursor=%s | rect=%s | path=%s" % [
				ctrl.name, ctrl.get_class(), filter_name, cursor_name,
				str(rect), ctrl.get_path()])
	else:
		print("  HOVERED par Godot : aucun")

	# 2. UI Controls — détection manuelle (get_global_rect)
	var ui_hits: Array[Control] = []
	_find_controls_at(get_tree().root, mouse_pos, ui_hits)
	if ui_hits.size() > 0:
		print("  UI Rect hits (%d) :" % ui_hits.size())
		for ctrl in ui_hits:
			var filter_name = _mouse_filter_name(ctrl.mouse_filter)
			var cursor_name = _cursor_shape_name(ctrl.mouse_default_cursor_shape)
			print("    -> %s (%s) | filter=%s | cursor=%s | visible=%s | path=%s" % [
				ctrl.name, ctrl.get_class(), filter_name, cursor_name,
				str(ctrl.visible), ctrl.get_path()])
	else:
		print("  UI Rect hits : aucun")

	# 3. Cursor shape actuel du viewport
	var current_cursor := Input.get_current_cursor_shape()
	print("  Cursor shape actuel : %s" % _input_cursor_shape_name(current_cursor))

	# 4. Physics (CollisionObject2D) sous le curseur
	var space_2d = get_viewport().world_2d.direct_space_state
	if space_2d:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var results = space_2d.intersect_point(query, 32)
		if results.size() > 0:
			print("  Physics2D (%d) :" % results.size())
			for r in results:
				var col = r["collider"]
				print("    -> %s (%s) | path=%s" % [col.name, col.get_class(), col.get_path()])
		else:
			print("  Physics2D : aucun")

	# 5. Physics 3D sous le curseur (raycast depuis la camera)
	var camera = get_viewport().get_camera_3d()
	if camera:
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		var space_3d = camera.get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.create(from, from + dir * 1000.0)
		ray_query.collide_with_areas = true
		ray_query.collide_with_bodies = true
		var result_3d = space_3d.intersect_ray(ray_query)
		if result_3d.size() > 0:
			var col = result_3d["collider"]
			print("  Physics3D : %s (%s) | path=%s" % [col.name, col.get_class(), col.get_path()])
		else:
			print("  Physics3D : aucun")

	print("-------------------------------")


func _find_hovered_controls(node: Node, results: Array[Control]) -> void:
	if node is SubViewport:
		return
	for child in node.get_children():
		_find_hovered_controls(child, results)
	if node is BaseButton:
		var btn: BaseButton = node
		if btn.is_hovered():
			results.append(btn)


func _find_controls_at(node: Node, pos: Vector2, results: Array[Control]) -> void:
	# Ne pas descendre dans les SubViewports (coordonnées incompatibles)
	if node is SubViewport:
		return
	for child in node.get_children():
		_find_controls_at(child, pos, results)
	if node is Control:
		var ctrl: Control = node
		if ctrl.is_visible_in_tree() and ctrl.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			if ctrl.get_global_rect().has_point(pos):
				results.append(ctrl)


func _mouse_filter_name(filter: Control.MouseFilter) -> String:
	match filter:
		Control.MOUSE_FILTER_STOP: return "STOP"
		Control.MOUSE_FILTER_PASS: return "PASS"
		Control.MOUSE_FILTER_IGNORE: return "IGNORE"
	return "UNKNOWN"


func _cursor_shape_name(shape: Control.CursorShape) -> String:
	match shape:
		Control.CURSOR_ARROW: return "ARROW"
		Control.CURSOR_IBEAM: return "IBEAM"
		Control.CURSOR_POINTING_HAND: return "POINTING_HAND"
		Control.CURSOR_CROSS: return "CROSS"
		Control.CURSOR_WAIT: return "WAIT"
		Control.CURSOR_BUSY: return "BUSY"
		Control.CURSOR_DRAG: return "DRAG"
		Control.CURSOR_CAN_DROP: return "CAN_DROP"
		Control.CURSOR_FORBIDDEN: return "FORBIDDEN"
		Control.CURSOR_VSIZE: return "VSIZE"
		Control.CURSOR_HSIZE: return "HSIZE"
		Control.CURSOR_BDIAGSIZE: return "BDIAGSIZE"
		Control.CURSOR_FDIAGSIZE: return "FDIAGSIZE"
		Control.CURSOR_MOVE: return "MOVE"
		Control.CURSOR_VSPLIT: return "VSPLIT"
		Control.CURSOR_HSPLIT: return "HSPLIT"
		Control.CURSOR_HELP: return "HELP"
	return "SHAPE_%d" % shape


func _input_cursor_shape_name(shape: Input.CursorShape) -> String:
	match shape:
		Input.CURSOR_ARROW: return "ARROW"
		Input.CURSOR_IBEAM: return "IBEAM"
		Input.CURSOR_POINTING_HAND: return "POINTING_HAND"
		Input.CURSOR_CROSS: return "CROSS"
		Input.CURSOR_WAIT: return "WAIT"
		Input.CURSOR_BUSY: return "BUSY"
		Input.CURSOR_DRAG: return "DRAG"
		Input.CURSOR_CAN_DROP: return "CAN_DROP"
		Input.CURSOR_FORBIDDEN: return "FORBIDDEN"
		Input.CURSOR_VSIZE: return "VSIZE"
		Input.CURSOR_HSIZE: return "HSIZE"
		Input.CURSOR_BDIAGSIZE: return "BDIAGSIZE"
		Input.CURSOR_FDIAGSIZE: return "FDIAGSIZE"
		Input.CURSOR_MOVE: return "MOVE"
		Input.CURSOR_VSPLIT: return "VSPLIT"
		Input.CURSOR_HSPLIT: return "HSPLIT"
		Input.CURSOR_HELP: return "HELP"
	return "SHAPE_%d" % shape


# Fonction pour changer la cible depuis n'importe quel autre script
func set_target(node: Node) -> void:
	target_node = node
	print("[Debug] Nouvelle cible d'analyse : ", node.name)
