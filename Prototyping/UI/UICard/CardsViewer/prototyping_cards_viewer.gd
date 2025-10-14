extends Control

@export var _families: Dictionary[Family.FamilyType, Family]
@export var _cards_viewer: UICardsViewer

func _on_attack_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.ATTACK].cards)


func _on_chicken_lord_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.CHICKEN].cards)


func _on_defense_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.DEFENSE].cards)


func _on_fire_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.FIRE].cards)


func _on_life_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.LIFE].cards)


func _on_lightning_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.LIGHTNING].cards)


func _on_mana_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.MANA].cards)


func _on_necro_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.NECROSIS].cards)


func _on_poison_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.POISON].cards)


func _on_serenity_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.SERENITY].cards)


func _on_shadow_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.SHADOW].cards)


func _on_storm_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.FamilyType.STORM].cards)
