# Marker spec : un héros joueur dans une formation. Toutes les données vivent
# sur EntitySpec (placement + desc + entry vers RoasterEntry). La sous-classe
# existe pour la compat des .tres legacy et pour le typage côté tooling.
# Sera fusionnée avec EntitySpec à terme.
@tool
class_name HeroSpec
extends EntitySpec


func get_entity_category() -> Entity.Category:
	return Entity.Category.HERO
