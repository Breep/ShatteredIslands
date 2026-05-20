# Spec d'un acolyte (unité summon contrôlée par un héros) placé dans une formation.
# Marker typé — toutes les données héritent d'EntitySpec.
@tool
class_name AcolyteSpec
extends EntitySpec


func get_entity_category() -> Entity.Category:
	return Entity.Category.ACOLYTE
