# Spec d'une unité antagoniste (ennemi de combat) placée dans une formation de combat.
# Marker typé — toutes les données héritent d'EntitySpec.
@tool
class_name AntagonistSpec
extends EntitySpec


func get_entity_category() -> Entity.Category:
	return Entity.Category.ANTAGONIST
