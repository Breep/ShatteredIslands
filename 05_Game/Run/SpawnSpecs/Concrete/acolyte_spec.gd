# Marker spec : un acolyte joueur. Toutes les données vivent sur EntitySpec.
# La sous-classe existe pour la compat des .tres legacy et le typage tooling.
@tool
class_name AcolyteSpec
extends EntitySpec


func get_entity_category() -> Entity.Category:
	return Entity.Category.ACOLYTE
