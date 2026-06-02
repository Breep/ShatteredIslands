class_name CardFan
extends Node3D

# ============================== Constants ==============================

const NUMBER_OF_FAMILIES_TO_DISPLAY:int = 3 # Top families to show on the card fan

# ============================== Export ==============================

@export var _cards: Array[Card3dVisual]

# ============================== Node base functions ==============================

func _ready() -> void:
	for child in get_children():
		child.hide()

# ============================== Public functions ==============================

func connect_to_player(player: Player) -> void:
	player.deck_changed.connect(_on_player_hand_changed)

# ============================== Private functions ==============================

func _update_visual(hand: Hand):
	pass
	#var families_lvl_raw = hand.get_families_lvl_raw()
	#var cards_number = hand.card_pile.size()
	#for i in min(cards_number, _cards.size()):
		#_cards[i].show()
	#
	#var families_sorted = _get_families_sorted(families_lvl_raw)
	#var total_lvl = 0
	#for family_index in min(NUMBER_OF_FAMILIES_TO_DISPLAY, families_sorted.size()):
		#total_lvl += families_lvl_raw[families_sorted[family_index]]
	#
	#var card_index:int = 0
	#for i in min(NUMBER_OF_FAMILIES_TO_DISPLAY, families_sorted.size()):
		#var ratio = families_lvl_raw[families_sorted[i]] / (total_lvl as float)
		#var number_of_cards_to_color:int = round(ratio * min(cards_number, _cards.size()))
		#print(i, " ", number_of_cards_to_color)
		#for j in number_of_cards_to_color:
			#_cards[card_index].set_color(Family.COLORS[families_sorted[i]])
			#card_index += 1


func _get_families_sorted(families_lvl_raw: Dictionary) -> Array[Family.Type]:
	var families_sorted: Array[Family.Type]
	var families_lvl_raw_duplicated = families_lvl_raw.duplicate()
	while not families_lvl_raw_duplicated.is_empty():
		var highest_family = _get_highest_family_lvl_raw(families_lvl_raw_duplicated)
		families_sorted.append(highest_family)
		families_lvl_raw_duplicated.erase(highest_family)
	return families_sorted


func _get_highest_family_lvl_raw(families_lvl_raw: Dictionary) -> Family.Type:
	var highest_family: Family.Type = Family.Type.WARRIOR
	var highest_lvl: int = 0
	for family_type in families_lvl_raw.keys():
		if families_lvl_raw[family_type] > highest_lvl:
			highest_family = family_type
			highest_lvl = families_lvl_raw[family_type]
	return highest_family

# ============================== Callbacks ==============================

func _on_player_hand_changed(hand: Hand) -> void:
	_update_visual(hand)
