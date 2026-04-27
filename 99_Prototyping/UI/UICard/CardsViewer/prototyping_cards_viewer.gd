extends Control

@export var _families: Dictionary[Family.Type, Family]
@export var _cards_viewer: UICardsViewer

var _current_family: Family


func _select_family(family: Family) -> void:
	_current_family = family
	var unlocked: Array[Card] = _get_fake_unlocked_cards(family.cards)
	_cards_viewer.update_content(family.cards, unlocked)


func _get_fake_unlocked_cards(cards: Array[Card]) -> Array[Card]:
	var unlocked: Array[Card] = []
	for card: Card in cards:
		if randi() % 2 == 0:
			unlocked.append(card)
	return unlocked


#region ============================== Sort buttons ==============================
func _on_sort_rarity_button_pressed() -> void:
	_cards_viewer.sort_cards(UICardsViewer.SortMode.RARITY)


func _on_sort_level_button_pressed() -> void:
	_cards_viewer.sort_cards(UICardsViewer.SortMode.LEVEL)


func _on_sort_name_button_pressed() -> void:
	_cards_viewer.sort_cards(UICardsViewer.SortMode.NAME)
#endregion


#region ============================== Display mode buttons ==============================
func _on_display_all_button_pressed() -> void:
	_cards_viewer.set_display_mode(UICardsViewer.DisplayMode.DEFAULT)


func _on_display_unlocked_button_pressed() -> void:
	_cards_viewer.set_display_mode(UICardsViewer.DisplayMode.UNLOCKED_ONLY)
#endregion


#region ============================== Family buttons ==============================
func _on_attack_family_button_pressed() -> void:
	_select_family(_families[Family.Type.WARRIOR])


func _on_chicken_lord_family_button_pressed() -> void:
	_select_family(_families[Family.Type.CHICKEN_LORD])


func _on_defense_family_button_pressed() -> void:
	_select_family(_families[Family.Type.ENGINEER])


func _on_fire_family_button_pressed() -> void:
	_select_family(_families[Family.Type.ARDENT_CELESTIAL])


func _on_life_family_button_pressed() -> void:
	_select_family(_families[Family.Type.COLOSSUS])


func _on_necro_family_button_pressed() -> void:
	_select_family(_families[Family.Type.NECROSIS])


func _on_poison_family_button_pressed() -> void:
	_select_family(_families[Family.Type.POISON])


func _on_serenity_family_button_pressed() -> void:
	_select_family(_families[Family.Type.LIGHT])


func _on_storm_family_button_pressed() -> void:
	_select_family(_families[Family.Type.STORM_CALLER])
#endregion
