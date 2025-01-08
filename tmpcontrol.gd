extends Control

@export var family_array: Array[Family]
@export var CardRules: CardRules

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var deck: CardPile = CardPile.new()
	deck.construct_pile_deck(family_array, CardRules)
	deck.shuffle()
	
