# Marker spec : un antagoniste (mob ennemi de combat). Toutes les données
# vivent sur EntitySpec. La sous-classe existe pour la compat des .tres legacy
# et le typage tooling.
@tool
class_name AntagonistSpec
extends EntitySpec


func get_entity_category() -> Entity.Category:
	return Entity.Category.ANTAGONIST
