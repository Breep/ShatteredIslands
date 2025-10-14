extends Control

@export var _families: Dictionary[Family.FamilyType, Family]
@export var _family_viewer: UIFamilyViewer

func _on_attack_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.ATTACK])


func _on_chicken_lord_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.CHICKEN])


func _on_defense_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.DEFENSE])


func _on_fire_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.FIRE])


func _on_life_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.LIFE])


func _on_lightning_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.LIGHTNING])


func _on_mana_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.MANA])


func _on_necro_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.NECROSIS])


func _on_poison_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.POISON])


func _on_serenity_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.SERENITY])


func _on_shadow_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.SHADOW])


func _on_storm_family_button_pressed() -> void:
	_family_viewer.update_content(_families[Family.FamilyType.STORM])
