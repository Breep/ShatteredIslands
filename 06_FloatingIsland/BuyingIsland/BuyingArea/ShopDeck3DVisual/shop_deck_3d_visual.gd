class_name ShopDeck3DVisual
extends Node3D

# ============================== Constants ==============================

const CARDS_PER_CARDS3D: int = 1 # Number of cards that represent a 3d card

# ============================== Export ==============================

@export var _card_towers: Array[CardTower]

# ============================== Private variables ==============================

func _ready() -> void:
	connect_to_shop_deck()

var _card_tower_family_ref: Dictionary[Family.Type, CardTower]

# ============================== Public functions ==============================

func connect_to_shop_deck() -> void:
	if not multiplayer.is_server(): return
	if CardShopManager.shop_deck == null: return

# ============================== Private functions ==============================

func _update_visual(available_cards_composition: Dictionary[Family.Type, int]) -> void:
	for family in available_cards_composition.keys():
		_card_tower_family_ref[family].card_family = family
		_card_tower_family_ref[family].cards_number = ceil(available_cards_composition[family] as float / CARDS_PER_CARDS3D)


func _setup_card_towers(available_cards_composition: Dictionary[Family.Type, int]) -> void:
	var i: int = 0
	for family in available_cards_composition.keys():
		_card_tower_family_ref[family] = _card_towers[i]
		_card_tower_family_ref[family].card_family = family
		_card_tower_family_ref[family].cards_number = ceil(available_cards_composition[family] as float / CARDS_PER_CARDS3D)
		i += 1

# ============================== Callback functions ==============================

func _on_shop_deck_available_cards_composition_changed(available_cards_composition: Dictionary[Family.Type, int]) -> void:
	_update_visual(available_cards_composition)
