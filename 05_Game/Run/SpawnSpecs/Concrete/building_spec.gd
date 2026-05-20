# Spec d'un bâtiment achetable placé dans une formation de combat.
# Marker typé — toutes les données héritent d'EntitySpec.
@tool
class_name BuildingSpec
extends EntitySpec


func get_entity_category() -> Entity.Category:
	return Entity.Category.BUILDING
