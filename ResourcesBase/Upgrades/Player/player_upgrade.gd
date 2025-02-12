class_name PlayerUpgrade
extends Resource


const VULNERABILITY: String = "[url=vulnerability][color=#00008B][wave freq=2.0 amp=5.0]vulnerability[/wave][/color][/url]"
# TODO rework le _cardlvl pour prendre en param une classe generique du genre UpgradeModifier
# qui permettra également de pouvoir utiliser les playerUpgrade pour des amélioration venant d'autre
# chose que les cartes
func apply(_stats: CharacterStats, _cardLvl: int) -> void:
	pass

func get_description(_cardlvl: int) -> String:
	return ""
