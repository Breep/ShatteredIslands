class_name AegisBlade
extends Entity

# Lame d'Aegis : summon défensif. Toute sa logique (conversion dégâts→Shield, combo,
# ultime, bonus de stats) vit dans ses skills (Skills/) ; les stats par niveau dans
# l'entity_desc.


func _init() -> void:
	super._init()
	category = Category.SUMMON
