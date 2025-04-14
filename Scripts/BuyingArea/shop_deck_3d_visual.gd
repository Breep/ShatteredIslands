class_name ShopDeck3DVisual
extends Node3D


# ============================== Constants ==============================

const CARDS_PER_CARDS3D: int = 1 # Number of cards that represent a 3d card

# ============================== Export ==============================

@export var _card_towers: Array[CardTower]

# ============================== Private variables ==============================

var _rng: RandomNumberGenerator

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

var _card_tower_family_ref: Dictionary[Family.FamilyType, CardTower]

# ============================== Public functions ==============================

func connect_to_shop_deck() -> void:
	if not multiplayer.is_server(): return
	MultiplayerDeckManager.shop_deck.available_cards_composition_changed.connect(_on_shop_deck_available_cards_composition_changed)
	_setup_card_towers(MultiplayerDeckManager.shop_deck.available_cards_composition)

# ============================== Private functions ==============================

func _update_visual(available_cards_composition: Dictionary[Family.FamilyType, int]) -> void:
	for family in available_cards_composition.keys():
		_card_towers[family].card_family = family
		_card_towers[family].cards_number = ceil(available_cards_composition[family] as float / CARDS_PER_CARDS3D)


func _setup_card_towers(available_cards_composition: Dictionary[Family.FamilyType, int]) -> void:
	var i: int = 0
	for family in available_cards_composition.keys():
		_card_towers[family] = _card_towers[i]
		_card_towers[family].card_family = family
		_card_towers[family].cards_number = ceil(available_cards_composition[family] as float / CARDS_PER_CARDS3D)
		i += 1

# ============================== Callback functions ==============================

func _on_shop_deck_available_cards_composition_changed(available_cards_composition: Dictionary[Family.FamilyType, int]) -> void:
	_update_visual(available_cards_composition)
