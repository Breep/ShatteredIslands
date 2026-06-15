# Control servant de zone de drop pour les drag-and-drop UI (main, shop, coffre…).
# Le rect du Control est positionné dans l'éditeur via les anchors classiques ;
# en runtime on lit son global_rect pour tester la présence du curseur. Un
# draw_rect debug n'apparaît qu'en éditeur (@tool) pour visualiser la zone sans
# polluer le rendu in-game.
@tool
class_name DropZone
extends Control

@export var _debug_color: Color = Color(0.2, 0.8, 0.4, 0.15)
@export var _debug_border_color: Color = Color(0.2, 0.8, 0.4, 0.6)


func _ready() -> void:
	# Les drop zones n'ont jamais besoin de capter la souris : on laisse passer
	# les events au layout en dessous (cartes, boutons…).
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(rect, _debug_color, true)
	draw_rect(rect, _debug_border_color, false, 2.0)


func contains_global(global_pos: Vector2) -> bool:
	return get_global_rect().has_point(global_pos)
