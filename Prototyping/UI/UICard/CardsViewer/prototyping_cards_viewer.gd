extends Control

@export var _families: Dictionary[Family.Type, Family]
@export var _cards_viewer: UICardsViewer

func _on_attack_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.WARRIOR].cards)


func _on_chicken_lord_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.CHICKEN_LORD].cards)


func _on_defense_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.ENGINEER].cards)


func _on_fire_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.ARDENT_CELESTIAL].cards)


func _on_life_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.COLOSSUS].cards)


func _on_lightning_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.LIGHTNING].cards)


func _on_mana_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.MANA].cards)


func _on_necro_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.NECROSIS].cards)


func _on_poison_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.POISON].cards)


func _on_serenity_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.LIGHT].cards)


func _on_shadow_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.SHADOW].cards)


func _on_storm_family_button_pressed() -> void:
	_cards_viewer.update_content(_families[Family.Type.STORM_CALLER].cards)
