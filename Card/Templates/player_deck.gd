class_name PlayerDeck
extends Deck

signal has_changed()

# ============================== Public function ==============================

func add_card(card_to_add: Card) -> void: #override
	_add_or_improve_card(card_to_add)
	has_changed.emit()


func get_max_lvl_cards() -> Array[Card]:
	var max_lvl_cards: Array[Card]
	for card in _card_pile:
		if card.rarity == Card.Rarity.COMMON and card.lvl == 5:
			max_lvl_cards.append(card)
		elif card.rarity == Card.Rarity.RARE and card.lvl == 3:
			max_lvl_cards.append(card)
		elif card.rarity == Card.Rarity.EPIC and card.lvl == 1:
			max_lvl_cards.append(card)
	return max_lvl_cards


func get_card_lvl(card_to_get_lvl: Card) -> int:
	for card in _card_pile:
		if card.name == card_to_get_lvl.name:
			return card.lvl
	return 0


func debug_print() -> void:
	print("Player deck:")
	for card in _card_pile:
		print(card.name, "->lvl[", card.lvl, "]")


func get_families_lvl_raw() -> Dictionary:
	var families_lvl_raw: Dictionary
	for card in _card_pile:
		for family in card.families:
			if families_lvl_raw.has(family):
				families_lvl_raw[family] += 1
			else:
				families_lvl_raw[family] = 1
	return families_lvl_raw

# ============================== Private function ==============================

func _add_or_improve_card(new_card_ref: Card) -> void:
	for card in _card_pile:
		if card.name == new_card_ref.name:
			#print("UPGRADING ", new_card.name)
			if card.lvl < _get_lvl_max_of_card_rarity(card.rarity):
				card.lvl += 1
			else:
				printerr("Trying to upgrade an already maximized card")
			return
	
	#print("ADDING NEW CARD ", new_card_ref.name)
	var new_card = new_card_ref.duplicate()
	new_card.lvl = new_card_ref.lvl
	_card_pile.append(new_card)


func _get_lvl_max_of_card_rarity(card_rarity: Card.Rarity) -> int:
	match card_rarity:
		Card.Rarity.COMMON:
			return 5
		Card.Rarity.RARE:
			return 3
		Card.Rarity.EPIC:
			return 1
	return 0
