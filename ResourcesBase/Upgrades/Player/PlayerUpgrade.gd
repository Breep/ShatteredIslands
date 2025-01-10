extends Resource
class_name PlayerUpgrade

# VIRTUAL

# TODO rework le _cardlvl pour prendre en param une classe generique du genre UpgradeModifier
# qui permettra également de pouvoir utiliser les playerUpgrade pour des amélioration venant d'autre
# chose que les cartes
func apply(_player: Player, _cardLvl: int) -> void:
	pass

func get_description(_cardlvl: int) -> String:
	return ""
